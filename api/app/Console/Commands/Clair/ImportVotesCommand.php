<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ImportVotesCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:votes
        {--chambre=assemblee : Target chamber (assemblee|senat)}
        {--numero=* : Optional scrutin number(s) to import}
        {--limit=50 : Number of latest scrutins when --numero is not provided}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import votes by scrutin from CLAIR API';

    public function handle(): int
    {
        return $this->runImport('votes', function (): int {
            $dryRun = (bool) $this->option('dry-run');
            $chamber = (string) $this->option('chambre');

            $numbers = collect((array) $this->option('numero'))
                ->map(fn (mixed $v) => (int) $v)
                ->filter(fn (int $v) => $v > 0)
                ->values();

            if ($numbers->isEmpty()) {
                $limit = max(1, (int) $this->option('limit'));

                if (! $dryRun) {
                    $numbers = DB::table('scrutins')
                        ->orderByDesc('date')
                        ->limit($limit)
                        ->pluck('numero')
                        ->map(fn (mixed $v) => (int) $v)
                        ->values();
                }

                if ($numbers->isEmpty()) {
                    $numbers = collect($this->fetchAllItems('/api/v1/scrutins', ['chambre' => $chamber]))
                        ->filter(fn (array $item) => ($item['chambre'] ?? null) === $chamber)
                        ->sortByDesc('date')
                        ->take($limit)
                        ->pluck('numero')
                        ->map(fn (mixed $v) => (int) $v)
                        ->filter(fn (int $v) => $v > 0)
                        ->values();
                }
            }

            if ($numbers->isEmpty()) {
                $this->warn('No scrutin numbers found. Import scrutins first or pass --numero.');

                return self::FAILURE;
            }

            /** @var array<string, string> $deputyBySlug */
            $deputyBySlug = DB::table('deputies')->pluck('id', 'slug')->all();
            /** @var array<string, string> $deputyByActorRef */
            $deputyByActorRef = [];
            foreach (DB::table('deputies')->select('id', 'source_id')->get() as $deputy) {
                $sourceId = trim((string) ($deputy->source_id ?? ''));
                if ($sourceId === '') {
                    continue;
                }

                $deputyByActorRef['PA'.$sourceId] = (string) $deputy->id;
            }

            if ($dryRun || empty($deputyBySlug)) {
                $apiDeputies = $this->fetchAllItems('/api/v1/deputes', ['chambre' => $chamber]);
                foreach ($apiDeputies as $deputy) {
                    if (! empty($deputy['slug']) && ! empty($deputy['id'])) {
                        $deputyBySlug[(string) $deputy['slug']] = (string) $deputy['id'];
                    }

                    if (! empty($deputy['sourceId']) && ! empty($deputy['id'])) {
                        $deputyByActorRef['PA'.(string) $deputy['sourceId']] = (string) $deputy['id'];
                    }
                }
            }

            /** @var array<int, string> $scrutinIdByNumero */
            $scrutinIdByNumero = DB::table('scrutins')->pluck('id', 'numero')->all();
            if ($dryRun || empty($scrutinIdByNumero)) {
                $apiScrutins = $this->fetchAllItems('/api/v1/scrutins', ['chambre' => $chamber]);
                foreach ($apiScrutins as $scrutin) {
                    if (($scrutin['chambre'] ?? null) !== $chamber || empty($scrutin['numero']) || empty($scrutin['id'])) {
                        continue;
                    }

                    $scrutinIdByNumero[(int) $scrutin['numero']] = (string) $scrutin['id'];
                }
            }

            $rows = [];
            $unknownDeputies = 0;
            $unknownScrutins = 0;

            foreach ($numbers as $numero) {
                $payload = $this->fetchJsonWithRetry('/api/v1/scrutins/'.$numero);
                $items = $this->normalizeVotesPayload($payload);

                foreach ($items as $item) {
                    $scrutinNumero = (int) ($item['numero'] ?? $item['scrutinNb'] ?? $numero);
                    $scrutinId = $item['id'] ?? $item['scrutinId'] ?? ($scrutinIdByNumero[$scrutinNumero] ?? null);

                    if (! $scrutinId) {
                        $unknownScrutins++;

                        continue;
                    }

                    $positionRows = $this->extractVotesByPosition(
                        $item['votesByPosition'] ?? [],
                        (string) $scrutinId,
                        $deputyBySlug,
                        $unknownDeputies
                    );

                    // Prefer votesByPosition when available: it contains stable slugs and avoids
                    // double-processing the same vote data from multiple payload representations.
                    if (! empty($positionRows)) {
                        $rows = array_merge($rows, $positionRows);

                        continue;
                    }

                    $ventilationRows = $this->extractVotesFromVentilation(
                        $item['sourceData']['ventilationVotes'] ?? ($item['ventilationVotes'] ?? []),
                        (string) $scrutinId,
                        $deputyBySlug,
                        $deputyByActorRef,
                        $unknownDeputies
                    );

                    $rows = array_merge($rows, $ventilationRows);
                }
            }

            $rows = $this->deduplicateVotes(collect($rows));

            if ($dryRun) {
                $this->logInfo('Dry-run summary', [
                    'import' => 'votes',
                    'rows' => count($rows),
                    'unknown_deputies' => $unknownDeputies,
                    'unknown_scrutins' => $unknownScrutins,
                    'chambre' => $chamber,
                    'scrutins_count' => $numbers->count(),
                ]);
                $this->info('Dry-run enabled. Votes to upsert: '.count($rows).', unknown deputies: '.$unknownDeputies.', unknown scrutins: '.$unknownScrutins);

                return self::SUCCESS;
            }

            DB::table('votes')->upsert(
                $rows,
                ['scrutin_id', 'deputy_id'],
                ['position', 'delegated', 'updated_at']
            );

            $this->logInfo('Import summary', [
                'import' => 'votes',
                'rows' => count($rows),
                'unknown_deputies' => $unknownDeputies,
                'unknown_scrutins' => $unknownScrutins,
                'chambre' => $chamber,
                'scrutins_count' => $numbers->count(),
            ]);
            $this->info('Votes imported: '.count($rows).', unknown deputies: '.$unknownDeputies.', unknown scrutins: '.$unknownScrutins);

            return self::SUCCESS;
        });
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function normalizeVotesPayload(mixed $payload): array
    {
        if (! is_array($payload)) {
            return [];
        }

        if (isset($payload['data']) && is_array($payload['data'])) {
            return [$payload['data']];
        }

        if (array_is_list($payload)) {
            return $payload;
        }

        if (
            isset($payload['sourceData']) ||
            isset($payload['ventilationVotes']) ||
            isset($payload['votesByPosition']) ||
            isset($payload['scrutinId']) ||
            isset($payload['scrutinNb']) ||
            isset($payload['id']) ||
            isset($payload['numero'])
        ) {
            return [$payload];
        }

        foreach (['data', 'items', 'results'] as $key) {
            $items = $payload[$key] ?? null;
            if (is_array($items) && array_is_list($items)) {
                return $items;
            }
        }

        return [];
    }

    /**
     * @param  array<string, mixed>  $votesByPosition
     * @param  array<string, string>  $deputyBySlug
     * @return array<int, array<string, mixed>>
     */
    private function extractVotesByPosition(array $votesByPosition, string $scrutinId, array $deputyBySlug, int &$unknownDeputies): array
    {
        $positionMap = [
            'pour' => 'POUR',
            'contre' => 'CONTRE',
            'abstention' => 'ABSTENTION',
            'absent' => 'NON_VOTANT',
        ];

        $rows = [];

        foreach ($positionMap as $sourceKey => $targetPosition) {
            $entries = $votesByPosition[$sourceKey] ?? [];
            if (! is_array($entries)) {
                continue;
            }

            foreach ($entries as $entry) {
                $slug = $entry['parlementaire']['slug'] ?? null;
                if (! $slug) {
                    continue;
                }

                $deputyId = $deputyBySlug[$slug] ?? null;
                if (! $deputyId) {
                    $unknownDeputies++;

                    continue;
                }

                $rows[] = [
                    'scrutin_id' => $scrutinId,
                    'deputy_id' => $deputyId,
                    'position' => $targetPosition,
                    'delegated' => false,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
        }

        return $rows;
    }

    /**
     * @param  array<string, mixed>  $ventilationVotes
     * @param  array<string, string>  $deputyBySlug
     * @param  array<string, string>  $deputyByActorRef
     * @return array<int, array<string, mixed>>
     */
    private function extractVotesFromVentilation(
        array $ventilationVotes,
        string $scrutinId,
        array $deputyBySlug,
        array $deputyByActorRef,
        int &$unknownDeputies
    ): array {
        $groups = $ventilationVotes['organe']['groupes']['groupe'] ?? [];
        if (! is_array($groups)) {
            return [];
        }

        if (! array_is_list($groups)) {
            $groups = [$groups];
        }

        $rows = [];
        foreach ($groups as $group) {
            if (! is_array($group)) {
                continue;
            }

            $decompte = $group['vote']['decompteNominatif'] ?? null;
            if (! is_array($decompte)) {
                continue;
            }

            $rows = array_merge(
                $rows,
                $this->extractNominalVotesForPosition($decompte['pours'] ?? ($decompte['pour'] ?? null), 'POUR', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies),
                $this->extractNominalVotesForPosition($decompte['contres'] ?? null, 'CONTRE', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies),
                $this->extractNominalVotesForPosition($decompte['abstentions'] ?? null, 'ABSTENTION', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies),
                $this->extractNominalVotesForPosition($decompte['nonVotants'] ?? null, 'NON_VOTANT', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies),
                $this->extractNominalVotesForPosition($decompte['nonVotantsVolontaires'] ?? null, 'NON_VOTANT', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies)
            );
        }

        return $rows;
    }

    /**
     * @param  array<string, string>  $deputyBySlug
     * @param  array<string, string>  $deputyByActorRef
     * @return array<int, array<string, mixed>>
     */
    private function extractNominalVotesForPosition(
        mixed $positionNode,
        string $position,
        string $scrutinId,
        array $deputyBySlug,
        array $deputyByActorRef,
        int &$unknownDeputies
    ): array {
        if (! is_array($positionNode)) {
            return [];
        }

        $votants = $positionNode['votant'] ?? [];
        if (! is_array($votants)) {
            return [];
        }

        if (! array_is_list($votants)) {
            $votants = [$votants];
        }

        $rows = [];
        foreach ($votants as $votant) {
            if (! is_array($votant)) {
                continue;
            }

            $slug = $votant['parlementaire']['slug'] ?? ($votant['slug'] ?? null);
            $actorRef = $votant['acteurRef'] ?? null;

            $deputyId = null;
            if ($slug) {
                $deputyId = $deputyBySlug[(string) $slug] ?? null;
            }

            if (! $deputyId && $actorRef) {
                $deputyId = $deputyByActorRef[(string) $actorRef] ?? null;
            }

            if (! $deputyId) {
                $unknownDeputies++;

                continue;
            }

            $rows[] = [
                'scrutin_id' => $scrutinId,
                'deputy_id' => $deputyId,
                'position' => $position,
                'delegated' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        return $rows;
    }

    /**
     * @param  Collection<int, array<string, mixed>>  $rows
     * @return array<int, array<string, mixed>>
     */
    private function deduplicateVotes(Collection $rows): array
    {
        return $rows
            ->keyBy(fn (array $row) => $row['scrutin_id'].'|'.$row['deputy_id'])
            ->values()
            ->all();
    }
}

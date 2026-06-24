<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class SyncVotesJob extends BaseSyncJob
{
    public function handle(ClairApiClient $client): void
    {
        $chamber = $this->chamber();
        $this->logInfo('Sync votes started', ['chamber' => $chamber]);

        /** @var array<string, string> $deputyBySlug */
        $deputyBySlug = DB::table('deputies')->pluck('id', 'slug')->all();
        /** @var array<string, string> $deputyByActorRef */
        $deputyByActorRef = [];

        foreach (DB::table('deputies')->select('id', 'source_id')->cursor() as $deputy) {
            $sourceId = trim((string) ($deputy->source_id ?? ''));
            if ($sourceId === '') {
                continue;
            }

            $deputyByActorRef['PA'.$sourceId] = (string) $deputy->id;
        }

        /** @var array<int, string> $scrutinIdByNumero */
        $scrutinIdByNumero = DB::table('scrutins')->pluck('id', 'numero')->all();
        $numbers = array_map('intval', array_keys($scrutinIdByNumero));
        rsort($numbers);

        $limit = max(0, (int) env('CLAIR_SYNC_VOTES_LIMIT', 0));
        if ($limit > 0) {
            $numbers = array_slice($numbers, 0, $limit);
        }

        $processed = 0;
        $unknownDeputies = 0;
        $unknownScrutins = 0;

        foreach ($client->getVotes($numbers) as $numero => $items) {
            $rows = [];

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
                    $unknownDeputies,
                );

                if ($positionRows !== []) {
                    $rows = array_merge($rows, $positionRows);
                    continue;
                }

                $rows = array_merge(
                    $rows,
                    $this->extractVotesFromVentilation(
                        $item['sourceData']['ventilationVotes'] ?? ($item['ventilationVotes'] ?? []),
                        (string) $scrutinId,
                        $deputyBySlug,
                        $deputyByActorRef,
                        $unknownDeputies,
                    ),
                );
            }

            $deduplicated = $this->deduplicateVotes(collect($rows));
            $processed += $this->upsertInChunks('votes', $deduplicated, ['scrutin_id', 'deputy_id'], [
                'position',
                'delegated',
                'updated_at',
            ]);

            $this->logInfo('Sync votes scrutin completed', [
                'chamber' => $chamber,
                'numero' => $numero,
                'rows' => count($deduplicated),
                'processed' => $processed,
                'unknown_deputies' => $unknownDeputies,
                'unknown_scrutins' => $unknownScrutins,
            ]);
        }

        $this->logInfo('Sync votes completed', [
            'chamber' => $chamber,
            'processed' => $processed,
            'unknown_deputies' => $unknownDeputies,
            'unknown_scrutins' => $unknownScrutins,
        ]);
        $this->logInfo('Sync completed', ['chamber' => $chamber, 'processed_votes' => $processed]);
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
                $this->extractNominalVotesForPosition($decompte['nonVotantsVolontaires'] ?? null, 'NON_VOTANT', $scrutinId, $deputyBySlug, $deputyByActorRef, $unknownDeputies),
            );
        }

        return $rows;
    }

    /**
     * @param  mixed  $positionNode
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
        int &$unknownDeputies,
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

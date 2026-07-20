<?php

namespace App\Services\Sync;

use App\Models\Scrutin;
use App\Services\Clair\ClairApiClient;
use App\Services\Scrutins\ImportanceScoringService;
use App\Support\Scrutins\ScrutinSourceUrlNormalizer;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class ScrutinSyncService extends BaseSyncService
{
    public function __construct(
        private readonly ClairApiClient $client,
        private readonly SyncStateService $syncStateService,
        private readonly ImportanceScoringService $importanceScoringService,
    ) {}

    /**
     * @return array{processed:int}
     */
    public function sync(): array
    {
        $chamber = $this->chamber();
        $institutionId = $this->institutionIdForChamber($chamber);
        $stateKey = 'last_scrutins_sync';
        $stateValue = $this->syncStateService->get($stateKey);
        $since = $this->parseStateDate($stateValue);
        if ($since !== null && $this->tableIsEmpty('scrutins')) {
            $this->logInfo('Scrutins table empty, forcing full sync', ['chamber' => $chamber]);
            $since = null;
        }
        $runStartedAt = $this->nowStateValue();
        $startedAt = microtime(true);

        $this->logInfo('Sync scrutins started', ['chamber' => $chamber, 'since' => $stateValue]);

        $processed = 0;

        try {
            $pages = $since === null
                ? $this->client->getScrutins($chamber)
                : $this->client->getUpdatedScrutins($since, $chamber);

            foreach ($pages as $page => $items) {
                $rows = [];

                foreach ($items as $item) {
                    if (($item['chambre'] ?? null) !== $chamber) {
                        continue;
                    }

                    if (! $this->isItemNewerThanSince($item, $since, ['updatedAt', 'sourceUpdatedAt', 'date', 'createdAt'])) {
                        continue;
                    }

                    $sort = strtoupper((string) ($item['sort'] ?? ''));
                    if ($sort !== 'ADOPTE' && $sort !== 'REJETE') {
                        $sort = null;
                    }

                    $rows[] = [
                        'id' => (string) $item['id'],
                        'institution_id' => $institutionId,
                        'numero' => (int) $item['numero'],
                        'date' => (string) $item['date'],
                        'titre' => (string) $item['titre'],
                        'sort' => $sort,
                        'importance_score' => 0,
                        'nombre_votants' => (int) ($item['nombreVotants'] ?? 0),
                        'nombre_pour' => (int) ($item['nombrePour'] ?? 0),
                        'nombre_contre' => (int) ($item['nombreContre'] ?? 0),
                        'nombre_abstention' => (int) ($item['nombreAbstention'] ?? 0),
                        'demandeur_texte' => $this->nullableString($item['demandeurTexte'] ?? null),
                        'source_url' => ScrutinSourceUrlNormalizer::normalize(
                            $this->nullableString($item['sourceUrl'] ?? null)
                        ),
                        'dossier_titre' => $this->nullableString($item['dossier']['titre'] ?? null),
                        'dossier_url' => $this->nullableString($item['dossier']['url'] ?? null),
                        'resume_ia' => $this->nullableString($item['resumeIA'] ?? null),
                        'last_synced_at' => $this->nowIso(),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                }

                $processed += $this->upsertInChunks('scrutins', $rows, ['id'], [
                    'institution_id',
                    'numero',
                    'date',
                    'titre',
                    'sort',
                    'importance_score',
                    'nombre_votants',
                    'nombre_pour',
                    'nombre_contre',
                    'nombre_abstention',
                    'demandeur_texte',
                    'source_url',
                    'dossier_titre',
                    'dossier_url',
                    'resume_ia',
                    'last_synced_at',
                    'updated_at',
                ]);

                if ($rows !== []) {
                    $this->recalculateImportanceForRows($rows);
                }

                $this->logInfo('Sync scrutins page completed', [
                    'chamber' => $chamber,
                    'page' => $page,
                    'rows' => count($rows),
                    'processed' => $processed,
                ]);
            }

            $this->syncStateService->set($stateKey, $runStartedAt);
            Cache::forget('scrutins:important:5');
            Cache::forget('scrutins:important:20');

            $this->logInfo(sprintf('Scrutins imported: %d', $processed), ['chamber' => $chamber]);
            $this->logInfo('Sync scrutins completed', [
                'chamber' => $chamber,
                'processed' => $processed,
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
            ]);

            return ['processed' => $processed];
        } catch (\Throwable $exception) {
            $this->logError('Sync scrutins failed', [
                'chamber' => $chamber,
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
                'exception_class' => $exception::class,
                'exception_message' => $exception->getMessage(),
            ]);

            throw $exception;
        }
    }

    /**
     * @param  array<int, array<string, mixed>>  $rows
     */
    private function recalculateImportanceForRows(array $rows): void
    {
        $ids = array_values(array_filter(array_map(
            fn (array $row): string => (string) ($row['id'] ?? ''),
            $rows,
        )));

        if ($ids === []) {
            return;
        }

        $scrutins = DB::table('scrutins')
            ->whereIn('id', $ids)
            ->get(['id', 'titre', 'demandeur_texte', 'nombre_pour', 'nombre_contre', 'importance_score']);

        foreach ($scrutins as $row) {
            $scrutin = new Scrutin;
            $scrutin->id = (string) $row->id;
            $scrutin->titre = (string) ($row->titre ?? '');
            $scrutin->demandeur_texte = $row->demandeur_texte;
            $scrutin->nombre_pour = (int) ($row->nombre_pour ?? 0);
            $scrutin->nombre_contre = (int) ($row->nombre_contre ?? 0);

            $score = $this->importanceScoringService->calculate($scrutin);

            DB::table('scrutins')
                ->where('id', $scrutin->id)
                ->update([
                    'importance_score' => $score,
                    'updated_at' => now(),
                ]);
        }
    }
}

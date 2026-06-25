<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use App\Services\Scrutins\ImportanceScoringService;
use App\Services\Sync\SyncStateService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class SyncScrutinsJob extends BaseSyncJob
{
    public function handle(
        ClairApiClient $client,
        SyncStateService $syncStateService,
        ImportanceScoringService $importanceScoringService,
    ): void
    {
        $chamber = $this->chamber();
        $institutionId = $this->institutionIdForChamber($chamber);
        $stateKey = 'last_scrutins_sync';
        $stateValue = $syncStateService->get($stateKey);
        $since = $this->parseStateDate($stateValue);
        $runStartedAt = $this->nowStateValue();

        $this->logInfo('Sync scrutins started', ['chamber' => $chamber, 'since' => $stateValue]);

        $processed = 0;

        $pages = $since === null
            ? $client->getScrutins($chamber)
            : $client->getUpdatedScrutins($since, $chamber);

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
                    'source_url' => $this->nullableString($item['sourceUrl'] ?? null),
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
                $this->recalculateImportanceForRows($rows, $importanceScoringService);
            }

            $this->logInfo('Sync scrutins page completed', [
                'chamber' => $chamber,
                'page' => $page,
                'rows' => count($rows),
                'processed' => $processed,
            ]);
        }

        $syncStateService->set($stateKey, $runStartedAt);
        Cache::forget('scrutins:important:5');
        Cache::forget('scrutins:important:20');

        $this->logInfo(sprintf('Scrutins imported: %d', $processed), ['chamber' => $chamber]);
        $this->logInfo('Sync scrutins completed', ['chamber' => $chamber, 'processed' => $processed]);
    }

    /**
     * @param  array<int, array<string, mixed>>  $rows
     */
    private function recalculateImportanceForRows(array $rows, ImportanceScoringService $importanceScoringService): void
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
            $scrutin = new \App\Models\Scrutin();
            $scrutin->id = (string) $row->id;
            $scrutin->titre = (string) ($row->titre ?? '');
            $scrutin->demandeur_texte = $row->demandeur_texte;
            $scrutin->nombre_pour = (int) ($row->nombre_pour ?? 0);
            $scrutin->nombre_contre = (int) ($row->nombre_contre ?? 0);

            $score = $importanceScoringService->calculate($scrutin);

            DB::table('scrutins')
                ->where('id', $scrutin->id)
                ->update([
                    'importance_score' => $score,
                    'updated_at' => now(),
                ]);
        }
    }
}

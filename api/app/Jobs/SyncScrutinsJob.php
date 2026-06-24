<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;

class SyncScrutinsJob extends BaseSyncJob
{
    public function handle(ClairApiClient $client): void
    {
        $chamber = $this->chamber();
        $institutionId = $this->institutionIdForChamber($chamber);

        $this->logInfo('Sync scrutins started', ['chamber' => $chamber]);

        $processed = 0;

        foreach ($client->getScrutins($chamber) as $page => $items) {
            $rows = [];

            foreach ($items as $item) {
                if (($item['chambre'] ?? null) !== $chamber) {
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

            $this->logInfo('Sync scrutins page completed', [
                'chamber' => $chamber,
                'page' => $page,
                'rows' => count($rows),
                'processed' => $processed,
            ]);
        }

        $this->logInfo('Sync scrutins completed', ['chamber' => $chamber, 'processed' => $processed]);
    }
}

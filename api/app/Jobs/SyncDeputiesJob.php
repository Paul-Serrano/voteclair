<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use Illuminate\Support\Facades\DB;

class SyncDeputiesJob extends BaseSyncJob
{
    public function handle(ClairApiClient $client): void
    {
        $chamber = $this->chamber();
        $institutionId = $this->institutionIdForChamber($chamber);

        $this->logInfo('Sync deputies started', ['chamber' => $chamber]);

        $processed = 0;
        $skipped = 0;

        foreach ($client->getDeputies($chamber) as $page => $items) {
            $groupById = DB::table('groups')->pluck('id', 'id')->all();
            $groupBySlug = DB::table('groups')
                ->where('institution_id', $institutionId)
                ->pluck('id', 'slug')
                ->all();

            $circonscriptions = [];
            $rows = [];

            foreach ($items as $item) {
                $circonscription = $item['circonscription'] ?? null;
                if (is_array($circonscription) && ! empty($circonscription['id'])) {
                    $circonscriptions[(string) $circonscription['id']] = [
                        'id' => (string) $circonscription['id'],
                        'departement' => (string) ($circonscription['departement'] ?? ''),
                        'departement_name' => $this->nullableString($circonscription['departementName'] ?? null),
                        'numero' => $this->nullableInt($circonscription['numero'] ?? null) ?? 0,
                        'nom' => (string) ($circonscription['nom'] ?? (($circonscription['departement'] ?? '').' - Circonscription '.($circonscription['numero'] ?? ''))),
                        'last_synced_at' => $this->nowIso(),
                        'created_at' => now(),
                        'updated_at' => now(),
                    ];
                }

                $groupId = $item['groupeId'] ?? null;
                if (! $groupId && isset($item['groupe']['slug'])) {
                    $groupId = $groupBySlug[$item['groupe']['slug']] ?? null;
                }

                if (! $groupId || ! isset($groupById[$groupId])) {
                    $skipped++;
                    continue;
                }

                $sourceId = $this->nullableString($item['sourceId'] ?? null);
                if ($sourceId === null) {
                    $skipped++;
                    continue;
                }

                $rows[] = [
                    'id' => (string) $item['id'],
                    'institution_id' => $institutionId,
                    'groupe_id' => (string) $groupId,
                    'circonscription_id' => $this->nullableString($item['circonscriptionId'] ?? ($circonscription['id'] ?? null)),
                    'source_id' => $sourceId,
                    'slug' => (string) $item['slug'],
                    'nom' => (string) $item['nom'],
                    'prenom' => (string) $item['prenom'],
                    'profession' => $this->nullableString($item['profession'] ?? null),
                    'email' => $this->nullableString($item['email'] ?? null),
                    'twitter' => $this->nullableString($item['twitter'] ?? null),
                    'photo_url' => $this->nullableString($item['photoUrl'] ?? null),
                    'actif' => (bool) ($item['actif'] ?? true),
                    'stats_presence' => $this->nullableInt($item['statsPresence'] ?? null),
                    'stats_presence_solennel' => $this->nullableInt($item['statsPresenceSolennel'] ?? null),
                    'stats_loyaute' => $this->nullableInt($item['statsLoyaute'] ?? null),
                    'stats_participation' => $this->nullableInt($item['statsParticipation'] ?? null),
                    'stats_interventions' => $this->nullableInt($item['statsInterventions'] ?? null),
                    'stats_amendements' => $this->nullableInt($item['statsAmendements'] ?? null),
                    'stats_amendements_adoptes' => $this->nullableInt($item['statsAmendementsAdoptes'] ?? null),
                    'stats_questions' => $this->nullableInt($item['statsQuestions'] ?? null),
                    'resume_ia' => $this->nullableString($item['resumeIA'] ?? null),
                    'parcours_ia' => $this->nullableString($item['parcoursIA'] ?? null),
                    'positions_cles_ia' => $this->nullableString($item['positionsClesIA'] ?? null),
                    'faits_notables_ia' => $this->nullableString($item['faitsNotablesIA'] ?? null),
                    'last_synced_at' => $this->nowIso(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            $this->upsertInChunks('circonscriptions', array_values($circonscriptions), ['id'], [
                'departement',
                'departement_name',
                'numero',
                'nom',
                'last_synced_at',
                'updated_at',
            ]);

            $processed += $this->upsertInChunks('deputies', $rows, ['id'], [
                'institution_id',
                'groupe_id',
                'circonscription_id',
                'source_id',
                'slug',
                'nom',
                'prenom',
                'profession',
                'email',
                'twitter',
                'photo_url',
                'actif',
                'stats_presence',
                'stats_presence_solennel',
                'stats_loyaute',
                'stats_participation',
                'stats_interventions',
                'stats_amendements',
                'stats_amendements_adoptes',
                'stats_questions',
                'resume_ia',
                'parcours_ia',
                'positions_cles_ia',
                'faits_notables_ia',
                'last_synced_at',
                'updated_at',
            ]);

            $this->logInfo('Sync deputies page completed', [
                'chamber' => $chamber,
                'page' => $page,
                'rows' => count($rows),
                'skipped' => $skipped,
                'processed' => $processed,
            ]);
        }

        $this->logInfo('Sync deputies completed', [
            'chamber' => $chamber,
            'processed' => $processed,
            'skipped' => $skipped,
        ]);
    }
}

<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;

class SyncGroupsJob extends BaseSyncJob
{
    public function handle(ClairApiClient $client): void
    {
        $chamber = $this->chamber();
        $institutionId = $this->institutionIdForChamber($chamber);

        $this->seedInstitutions();
        $this->logInfo('Sync groups started', ['chamber' => $chamber]);

        $processed = 0;

        foreach ($client->getGroups($chamber) as $page => $items) {
            $rows = [];

            foreach ($items as $item) {
                if (($item['chambre'] ?? null) !== $chamber) {
                    continue;
                }

                $position = isset($item['position']) ? strtoupper((string) $item['position']) : null;

                $rows[] = [
                    'id' => (string) $item['id'],
                    'institution_id' => $institutionId,
                    'source_id' => $this->nullableString($item['sourceId'] ?? null),
                    'slug' => (string) $item['slug'],
                    'nom' => (string) $item['nom'],
                    'nom_complet' => (string) ($item['nomComplet'] ?? $item['nom']),
                    'couleur' => (string) ($item['couleur'] ?? '#000000'),
                    'logo_url' => $this->nullableString($item['logoUrl'] ?? null),
                    'position' => $position,
                    'ordre' => $this->nullableInt($item['ordre'] ?? null),
                    'actif' => (bool) ($item['actif'] ?? true),
                    'stats_membres_actifs' => $this->nullableInt($item['statsMembresActifs'] ?? null),
                    'stats_presence_moyenne' => $this->nullableInt($item['statsPresenceMoyenne'] ?? null),
                    'stats_presence_solennel_moyenne' => $this->nullableInt($item['statsPresenceSolennelMoyenne'] ?? null),
                    'stats_loyaute_moyenne' => $this->nullableInt($item['statsLoyauteMoyenne'] ?? null),
                    'stats_cohesion' => $this->nullableInt($item['statsCohesion'] ?? null),
                    'stats_participation' => $this->nullableInt($item['statsParticipation'] ?? null),
                    'stats_votes_pour' => $this->nullableInt($item['statsVotesPour'] ?? null),
                    'stats_votes_contre' => $this->nullableInt($item['statsVotesContre'] ?? null),
                    'stats_votes_abstention' => $this->nullableInt($item['statsVotesAbstention'] ?? null),
                    'stats_votes_absent' => $this->nullableInt($item['statsVotesAbsent'] ?? null),
                    'stats_calculated_at' => $this->nullableString($item['statsCalculatedAt'] ?? null),
                    'last_synced_at' => $this->nowIso(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            $processed += $this->upsertInChunks('groups', $rows, ['id'], [
                'institution_id',
                'source_id',
                'slug',
                'nom',
                'nom_complet',
                'couleur',
                'logo_url',
                'position',
                'ordre',
                'actif',
                'stats_membres_actifs',
                'stats_presence_moyenne',
                'stats_presence_solennel_moyenne',
                'stats_loyaute_moyenne',
                'stats_cohesion',
                'stats_participation',
                'stats_votes_pour',
                'stats_votes_contre',
                'stats_votes_abstention',
                'stats_votes_absent',
                'stats_calculated_at',
                'last_synced_at',
                'updated_at',
            ]);

            $this->logInfo('Sync groups page completed', [
                'chamber' => $chamber,
                'page' => $page,
                'rows' => count($rows),
                'processed' => $processed,
            ]);
        }

        $this->logInfo('Sync groups completed', ['chamber' => $chamber, 'processed' => $processed]);
    }

    private function seedInstitutions(): void
    {
        $rows = [
            [
                'id' => '11111111-1111-1111-1111-111111111111',
                'slug' => 'assemblee-nationale',
                'nom' => 'Assemblee nationale',
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => $this->nowIso(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '22222222-2222-2222-2222-222222222222',
                'slug' => 'senat',
                'nom' => 'Senat',
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => $this->nowIso(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '33333333-3333-3333-3333-333333333333',
                'slug' => 'parlement-europeen',
                'nom' => 'Parlement europeen',
                'pays' => 'Union europeenne',
                'actif' => false,
                'last_synced_at' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        $this->upsertInChunks('institutions', $rows, ['slug'], [
            'id',
            'nom',
            'pays',
            'actif',
            'last_synced_at',
            'updated_at',
        ]);
    }
}

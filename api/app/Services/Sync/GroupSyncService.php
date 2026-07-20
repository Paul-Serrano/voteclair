<?php

namespace App\Services\Sync;

use App\Services\Clair\ClairApiClient;
use Illuminate\Support\Facades\DB;

class GroupSyncService extends BaseSyncService
{
    public function __construct(
        private readonly ClairApiClient $client,
        private readonly SyncStateService $syncStateService,
    ) {}

    /**
     * @return array{processed:int}
     */
    public function sync(): array
    {
        $chamber = $this->chamber();
        $stateKey = 'last_groups_sync';
        $stateValue = $this->syncStateService->get($stateKey);
        $since = $this->parseStateDate($stateValue);
        if ($since !== null && $this->tableIsEmpty('groups')) {
            $this->logInfo('Groups table empty, forcing full sync', ['chamber' => $chamber]);
            $since = null;
        }
        $runStartedAt = $this->nowStateValue();
        $startedAt = microtime(true);

        $this->seedInstitutions();
        $institutionId = $this->resolveInstitutionIdForChamber($chamber);
        $this->logInfo('Sync groups started', ['chamber' => $chamber, 'since' => $stateValue]);

        $processed = 0;

        try {
            $pages = $since === null
                ? $this->client->getGroups($chamber)
                : $this->client->getUpdatedGroups($since, $chamber);

            foreach ($pages as $page => $items) {
                $rows = [];

                foreach ($items as $item) {
                    if (($item['chambre'] ?? null) !== $chamber) {
                        continue;
                    }

                    if (! $this->isItemNewerThanSince($item, $since, ['updatedAt', 'sourceUpdatedAt', 'statsCalculatedAt', 'createdAt'])) {
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

            $this->syncStateService->set($stateKey, $runStartedAt);

            $this->logInfo('Sync groups completed', [
                'chamber' => $chamber,
                'processed' => $processed,
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
            ]);

            return ['processed' => $processed];
        } catch (\Throwable $exception) {
            $this->logError('Sync groups failed', [
                'chamber' => $chamber,
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
                'exception_class' => $exception::class,
                'exception_message' => $exception->getMessage(),
            ]);

            throw $exception;
        }
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
            'nom',
            'pays',
            'actif',
            'last_synced_at',
            'updated_at',
        ]);
    }

    private function resolveInstitutionIdForChamber(string $chamber): string
    {
        $normalizedChamber = strtolower($chamber);

        $slugCandidates = match ($normalizedChamber) {
            'assemblee' => ['assemblee-nationale', 'assemblee_nationale', 'assemblee'],
            'senat' => ['senat', 'senate'],
            default => throw new \RuntimeException("Unsupported chamber: {$chamber}"),
        };

        $institutionId = DB::table('institutions')
            ->whereIn('slug', $slugCandidates)
            ->value('id');

        if (is_string($institutionId) && trim($institutionId) !== '') {
            return $institutionId;
        }

        if ($normalizedChamber === 'assemblee') {
            $institutionId = DB::table('institutions')
                ->whereRaw('LOWER(nom) LIKE ?', ['%assemblee%'])
                ->whereRaw('LOWER(nom) LIKE ?', ['%nationale%'])
                ->value('id');
        } else {
            $institutionId = DB::table('institutions')
                ->whereRaw('LOWER(nom) LIKE ?', ['%senat%'])
                ->value('id');
        }

        if (is_string($institutionId) && trim($institutionId) !== '') {
            return $institutionId;
        }

        if ($normalizedChamber === 'assemblee') {
            $canonical = [
                'id' => '11111111-1111-1111-1111-111111111111',
                'slug' => 'assemblee-nationale',
                'nom' => 'Assemblee nationale',
            ];
        } else {
            $canonical = [
                'id' => '22222222-2222-2222-2222-222222222222',
                'slug' => 'senat',
                'nom' => 'Senat',
            ];
        }

        DB::table('institutions')->updateOrInsert(
            ['id' => $canonical['id']],
            [
                'slug' => $canonical['slug'],
                'nom' => $canonical['nom'],
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => $this->nowIso(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        );

        return (string) $canonical['id'];
    }
}

<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Facades\DB;

class ImportGroupsCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:groups
        {--chambre=assemblee : Target chamber (assemblee|senat)}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import political groups from CLAIR API';

    public function handle(): int
    {
        return $this->runImport('groups', function (): int {
            $chamber = (string) $this->option('chambre');
            $institutionId = $this->institutionIdForChamber($chamber);

            $items = $this->fetchAllItems('/api/v1/groupes', [
                'chambre' => $chamber,
            ]);

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

            if ($this->option('dry-run')) {
                $this->logInfo('Dry-run summary', ['import' => 'groups', 'rows' => count($rows), 'chambre' => $chamber]);
                $this->info('Dry-run enabled. Groups to upsert: '.count($rows));

                return self::SUCCESS;
            }

            DB::table('groups')->upsert(
                $rows,
                ['id'],
                [
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
                ]
            );

            $this->logInfo('Import summary', ['import' => 'groups', 'rows' => count($rows), 'chambre' => $chamber]);
            $this->info('Groups imported: '.count($rows));

            return self::SUCCESS;
        });
    }
}

<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Facades\DB;

class ImportDeputiesCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:deputies
        {--chambre=assemblee : Target chamber (assemblee|senat)}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import deputies from CLAIR API';

    public function handle(): int
    {
        return $this->runImport('deputies', function (): int {
            $chamber = (string) $this->option('chambre');
            $institutionId = $this->institutionIdForChamber($chamber);
            $dryRun = (bool) $this->option('dry-run');

            $items = $this->fetchAllItems('/api/v1/deputes', [
                'chambre' => $chamber,
            ]);

            $groupById = [];
            $groupBySlug = [];

            if ($dryRun) {
                $apiGroups = $this->fetchAllItems('/api/v1/groupes', [
                    'chambre' => $chamber,
                ]);

                foreach ($apiGroups as $group) {
                    if (($group['chambre'] ?? null) !== $chamber || empty($group['id']) || empty($group['slug'])) {
                        continue;
                    }

                    $groupById[(string) $group['id']] = (string) $group['id'];
                    $groupBySlug[(string) $group['slug']] = (string) $group['id'];
                }
            } else {
                $groupById = DB::table('groups')->pluck('id', 'id')->all();
                $groupBySlug = DB::table('groups')
                    ->where('institution_id', $institutionId)
                    ->pluck('id', 'slug')
                    ->all();
            }

            $rows = [];
            $skipped = 0;

            foreach ($items as $item) {
                $groupId = $item['groupeId'] ?? null;

                if (! $groupId && isset($item['groupe']['slug'])) {
                    $groupId = $groupBySlug[$item['groupe']['slug']] ?? null;
                }

                if (! $groupId || ! isset($groupById[$groupId])) {
                    $skipped++;

                    continue;
                }

                $rows[] = [
                    'id' => (string) $item['id'],
                    'institution_id' => $institutionId,
                    'groupe_id' => (string) $groupId,
                    'circonscription_id' => $this->nullableString($item['circonscriptionId'] ?? ($item['circonscription']['id'] ?? null)),
                    'source_id' => (string) ($item['sourceId'] ?? ''),
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

            if ($dryRun) {
                $this->logInfo('Dry-run summary', [
                    'import' => 'deputies',
                    'rows' => count($rows),
                    'skipped' => $skipped,
                    'chambre' => $chamber,
                ]);
                $this->info('Dry-run enabled. Deputies to upsert: '.count($rows).', skipped: '.$skipped);

                return self::SUCCESS;
            }

            DB::table('deputies')->upsert(
                $rows,
                ['id'],
                [
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
                ]
            );

            $this->logInfo('Import summary', [
                'import' => 'deputies',
                'rows' => count($rows),
                'skipped' => $skipped,
                'chambre' => $chamber,
            ]);
            $this->info('Deputies imported: '.count($rows).', skipped: '.$skipped);

            return self::SUCCESS;
        });
    }
}

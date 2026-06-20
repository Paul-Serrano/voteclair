<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Facades\DB;

class ImportInstitutionsCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:institutions {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import institutions reference data for VoteClair';

    public function handle(): int
    {
        return $this->runImport('institutions', function (): int {
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

            if ($this->option('dry-run')) {
                $this->logInfo('Dry-run summary', ['import' => 'institutions', 'rows' => count($rows)]);
                $this->info('Dry-run enabled. Institutions to upsert: '.count($rows));

                return self::SUCCESS;
            }

            DB::table('institutions')->upsert(
                $rows,
                ['slug'],
                ['id', 'nom', 'pays', 'actif', 'last_synced_at', 'updated_at']
            );

            $this->logInfo('Import summary', ['import' => 'institutions', 'rows' => count($rows)]);
            $this->info('Institutions imported: '.count($rows));

            return self::SUCCESS;
        });
    }
}

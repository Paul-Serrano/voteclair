<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Facades\DB;

class ImportCirconscriptionsCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:circonscriptions
        {--chambre=assemblee : Target chamber (assemblee|senat)}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import circonscriptions inferred from CLAIR deputes feed';

    public function handle(): int
    {
        return $this->runImport('circonscriptions', function (): int {
            $chamber = (string) $this->option('chambre');

            $items = $this->fetchAllItems('/api/v1/deputes', [
                'chambre' => $chamber,
            ]);

            $unique = [];
            foreach ($items as $item) {
                $c = $item['circonscription'] ?? null;

                if (! is_array($c) || empty($c['id'])) {
                    continue;
                }

                $unique[(string) $c['id']] = [
                    'id' => (string) $c['id'],
                    'departement' => (string) ($c['departement'] ?? ''),
                    'departement_name' => $this->nullableString($c['departementName'] ?? null),
                    'numero' => $this->nullableInt($c['numero'] ?? null) ?? 0,
                    'nom' => (string) ($c['nom'] ?? (($c['departement'] ?? '').' - Circonscription '.($c['numero'] ?? ''))),
                    'last_synced_at' => $this->nowIso(),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }

            $rows = array_values($unique);

            if ($this->option('dry-run')) {
                $this->logInfo('Dry-run summary', ['import' => 'circonscriptions', 'rows' => count($rows), 'chambre' => $chamber]);
                $this->info('Dry-run enabled. Circonscriptions to upsert: '.count($rows));

                return self::SUCCESS;
            }

            DB::table('circonscriptions')->upsert(
                $rows,
                ['id'],
                ['departement', 'departement_name', 'numero', 'nom', 'last_synced_at', 'updated_at']
            );

            $this->logInfo('Import summary', ['import' => 'circonscriptions', 'rows' => count($rows), 'chambre' => $chamber]);
            $this->info('Circonscriptions imported: '.count($rows));

            return self::SUCCESS;
        });
    }
}

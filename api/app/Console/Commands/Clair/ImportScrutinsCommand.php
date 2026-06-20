<?php

namespace App\Console\Commands\Clair;

use Illuminate\Support\Facades\DB;

class ImportScrutinsCommand extends BaseClairImportCommand
{
    protected $signature = 'clair:import:scrutins
        {--chambre=assemblee : Target chamber (assemblee|senat)}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import scrutins from CLAIR API';

    public function handle(): int
    {
        return $this->runImport('scrutins', function (): int {
            $chamber = (string) $this->option('chambre');
            $institutionId = $this->institutionIdForChamber($chamber);
            $pageSize = min(100, max(1, (int) env('CLAIR_API_PAGE_SIZE', 100)));
            $maxPages = max(1, (int) env('CLAIR_API_MAX_PAGES', 500));
            $currentPage = 1;
            $totalRows = 0;

            while ($currentPage <= $maxPages) {
                $payload = $this->fetchJsonWithRetry('/api/v1/scrutins', [
                    'chambre' => $chamber,
                    'page' => $currentPage,
                    'limit' => $pageSize,
                ]);

                $items = $this->extractItemsFromPayload($payload);
                if (empty($items)) {
                    break;
                }

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

                $totalRows += count($rows);

                if (! $this->option('dry-run')) {
                    DB::table('scrutins')->upsert(
                        $rows,
                        ['id'],
                        [
                            'institution_id',
                            'numero',
                            'date',
                            'titre',
                            'sort',
                            'demandeur_texte',
                            'source_url',
                            'dossier_titre',
                            'dossier_url',
                            'resume_ia',
                            'last_synced_at',
                            'updated_at',
                        ]
                    );
                }

                $this->logInfo('Scrutins page processed', [
                    'import' => 'scrutins',
                    'chambre' => $chamber,
                    'page' => $currentPage,
                    'rows' => count($rows),
                    'running_total' => $totalRows,
                ]);

                if (! $this->hasNextPage($payload, $currentPage, count($items), $pageSize)) {
                    break;
                }

                $currentPage++;
            }

            if ($this->option('dry-run')) {
                $this->logInfo('Dry-run summary', [
                    'import' => 'scrutins',
                    'rows' => $totalRows,
                    'chambre' => $chamber,
                    'pages_processed' => $currentPage,
                ]);
                $this->info('Dry-run enabled. Scrutins to upsert: '.$totalRows);

                return self::SUCCESS;
            }

            $this->logInfo('Import summary', [
                'import' => 'scrutins',
                'rows' => $totalRows,
                'chambre' => $chamber,
                'pages_processed' => $currentPage,
            ]);
            $this->info('Scrutins imported: '.$totalRows);

            return self::SUCCESS;
        });
    }
}

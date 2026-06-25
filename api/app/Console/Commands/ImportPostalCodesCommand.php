<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use RuntimeException;

class ImportPostalCodesCommand extends Command
{
    protected $signature = 'voteclair:import-postal-codes
        {path? : Path to a JSON file containing postal code rows}
        {--dry-run : Show what would be imported without writing to DB}';

    protected $description = 'Import postal code mappings into the database';

    public function handle(): int
    {
        $path = (string) ($this->argument('path') ?? '');
        if ($path === '') {
            throw new InvalidArgumentException('You must provide a dataset path.');
        }

        if (! is_file($path)) {
            throw new RuntimeException("Dataset file not found: {$path}");
        }

        $rows = $this->loadRows($path);
        $payload = [];

        foreach ($rows as $row) {
            if (! is_array($row)) {
                continue;
            }

            $payload[] = [
                'postal_code' => (string) ($row['postal_code'] ?? ''),
                'departement_code' => (string) ($row['departement_code'] ?? ''),
                'institution_id' => $this->normalizeNullableString($row['institution_id'] ?? null),
                'circonscription_id' => (string) ($row['circonscription_id'] ?? ''),
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        $payload = array_values(array_filter($payload, function (array $row): bool {
            return $row['postal_code'] !== '' && $row['departement_code'] !== '' && $row['circonscription_id'] !== '';
        }));

        if ($this->option('dry-run')) {
            $this->info('Dry-run enabled. Postal codes to upsert: '.count($payload));

            return self::SUCCESS;
        }

        DB::table('postal_codes')->upsert(
            $payload,
            ['postal_code', 'institution_id'],
            ['departement_code', 'circonscription_id', 'updated_at']
        );

        $this->info('Postal codes imported: '.count($payload));

        return self::SUCCESS;
    }

    private function normalizeNullableString(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $stringValue = trim((string) $value);

        return $stringValue === '' ? null : $stringValue;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function loadRows(string $path): array
    {
        $content = file_get_contents($path);
        if ($content === false) {
            throw new RuntimeException("Unable to read dataset file: {$path}");
        }

        $decoded = json_decode($content, true);
        if (! is_array($decoded)) {
            throw new RuntimeException('Postal codes dataset must be a JSON array.');
        }

        return $decoded;
    }
}
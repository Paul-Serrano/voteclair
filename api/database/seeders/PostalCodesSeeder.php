<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PostalCodesSeeder extends Seeder
{
    public function run(): void
    {
        $path = base_path('../docs/clair-api/postal_codes.sample.json');

        if (! is_file($path)) {
            $this->command?->warn(sprintf('PostalCodesSeeder skipped: file not found at %s', $path));

            return;
        }

        $payload = json_decode((string) file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);
        if (! is_array($payload)) {
            $this->command?->warn('PostalCodesSeeder skipped: invalid postal codes payload.');

            return;
        }

        $assembleeInstitutionId = DB::table('institutions')
            ->where('slug', 'assemblee-nationale')
            ->value('id');

        $institutionId = is_string($assembleeInstitutionId) && trim($assembleeInstitutionId) !== ''
            ? $assembleeInstitutionId
            : null;

        $rows = [];

        foreach ($payload as $item) {
            if (! is_array($item)) {
                continue;
            }

            $postalCode = trim((string) ($item['postal_code'] ?? ''));
            $departementCode = trim((string) ($item['departement_code'] ?? ''));
            $circonscriptionId = trim((string) ($item['circonscription_id'] ?? ''));

            if ($postalCode === '' || $departementCode === '' || $circonscriptionId === '') {
                continue;
            }

            $rows[] = [
                'postal_code' => $postalCode,
                'departement_code' => $departementCode,
                'institution_id' => $institutionId,
                'circonscription_id' => $circonscriptionId,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        $rows = array_values($rows);

        if ($rows === []) {
            $this->command?->warn('PostalCodesSeeder skipped: no postal codes found in sample payload.');

            return;
        }

        DB::table('postal_codes')->upsert(
            $rows,
            ['postal_code', 'institution_id'],
            ['departement_code', 'circonscription_id', 'updated_at']
        );

        $this->command?->info(sprintf('Postal codes seeded: %d', count($rows)));
    }
}

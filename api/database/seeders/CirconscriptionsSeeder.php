<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class CirconscriptionsSeeder extends Seeder
{
    public function run(): void
    {
        $path = base_path('../docs/clair-api/deputies.json');

        if (! is_file($path)) {
            $this->command?->warn(sprintf('CirconscriptionsSeeder skipped: file not found at %s', $path));

            return;
        }

        $payload = json_decode((string) file_get_contents($path), true, 512, JSON_THROW_ON_ERROR);
        if (! is_array($payload)) {
            $this->command?->warn('CirconscriptionsSeeder skipped: invalid deputies payload.');

            return;
        }

        $assembleeInstitutionId = DB::table('institutions')
            ->where('slug', 'assemblee-nationale')
            ->value('id');

        $institutionId = is_string($assembleeInstitutionId) && trim($assembleeInstitutionId) !== ''
            ? $assembleeInstitutionId
            : null;

        $unique = [];

        foreach ($payload as $item) {
            if (! is_array($item)) {
                continue;
            }

            $circonscription = $item['circonscription'] ?? null;
            if (! is_array($circonscription) || empty($circonscription['id'])) {
                continue;
            }

            $circonscriptionId = (string) $circonscription['id'];
            $unique[$circonscriptionId] = [
                'id' => $circonscriptionId,
                'departement' => (string) ($circonscription['departement'] ?? ''),
                'departement_name' => $this->nullableString($circonscription['departementName'] ?? null),
                'numero' => $this->nullableInt($circonscription['numero'] ?? null) ?? 0,
                'nom' => (string) ($circonscription['nom'] ?? (($circonscription['departement'] ?? '').' - Circonscription '.($circonscription['numero'] ?? ''))),
                'institution_id' => $institutionId,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        $rows = array_values($unique);

        if ($rows === []) {
            $this->command?->warn('CirconscriptionsSeeder skipped: no circonscriptions found in deputies payload.');

            return;
        }

        DB::table('circonscriptions')->upsert(
            $rows,
            ['id'],
            ['departement', 'departement_name', 'numero', 'nom', 'institution_id', 'last_synced_at', 'updated_at']
        );

        $this->command?->info(sprintf('Circonscriptions seeded: %d', count($rows)));
    }

    private function nullableString(mixed $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (string) $value;
    }

    private function nullableInt(mixed $value): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (int) $value;
    }
}

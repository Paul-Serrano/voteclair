<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class InstitutionsSeeder extends Seeder
{
    public function run(): void
    {
        $rows = [
            [
                'id' => '11111111-1111-1111-1111-111111111111',
                'slug' => 'assemblee-nationale',
                'nom' => 'Assemblee nationale',
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => '22222222-2222-2222-2222-222222222222',
                'slug' => 'senat',
                'nom' => 'Senat',
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => now(),
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

        DB::table('institutions')->upsert(
            $rows,
            ['slug'],
            ['id', 'nom', 'pays', 'actif', 'last_synced_at', 'updated_at']
        );

        $this->command?->info(sprintf('Institutions seeded: %d', count($rows)));
    }
}

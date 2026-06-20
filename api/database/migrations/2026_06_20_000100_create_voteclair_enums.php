<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("CREATE TYPE vote_position AS ENUM ('POUR', 'CONTRE', 'ABSTENTION', 'NON_VOTANT')");
        DB::statement("CREATE TYPE political_position AS ENUM ('EXTREME_GAUCHE', 'GAUCHE', 'CENTRE_GAUCHE', 'CENTRE', 'CENTRE_DROIT', 'DROITE', 'EXTREME_DROITE')");
        DB::statement("CREATE TYPE scrutin_result AS ENUM ('ADOPTE', 'REJETE')");
    }

    public function down(): void
    {
        DB::statement('DROP TYPE IF EXISTS scrutin_result');
        DB::statement('DROP TYPE IF EXISTS political_position');
        DB::statement('DROP TYPE IF EXISTS vote_position');
    }
};

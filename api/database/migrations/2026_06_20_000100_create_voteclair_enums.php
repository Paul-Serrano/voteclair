<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::unprepared(<<<'SQL'
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vote_position') THEN
                    CREATE TYPE vote_position AS ENUM ('POUR', 'CONTRE', 'ABSTENTION', 'NON_VOTANT');
                END IF;
            END
            $$;
        SQL);

        DB::unprepared(<<<'SQL'
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'political_position') THEN
                    CREATE TYPE political_position AS ENUM ('EXTREME_GAUCHE', 'GAUCHE', 'CENTRE_GAUCHE', 'CENTRE', 'CENTRE_DROIT', 'DROITE', 'EXTREME_DROITE');
                END IF;
            END
            $$;
        SQL);

        DB::unprepared(<<<'SQL'
            DO $$
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'scrutin_result') THEN
                    CREATE TYPE scrutin_result AS ENUM ('ADOPTE', 'REJETE');
                END IF;
            END
            $$;
        SQL);
    }

    public function down(): void
    {
        DB::statement('DROP TYPE IF EXISTS scrutin_result');
        DB::statement('DROP TYPE IF EXISTS political_position');
        DB::statement('DROP TYPE IF EXISTS vote_position');
    }
};

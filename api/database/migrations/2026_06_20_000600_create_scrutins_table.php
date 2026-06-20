<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('scrutins', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('institution_id')->constrained('institutions');

            $table->integer('numero')->unique();
            $table->timestamp('date');
            $table->text('titre');
            $table->text('demandeur_texte')->nullable();
            $table->text('source_url')->nullable();

            $table->text('dossier_titre')->nullable();
            $table->text('dossier_url')->nullable();

            $table->text('resume_ia')->nullable();

            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();

            $table->index('date');
            $table->index('institution_id');
        });

        DB::statement('ALTER TABLE scrutins ADD COLUMN sort scrutin_result NOT NULL');
        DB::statement('CREATE INDEX scrutins_sort_index ON scrutins (sort)');
    }

    public function down(): void
    {
        Schema::dropIfExists('scrutins');
    }
};

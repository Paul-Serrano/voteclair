<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('groups', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('institution_id')->constrained('institutions');
            $table->string('source_id', 50)->nullable();
            $table->string('slug', 50)->unique();
            $table->string('nom', 100);
            $table->string('nom_complet', 255);
            $table->string('couleur', 7);
            $table->text('logo_url')->nullable();
            $table->integer('ordre')->nullable();
            $table->boolean('actif');

            $table->integer('stats_membres_actifs')->nullable();
            $table->smallInteger('stats_presence_moyenne')->nullable();
            $table->smallInteger('stats_presence_solennel_moyenne')->nullable();
            $table->smallInteger('stats_loyaute_moyenne')->nullable();
            $table->smallInteger('stats_cohesion')->nullable();
            $table->integer('stats_participation')->nullable();
            $table->integer('stats_votes_pour')->nullable();
            $table->integer('stats_votes_contre')->nullable();
            $table->integer('stats_votes_abstention')->nullable();
            $table->integer('stats_votes_absent')->nullable();
            $table->timestamp('stats_calculated_at')->nullable();

            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();

            $table->index('institution_id');
        });

        DB::statement('ALTER TABLE groups ADD COLUMN position political_position NULL');
        DB::statement('CREATE INDEX groups_position_index ON groups (position)');
    }

    public function down(): void
    {
        Schema::dropIfExists('groups');
    }
};

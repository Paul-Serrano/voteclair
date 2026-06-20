<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('deputies', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('institution_id')->constrained('institutions');
            $table->foreignUuid('groupe_id')->constrained('groups');
            $table->foreignUuid('circonscription_id')->nullable()->constrained('circonscriptions');

            $table->string('source_id', 50)->unique();
            $table->string('slug', 255)->unique();
            $table->string('nom', 255);
            $table->string('prenom', 255);

            $table->string('profession', 255)->nullable();
            $table->string('email', 255)->nullable();
            $table->string('twitter', 255)->nullable();
            $table->text('photo_url')->nullable();
            $table->boolean('actif');

            $table->smallInteger('stats_presence')->nullable();
            $table->smallInteger('stats_presence_solennel')->nullable();
            $table->smallInteger('stats_loyaute')->nullable();
            $table->integer('stats_participation')->nullable();
            $table->integer('stats_interventions')->nullable();
            $table->integer('stats_amendements')->nullable();
            $table->integer('stats_amendements_adoptes')->nullable();
            $table->integer('stats_questions')->nullable();

            $table->text('resume_ia')->nullable();
            $table->text('parcours_ia')->nullable();
            $table->text('positions_cles_ia')->nullable();
            $table->text('faits_notables_ia')->nullable();

            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();

            $table->index('nom');
            $table->index('institution_id');
            $table->index('groupe_id');
            $table->index('circonscription_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('deputies');
    }
};

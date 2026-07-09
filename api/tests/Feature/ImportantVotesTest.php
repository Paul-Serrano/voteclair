<?php

namespace Tests\Feature;

use App\Models\Scrutin;
use App\Services\Scrutins\ImportanceScoringService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class ImportantVotesTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->resetSchema();
        $this->createSchema();
    }

    public function test_importance_scoring_service_applies_expected_rules(): void
    {
        $service = app(ImportanceScoringService::class);

        $scrutin = new Scrutin;
        $scrutin->titre = 'Motion de censure sur le budget de la constitution';
        $scrutin->demandeur_texte = 'Vote solennel';
        $scrutin->nombre_pour = 255;
        $scrutin->nombre_contre = 260;

        // censure 100 + budget 80 + constitution 90 + solennel 50 + exprimes>500 20 + ecart<20 30 = 370
        $this->assertSame(370, $service->calculate($scrutin));
    }

    public function test_recalculate_importance_command_updates_scores(): void
    {
        DB::table('scrutins')->insert([
            [
                'id' => 'imp-1',
                'institution_id' => 'inst-an',
                'numero' => 1,
                'date' => '2026-01-01 00:00:00',
                'titre' => 'Motion de censure',
                'sort' => 'REJETE',
                'importance_score' => 0,
                'nombre_votants' => 577,
                'nombre_pour' => 280,
                'nombre_contre' => 297,
                'nombre_abstention' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'imp-2',
                'institution_id' => 'inst-an',
                'numero' => 2,
                'date' => '2026-01-02 00:00:00',
                'titre' => 'Question orale',
                'sort' => 'ADOPTE',
                'importance_score' => 0,
                'nombre_votants' => 20,
                'nombre_pour' => 15,
                'nombre_contre' => 5,
                'nombre_abstention' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $this->artisan('voteclair:recalculate-importance')
            ->expectsOutputToContain('Importance recalculated.')
            ->assertSuccessful();

        $this->assertDatabaseHas('scrutins', ['id' => 'imp-1', 'importance_score' => 150]);
        $this->assertDatabaseHas('scrutins', ['id' => 'imp-2', 'importance_score' => 30]);
    }

    private function resetSchema(): void
    {
        Schema::disableForeignKeyConstraints();
        Schema::dropIfExists('scrutins');
        Schema::enableForeignKeyConstraints();
    }

    private function createSchema(): void
    {
        Schema::create('scrutins', function (Blueprint $table): void {
            $table->string('id')->primary();
            $table->string('institution_id');
            $table->integer('numero')->unique();
            $table->timestamp('date');
            $table->text('titre');
            $table->string('sort')->nullable();
            $table->integer('importance_score')->default(0);
            $table->integer('nombre_votants')->default(0);
            $table->integer('nombre_pour')->default(0);
            $table->integer('nombre_contre')->default(0);
            $table->integer('nombre_abstention')->default(0);
            $table->text('demandeur_texte')->nullable();
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });
    }
}

<?php

namespace Tests\Feature;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class ImportCommandsTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        putenv('CLAIR_IMPORT_LOG_CHANNEL=array');
        $_ENV['CLAIR_IMPORT_LOG_CHANNEL'] = 'array';

        $this->resetSchema();
        $this->createSchema();
    }

    public function test_import_institutions_command(): void
    {
        $this->artisan('clair:import:institutions')->assertSuccessful();

        $this->assertDatabaseCount('institutions', 3);
        $this->assertDatabaseHas('institutions', [
            'slug' => 'assemblee-nationale',
            'nom' => 'Assemblee nationale',
        ]);
    }

    public function test_import_groups_command(): void
    {
        $this->seedInstitutions();

        Http::fake([
            '*/api/v1/groupes*' => Http::response([
                [
                    'id' => 'g-1',
                    'slug' => 'liot',
                    'nom' => 'LIOT',
                    'nomComplet' => 'Libertes, Independants, Outre-mer et Territoires',
                    'couleur' => '#123456',
                    'logoUrl' => null,
                    'position' => 'centre',
                    'ordre' => 4,
                    'actif' => true,
                    'chambre' => 'assemblee',
                    'statsMembresActifs' => 21,
                    'statsPresenceMoyenne' => 45,
                    'statsPresenceSolennelMoyenne' => 60,
                    'statsLoyauteMoyenne' => 77,
                    'statsCohesion' => 70,
                    'statsParticipation' => 100,
                    'statsVotesPour' => 30,
                    'statsVotesContre' => 20,
                    'statsVotesAbstention' => 10,
                    'statsVotesAbsent' => 0,
                    'statsCalculatedAt' => '2026-06-20T00:00:00.000Z',
                    'sourceId' => 'POX',
                ],
            ], 200),
        ]);

        $this->artisan('clair:import:groups', ['--chambre' => 'assemblee'])->assertSuccessful();

        $this->assertDatabaseCount('groups', 1);
        $this->assertDatabaseHas('groups', [
            'id' => 'g-1',
            'institution_id' => '11111111-1111-1111-1111-111111111111',
            'slug' => 'liot',
            'position' => 'CENTRE',
        ]);
    }

    public function test_import_circonscriptions_command(): void
    {
        Http::fake([
            '*/api/v1/deputes*' => Http::response([
                [
                    'id' => 'dep-1',
                    'circonscription' => [
                        'id' => 'cir-1',
                        'departement' => '75',
                        'departementName' => 'Paris',
                        'numero' => 1,
                        'nom' => '75 - Circonscription 1',
                    ],
                ],
            ], 200),
        ]);

        $this->artisan('clair:import:circonscriptions', ['--chambre' => 'assemblee'])->assertSuccessful();

        $this->assertDatabaseCount('circonscriptions', 1);
        $this->assertDatabaseHas('circonscriptions', [
            'id' => 'cir-1',
            'departement' => '75',
            'departement_name' => 'Paris',
            'numero' => 1,
        ]);
    }

    public function test_import_deputies_command(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();
        $this->seedCirconscription();

        Http::fake([
            '*/api/v1/deputes*' => Http::response([
                [
                    'id' => 'dep-1',
                    'groupeId' => 'g-1',
                    'circonscriptionId' => 'cir-1',
                    'sourceId' => '841495',
                    'slug' => 'audrey-abadie-amiel',
                    'nom' => 'Abadie-Amiel',
                    'prenom' => 'Audrey',
                    'profession' => 'Enseignante',
                    'photoUrl' => null,
                    'twitter' => null,
                    'email' => 'audrey@example.com',
                    'actif' => true,
                    'statsPresence' => 7,
                    'statsPresenceSolennel' => 39,
                    'statsLoyaute' => 87,
                    'statsParticipation' => 525,
                    'statsInterventions' => 12,
                    'statsAmendements' => 152,
                    'statsAmendementsAdoptes' => 57,
                    'statsQuestions' => 3,
                    'resumeIA' => 'Resume',
                    'parcoursIA' => 'Parcours',
                    'positionsClesIA' => 'Positions',
                    'faitsNotablesIA' => 'Faits',
                ],
            ], 200),
            '*/api/v1/groupes*' => Http::response([
                [
                    'id' => 'g-1',
                    'slug' => 'liot',
                    'chambre' => 'assemblee',
                ],
            ], 200),
        ]);

        $this->artisan('clair:import:deputies', ['--chambre' => 'assemblee'])->assertSuccessful();

        $this->assertDatabaseCount('deputies', 1);
        $this->assertDatabaseHas('deputies', [
            'id' => 'dep-1',
            'slug' => 'audrey-abadie-amiel',
            'groupe_id' => 'g-1',
        ]);
    }

    public function test_import_scrutins_command(): void
    {
        $this->seedInstitutions();

        Http::fake([
            '*/api/v1/scrutins*' => Http::response([
                [
                    'id' => 'scr-1',
                    'numero' => 7407,
                    'chambre' => 'assemblee',
                    'date' => '2026-06-16T00:00:00.000Z',
                    'titre' => 'Scrutin test',
                    'sort' => 'rejete',
                    'demandeurTexte' => 'Demandeur',
                    'sourceUrl' => 'https://example.test/scrutins/7407',
                    'dossier' => ['titre' => 'Dossier test', 'url' => 'https://example.test/dossier'],
                    'resumeIA' => 'Resume',
                ],
            ], 200),
        ]);

        $this->artisan('clair:import:scrutins', ['--chambre' => 'assemblee'])->assertSuccessful();

        $this->assertDatabaseCount('scrutins', 1);
        $this->assertDatabaseHas('scrutins', [
            'id' => 'scr-1',
            'numero' => 7407,
            'sort' => 'REJETE',
        ]);
    }

    public function test_import_votes_command(): void
    {
        $this->seedScrutin();
        $this->seedDeputy();

        Http::fake([
            '*/api/v1/scrutins/7407' => Http::response([
                'data' => [
                    'id' => 'scr-1',
                    'numero' => 7407,
                    'chambre' => 'assemblee',
                    'sourceData' => [
                        'ventilationVotes' => [
                            'organe' => [
                                'groupes' => [
                                    'groupe' => [
                                        [
                                            'vote' => [
                                                'decompteNominatif' => [
                                                    'pours' => [
                                                        'votant' => [
                                                            [
                                                                'acteurRef' => 'PA841495',
                                                                'parDelegation' => 'false',
                                                            ],
                                                        ],
                                                    ],
                                                ],
                                            ],
                                        ],
                                    ],
                                ],
                            ],
                        ],
                    ],
                ],
            ], 200),
            '*' => Http::response([], 200),
        ]);

        $this->artisan('clair:import:votes', ['--chambre' => 'assemblee', '--numero' => [7407]])->assertSuccessful();

        $this->assertDatabaseCount('votes', 1);
        $this->assertDatabaseHas('votes', [
            'scrutin_id' => 'scr-1',
            'deputy_id' => 'dep-1',
            'position' => 'POUR',
        ]);
    }

    private function resetSchema(): void
    {
        Schema::disableForeignKeyConstraints();

        foreach (['votes', 'scrutins', 'deputies', 'circonscriptions', 'groups', 'institutions'] as $table) {
            Schema::dropIfExists($table);
        }

        Schema::enableForeignKeyConstraints();
    }

    private function createSchema(): void
    {
        Schema::create('institutions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('slug')->unique();
            $table->string('nom');
            $table->string('pays');
            $table->boolean('actif')->default(true);
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('groups', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('institution_id');
            $table->string('source_id')->nullable();
            $table->string('slug')->unique();
            $table->string('nom');
            $table->string('nom_complet');
            $table->string('couleur')->nullable();
            $table->text('logo_url')->nullable();
            $table->string('position')->nullable();
            $table->integer('ordre')->nullable();
            $table->boolean('actif')->default(true);
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
        });

        Schema::create('circonscriptions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('departement', 5);
            $table->string('departement_name')->nullable();
            $table->integer('numero');
            $table->string('nom');
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('deputies', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('institution_id');
            $table->string('groupe_id');
            $table->string('circonscription_id')->nullable();
            $table->string('source_id')->unique();
            $table->string('slug')->unique();
            $table->string('nom');
            $table->string('prenom');
            $table->string('profession')->nullable();
            $table->string('email')->nullable();
            $table->string('twitter')->nullable();
            $table->text('photo_url')->nullable();
            $table->boolean('actif')->default(true);
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
        });

        Schema::create('scrutins', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('institution_id');
            $table->integer('numero')->unique();
            $table->timestamp('date');
            $table->text('titre');
            $table->string('sort')->nullable();
            $table->integer('nombre_votants')->default(0);
            $table->integer('nombre_pour')->default(0);
            $table->integer('nombre_contre')->default(0);
            $table->integer('nombre_abstention')->default(0);
            $table->text('demandeur_texte')->nullable();
            $table->text('source_url')->nullable();
            $table->text('dossier_titre')->nullable();
            $table->text('dossier_url')->nullable();
            $table->text('resume_ia')->nullable();
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('votes', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('scrutin_id');
            $table->string('deputy_id');
            $table->string('position');
            $table->boolean('delegated')->default(false);
            $table->timestamps();
            $table->unique(['scrutin_id', 'deputy_id']);
        });
    }

    private function seedInstitutions(): void
    {
        $this->seedInstitution('11111111-1111-1111-1111-111111111111', 'assemblee-nationale');
    }

    private function seedInstitution(string $id, string $slug): void
    {
        \DB::table('institutions')->updateOrInsert(
            ['id' => $id],
            [
                'slug' => $slug,
                'nom' => 'Institution',
                'pays' => 'France',
                'actif' => true,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }

    private function seedGroup(): void
    {
        \DB::table('groups')->updateOrInsert(
            ['id' => 'g-1'],
            [
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'source_id' => 'POX',
                'slug' => 'liot',
                'nom' => 'LIOT',
                'nom_complet' => 'LIOT',
                'couleur' => '#123456',
                'logo_url' => null,
                'position' => 'CENTRE',
                'ordre' => 1,
                'actif' => true,
                'stats_membres_actifs' => null,
                'stats_presence_moyenne' => null,
                'stats_presence_solennel_moyenne' => null,
                'stats_loyaute_moyenne' => null,
                'stats_cohesion' => null,
                'stats_participation' => null,
                'stats_votes_pour' => null,
                'stats_votes_contre' => null,
                'stats_votes_abstention' => null,
                'stats_votes_absent' => null,
                'stats_calculated_at' => null,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }

    private function seedCirconscription(): void
    {
        \DB::table('circonscriptions')->updateOrInsert(
            ['id' => 'cir-1'],
            [
                'departement' => '75',
                'departement_name' => 'Paris',
                'numero' => 1,
                'nom' => '75 - Circonscription 1',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }

    private function seedScrutin(): void
    {
        $this->seedInstitutions();

        \DB::table('scrutins')->updateOrInsert(
            ['id' => 'scr-1'],
            [
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'numero' => 7407,
                'date' => '2026-06-16 00:00:00',
                'titre' => 'Scrutin test',
                'sort' => 'REJETE',
                'nombre_votants' => 276,
                'nombre_pour' => 85,
                'nombre_contre' => 180,
                'nombre_abstention' => 11,
                'demandeur_texte' => null,
                'source_url' => null,
                'dossier_titre' => null,
                'dossier_url' => null,
                'resume_ia' => null,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }

    private function seedDeputy(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();

        \DB::table('deputies')->updateOrInsert(
            ['id' => 'dep-1'],
            [
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'groupe_id' => 'g-1',
                'circonscription_id' => null,
                'source_id' => '841495',
                'slug' => 'audrey-abadie-amiel',
                'nom' => 'Abadie-Amiel',
                'prenom' => 'Audrey',
                'profession' => null,
                'email' => null,
                'twitter' => null,
                'photo_url' => null,
                'actif' => true,
                'stats_presence' => null,
                'stats_presence_solennel' => null,
                'stats_loyaute' => null,
                'stats_participation' => null,
                'stats_interventions' => null,
                'stats_amendements' => null,
                'stats_amendements_adoptes' => null,
                'stats_questions' => null,
                'resume_ia' => null,
                'parcours_ia' => null,
                'positions_cles_ia' => null,
                'faits_notables_ia' => null,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }
}

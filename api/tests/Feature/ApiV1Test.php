<?php

namespace Tests\Feature;

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class ApiV1Test extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        $this->resetSchema();
        $this->createSchema();
        $this->seedFixtures();
    }

    public function test_groups_index_returns_ordered_group_resources(): void
    {
        $response = $this->getJson('/api/groups');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.slug', 'g-centre')
            ->assertJsonPath('data.1.slug', 'g-gauche')
            ->assertJsonPath('data.0.membres_count', 1)
            ->assertJsonPath('data.1.membres_count', 1)
            ->assertJsonStructure([
                'data' => [
                    [
                        'slug',
                        'nom',
                        'nom_complet',
                        'couleur',
                        'logo_url',
                        'position',
                        'membres_count',
                    ],
                ],
            ]);
    }

    public function test_group_show_returns_group_details_with_stats(): void
    {
        $response = $this->getJson('/api/groups/g-centre');

        $response
            ->assertOk()
            ->assertJsonPath('data.slug', 'g-centre')
            ->assertJsonPath('data.nom', 'Centre')
            ->assertJsonPath('data.institution.slug', 'assemblee-nationale')
            ->assertJsonPath('data.membres_count', 1)
            ->assertJsonPath('data.stats.presence', 32)
            ->assertJsonPath('data.stats.presence_solennelle', 91)
            ->assertJsonPath('data.stats.loyaute', 99)
            ->assertJsonPath('data.stats.cohesion', 99)
            ->assertJsonPath('data.stats.participation', 168139)
            ->assertJsonPath('data.stats.votes_pour', 82918)
            ->assertJsonPath('data.stats.votes_contre', 76810)
            ->assertJsonPath('data.stats.votes_abstention', 8411)
            ->assertJsonPath('data.stats.votes_absent', 0)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'slug',
                    'nom',
                    'nom_complet',
                    'couleur',
                    'logo_url',
                    'position',
                    'membres_count',
                    'institution' => ['slug', 'nom', 'pays'],
                    'stats' => [
                        'presence',
                        'presence_solennelle',
                        'loyaute',
                        'cohesion',
                        'participation',
                        'votes_pour',
                        'votes_contre',
                        'votes_abstention',
                        'votes_absent',
                    ],
                ],
            ]);
    }

    public function test_group_deputies_returns_paginated_members(): void
    {
        $response = $this->getJson('/api/groups/g-centre/deputies');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'jean-dupont')
            ->assertJsonPath('data.0.stats_presence', 91)
            ->assertJsonStructure([
                'data' => [
                    [
                        'slug',
                        'nom',
                        'prenom',
                        'photo_url',
                        'stats_presence',
                    ],
                ],
                'links',
                'meta',
            ]);
    }

    public function test_deputies_index_returns_paginated_data_and_group_filter(): void
    {
        $response = $this->getJson('/api/deputies?group=g-centre');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'jean-dupont')
            ->assertJsonPath('data.0.group.slug', 'g-centre')
            ->assertJsonStructure([
                'data' => [
                    [
                        'slug',
                        'nom',
                        'prenom',
                        'profession',
                        'photo_url',
                        'group' => ['slug', 'nom'],
                        'circonscription' => ['nom'],
                        'stats' => ['presence', 'loyaute'],
                        'resume_ia',
                    ],
                ],
                'links',
                'meta',
            ]);
    }

    public function test_deputies_index_search_filters_results_on_postgresql(): void
    {
        $response = $this->getJson('/api/deputies?search=dup');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.slug', 'jean-dupont');
    }

    public function test_deputy_show_uses_slug_route_binding(): void
    {
        $response = $this->getJson('/api/deputies/jean-dupont');

        $response
            ->assertOk()
            ->assertJsonPath('data.slug', 'jean-dupont')
            ->assertJsonPath('data.group.slug', 'g-centre')
            ->assertJsonPath('data.circonscription.nom', 'Paris 1')
            ->assertJsonPath('data.stats.presence', 91)
            ->assertJsonPath('data.stats.loyaute', 84);
    }

    public function test_deputy_votes_returns_paginated_votes_sorted_by_scrutin_numero_desc(): void
    {
        DB::table('scrutins')->insert([
            'id' => 'f0f0f0f0-f0f0-4f0f-8f0f-f0f0f0f0f0f0',
            'institution_id' => 'inst-an',
            'numero' => 999,
            'date' => '2020-01-01 00:00:00',
            'titre' => 'Scrutin test numero eleve',
            'sort' => 'ADOPTE',
            'nombre_votants' => 0,
            'nombre_pour' => 0,
            'nombre_contre' => 0,
            'nombre_abstention' => 0,
            'demandeur_texte' => null,
            'source_url' => null,
            'dossier_titre' => null,
            'dossier_url' => null,
            'resume_ia' => null,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('votes')->insert([
            'scrutin_id' => 'f0f0f0f0-f0f0-4f0f-8f0f-f0f0f0f0f0f0',
            'deputy_id' => 'dep-1',
            'position' => 'POUR',
            'delegated' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson('/api/deputies/jean-dupont/votes');

        $response
            ->assertOk()
            ->assertJsonCount(3, 'data')
            ->assertJsonPath('data.0.scrutin.numero', 999)
            ->assertJsonPath('data.1.scrutin.numero', 101)
            ->assertJsonPath('data.2.scrutin.numero', 100)
            ->assertJsonStructure([
                'data' => [
                    [
                        'position',
                        'delegated',
                        'scrutin' => ['numero', 'titre', 'date'],
                    ],
                ],
                'links',
                'meta',
            ]);
    }

    public function test_scrutins_index_filters_by_sort_and_date_range(): void
    {
        $response = $this->getJson('/api/scrutins?sort=REJETE&from=2026-06-15&to=2026-06-30');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb')
            ->assertJsonPath('data.0.numero', 101)
            ->assertJsonPath('data.0.sort', 'REJETE')
            ->assertJsonPath('data.0.institution.slug', 'assemblee-nationale')
            ->assertJsonStructure([
                'data' => [
                    [
                        'id',
                        'numero',
                        'date',
                        'titre',
                        'sort',
                        'resume_ia',
                        'demandeur_texte',
                        'source_url',
                        'dossier' => ['titre', 'url'],
                    ],
                ],
                'links',
                'meta',
            ]);
    }

    public function test_scrutins_index_search_filters_results(): void
    {
        $response = $this->getJson('/api/scrutins?search=climat');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
            ->assertJsonPath('data.0.titre', 'Loi Climat');
    }

    public function test_scrutins_index_sorts_by_numero_desc(): void
    {
        DB::table('scrutins')->insert([
            'id' => 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
            'institution_id' => 'inst-an',
            'numero' => 999,
            'date' => '2020-01-01 00:00:00',
            'titre' => 'Ancien scrutin avec numero eleve',
            'sort' => 'ADOPTE',
            'nombre_votants' => 0,
            'nombre_pour' => 0,
            'nombre_contre' => 0,
            'nombre_abstention' => 0,
            'demandeur_texte' => null,
            'source_url' => null,
            'dossier_titre' => null,
            'dossier_url' => null,
            'resume_ia' => null,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson('/api/scrutins');

        $response
            ->assertOk()
            ->assertJsonPath('data.0.numero', 999)
            ->assertJsonPath('data.1.numero', 101)
            ->assertJsonPath('data.2.numero', 100);
    }

    public function test_scrutin_show_returns_single_scrutin_resource(): void
    {
        $response = $this->getJson('/api/scrutins/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

        $response
            ->assertOk()
            ->assertJsonPath('data.id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
            ->assertJsonPath('data.numero', 100)
            ->assertJsonPath('data.titre', 'Loi Climat')
            ->assertJsonPath('data.institution.slug', 'assemblee-nationale')
            ->assertJsonPath('data.resultats.pour', 1)
            ->assertJsonPath('data.resultats.contre', 0)
            ->assertJsonPath('data.resultats.abstention', 1)
            ->assertJsonPath('data.resultats.non_votant', 0)
            ->assertJsonPath('data.resultats.total', 2)
            ->assertJsonPath('data.groupes.0.slug', 'g-centre')
            ->assertJsonPath('data.groupes.0.pour', 1)
            ->assertJsonPath('data.groupes.0.total', 1)
            ->assertJsonPath('data.groupes.1.slug', 'g-gauche')
            ->assertJsonPath('data.groupes.1.abstention', 1)
            ->assertJsonPath('data.groupes.1.total', 1)
            ->assertJsonPath('data.dossier.titre', 'Projet de loi Climat');
    }

    public function test_scrutin_votes_returns_paginated_votes_with_deputy_resource(): void
    {
        $response = $this->getJson('/api/scrutins/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/votes');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.deputy.slug', 'jean-dupont')
            ->assertJsonPath('data.0.deputy.group.slug', 'g-centre')
            ->assertJsonPath('data.1.deputy.slug', 'marie-durand')
            ->assertJsonPath('data.1.deputy.group.slug', 'g-gauche')
            ->assertJsonStructure([
                'data' => [
                    [
                        'position',
                        'delegated',
                        'deputy' => ['slug', 'nom', 'prenom', 'group' => ['slug', 'nom', 'couleur']],
                    ],
                ],
                'links',
                'meta',
            ]);
    }

    public function test_search_returns_categorized_results(): void
    {
        $response = $this->getJson('/api/search?q=climat');

        $response
            ->assertOk()
            ->assertJsonPath('scrutins.0.titre', 'Loi Climat')
            ->assertJsonPath('deputies', [])
            ->assertJsonPath('groups', [])
            ->assertJsonStructure([
                'deputies',
                'groups',
                'scrutins' => [
                    [
                        'id',
                        'titre',
                        'date',
                        'sort',
                    ],
                ],
            ]);

        $responseDeputy = $this->getJson('/api/search?q=dupont');

        $responseDeputy
            ->assertOk()
            ->assertJsonPath('deputies.0.slug', 'jean-dupont')
            ->assertJsonPath('deputies.0.group', 'Centre');
    }

    public function test_search_scrutins_are_sorted_by_numero_desc(): void
    {
        DB::table('scrutins')->insert([
            [
                'id' => 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
                'institution_id' => 'inst-an',
                'numero' => 250,
                'date' => '2019-01-01 00:00:00',
                'titre' => 'Texte commun alpha',
                'sort' => 'ADOPTE',
                'nombre_votants' => 0,
                'nombre_pour' => 0,
                'nombre_contre' => 0,
                'nombre_abstention' => 0,
                'demandeur_texte' => null,
                'source_url' => null,
                'dossier_titre' => null,
                'dossier_url' => null,
                'resume_ia' => 'Resume alpha',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
                'institution_id' => 'inst-an',
                'numero' => 150,
                'date' => '2027-01-01 00:00:00',
                'titre' => 'Texte commun beta',
                'sort' => 'REJETE',
                'nombre_votants' => 0,
                'nombre_pour' => 0,
                'nombre_contre' => 0,
                'nombre_abstention' => 0,
                'demandeur_texte' => null,
                'source_url' => null,
                'dossier_titre' => null,
                'dossier_url' => null,
                'resume_ia' => 'Resume beta',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        $response = $this->getJson('/api/search?q=Texte commun');

        $response
            ->assertOk()
            ->assertJsonPath('scrutins.0.titre', 'Texte commun alpha')
            ->assertJsonPath('scrutins.1.titre', 'Texte commun beta');
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
        Schema::create('institutions', function (Blueprint $table): void {
            $table->string('id')->primary();
            $table->string('slug')->unique();
            $table->string('nom');
            $table->string('pays');
            $table->boolean('actif')->default(true);
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('groups', function (Blueprint $table): void {
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

        Schema::create('circonscriptions', function (Blueprint $table): void {
            $table->string('id')->primary();
            $table->string('departement', 5);
            $table->string('departement_name')->nullable();
            $table->integer('numero');
            $table->string('nom');
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('deputies', function (Blueprint $table): void {
            $table->string('id')->primary();
            $table->string('institution_id');
            $table->string('groupe_id');
            $table->string('circonscription_id')->nullable();
            $table->string('source_id')->unique();
            $table->string('slug')->unique();
            $table->string('nom');
            $table->string('prenom');
            $table->string('profession')->nullable();
            $table->text('photo_url')->nullable();
            $table->boolean('actif')->default(true);
            $table->smallInteger('stats_presence')->nullable();
            $table->smallInteger('stats_loyaute')->nullable();
            $table->text('resume_ia')->nullable();
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();
        });

        Schema::create('scrutins', function (Blueprint $table): void {
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

        Schema::create('votes', function (Blueprint $table): void {
            $table->bigIncrements('id');
            $table->string('scrutin_id');
            $table->string('deputy_id');
            $table->string('position');
            $table->boolean('delegated')->default(false);
            $table->timestamps();
            $table->unique(['scrutin_id', 'deputy_id']);
        });
    }

    private function seedFixtures(): void
    {
        DB::table('institutions')->insert([
            'id' => 'inst-an',
            'slug' => 'assemblee-nationale',
            'nom' => 'Assemblee nationale',
            'pays' => 'France',
            'actif' => true,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('groups')->insert([
            [
                'id' => 'grp-centre',
                'institution_id' => 'inst-an',
                'source_id' => 'POC',
                'slug' => 'g-centre',
                'nom' => 'Centre',
                'nom_complet' => 'Groupe du Centre',
                'couleur' => '#00AAFF',
                'logo_url' => null,
                'position' => 'CENTRE',
                'ordre' => 1,
                'actif' => true,
                'stats_membres_actifs' => 1,
                'stats_presence_moyenne' => 32,
                'stats_presence_solennel_moyenne' => 91,
                'stats_loyaute_moyenne' => 99,
                'stats_cohesion' => 99,
                'stats_participation' => 168139,
                'stats_votes_pour' => 82918,
                'stats_votes_contre' => 76810,
                'stats_votes_abstention' => 8411,
                'stats_votes_absent' => 0,
                'stats_calculated_at' => null,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'grp-gauche',
                'institution_id' => 'inst-an',
                'source_id' => 'POG',
                'slug' => 'g-gauche',
                'nom' => 'Gauche',
                'nom_complet' => 'Groupe de Gauche',
                'couleur' => '#FF3366',
                'logo_url' => null,
                'position' => 'GAUCHE',
                'ordre' => 2,
                'actif' => true,
                'stats_membres_actifs' => 1,
                'stats_presence_moyenne' => 41,
                'stats_presence_solennel_moyenne' => 88,
                'stats_loyaute_moyenne' => 93,
                'stats_cohesion' => 94,
                'stats_participation' => 151234,
                'stats_votes_pour' => 54000,
                'stats_votes_contre' => 89000,
                'stats_votes_abstention' => 8234,
                'stats_votes_absent' => 0,
                'stats_calculated_at' => null,
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('circonscriptions')->insert([
            'id' => 'cir-1',
            'departement' => '75',
            'departement_name' => 'Paris',
            'numero' => 1,
            'nom' => 'Paris 1',
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        DB::table('deputies')->insert([
            [
                'id' => 'dep-1',
                'institution_id' => 'inst-an',
                'groupe_id' => 'grp-centre',
                'circonscription_id' => 'cir-1',
                'source_id' => '841001',
                'slug' => 'jean-dupont',
                'nom' => 'Dupont',
                'prenom' => 'Jean',
                'profession' => 'Ingenieur',
                'photo_url' => null,
                'actif' => true,
                'stats_presence' => 91,
                'stats_loyaute' => 84,
                'resume_ia' => 'Profil Jean',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'dep-2',
                'institution_id' => 'inst-an',
                'groupe_id' => 'grp-gauche',
                'circonscription_id' => null,
                'source_id' => '841002',
                'slug' => 'marie-durand',
                'nom' => 'Durand',
                'prenom' => 'Marie',
                'profession' => 'Avocate',
                'photo_url' => null,
                'actif' => true,
                'stats_presence' => 77,
                'stats_loyaute' => 65,
                'resume_ia' => 'Profil Marie',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('scrutins')->insert([
            [
                'id' => 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                'institution_id' => 'inst-an',
                'numero' => 100,
                'date' => '2026-06-10 12:00:00',
                'titre' => 'Loi Climat',
                'sort' => 'ADOPTE',
                'nombre_votants' => 276,
                'nombre_pour' => 85,
                'nombre_contre' => 180,
                'nombre_abstention' => 11,
                'demandeur_texte' => 'Gouvernement',
                'source_url' => 'https://example.test/scrutins/100',
                'dossier_titre' => 'Projet de loi Climat',
                'dossier_url' => 'https://example.test/dossiers/climat',
                'resume_ia' => 'Resume Climat',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
                'institution_id' => 'inst-an',
                'numero' => 101,
                'date' => '2026-06-20 09:00:00',
                'titre' => 'Budget Defense',
                'sort' => 'REJETE',
                'nombre_votants' => 273,
                'nombre_pour' => 5,
                'nombre_contre' => 261,
                'nombre_abstention' => 7,
                'demandeur_texte' => 'Commission',
                'source_url' => 'https://example.test/scrutins/101',
                'dossier_titre' => 'Projet Budget Defense',
                'dossier_url' => 'https://example.test/dossiers/budget-defense',
                'resume_ia' => 'Resume Budget',
                'last_synced_at' => now(),
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        DB::table('votes')->insert([
            [
                'scrutin_id' => 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                'deputy_id' => 'dep-1',
                'position' => 'POUR',
                'delegated' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'scrutin_id' => 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
                'deputy_id' => 'dep-1',
                'position' => 'CONTRE',
                'delegated' => true,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'scrutin_id' => 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                'deputy_id' => 'dep-2',
                'position' => 'ABSTENTION',
                'delegated' => false,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }

    public function test_dashboard_returns_stats_and_recent_activity(): void
    {
        $response = $this->getJson('/api/dashboard');

        $response
            ->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'stats' => ['deputies', 'groups', 'scrutins', 'votes'],
                    'latest_scrutins' => [
                        [
                            'id',
                            'numero',
                            'titre',
                            'date',
                            'sort',
                        ],
                    ],
                    'top_groups' => [
                        [
                            'slug',
                            'nom',
                            'couleur',
                            'members_count',
                        ],
                    ],
                    'recent_activity' => [
                        'last_scrutin_date',
                        'last_scrutin_title',
                    ],
                ],
            ])
            ->assertJsonPath('data.stats.deputies', 2)
            ->assertJsonPath('data.stats.groups', 2)
            ->assertJsonPath('data.stats.scrutins', 2)
            ->assertJsonPath('data.stats.votes', 3);
    }

    public function test_favorites_activity_returns_latest_vote_per_deputy_sorted_by_vote_date_desc(): void
    {
        $response = $this->getJson('/api/favorites/activity?slugs=marie-durand,jean-dupont');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.deputy.slug', 'jean-dupont')
            ->assertJsonPath('data.0.latest_vote.position', 'CONTRE')
            ->assertJsonPath('data.0.latest_vote.scrutin.id', 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb')
            ->assertJsonPath('data.1.deputy.slug', 'marie-durand')
            ->assertJsonPath('data.1.latest_vote.position', 'ABSTENTION')
            ->assertJsonPath('data.1.latest_vote.scrutin.id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
            ->assertJsonStructure([
                'data' => [
                    [
                        'deputy' => ['slug', 'nom', 'prenom', 'photo_url'],
                        'latest_vote' => [
                            'id',
                            'position',
                            'scrutin' => ['id', 'titre', 'date'],
                        ],
                    ],
                ],
            ]);
    }

    public function test_favorites_activity_returns_empty_data_for_missing_or_unknown_slugs(): void
    {
        $responseNoParam = $this->getJson('/api/favorites/activity');
        $responseNoParam
            ->assertOk()
            ->assertJsonPath('data', []);

        $responseUnknown = $this->getJson('/api/favorites/activity?slugs=unknown-slug');
        $responseUnknown
            ->assertOk()
            ->assertJsonPath('data', []);
    }

    public function test_favorites_activity_ignores_favorites_without_votes(): void
    {
        DB::table('deputies')->insert([
            'id' => 'dep-3',
            'institution_id' => 'inst-an',
            'groupe_id' => 'grp-centre',
            'circonscription_id' => null,
            'source_id' => '841003',
            'slug' => 'alice-sans-vote',
            'nom' => 'SansVote',
            'prenom' => 'Alice',
            'profession' => 'Juriste',
            'photo_url' => null,
            'actif' => true,
            'stats_presence' => 10,
            'stats_loyaute' => 10,
            'resume_ia' => null,
            'last_synced_at' => now(),
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $response = $this->getJson('/api/favorites/activity?slugs=alice-sans-vote,jean-dupont');

        $response
            ->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.deputy.slug', 'jean-dupont');
    }
}

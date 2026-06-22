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
            ->assertJsonStructure([
                'data' => [
                    [
                        'slug',
                        'nom',
                        'nom_complet',
                        'couleur',
                        'logo_url',
                        'position',
                    ],
                ],
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

    public function test_deputy_votes_returns_paginated_votes_sorted_by_scrutin_date_desc(): void
    {
        $response = $this->getJson('/api/deputies/jean-dupont/votes');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.scrutin.numero', 101)
            ->assertJsonPath('data.1.scrutin.numero', 100)
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

    public function test_scrutin_show_returns_single_scrutin_resource(): void
    {
        $response = $this->getJson('/api/scrutins/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

        $response
            ->assertOk()
            ->assertJsonPath('data.id', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')
            ->assertJsonPath('data.numero', 100)
            ->assertJsonPath('data.titre', 'Loi Climat')
            ->assertJsonPath('data.dossier.titre', 'Projet de loi Climat');
    }

    public function test_scrutin_votes_returns_paginated_votes_with_deputy_resource(): void
    {
        $response = $this->getJson('/api/scrutins/aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa/votes');

        $response
            ->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.deputy.slug', 'jean-dupont')
            ->assertJsonPath('data.1.deputy.slug', 'marie-durand')
            ->assertJsonStructure([
                'data' => [
                    [
                        'position',
                        'delegated',
                        'deputy' => ['slug', 'nom', 'prenom'],
                    ],
                ],
                'links',
                'meta',
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
}

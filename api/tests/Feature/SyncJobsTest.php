<?php

namespace Tests\Feature;

use App\Jobs\SyncDeputiesJob;
use App\Jobs\SyncGroupsJob;
use App\Jobs\SyncScrutinsJob;
use App\Jobs\SyncVotesJob;
use App\Jobs\UpdateDeputiesJob;
use App\Jobs\UpdateGroupsJob;
use App\Jobs\ImportScrutinsJob;
use App\Jobs\ImportVotesJob;
use App\Jobs\RecalculateStatisticsJob;
use App\Jobs\UpdateSystemStatusJob;
use App\Jobs\CreateSystemEventJob;
use App\Services\Clair\ClairApiClient;
use App\Services\Scrutins\ImportanceScoringService;
use App\Services\Sync\SyncStateService;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Mockery;
use RuntimeException;
use Tests\TestCase;

class SyncJobsTest extends TestCase
{
    protected function setUp(): void
    {
        parent::setUp();

        putenv('VOTECLAIR_LOG_CHANNEL=stderr');
        $_ENV['VOTECLAIR_LOG_CHANNEL'] = 'stderr';
        putenv('CLAIR_API_THROTTLE_MS=0');
        $_ENV['CLAIR_API_THROTTLE_MS'] = '0';
        putenv('CLAIR_SYNC_BATCH_SIZE=100');
        $_ENV['CLAIR_SYNC_BATCH_SIZE'] = '100';

        $this->resetSchema();
        $this->createSchema();
    }

    public function test_sync_command_dispatches_expected_job_chain(): void
    {
        Bus::fake();

        $this->artisan('voteclair:sync')
            ->expectsOutput('Synchronization chain dispatched.')
            ->assertSuccessful();

        Bus::assertChained([
            UpdateGroupsJob::class,
            UpdateDeputiesJob::class,
            ImportScrutinsJob::class,
            ImportVotesJob::class,
            RecalculateStatisticsJob::class,
            UpdateSystemStatusJob::class,
            CreateSystemEventJob::class,
        ]);
    }

    public function test_sync_command_logs_start_message_on_voteclair_channel(): void
    {
        Bus::fake();

        $logger = Mockery::mock();
        $logger->shouldReceive('info')
            ->once()
            ->with('Sync started');

        Log::shouldReceive('channel')
            ->once()
            ->with('voteclair')
            ->andReturn($logger);

        $this->artisan('voteclair:sync')->assertSuccessful();
    }

    public function test_schedule_registers_hourly_sync_command(): void
    {
        Artisan::call('schedule:list');
        $output = Artisan::output();

        $this->assertStringContainsString('voteclair:sync', $output);
        $this->assertMatchesRegularExpression('/0\s+\*\s+\*\s+\*\s+\*/', $output);
    }

    public function test_sync_status_command_displays_never_when_state_is_missing(): void
    {
        $this->artisan('voteclair:sync-status')
            ->expectsOutput('Groups sync :')
            ->expectsOutput('never')
            ->expectsOutput('Deputies sync :')
            ->expectsOutput('never')
            ->expectsOutput('Scrutins sync :')
            ->expectsOutput('never')
            ->expectsOutput('Votes sync :')
            ->expectsOutput('never')
            ->assertSuccessful();
    }

    public function test_sync_groups_job_is_idempotent_and_seeds_institutions(): void
    {
        Http::fake([
            '*/api/v1/groupes*' => Http::sequence()
                ->push([
                    [
                        'id' => 'g-1',
                        'slug' => 'liot',
                        'nom' => 'LIOT',
                        'nomComplet' => 'LIOT initial',
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
                ], 200)
                ->push([
                    [
                        'id' => 'g-1',
                        'slug' => 'liot',
                        'nom' => 'LIOT mis a jour',
                        'nomComplet' => 'LIOT complet',
                        'couleur' => '#654321',
                        'logoUrl' => null,
                        'position' => 'centre',
                        'ordre' => 4,
                        'actif' => true,
                        'chambre' => 'assemblee',
                        'statsMembresActifs' => 22,
                        'statsPresenceMoyenne' => 47,
                        'statsPresenceSolennelMoyenne' => 61,
                        'statsLoyauteMoyenne' => 78,
                        'statsCohesion' => 71,
                        'statsParticipation' => 101,
                        'statsVotesPour' => 31,
                        'statsVotesContre' => 20,
                        'statsVotesAbstention' => 10,
                        'statsVotesAbsent' => 0,
                        'statsCalculatedAt' => '2026-06-21T00:00:00.000Z',
                        'sourceId' => 'POX',
                    ],
                ], 200),
        ]);

        $job = new SyncGroupsJob;
        $client = app(ClairApiClient::class);
        $state = app(SyncStateService::class);

        $job->handle($client, $state);
        $state->set('last_groups_sync', '2026-06-20T12:00:00Z');
        $job->handle($client, $state);

        $this->assertDatabaseCount('institutions', 3);
        $this->assertDatabaseCount('groups', 1);
        $this->assertDatabaseHas('groups', [
            'id' => 'g-1',
            'nom' => 'LIOT mis a jour',
            'nom_complet' => 'LIOT complet',
            'couleur' => '#654321',
            'stats_membres_actifs' => 22,
        ]);
        $this->assertNotNull($state->get('last_groups_sync'));
    }

    public function test_sync_groups_job_logs_progress_context_on_voteclair_channel(): void
    {
        Http::fake([
            '*/api/v1/groupes*' => Http::response([
                [
                    'id' => 'g-1',
                    'slug' => 'liot',
                    'nom' => 'LIOT',
                    'nomComplet' => 'LIOT',
                    'couleur' => '#123456',
                    'position' => 'centre',
                    'ordre' => 4,
                    'actif' => true,
                    'chambre' => 'assemblee',
                ],
            ], 200),
        ]);

        $logger = Mockery::mock();
        $logger->shouldReceive('info')
            ->once()
            ->with('Sync groups started', Mockery::subset(['chamber' => 'assemblee']));
        $logger->shouldReceive('info')
            ->once()
            ->with('Sync groups page completed', Mockery::on(function (array $context): bool {
                return ($context['chamber'] ?? null) === 'assemblee'
                    && ($context['page'] ?? null) === 1
                    && ($context['rows'] ?? null) === 1
                    && ($context['processed'] ?? null) === 1;
            }));
        $logger->shouldReceive('info')
            ->once()
            ->with('Sync groups completed', Mockery::subset([
                'chamber' => 'assemblee',
                'processed' => 1,
            ]));

        Log::shouldReceive('channel')
            ->times(3)
            ->with('voteclair')
            ->andReturn($logger);

        (new SyncGroupsJob)->handle(app(ClairApiClient::class), app(SyncStateService::class));
    }

    public function test_sync_deputies_job_upserts_deputies_and_circonscriptions(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();

        Http::fake([
            '*/api/v1/deputes*' => Http::sequence()
                ->push([
                    [
                        'id' => 'dep-1',
                        'groupeId' => 'g-1',
                        'circonscription' => [
                            'id' => 'cir-1',
                            'departement' => '75',
                            'departementName' => 'Paris',
                            'numero' => 1,
                            'nom' => 'Paris 1',
                        ],
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
                ], 200)
                ->push([
                    [
                        'id' => 'dep-1',
                        'groupeId' => 'g-1',
                        'circonscription' => [
                            'id' => 'cir-1',
                            'departement' => '75',
                            'departementName' => 'Paris',
                            'numero' => 1,
                            'nom' => 'Paris 1',
                        ],
                        'sourceId' => '841495',
                        'slug' => 'audrey-abadie-amiel',
                        'nom' => 'Abadie-Amiel',
                        'prenom' => 'Audrey',
                        'profession' => 'Avocate',
                        'photoUrl' => null,
                        'twitter' => '@audrey',
                        'email' => 'audrey@example.com',
                        'actif' => true,
                        'statsPresence' => 8,
                        'statsPresenceSolennel' => 40,
                        'statsLoyaute' => 88,
                        'statsParticipation' => 530,
                        'statsInterventions' => 13,
                        'statsAmendements' => 153,
                        'statsAmendementsAdoptes' => 58,
                        'statsQuestions' => 4,
                        'resumeIA' => 'Resume 2',
                        'parcoursIA' => 'Parcours 2',
                        'positionsClesIA' => 'Positions 2',
                        'faitsNotablesIA' => 'Faits 2',
                    ],
                ], 200),
        ]);

        $job = new SyncDeputiesJob;
        $client = app(ClairApiClient::class);
        $state = app(SyncStateService::class);

        $job->handle($client, $state);
        $job->handle($client, $state);

        $this->assertDatabaseCount('circonscriptions', 1);
        $this->assertDatabaseCount('deputies', 1);
        $this->assertDatabaseHas('deputies', [
            'id' => 'dep-1',
            'profession' => 'Avocate',
            'twitter' => '@audrey',
            'stats_presence' => 8,
            'stats_questions' => 4,
        ]);
    }

    public function test_sync_deputies_job_skips_rows_with_missing_group_or_source_id(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();

        Http::fake([
            '*/api/v1/deputes*' => Http::response([
                [
                    'id' => 'dep-skip-group',
                    'groupeId' => 'g-missing',
                    'sourceId' => '111',
                    'slug' => 'missing-group',
                    'nom' => 'Missing',
                    'prenom' => 'Group',
                ],
                [
                    'id' => 'dep-skip-source',
                    'groupeId' => 'g-1',
                    'sourceId' => null,
                    'slug' => 'missing-source',
                    'nom' => 'Missing',
                    'prenom' => 'Source',
                ],
                [
                    'id' => 'dep-ok',
                    'groupeId' => 'g-1',
                    'sourceId' => '841495',
                    'slug' => 'audrey-abadie-amiel',
                    'nom' => 'Abadie-Amiel',
                    'prenom' => 'Audrey',
                ],
            ], 200),
        ]);

        (new SyncDeputiesJob)->handle(app(ClairApiClient::class), app(SyncStateService::class));

        $this->assertDatabaseCount('deputies', 1);
        $this->assertDatabaseHas('deputies', [
            'id' => 'dep-ok',
            'slug' => 'audrey-abadie-amiel',
            'source_id' => '841495',
        ]);
    }

    public function test_sync_scrutins_job_normalizes_sort_and_is_idempotent(): void
    {
        $this->seedInstitutions();

        Http::fake([
            '*/api/v1/scrutins*' => Http::sequence()
                ->push([
                    [
                        'id' => 'scr-1',
                        'numero' => 7407,
                        'chambre' => 'assemblee',
                        'date' => '2026-06-16T00:00:00.000Z',
                        'updatedAt' => '2026-06-16T00:00:00.000Z',
                        'titre' => 'Scrutin test',
                        'sort' => 'adopte',
                        'sourceUrl' => 'https://www.assemblee-nationale.fr/dyn/17/scrutins/VTANR5L17V7407',
                        'nombreVotants' => 10,
                        'nombrePour' => 6,
                        'nombreContre' => 3,
                        'nombreAbstention' => 1,
                    ],
                    [
                        'id' => 'scr-2',
                        'numero' => 7408,
                        'chambre' => 'assemblee',
                        'date' => '2026-06-17T00:00:00.000Z',
                        'updatedAt' => '2026-06-17T00:00:00.000Z',
                        'titre' => 'Scrutin sans sort reconnu',
                        'sort' => 'retire',
                    ],
                ], 200)
                ->push([
                    [
                        'id' => 'scr-1',
                        'numero' => 7407,
                        'chambre' => 'assemblee',
                        'date' => '2026-06-16T00:00:00.000Z',
                        'updatedAt' => '2026-06-18T00:00:00.000Z',
                        'titre' => 'Scrutin test (maj)',
                        'sort' => 'REJETE',
                        'sourceUrl' => 'https://www.assemblee-nationale.fr/dyn/17/scrutins/VTANR5L17V7407',
                        'nombreVotants' => 12,
                        'nombrePour' => 4,
                        'nombreContre' => 7,
                        'nombreAbstention' => 1,
                    ],
                    [
                        'id' => 'scr-2',
                        'numero' => 7408,
                        'chambre' => 'assemblee',
                        'date' => '2026-06-17T00:00:00.000Z',
                        'updatedAt' => '2026-06-17T00:00:00.000Z',
                        'titre' => 'Scrutin sans sort reconnu',
                        'sort' => 'retire',
                    ],
                ], 200),
        ]);

        $job = new SyncScrutinsJob;
        $client = app(ClairApiClient::class);
        $state = app(SyncStateService::class);
        $importanceScoringService = app(ImportanceScoringService::class);

        $job->handle($client, $state, $importanceScoringService);
        $state->set('last_scrutins_sync', '2026-06-17T12:00:00Z');
        $job->handle($client, $state, $importanceScoringService);

        $this->assertDatabaseCount('scrutins', 2);
        $this->assertDatabaseHas('scrutins', [
            'id' => 'scr-1',
            'titre' => 'Scrutin test (maj)',
            'sort' => 'REJETE',
            'nombre_votants' => 12,
            'source_url' => 'https://www.assemblee-nationale.fr/dyn/17/scrutins/7407',
        ]);
        $this->assertDatabaseHas('scrutins', [
            'id' => 'scr-2',
            'sort' => null,
        ]);
    }

    public function test_sync_votes_job_upserts_without_creating_duplicates(): void
    {
        $this->seedScrutin();
        $this->seedDeputy();

        putenv('CLAIR_SYNC_VOTES_LIMIT=1');
        $_ENV['CLAIR_SYNC_VOTES_LIMIT'] = '1';

        Http::fake([
            '*/api/v1/scrutins/7407' => Http::sequence()
                ->push([
                    'data' => [
                        'id' => 'scr-1',
                        'numero' => 7407,
                        'votesByPosition' => [
                            'pour' => [
                                ['parlementaire' => ['slug' => 'audrey-abadie-amiel']],
                            ],
                        ],
                    ],
                ], 200)
                ->push([
                    'data' => [
                        'id' => 'scr-1',
                        'numero' => 7407,
                        'votesByPosition' => [
                            'contre' => [
                                ['parlementaire' => ['slug' => 'audrey-abadie-amiel']],
                            ],
                        ],
                    ],
                ], 200),
        ]);

        $job = new SyncVotesJob;
        $client = app(ClairApiClient::class);
        $state = app(SyncStateService::class);

        $job->handle($client, $state);
        DB::table('sync_states')->where('key', 'last_votes_sync')->delete();
        $job->handle($client, $state);

        $this->assertDatabaseCount('votes', 1);
        $this->assertDatabaseHas('votes', [
            'scrutin_id' => 'scr-1',
            'deputy_id' => 'dep-1',
            'position' => 'CONTRE',
        ]);
    }

    public function test_sync_votes_job_falls_back_to_ventilation_votes_payload(): void
    {
        $this->seedScrutin();
        $this->seedDeputy();

        putenv('CLAIR_SYNC_VOTES_LIMIT=1');
        $_ENV['CLAIR_SYNC_VOTES_LIMIT'] = '1';

        Http::fake([
            '*/api/v1/scrutins/7407' => Http::response([
                'data' => [
                    'id' => 'scr-1',
                    'numero' => 7407,
                    'sourceData' => [
                        'ventilationVotes' => [
                            'organe' => [
                                'groupes' => [
                                    'groupe' => [
                                        [
                                            'vote' => [
                                                'decompteNominatif' => [
                                                    'abstentions' => [
                                                        'votant' => [
                                                            [
                                                                'acteurRef' => 'PA841495',
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
        ]);

        (new SyncVotesJob)->handle(app(ClairApiClient::class), app(SyncStateService::class));

        $this->assertDatabaseCount('votes', 1);
        $this->assertDatabaseHas('votes', [
            'scrutin_id' => 'scr-1',
            'deputy_id' => 'dep-1',
            'position' => 'ABSTENTION',
        ]);
    }

    public function test_sync_votes_job_processes_latest_scrutin_numbers_first(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();
        $this->seedDeputy();

        DB::table('scrutins')->insert([
            [
                'id' => 'scr-10',
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'numero' => 10,
                'date' => '2026-06-10 00:00:00',
                'titre' => 'S10',
                'sort' => 'REJETE',
                'nombre_votants' => 0,
                'nombre_pour' => 0,
                'nombre_contre' => 0,
                'nombre_abstention' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'id' => 'scr-20',
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'numero' => 20,
                'date' => '2026-06-20 00:00:00',
                'titre' => 'S20',
                'sort' => 'REJETE',
                'nombre_votants' => 0,
                'nombre_pour' => 0,
                'nombre_contre' => 0,
                'nombre_abstention' => 0,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        Http::fake([
            '*/api/v1/scrutins/20' => Http::response([
                'data' => [
                    'id' => 'scr-20',
                    'numero' => 20,
                    'votesByPosition' => [
                        'pour' => [
                            ['parlementaire' => ['slug' => 'audrey-abadie-amiel']],
                        ],
                    ],
                ],
            ], 200),
            '*/api/v1/scrutins/10' => Http::response(['data' => []], 200),
        ]);

        (new SyncVotesJob)->handle(app(ClairApiClient::class), app(SyncStateService::class));

        $recorded = Http::recorded();
        $this->assertGreaterThanOrEqual(2, $recorded->count());
        $firstUrl = $recorded->first()[0]->url();
        $secondUrl = $recorded->get(1)[0]->url();
        $this->assertStringContainsString('/api/v1/scrutins/20', $firstUrl);
        $this->assertStringContainsString('/api/v1/scrutins/10', $secondUrl);

        Http::assertSent(function ($request): bool {
            return str_contains($request->url(), '/api/v1/scrutins/20');
        });
        Http::assertSent(function ($request): bool {
            return str_contains($request->url(), '/api/v1/scrutins/10');
        });

        $this->assertDatabaseCount('votes', 1);
        $this->assertDatabaseHas('votes', [
            'scrutin_id' => 'scr-20',
            'deputy_id' => 'dep-1',
            'position' => 'POUR',
        ]);
        $this->assertNotNull(app(SyncStateService::class)->get('last_votes_sync'));
    }

    public function test_sync_state_is_not_updated_when_job_fails(): void
    {
        putenv('CLAIR_API_MAX_ATTEMPTS=1');
        $_ENV['CLAIR_API_MAX_ATTEMPTS'] = '1';
        putenv('CLAIR_API_BACKOFF_MS=0');
        $_ENV['CLAIR_API_BACKOFF_MS'] = '0';

        Http::fake([
            '*/api/v1/groupes*' => Http::response(['message' => 'Server error'], 500),
        ]);

        $state = app(SyncStateService::class);

        try {
            (new SyncGroupsJob)->handle(app(ClairApiClient::class), $state);
            $this->fail('Expected a RuntimeException to be thrown.');
        } catch (RuntimeException) {
            $this->assertNull($state->get('last_groups_sync'));
        }
    }

    public function test_clair_api_client_get_updated_votes_only_fetches_newer_scrutins(): void
    {
        putenv('CLAIR_API_THROTTLE_MS=0');
        $_ENV['CLAIR_API_THROTTLE_MS'] = '0';
        putenv('CLAIR_API_INCREMENTAL_RECENT_PAGES=2');
        $_ENV['CLAIR_API_INCREMENTAL_RECENT_PAGES'] = '2';

        Http::fake([
            '*/api/v1/scrutins*' => Http::response([
                [
                    'id' => 'scr-old',
                    'numero' => 100,
                    'date' => '2026-06-10T00:00:00.000Z',
                ],
                [
                    'id' => 'scr-new',
                    'numero' => 101,
                    'date' => '2026-06-20T00:00:00.000Z',
                ],
            ], 200),
            '*/api/v1/scrutins/101' => Http::response([
                'data' => [
                    'id' => 'scr-new',
                    'numero' => 101,
                    'votesByPosition' => [],
                ],
            ], 200),
        ]);

        $pages = iterator_to_array(app(ClairApiClient::class)->getUpdatedVotes(new \DateTimeImmutable('2026-06-15T00:00:00Z')));

        Http::assertSent(function ($request): bool {
            return str_contains($request->url(), '/api/v1/scrutins/101');
        });
        Http::assertNotSent(function ($request): bool {
            return str_contains($request->url(), '/api/v1/scrutins/100');
        });
        $this->assertCount(1, $pages);
    }

    public function test_sync_groups_job_incremental_filters_by_updated_at(): void
    {
        $state = app(SyncStateService::class);
        $state->set('last_groups_sync', '2026-06-15T00:00:00Z');

        Http::fake([
            '*/api/v1/groupes*' => Http::response([
                [
                    'id' => 'g-old',
                    'slug' => 'old-group',
                    'nom' => 'Old Group',
                    'nomComplet' => 'Old Group',
                    'couleur' => '#111111',
                    'position' => 'centre',
                    'ordre' => 1,
                    'actif' => true,
                    'chambre' => 'assemblee',
                    'sourceId' => 'PO-OLD',
                    'updatedAt' => '2026-06-10T00:00:00.000Z',
                ],
                [
                    'id' => 'g-new',
                    'slug' => 'new-group',
                    'nom' => 'New Group',
                    'nomComplet' => 'New Group',
                    'couleur' => '#222222',
                    'position' => 'centre',
                    'ordre' => 2,
                    'actif' => true,
                    'chambre' => 'assemblee',
                    'sourceId' => 'PO-NEW',
                    'updatedAt' => '2026-06-20T00:00:00.000Z',
                ],
            ], 200),
        ]);

        (new SyncGroupsJob)->handle(app(ClairApiClient::class), $state);

        $this->assertDatabaseCount('groups', 1);
        $this->assertDatabaseHas('groups', [
            'id' => 'g-new',
            'slug' => 'new-group',
        ]);
        $this->assertDatabaseMissing('groups', [
            'id' => 'g-old',
        ]);
    }

    public function test_sync_deputies_job_incremental_filters_by_source_updated_at(): void
    {
        $this->seedInstitutions();
        $this->seedGroup();

        $state = app(SyncStateService::class);
        $state->set('last_deputies_sync', '2026-06-15T00:00:00Z');

        Http::fake([
            '*/api/v1/deputes*' => Http::response([
                [
                    'id' => 'dep-old',
                    'groupeId' => 'g-1',
                    'sourceId' => '800001',
                    'slug' => 'deputy-old',
                    'nom' => 'Old',
                    'prenom' => 'Deputy',
                    'sourceUpdatedAt' => '2026-06-10T00:00:00.000Z',
                ],
                [
                    'id' => 'dep-new',
                    'groupeId' => 'g-1',
                    'sourceId' => '800002',
                    'slug' => 'deputy-new',
                    'nom' => 'New',
                    'prenom' => 'Deputy',
                    'sourceUpdatedAt' => '2026-06-20T00:00:00.000Z',
                ],
            ], 200),
        ]);

        (new SyncDeputiesJob)->handle(app(ClairApiClient::class), $state);

        $this->assertDatabaseCount('deputies', 1);
        $this->assertDatabaseHas('deputies', [
            'id' => 'dep-new',
            'slug' => 'deputy-new',
            'source_id' => '800002',
        ]);
        $this->assertDatabaseMissing('deputies', [
            'id' => 'dep-old',
        ]);
    }

    public function test_sync_scrutins_job_incremental_filters_by_date_when_updated_at_is_missing(): void
    {
        $this->seedInstitutions();

        $state = app(SyncStateService::class);
        $state->set('last_scrutins_sync', '2026-06-15T00:00:00Z');

        Http::fake([
            '*/api/v1/scrutins*' => Http::response([
                [
                    'id' => 'scr-old',
                    'numero' => 8001,
                    'chambre' => 'assemblee',
                    'date' => '2026-06-10T00:00:00.000Z',
                    'titre' => 'Old scrutin',
                    'sort' => 'adopte',
                ],
                [
                    'id' => 'scr-new',
                    'numero' => 8002,
                    'chambre' => 'assemblee',
                    'date' => '2026-06-20T00:00:00.000Z',
                    'titre' => 'New scrutin',
                    'sort' => 'rejete',
                ],
            ], 200),
        ]);

        (new SyncScrutinsJob)->handle(
            app(ClairApiClient::class),
            $state,
            app(ImportanceScoringService::class),
        );

        $this->assertDatabaseCount('scrutins', 1);
        $this->assertDatabaseHas('scrutins', [
            'id' => 'scr-new',
            'numero' => 8002,
        ]);
        $this->assertDatabaseMissing('scrutins', [
            'id' => 'scr-old',
        ]);
    }

    public function test_sync_scrutins_state_is_not_updated_when_job_fails(): void
    {
        putenv('CLAIR_API_MAX_ATTEMPTS=1');
        $_ENV['CLAIR_API_MAX_ATTEMPTS'] = '1';
        putenv('CLAIR_API_BACKOFF_MS=0');
        $_ENV['CLAIR_API_BACKOFF_MS'] = '0';

        Http::fake([
            '*/api/v1/scrutins*' => Http::response(['message' => 'Server error'], 500),
        ]);

        $state = app(SyncStateService::class);

        try {
            (new SyncScrutinsJob)->handle(
                app(ClairApiClient::class),
                $state,
                app(ImportanceScoringService::class),
            );
            $this->fail('Expected a RuntimeException to be thrown.');
        } catch (RuntimeException) {
            $this->assertNull($state->get('last_scrutins_sync'));
        }
    }

    public function test_sync_votes_state_is_not_updated_when_job_fails(): void
    {
        $this->seedScrutin();
        $this->seedDeputy();

        putenv('CLAIR_API_MAX_ATTEMPTS=1');
        $_ENV['CLAIR_API_MAX_ATTEMPTS'] = '1';
        putenv('CLAIR_API_BACKOFF_MS=0');
        $_ENV['CLAIR_API_BACKOFF_MS'] = '0';

        Http::fake([
            '*/api/v1/scrutins/7407' => Http::response(['message' => 'Server error'], 500),
        ]);

        $state = app(SyncStateService::class);

        try {
            (new SyncVotesJob)->handle(app(ClairApiClient::class), $state);
            $this->fail('Expected a RuntimeException to be thrown.');
        } catch (RuntimeException) {
            $this->assertNull($state->get('last_votes_sync'));
        }
    }

    public function test_clair_api_client_retries_rate_limited_requests(): void
    {
        putenv('CLAIR_API_MAX_ATTEMPTS=2');
        $_ENV['CLAIR_API_MAX_ATTEMPTS'] = '2';
        putenv('CLAIR_API_BACKOFF_MS=0');
        $_ENV['CLAIR_API_BACKOFF_MS'] = '0';
        putenv('CLAIR_API_THROTTLE_MS=0');
        $_ENV['CLAIR_API_THROTTLE_MS'] = '0';

        Http::fake([
            '*/api/v1/scrutins*' => Http::sequence()
                ->push([], 429, ['Retry-After' => '0'])
                ->push([
                    [
                        'id' => 'scr-1',
                        'numero' => 7407,
                        'chambre' => 'assemblee',
                        'date' => '2026-06-16T00:00:00.000Z',
                        'titre' => 'Scrutin test',
                        'sort' => 'ADOPTE',
                    ],
                ], 200),
        ]);

        $pages = iterator_to_array(app(ClairApiClient::class)->getScrutins());

        Http::assertSentCount(2);
        $this->assertCount(1, $pages);
        $this->assertSame('scr-1', $pages[1][0]['id']);
        $this->assertSame(7407, $pages[1][0]['numero']);
    }

    public function test_clair_api_client_throws_on_non_retryable_error(): void
    {
        putenv('CLAIR_API_MAX_ATTEMPTS=3');
        $_ENV['CLAIR_API_MAX_ATTEMPTS'] = '3';
        putenv('CLAIR_API_THROTTLE_MS=0');
        $_ENV['CLAIR_API_THROTTLE_MS'] = '0';

        Http::fake([
            '*/api/v1/groupes*' => Http::response(['message' => 'Not found'], 404),
        ]);

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('status 404');

        iterator_to_array(app(ClairApiClient::class)->getGroups());
    }

    public function test_clair_api_client_stops_on_repeated_page_signature(): void
    {
        putenv('CLAIR_API_THROTTLE_MS=0');
        $_ENV['CLAIR_API_THROTTLE_MS'] = '0';

        Http::fake([
            '*/api/v1/groupes*' => Http::sequence()
                ->push([
                    'data' => [
                        ['id' => 'g-1', 'slug' => 'liot', 'nom' => 'LIOT', 'chambre' => 'assemblee'],
                    ],
                    'links' => ['next' => 'next-page'],
                ], 200)
                ->push([
                    'data' => [
                        ['id' => 'g-1', 'slug' => 'liot', 'nom' => 'LIOT', 'chambre' => 'assemblee'],
                    ],
                    'links' => ['next' => 'next-page'],
                ], 200),
        ]);

        $pages = iterator_to_array(app(ClairApiClient::class)->getGroups());

        Http::assertSentCount(2);
        $this->assertCount(1, $pages);
        $this->assertSame('g-1', $pages[1][0]['id']);
    }

    private function resetSchema(): void
    {
        Schema::disableForeignKeyConstraints();

        foreach (['system_events', 'system_status', 'votes', 'postal_codes', 'scrutins', 'deputies', 'circonscriptions', 'groups', 'institutions', 'sync_states'] as $table) {
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
            $table->integer('importance_score')->default(0);
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

        Schema::create('sync_states', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->string('key', 100)->unique();
            $table->text('value')->nullable();
            $table->timestamps();
        });

        Schema::create('system_status', function (Blueprint $table) {
            $table->id();
            $table->string('api_version', 50)->nullable();
            $table->string('clair_data_version', 100)->nullable();
            $table->string('database_status', 20)->default('unknown');
            $table->string('redis_status', 20)->default('unknown');
            $table->string('queue_status', 20)->default('unknown');
            $table->unsignedInteger('queue_pending_jobs')->default(0);
            $table->unsignedInteger('queue_failed_jobs')->default(0);
            $table->timestamp('last_successful_sync_at')->nullable();
            $table->timestamp('last_failed_sync_at')->nullable();
            $table->string('last_sync_status', 20)->default('idle');
            $table->unsignedBigInteger('last_sync_duration_ms')->nullable();
            $table->unsignedInteger('last_scrutins_imported')->default(0);
            $table->unsignedInteger('last_votes_imported')->default(0);
            $table->unsignedInteger('last_deputies_updated')->default(0);
            $table->unsignedInteger('last_groups_updated')->default(0);
            $table->timestamps();
        });

        Schema::create('system_events', function (Blueprint $table) {
            $table->id();
            $table->string('type', 100)->index();
            $table->string('level', 20)->default('info')->index();
            $table->text('message');
            $table->json('context')->nullable();
            $table->unsignedBigInteger('duration_ms')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->index('created_at');
        });
    }

    private function seedInstitutions(): void
    {
        $this->seedInstitution('11111111-1111-1111-1111-111111111111', 'assemblee-nationale');
    }

    private function seedInstitution(string $id, string $slug): void
    {
        DB::table('institutions')->updateOrInsert(
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
        DB::table('groups')->updateOrInsert(
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

    private function seedScrutin(): void
    {
        $this->seedInstitutions();

        DB::table('scrutins')->updateOrInsert(
            ['id' => 'scr-1'],
            [
                'institution_id' => '11111111-1111-1111-1111-111111111111',
                'numero' => 7407,
                'date' => '2026-06-16 00:00:00',
                'titre' => 'Scrutin test',
                'sort' => 'REJETE',
                'importance_score' => 0,
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

        DB::table('deputies')->updateOrInsert(
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

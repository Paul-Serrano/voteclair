<?php

namespace App\Services\Sync;

use App\Jobs\CreateSystemEventJob;
use App\Jobs\ImportScrutinsJob;
use App\Jobs\ImportVotesJob;
use App\Jobs\RecalculateStatisticsJob;
use App\Jobs\UpdateDeputiesJob;
use App\Jobs\UpdateGroupsJob;
use App\Jobs\UpdateSystemStatusJob;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Str;
use Throwable;

class SyncManager
{
    public function __construct(
        private readonly SyncRunStateService $syncRunStateService,
        private readonly SystemStatusService $systemStatusService,
    ) {}

    public function start(): string
    {
        $runId = (string) Str::uuid();
        $startedAt = now();

        $this->syncRunStateService->init($runId, $startedAt);
        $this->systemStatusService->markSyncRunning($runId, $startedAt);

        CreateSystemEventJob::dispatch(
            type: 'sync.started',
            level: 'info',
            message: 'Synchronization started',
            context: [
                'run_id' => $runId,
                'started_at' => $startedAt->toIso8601String(),
            ],
            runId: $runId,
            includeRunSnapshot: false,
            clearRunState: false,
        );

        Bus::chain([
            new UpdateGroupsJob($runId),
            new UpdateDeputiesJob($runId),
            new ImportScrutinsJob($runId),
            new ImportVotesJob($runId),
            new RecalculateStatisticsJob($runId),
            new UpdateSystemStatusJob($runId, 'success'),
            new CreateSystemEventJob(
                type: 'sync.finished',
                level: 'info',
                message: 'Synchronization completed',
                context: ['run_id' => $runId],
                runId: $runId,
                includeRunSnapshot: true,
                clearRunState: true,
            ),
        ])
            ->catch(function (Throwable $exception) use ($runId): void {
                $syncRunStateService = app(SyncRunStateService::class);
                $syncRunStateService->markFailed($runId, [
                    'exception_class' => $exception::class,
                    'exception_message' => $exception->getMessage(),
                ]);

                UpdateSystemStatusJob::dispatchSync($runId, 'failed');

                CreateSystemEventJob::dispatchSync(
                    type: 'sync.failed',
                    level: 'error',
                    message: 'Synchronization failed',
                    context: [
                        'run_id' => $runId,
                        'exception_class' => $exception::class,
                        'exception_message' => $exception->getMessage(),
                    ],
                    runId: $runId,
                    includeRunSnapshot: true,
                    clearRunState: true,
                );
            })
            ->dispatch();

        return $runId;
    }
}

<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use App\Services\Scrutins\ImportanceScoringService;
use App\Services\Sync\ScrutinSyncService;
use App\Services\Sync\SyncRunStateService;
use App\Services\Sync\SyncStateService;

class SyncScrutinsJob extends BaseSyncJob
{
    public function handle(
        ClairApiClient $client,
        SyncStateService $syncStateService,
        ImportanceScoringService $importanceScoringService,
        ?SyncRunStateService $syncRunStateService = null,
        ?ScrutinSyncService $scrutinSyncService = null,
    ): void {
        $scrutinSyncService ??= app(ScrutinSyncService::class);
        $syncRunStateService ??= app(SyncRunStateService::class);

        $result = $scrutinSyncService->sync();

        if ($this->syncRunId() !== null) {
            $syncRunStateService->mergeMetrics($this->syncRunId(), [
                'scrutins_imported' => (int) ($result['processed'] ?? 0),
            ]);
        }
    }
}

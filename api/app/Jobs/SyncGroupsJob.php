<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use App\Services\Sync\GroupSyncService;
use App\Services\Sync\SyncStateService;
use App\Services\Sync\SyncRunStateService;

class SyncGroupsJob extends BaseSyncJob
{
    public function handle(
        ClairApiClient $client,
        SyncStateService $syncStateService,
        ?SyncRunStateService $syncRunStateService = null,
        ?GroupSyncService $groupSyncService = null,
    ): void
    {
        $groupSyncService ??= app(GroupSyncService::class);
        $syncRunStateService ??= app(SyncRunStateService::class);

        $result = $groupSyncService->sync();

        if ($this->syncRunId() !== null) {
            $syncRunStateService->mergeMetrics($this->syncRunId(), [
                'groups_updated' => (int) ($result['processed'] ?? 0),
            ]);
        }
    }
}

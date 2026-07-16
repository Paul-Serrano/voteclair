<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use App\Services\Sync\DeputySyncService;
use App\Services\Sync\SyncStateService;
use App\Services\Sync\SyncRunStateService;

class SyncDeputiesJob extends BaseSyncJob
{
    public function handle(
        ClairApiClient $client,
        SyncStateService $syncStateService,
        ?SyncRunStateService $syncRunStateService = null,
        ?DeputySyncService $deputySyncService = null,
    ): void
    {
        $deputySyncService ??= app(DeputySyncService::class);
        $syncRunStateService ??= app(SyncRunStateService::class);

        $result = $deputySyncService->sync();

        if ($this->syncRunId() !== null) {
            $syncRunStateService->mergeMetrics($this->syncRunId(), [
                'deputies_updated' => (int) ($result['processed'] ?? 0),
            ]);
        }
    }
}

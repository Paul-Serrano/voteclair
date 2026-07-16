<?php

namespace App\Jobs;

use App\Services\Clair\ClairApiClient;
use App\Services\Sync\SyncStateService;
use App\Services\Sync\SyncRunStateService;
use App\Services\Sync\VoteSyncService;

class SyncVotesJob extends BaseSyncJob
{
    public function handle(
        ClairApiClient $client,
        SyncStateService $syncStateService,
        ?SyncRunStateService $syncRunStateService = null,
        ?VoteSyncService $voteSyncService = null,
    ): void
    {
        $voteSyncService ??= app(VoteSyncService::class);
        $syncRunStateService ??= app(SyncRunStateService::class);

        $result = $voteSyncService->sync();

        if ($this->syncRunId() !== null) {
            $syncRunStateService->mergeMetrics($this->syncRunId(), [
                'votes_imported' => (int) ($result['processed'] ?? 0),
            ]);
        }
    }
}

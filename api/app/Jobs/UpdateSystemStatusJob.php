<?php

namespace App\Jobs;

use App\Services\Sync\SyncRunStateService;
use App\Services\Sync\SystemStatusService;

class UpdateSystemStatusJob extends BaseSyncJob
{
    public function __construct(
        ?string $syncRunId = null,
        private readonly string $status = 'success',
    ) {
        parent::__construct($syncRunId);
    }

    public function handle(SystemStatusService $systemStatusService, SyncRunStateService $syncRunStateService): void
    {
        if ($this->syncRunId() === null) {
            return;
        }

        if ($this->status === 'success') {
            $syncRunStateService->markFinished($this->syncRunId());
        }

        $systemStatusService->applyRunOutcome($this->syncRunId(), $this->status, $syncRunStateService);
    }
}

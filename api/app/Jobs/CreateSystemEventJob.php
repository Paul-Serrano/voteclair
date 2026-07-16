<?php

namespace App\Jobs;

use App\Services\Sync\SyncRunStateService;
use App\Services\Sync\SystemEventService;

class CreateSystemEventJob extends BaseSyncJob
{
    /**
     * @param  array<string, mixed>  $context
     */
    public function __construct(
        private readonly string $type,
        private readonly string $level,
        private readonly string $message,
        private readonly array $context = [],
        private readonly ?int $durationMs = null,
        ?string $runId = null,
        private readonly bool $includeRunSnapshot = false,
        private readonly bool $clearRunState = false,
    ) {
        parent::__construct($runId);
    }

    public function handle(SystemEventService $systemEventService, SyncRunStateService $syncRunStateService): void
    {
        $context = $this->context;
        $durationMs = $this->durationMs;

        if ($this->syncRunId() !== null && $this->includeRunSnapshot) {
            $run = $syncRunStateService->get($this->syncRunId());
            $context['run'] = $run;

            if ($durationMs === null && isset($run['duration_ms'])) {
                $durationMs = (int) $run['duration_ms'];
            }
        }

        $systemEventService->record(
            type: $this->type,
            level: $this->level,
            message: $this->message,
            context: $context,
            durationMs: $durationMs,
        );

        if ($this->syncRunId() !== null && $this->clearRunState) {
            $syncRunStateService->clear($this->syncRunId());
        }
    }
}

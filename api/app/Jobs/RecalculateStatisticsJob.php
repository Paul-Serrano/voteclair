<?php

namespace App\Jobs;

use App\Services\Sync\StatisticsService;
use App\Services\Sync\SyncRunStateService;
use Illuminate\Support\Facades\Log;

class RecalculateStatisticsJob extends BaseSyncJob
{
    public function handle(StatisticsService $statisticsService, SyncRunStateService $syncRunStateService): void
    {
        $startedAt = microtime(true);

        try {
            $result = $statisticsService->recalculateImportance();

            if ($this->syncRunId() !== null) {
                $syncRunStateService->mergeMetrics($this->syncRunId(), [
                    'statistics_updated' => (int) ($result['updated'] ?? 0),
                ]);
            }

            Log::channel('voteclair')->info('Statistics recalculated', [
                'processed' => (int) ($result['processed'] ?? 0),
                'updated' => (int) ($result['updated'] ?? 0),
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
            ]);
        } catch (\Throwable $exception) {
            Log::channel('voteclair')->error('Statistics recalculation failed', [
                'exception_class' => $exception::class,
                'exception_message' => $exception->getMessage(),
                'duration_ms' => (int) round((microtime(true) - $startedAt) * 1000),
            ]);

            throw $exception;
        }
    }
}

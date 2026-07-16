<?php

namespace App\Console\Commands;

use App\Jobs\CreateSystemEventJob;
use App\Services\Sync\StatisticsService;
use Illuminate\Console\Command;

class RecalculateImportanceCommand extends Command
{
    protected $signature = 'voteclair:recalculate-importance {--chunk=200 : Batch size for recalculation}';

    protected $description = 'Recalculate importance_score for all scrutins';

    public function handle(StatisticsService $statisticsService): int
    {
        $chunk = max(1, (int) $this->option('chunk'));
        $startedAt = microtime(true);
        $result = $statisticsService->recalculateImportance($chunk);

        $durationMs = (int) round((microtime(true) - $startedAt) * 1000);

        CreateSystemEventJob::dispatchSync(
            type: 'stats.recalculated',
            level: 'info',
            message: 'Statistics recalculated',
            context: [
                'processed' => (int) ($result['processed'] ?? 0),
                'updated' => (int) ($result['updated'] ?? 0),
            ],
            durationMs: $durationMs,
        );

        $this->info(sprintf(
            'Importance recalculated. Processed: %d, Updated: %d',
            (int) ($result['processed'] ?? 0),
            (int) ($result['updated'] ?? 0),
        ));

        return self::SUCCESS;
    }
}

<?php

namespace App\Console\Commands;

use App\Services\Sync\SyncManager;
use App\Services\Sync\SystemStatusService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class SyncParliamentDataCommand extends Command
{
    protected $signature = 'voteclair:sync';

    protected $description = 'Orchestrate VoteClair synchronization with Redis locking';

    public function handle(SyncManager $syncManager, SystemStatusService $systemStatusService): int
    {
        $lock = Cache::lock('voteclair:sync:dispatch', 300);

        if (! $lock->get()) {
            $this->warn('Synchronization is already being started by another process.');

            return self::FAILURE;
        }

        try {
            if ($systemStatusService->isSyncRunning()) {
                $this->warn('A synchronization is already running.');

                return self::FAILURE;
            }

            Log::channel('voteclair')->info('Sync started');

            $runId = $syncManager->start();

            $this->info('Synchronization chain dispatched.');
            $this->line('Run ID: '.$runId);

            return self::SUCCESS;
        } finally {
            $lock->release();
        }
    }
}

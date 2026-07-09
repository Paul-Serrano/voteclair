<?php

namespace App\Console\Commands;

use App\Jobs\SyncDeputiesJob;
use App\Jobs\SyncGroupsJob;
use App\Jobs\SyncScrutinsJob;
use App\Jobs\SyncVotesJob;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Bus;
use Illuminate\Support\Facades\Log;
use Throwable;

class SyncParliamentDataCommand extends Command
{
    protected $signature = 'voteclair:sync';

    protected $description = 'Dispatch the automatic VoteClair parliament synchronization chain';

    public function handle(): int
    {
        Log::channel('voteclair')->info('Sync started');

        Bus::chain([
            new SyncGroupsJob,
            new SyncDeputiesJob,
            new SyncScrutinsJob,
            new SyncVotesJob,
        ])
            ->catch(function (Throwable $exception): void {
                Log::channel('voteclair')->error('Sync failed', [
                    'exception_class' => $exception::class,
                    'exception_message' => $exception->getMessage(),
                ]);
            })
            ->dispatch();

        $this->info('Synchronization chain dispatched.');

        return self::SUCCESS;
    }
}

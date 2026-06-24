<?php

namespace App\Console\Commands;

use App\Services\Sync\SyncStateService;
use Illuminate\Console\Command;

class SyncStatusCommand extends Command
{
    protected $signature = 'voteclair:sync-status';

    protected $description = 'Display the current incremental synchronization state';

    public function handle(SyncStateService $syncStateService): int
    {
        $this->line('Groups sync :');
        $this->line($this->formatValue($syncStateService->get('last_groups_sync')));
        $this->newLine();

        $this->line('Deputies sync :');
        $this->line($this->formatValue($syncStateService->get('last_deputies_sync')));
        $this->newLine();

        $this->line('Scrutins sync :');
        $this->line($this->formatValue($syncStateService->get('last_scrutins_sync')));
        $this->newLine();

        $this->line('Votes sync :');
        $this->line($this->formatValue($syncStateService->get('last_votes_sync')));

        return self::SUCCESS;
    }

    private function formatValue(?string $value): string
    {
        return $value ?? 'never';
    }
}

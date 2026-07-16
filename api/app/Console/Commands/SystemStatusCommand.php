<?php

namespace App\Console\Commands;

use App\Services\Sync\SystemStatusService;
use Illuminate\Console\Command;

class SystemStatusCommand extends Command
{
    protected $signature = 'voteclair:status';

    protected $description = 'Display current production status for API, infra and synchronization';

    public function handle(SystemStatusService $systemStatusService): int
    {
        $status = $systemStatusService->diagnosticSummary();

        $rows = [
            ['API', (string) ($status['api'] ?? 'unknown')],
            ['PostgreSQL', (string) ($status['postgresql'] ?? 'unknown')],
            ['Redis', (string) ($status['redis'] ?? 'unknown')],
            ['Queue', (string) ($status['queue'] ?? 'unknown')],
            ['Version API', (string) ($status['api_version'] ?? 'unknown')],
            ['Version Clair', (string) ($status['clair_version'] ?? 'unknown')],
            ['Derniere synchronisation', (string) ($status['last_sync'] ?? 'never')],
            ['Statut synchronisation', (string) ($status['last_sync_status'] ?? 'unknown')],
            ['Duree (ms)', (string) ($status['last_sync_duration_ms'] ?? '0')],
            ['Votes importes', (string) ($status['last_votes_imported'] ?? '0')],
            ['Scrutins importes', (string) ($status['last_scrutins_imported'] ?? '0')],
            ['Jobs en attente', (string) ($status['queue_pending_jobs'] ?? '0')],
            ['Jobs echoues', (string) ($status['queue_failed_jobs'] ?? '0')],
        ];

        $this->table(['Indicateur', 'Valeur'], $rows);

        return self::SUCCESS;
    }
}

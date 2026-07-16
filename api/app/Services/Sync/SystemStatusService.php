<?php

namespace App\Services\Sync;

use App\Models\SystemStatus;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\Redis;

class SystemStatusService
{
    public function isSyncRunning(): bool
    {
        return $this->row()->last_sync_status === 'running';
    }

    public function markSyncRunning(string $runId, Carbon $startedAt): void
    {
        $row = $this->row();
        $infra = $this->infraStatus();

        $row->update([
            'api_version' => (string) config('voteclair.version'),
            'clair_data_version' => (string) env('CLAIR_DATA_VERSION', 'unknown'),
            'database_status' => $infra['database_status'],
            'redis_status' => $infra['redis_status'],
            'queue_status' => $infra['queue_status'],
            'queue_pending_jobs' => $infra['queue_pending_jobs'],
            'queue_failed_jobs' => $infra['queue_failed_jobs'],
            'last_sync_status' => 'running',
            'last_sync_duration_ms' => null,
            'updated_at' => $startedAt,
        ]);
    }

    public function applyRunOutcome(string $runId, string $status, SyncRunStateService $runStateService): void
    {
        $row = $this->row();
        $run = $runStateService->get($runId);
        $infra = $this->infraStatus();
        $metrics = is_array($run['metrics'] ?? null) ? $run['metrics'] : [];
        $finishedAt = isset($run['finished_at']) && is_string($run['finished_at'])
            ? Carbon::parse($run['finished_at'])
            : now();

        $payload = [
            'api_version' => (string) config('voteclair.version'),
            'clair_data_version' => (string) env('CLAIR_DATA_VERSION', 'unknown'),
            'database_status' => $infra['database_status'],
            'redis_status' => $infra['redis_status'],
            'queue_status' => $infra['queue_status'],
            'queue_pending_jobs' => $infra['queue_pending_jobs'],
            'queue_failed_jobs' => $infra['queue_failed_jobs'],
            'last_sync_status' => $status,
            'last_sync_duration_ms' => (int) ($run['duration_ms'] ?? 0),
            'last_groups_updated' => (int) ($metrics['groups_updated'] ?? 0),
            'last_deputies_updated' => (int) ($metrics['deputies_updated'] ?? 0),
            'last_scrutins_imported' => (int) ($metrics['scrutins_imported'] ?? 0),
            'last_votes_imported' => (int) ($metrics['votes_imported'] ?? 0),
            'updated_at' => $finishedAt,
        ];

        if ($status === 'success') {
            $payload['last_successful_sync_at'] = $finishedAt;
        }

        if ($status === 'failed') {
            $payload['last_failed_sync_at'] = $finishedAt;
        }

        $row->update($payload);
    }

    /**
     * @return array<string, mixed>
     */
    public function healthPayload(): array
    {
        $row = $this->row();

        return [
            'status' => $this->globalStatus($row),
            'database' => $row->database_status,
            'redis' => $row->redis_status,
            'queue' => $row->queue_status,
            'last_sync' => $row->last_successful_sync_at?->toIso8601String(),
            'sync_status' => $row->last_sync_status,
            'api_version' => $row->api_version,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function diagnosticSummary(): array
    {
        $row = $this->row();

        return [
            'api' => $this->globalStatus($row),
            'postgresql' => $row->database_status,
            'redis' => $row->redis_status,
            'queue' => $row->queue_status,
            'api_version' => $row->api_version,
            'clair_version' => $row->clair_data_version,
            'last_sync' => $row->last_successful_sync_at?->toIso8601String(),
            'last_sync_status' => $row->last_sync_status,
            'last_sync_duration_ms' => $row->last_sync_duration_ms,
            'last_votes_imported' => $row->last_votes_imported,
            'last_scrutins_imported' => $row->last_scrutins_imported,
            'queue_pending_jobs' => $row->queue_pending_jobs,
            'queue_failed_jobs' => $row->queue_failed_jobs,
        ];
    }

    private function row(): SystemStatus
    {
        return SystemStatus::query()->firstOrCreate(
            ['id' => 1],
            [
                'api_version' => (string) config('voteclair.version'),
                'clair_data_version' => (string) env('CLAIR_DATA_VERSION', 'unknown'),
                'database_status' => 'unknown',
                'redis_status' => 'unknown',
                'queue_status' => 'unknown',
                'queue_pending_jobs' => 0,
                'queue_failed_jobs' => 0,
                'last_sync_status' => 'idle',
                'last_sync_duration_ms' => null,
                'last_scrutins_imported' => 0,
                'last_votes_imported' => 0,
                'last_deputies_updated' => 0,
                'last_groups_updated' => 0,
            ],
        );
    }

    /**
     * @return array<string, int|string>
     */
    private function infraStatus(): array
    {
        $databaseStatus = 'ok';
        $redisStatus = 'ok';

        try {
            DB::select('SELECT 1');
        } catch (\Throwable) {
            $databaseStatus = 'error';
        }

        try {
            $ping = Redis::connection()->ping();
            if (! is_string($ping) && ! is_numeric($ping) && ! is_bool($ping)) {
                $redisStatus = 'error';
            }
        } catch (\Throwable) {
            $redisStatus = 'error';
        }

        $pending = $this->queuePendingJobs();
        $failed = $this->queueFailedJobs();
        $queueStatus = ($redisStatus === 'ok') ? 'ok' : 'error';

        return [
            'database_status' => $databaseStatus,
            'redis_status' => $redisStatus,
            'queue_status' => $queueStatus,
            'queue_pending_jobs' => $pending,
            'queue_failed_jobs' => $failed,
        ];
    }

    private function queuePendingJobs(): int
    {
        $queueName = (string) config('queue.connections.redis.queue', 'default');

        try {
            return max(0, (int) Queue::connection('redis')->size($queueName));
        } catch (\Throwable) {
            return 0;
        }
    }

    private function queueFailedJobs(): int
    {
        try {
            return max(0, (int) DB::table('failed_jobs')->count());
        } catch (\Throwable) {
            return 0;
        }
    }

    private function globalStatus(SystemStatus $row): string
    {
        return ($row->database_status === 'ok' && $row->redis_status === 'ok' && $row->queue_status === 'ok')
            ? 'ok'
            : 'degraded';
    }
}

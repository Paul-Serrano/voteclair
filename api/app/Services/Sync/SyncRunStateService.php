<?php

namespace App\Services\Sync;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;

class SyncRunStateService
{
    private const TTL_SECONDS = 86400;

    public function init(string $runId, Carbon $startedAt): void
    {
        Cache::put($this->key($runId), [
            'run_id' => $runId,
            'status' => 'running',
            'started_at' => $startedAt->toIso8601String(),
            'finished_at' => null,
            'duration_ms' => null,
            'metrics' => [
                'groups_updated' => 0,
                'deputies_updated' => 0,
                'scrutins_imported' => 0,
                'votes_imported' => 0,
                'statistics_updated' => 0,
            ],
            'error' => null,
        ], self::TTL_SECONDS);
    }

    /**
     * @param  array<string, int>  $metrics
     */
    public function mergeMetrics(string $runId, array $metrics): void
    {
        $state = $this->get($runId);

        foreach ($metrics as $key => $value) {
            $state['metrics'][$key] = max(0, (int) ($value ?? 0));
        }

        Cache::put($this->key($runId), $state, self::TTL_SECONDS);
    }

    /**
     * @param  array<string, mixed>  $error
     */
    public function markFailed(string $runId, array $error): void
    {
        $state = $this->get($runId);
        $startedAt = Carbon::parse((string) $state['started_at']);
        $finishedAt = now();

        $state['status'] = 'failed';
        $state['finished_at'] = $finishedAt->toIso8601String();
        $state['duration_ms'] = $startedAt->diffInMilliseconds($finishedAt);
        $state['error'] = $error;

        Cache::put($this->key($runId), $state, self::TTL_SECONDS);
    }

    public function markFinished(string $runId): void
    {
        $state = $this->get($runId);
        $startedAt = Carbon::parse((string) $state['started_at']);
        $finishedAt = now();

        $state['status'] = 'success';
        $state['finished_at'] = $finishedAt->toIso8601String();
        $state['duration_ms'] = $startedAt->diffInMilliseconds($finishedAt);

        Cache::put($this->key($runId), $state, self::TTL_SECONDS);
    }

    /**
     * @return array<string, mixed>
     */
    public function get(string $runId): array
    {
        $state = Cache::get($this->key($runId));

        return is_array($state) ? $state : [
            'run_id' => $runId,
            'status' => 'unknown',
            'started_at' => null,
            'finished_at' => null,
            'duration_ms' => null,
            'metrics' => [],
            'error' => null,
        ];
    }

    public function clear(string $runId): void
    {
        Cache::forget($this->key($runId));
    }

    private function key(string $runId): string
    {
        return 'voteclair:sync:run:'.$runId;
    }
}

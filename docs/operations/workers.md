# Workers and Scheduler

## Render Background Worker

Create one Render Background Worker that uses the same environment variables as the web service.

Command:

```bash
php artisan queue:work \
  --queue=default \
  --tries=3 \
  --sleep=3 \
  --timeout=120
```

This worker executes all heavy synchronization jobs on Redis.

## Render Cron Job

Create one Render Cron Job:

- Schedule: `* * * * *`
- Command: `php artisan schedule:run`

Laravel scheduler orchestrates synchronization, statistics and maintenance tasks.

## Scheduler Strategy

Configured scheduled commands:

- Hourly: `voteclair:sync`
- Nightly: `voteclair:recalculate-importance`
- Weekly: `queue:prune-failed --hours=168`
- Weekly: `voteclair:verify-integrity`

All business processing remains in services. Commands only orchestrate.

## Queue Redis

- Queue connection: Redis
- Queue name: `default`
- Locking: Redis-only via `Cache::lock()`
- No SQL lock is used.

## SyncManager Flow

`voteclair:sync` acquires a Redis lock and delegates orchestration to `SyncManager`.

Execution chain:

1. `UpdateGroupsJob`
2. `UpdateDeputiesJob`
3. `ImportScrutinsJob`
4. `ImportVotesJob`
5. `RecalculateStatisticsJob`
6. `UpdateSystemStatusJob`
7. `CreateSystemEventJob`

On failure, status and events are finalized with `sync.failed`.

## system_status

`system_status` stores one canonical line of runtime health and latest synchronization metrics.

Used by:

- `GET /health`
- `php artisan voteclair:status`
- future admin dashboard and uptime probes

`GET /health` performs no runtime checks and reads only this table.

## system_events

`system_events` stores technical event history with:

- `type`
- `level`
- `message`
- `context` (JSONB on PostgreSQL)
- `duration_ms`

Typical events:

- `sync.started`
- `sync.finished`
- `sync.failed`
- `stats.recalculated`
- `scheduler.started`
- `scheduler.failed`
- `database.error`
- `redis.error`

## Monitoring Strategy

- UptimeRobot targets `GET /health`.
- `voteclair:status` gives an operational snapshot.
- `system_events` provides technical auditability.
- Queue pressure is tracked with pending and failed job counters in `system_status`.

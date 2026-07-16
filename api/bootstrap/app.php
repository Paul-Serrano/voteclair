<?php

use App\Jobs\CreateSystemEventJob;
use App\Services\Sync\SystemStatusService;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: function (): void {
            Route::get('/health', function () {
                return response()->json(app(SystemStatusService::class)->healthPayload());
            });
        },
    )
    ->withMiddleware(function (Middleware $middleware): void {
        //
    })
    ->withSchedule(function (Schedule $schedule): void {
        $sync = $schedule->command('voteclair:sync')
            ->hourly()
            ->withoutOverlapping();

        $sync->before(function (): void {
            CreateSystemEventJob::dispatch(
                type: 'scheduler.started',
                level: 'info',
                message: 'Scheduler starting voteclair:sync',
                context: ['command' => 'voteclair:sync'],
            );
        });

        $sync->onFailure(function (): void {
            CreateSystemEventJob::dispatch(
                type: 'scheduler.failed',
                level: 'error',
                message: 'Scheduler failed voteclair:sync',
                context: ['command' => 'voteclair:sync'],
            );
        });

        $schedule->command('voteclair:recalculate-importance')->dailyAt('02:30');
        $schedule->command('queue:prune-failed --hours=168')->weeklyOn(0, '04:00');
        $schedule->command('voteclair:verify-integrity')->weeklyOn(0, '04:30');
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );
    })->create();

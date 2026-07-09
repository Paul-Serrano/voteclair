<?php

declare(strict_types=1);
use Illuminate\Contracts\Console\Kernel;

require __DIR__.'/../vendor/autoload.php';

$app = require __DIR__.'/../bootstrap/app.php';
$kernel = $app->make(Kernel::class);
$kernel->bootstrap();

$chunkSize = max(1, (int) ($_ENV['VOTE_BACKFILL_CHUNK'] ?? 4));
$maxChunks = max(1, (int) ($_ENV['VOTE_BACKFILL_MAX_CHUNKS'] ?? 100000));
$sleepMs = max(0, (int) ($_ENV['VOTE_BACKFILL_SLEEP_MS'] ?? 1000));

$started = microtime(true);
$totalProcessed = 0;
$chunkIndex = 0;

while ($chunkIndex < $maxChunks) {
    $chunkIndex++;

    $numeros = DB::table('scrutins')
        ->leftJoin('votes', 'votes.scrutin_id', '=', 'scrutins.id')
        ->whereNull('votes.id')
        ->orderByDesc('scrutins.numero')
        ->limit($chunkSize)
        ->pluck('scrutins.numero')
        ->map(fn ($v) => (int) $v)
        ->all();

    if (empty($numeros)) {
        break;
    }

    $args = ['--chambre' => 'assemblee'];
    foreach ($numeros as $numero) {
        $args['--numero'][] = $numero;
    }

    Artisan::call('clair:import:votes', $args);

    $totalProcessed += count($numeros);
    $votesCount = DB::table('votes')->count();
    $remaining = DB::table('scrutins')
        ->leftJoin('votes', 'votes.scrutin_id', '=', 'scrutins.id')
        ->whereNull('votes.id')
        ->count('scrutins.id');

    $elapsed = (int) (microtime(true) - $started);

    echo Artisan::output();
    echo '[backfill-votes] chunk='.$chunkIndex
        .' processed_scrutins='.$totalProcessed
        .' votes='.$votesCount
        .' remaining_scrutins_without_votes='.$remaining
        .' elapsed_s='.$elapsed
        .PHP_EOL;

    if ($sleepMs > 0) {
        usleep($sleepMs * 1000);
    }
}

echo '[backfill-votes] done total_processed_scrutins='.$totalProcessed.PHP_EOL;

<?php

namespace App\Console\Commands;

use App\Models\Scrutin;
use App\Services\Scrutins\ImportanceScoringService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class RecalculateImportanceCommand extends Command
{
    protected $signature = 'voteclair:recalculate-importance {--chunk=200 : Batch size for recalculation}';

    protected $description = 'Recalculate importance_score for all scrutins';

    public function handle(ImportanceScoringService $importanceScoringService): int
    {
        $chunk = max(1, (int) $this->option('chunk'));
        $processed = 0;
        $updated = 0;

        Scrutin::query()
            ->select([
                'id',
                'titre',
                'demandeur_texte',
                'nombre_pour',
                'nombre_contre',
                'importance_score',
            ])
            ->orderBy('id')
            ->chunk($chunk, function ($scrutins) use ($importanceScoringService, &$processed, &$updated): void {
                foreach ($scrutins as $scrutin) {
                    $processed++;
                    $score = $importanceScoringService->calculate($scrutin);

                    if ((int) $scrutin->importance_score === $score) {
                        continue;
                    }

                    DB::table('scrutins')
                        ->where('id', $scrutin->id)
                        ->update([
                            'importance_score' => $score,
                            'updated_at' => now(),
                        ]);
                    $updated++;
                }
            });

        Cache::forget('scrutins:important:5');
        Cache::forget('scrutins:important:20');

        $this->info(sprintf('Importance recalculated. Processed: %d, Updated: %d', $processed, $updated));

        return self::SUCCESS;
    }
}

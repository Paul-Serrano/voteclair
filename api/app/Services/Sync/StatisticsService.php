<?php

namespace App\Services\Sync;

use App\Models\Scrutin;
use App\Services\Scrutins\ImportanceScoringService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class StatisticsService
{
    public function __construct(
        private readonly ImportanceScoringService $importanceScoringService,
    ) {}

    /**
     * @return array{processed:int,updated:int}
     */
    public function recalculateImportance(int $chunk = 200): array
    {
        $chunk = max(1, $chunk);
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
            ->chunk($chunk, function ($scrutins) use (&$processed, &$updated): void {
                foreach ($scrutins as $scrutin) {
                    $processed++;
                    $score = $this->importanceScoringService->calculate($scrutin);

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

        return [
            'processed' => $processed,
            'updated' => $updated,
        ];
    }
}

<?php

namespace App\Services\Deputies;

use App\Models\Deputy;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class DeputyComparisonService
{
    /**
     * @return array<string, mixed>
     */
    public function compare(Deputy $left, Deputy $right): array
    {
        $orderedDeputies = [$left, $right];
        usort($orderedDeputies, static fn (Deputy $a, Deputy $b): int => strcmp($a->slug, $b->slug));

        /** @var Deputy $canonicalLeft */
        $canonicalLeft = $orderedDeputies[0];
        /** @var Deputy $canonicalRight */
        $canonicalRight = $orderedDeputies[1];

        $cacheKey = sprintf('deputies:compare:v3:%s:%s', $canonicalLeft->slug, $canonicalRight->slug);

        $canonicalPayload = Cache::remember($cacheKey, now()->addHours(6), function () use ($canonicalLeft, $canonicalRight): array {
            $baseQuery = DB::table('votes as left_votes')
                ->join('votes as right_votes', function ($join): void {
                    $join->on('left_votes.scrutin_id', '=', 'right_votes.scrutin_id');
                })
                ->where('left_votes.deputy_id', $canonicalLeft->id)
                ->where('right_votes.deputy_id', $canonicalRight->id);

            $statsRow = (clone $baseQuery)
                ->selectRaw('COUNT(*) as common_votes')
                ->selectRaw("SUM(CASE WHEN UPPER(CAST(left_votes.position AS text)) = UPPER(CAST(right_votes.position AS text)) AND UPPER(CAST(left_votes.position AS text)) IN ('POUR', 'CONTRE', 'ABSTENTION', 'NON_VOTANT') THEN 1 ELSE 0 END) as agreements")
                ->selectRaw("SUM(CASE WHEN (UPPER(CAST(left_votes.position AS text)) = 'POUR' AND UPPER(CAST(right_votes.position AS text)) IN ('CONTRE', 'ABSTENTION')) OR (UPPER(CAST(left_votes.position AS text)) = 'CONTRE' AND UPPER(CAST(right_votes.position AS text)) IN ('POUR', 'ABSTENTION')) OR (UPPER(CAST(left_votes.position AS text)) = 'ABSTENTION' AND UPPER(CAST(right_votes.position AS text)) IN ('POUR', 'CONTRE')) THEN 1 ELSE 0 END) as disagreements")
                ->selectRaw("SUM(CASE WHEN UPPER(CAST(left_votes.position AS text)) = 'ABSTENTION' AND UPPER(CAST(right_votes.position AS text)) = 'ABSTENTION' THEN 1 ELSE 0 END) as same_abstentions")
                ->first();

            $commonVotes = (int) ($statsRow->common_votes ?? 0);
            $agreements = (int) ($statsRow->agreements ?? 0);
            $disagreements = (int) ($statsRow->disagreements ?? 0);
            $sameAbstentions = (int) ($statsRow->same_abstentions ?? 0);

            $recentCommon = (clone $baseQuery)
                ->join('scrutins', 'scrutins.id', '=', 'left_votes.scrutin_id')
                ->select([
                    'scrutins.id as scrutin_id',
                    'scrutins.numero',
                    'scrutins.titre',
                    'scrutins.date',
                    'scrutins.sort as scrutin_sort',
                    'scrutins.importance_score',
                    'left_votes.position as left_vote',
                    'right_votes.position as right_vote',
                ])
                ->orderByDesc('scrutins.date')
                ->orderByDesc('scrutins.numero')
                ->limit(100)
                ->get();

            $recentCommonVotes = [];
            $differences = [];
            foreach ($recentCommon as $row) {
                $leftVote = strtoupper((string) ($row->left_vote ?? ''));
                $rightVote = strtoupper((string) ($row->right_vote ?? ''));

                $entry = [
                    'scrutin_id' => (string) $row->scrutin_id,
                    'numero' => (int) ($row->numero ?? 0),
                    'titre' => (string) ($row->titre ?? ''),
                    'date' => (string) ($row->date ?? ''),
                    'scrutin_sort' => (string) ($row->scrutin_sort ?? ''),
                    'importance_score' => (int) ($row->importance_score ?? 0),
                    'left_vote' => $leftVote,
                    'right_vote' => $rightVote,
                ];

                $recentCommonVotes[] = $entry;

                if ($leftVote === $rightVote) {
                    continue;
                }

                $differences[] = $entry;
            }

            return [
                'left' => [
                    'slug' => $canonicalLeft->slug,
                    'nom' => $canonicalLeft->nom,
                    'prenom' => $canonicalLeft->prenom,
                ],
                'right' => [
                    'slug' => $canonicalRight->slug,
                    'nom' => $canonicalRight->nom,
                    'prenom' => $canonicalRight->prenom,
                ],
                'stats' => [
                    'common_votes' => $commonVotes,
                    'agreements' => $agreements,
                    'disagreements' => $disagreements,
                    'same_abstentions' => $sameAbstentions,
                    'agreement_rate' => $commonVotes > 0
                        ? round(($agreements / $commonVotes) * 100, 1)
                        : 0.0,
                ],
                'recent_common_votes' => $recentCommonVotes,
                'recent_differences' => $differences,
            ];
        });

        if ($left->slug === $canonicalLeft->slug && $right->slug === $canonicalRight->slug) {
            return $canonicalPayload;
        }

        return $this->swapSides($canonicalPayload);
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    private function swapSides(array $payload): array
    {
        $left = (array) ($payload['left'] ?? []);
        $right = (array) ($payload['right'] ?? []);

        $swapVotes = static function ($rows): array {
            return collect($rows ?? [])
                ->map(function ($item): array {
                    $row = (array) $item;

                    return [
                        ...$row,
                        'left_vote' => (string) ($row['right_vote'] ?? ''),
                        'right_vote' => (string) ($row['left_vote'] ?? ''),
                    ];
                })
                ->values()
                ->all();
        };

        return [
            ...$payload,
            'left' => $right,
            'right' => $left,
            'recent_common_votes' => $swapVotes($payload['recent_common_votes'] ?? []),
            'recent_differences' => $swapVotes($payload['recent_differences'] ?? []),
        ];
    }
}

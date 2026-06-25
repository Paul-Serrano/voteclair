<?php

namespace App\Services\Deputies;

use App\Models\Deputy;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class DeputyPoliticalProfileService
{
    /**
     * @return array<string, mixed>
     */
    public function build(Deputy $deputy): array
    {
        $cacheKey = sprintf('deputies:political-profile:v1:%s', $deputy->slug);

        return Cache::remember($cacheKey, now()->addHours(6), function () use ($deputy): array {
            $voteCounts = DB::table('votes')
                ->where('deputy_id', $deputy->id)
                ->select('position', DB::raw('COUNT(*) as total'))
                ->groupBy('position')
                ->get();

            $priority = [
                'POUR' => 1,
                'CONTRE' => 2,
                'ABSTENTION' => 3,
                'NON_VOTANT' => 4,
            ];

            $normalizedVoteCounts = [];
            foreach ($voteCounts as $row) {
                $position = strtoupper((string) ($row->position ?? ''));
                $normalizedVoteCounts[] = [
                    'position' => $position,
                    'count' => (int) ($row->total ?? 0),
                    'priority' => $priority[$position] ?? 999,
                ];
            }

            usort($normalizedVoteCounts, static function (array $a, array $b): int {
                if ($a['count'] !== $b['count']) {
                    return $b['count'] <=> $a['count'];
                }

                return $a['priority'] <=> $b['priority'];
            });

            $mostFrequentVote = null;
            $mostFrequentVoteCount = 0;
            if (! empty($normalizedVoteCounts)) {
                $mostFrequentVote = (string) $normalizedVoteCounts[0]['position'];
                $mostFrequentVoteCount = (int) $normalizedVoteCounts[0]['count'];
            }

            $topTopics = DB::table('votes')
                ->join('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
                ->where('votes.deputy_id', $deputy->id)
                ->selectRaw('COALESCE(scrutins.dossier_titre, scrutins.titre) as label, COUNT(*) as total')
                ->groupByRaw('COALESCE(scrutins.dossier_titre, scrutins.titre)')
                ->orderByDesc('total')
                ->limit(5)
                ->get()
                ->map(static function ($row): array {
                    return [
                        'label' => (string) ($row->label ?? ''),
                        'count' => (int) ($row->total ?? 0),
                    ];
                })
                ->values()
                ->all();

            $deputyVotes = DB::table('votes')
                ->where('deputy_id', $deputy->id)
                ->select('scrutin_id', 'position')
                ->get();

            $deputyVotesByScrutin = [];
            foreach ($deputyVotes as $vote) {
                $scrutinId = (string) ($vote->scrutin_id ?? '');
                if ($scrutinId === '') {
                    continue;
                }
                $deputyVotesByScrutin[$scrutinId] = strtoupper((string) ($vote->position ?? ''));
            }

            $groupMemberIds = DB::table('deputies')
                ->where('groupe_id', $deputy->groupe_id)
                ->where('id', '!=', $deputy->id)
                ->pluck('id')
                ->all();

            $proximityRate = null;
            $proximityVotesCount = 0;

            if (! empty($groupMemberIds) && ! empty($deputyVotesByScrutin)) {
                $groupVotes = DB::table('votes')
                    ->whereIn('deputy_id', $groupMemberIds)
                    ->whereIn('scrutin_id', array_keys($deputyVotesByScrutin))
                    ->select('scrutin_id', 'position')
                    ->get();

                $countsByScrutin = [];
                foreach ($groupVotes as $vote) {
                    $scrutinId = (string) ($vote->scrutin_id ?? '');
                    $position = strtoupper((string) ($vote->position ?? ''));
                    if ($scrutinId === '' || $position === '') {
                        continue;
                    }
                    if (! isset($countsByScrutin[$scrutinId])) {
                        $countsByScrutin[$scrutinId] = [];
                    }
                    if (! isset($countsByScrutin[$scrutinId][$position])) {
                        $countsByScrutin[$scrutinId][$position] = 0;
                    }
                    $countsByScrutin[$scrutinId][$position]++;
                }

                $matches = 0;
                foreach ($countsByScrutin as $scrutinId => $positionCounts) {
                    if (empty($positionCounts) || ! isset($deputyVotesByScrutin[$scrutinId])) {
                        continue;
                    }

                    $max = max($positionCounts);
                    $leaders = array_keys(array_filter(
                        $positionCounts,
                        static fn (int $count): bool => $count === $max
                    ));

                    if (count($leaders) !== 1) {
                        continue;
                    }

                    $majority = $leaders[0];
                    $proximityVotesCount++;
                    if ($deputyVotesByScrutin[$scrutinId] === $majority) {
                        $matches++;
                    }
                }

                if ($proximityVotesCount > 0) {
                    $proximityRate = round(($matches / $proximityVotesCount) * 100, 1);
                }
            }

            return [
                'most_frequent_vote' => $mostFrequentVote,
                'most_frequent_vote_count' => $mostFrequentVoteCount,
                'group_proximity_rate' => $proximityRate,
                'group_proximity_votes_count' => $proximityVotesCount,
                'top_topics' => $topTopics,
                'presence_rate' => $deputy->stats_presence,
                'loyalty_rate' => $deputy->stats_loyaute,
            ];
        });
    }
}

<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeputyComparisonResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $left = (array) ($this->resource['left'] ?? []);
        $right = (array) ($this->resource['right'] ?? []);
        $stats = (array) ($this->resource['stats'] ?? []);

        $normalizeVoteRows = static function ($rows): array {
            return collect($rows ?? [])
            ->map(function ($item): array {
                $row = (array) $item;

                return [
                    'scrutin_id' => (string) ($row['scrutin_id'] ?? ''),
                    'numero' => (int) ($row['numero'] ?? 0),
                    'titre' => (string) ($row['titre'] ?? ''),
                    'date' => (string) ($row['date'] ?? ''),
                    'scrutin_sort' => (string) ($row['scrutin_sort'] ?? ''),
                    'importance_score' => (int) ($row['importance_score'] ?? 0),
                    'left_vote' => (string) ($row['left_vote'] ?? ''),
                    'right_vote' => (string) ($row['right_vote'] ?? ''),
                ];
            })
            ->values()
            ->all();
        };

        $recentCommonVotes = $normalizeVoteRows($this->resource['recent_common_votes'] ?? []);
        $differences = $normalizeVoteRows($this->resource['recent_differences'] ?? []);

        return [
            'left' => [
                'slug' => (string) ($left['slug'] ?? ''),
                'nom' => (string) ($left['nom'] ?? ''),
                'prenom' => (string) ($left['prenom'] ?? ''),
            ],
            'right' => [
                'slug' => (string) ($right['slug'] ?? ''),
                'nom' => (string) ($right['nom'] ?? ''),
                'prenom' => (string) ($right['prenom'] ?? ''),
            ],
            'stats' => [
                'common_votes' => (int) ($stats['common_votes'] ?? 0),
                'agreements' => (int) ($stats['agreements'] ?? 0),
                'disagreements' => (int) ($stats['disagreements'] ?? 0),
                'same_abstentions' => (int) ($stats['same_abstentions'] ?? 0),
                'agreement_rate' => (float) ($stats['agreement_rate'] ?? 0),
            ],
            'recent_common_votes' => $recentCommonVotes,
            'recent_differences' => $differences,
        ];
    }
}

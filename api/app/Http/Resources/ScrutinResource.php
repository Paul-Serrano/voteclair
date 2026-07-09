<?php

namespace App\Http\Resources;

use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ScrutinResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'numero' => $this->numero,
            'date' => $this->date?->toDateString(),
            'titre' => $this->titre,
            'sort' => $this->sort,
            'importance_score' => (int) ($this->importance_score ?? 0),
            'institution' => $this->whenLoaded('institution', fn (): array => [
                'id' => $this->institution->id,
                'slug' => $this->institution->slug,
                'nom' => $this->institution->nom,
                'pays' => $this->institution->pays,
            ]),
            'resume_ia' => $this->resume_ia,
            'demandeur_texte' => $this->demandeur_texte,
            'source_url' => $this->source_url,
            'dossier' => [
                'titre' => $this->dossier_titre,
                'url' => $this->dossier_url,
            ],
            'resultats' => $this->buildResultats(),
            'groupes' => $this->buildGroupStats(),
        ];
    }

    /**
     * @return array<string, int>
     */
    private function buildResultats(): array
    {
        $votes = $this->votePool();

        if ($votes !== null) {
            $deputiesCount = $this->deputiesCount();
            if ($deputiesCount !== null) {
                $pour = $this->countVotesByPosition($votes, 'POUR');
                $contre = $this->countVotesByPosition($votes, 'CONTRE');
                $abstention = $this->countVotesByPosition($votes, 'ABSTENTION');
                $votedDeputies = $votes->pluck('deputy.id')->filter()->unique()->count();
                $nonVotant = max($deputiesCount - $votedDeputies, 0);

                return [
                    'pour' => $pour,
                    'contre' => $contre,
                    'abstention' => $abstention,
                    'non_votant' => $nonVotant,
                    'total' => $pour + $contre + $abstention + $nonVotant,
                ];
            }
        }

        $pour = (int) ($this->nombre_pour ?? 0);
        $contre = (int) ($this->nombre_contre ?? 0);
        $abstention = (int) ($this->nombre_abstention ?? 0);
        $total = (int) ($this->nombre_votants ?? 0);

        return [
            'pour' => $pour,
            'contre' => $contre,
            'abstention' => $abstention,
            'non_votant' => max($total - $pour - $contre - $abstention, 0),
            'total' => $total,
        ];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function buildGroupStats(): array
    {
        $votes = $this->votePool();
        $deputies = $this->institution?->relationLoaded('deputies') && $this->institution->deputies instanceof EloquentCollection
            ? $this->institution->deputies
            : null;

        if ($votes === null || $deputies === null || $deputies->isEmpty()) {
            return [];
        }

        $activeDeputies = $deputies->filter(function ($deputy): bool {
            return (bool) ($deputy->actif ?? true);
        });

        $deputiesByGroup = $activeDeputies->groupBy(function ($deputy): string {
            return $deputy->group?->slug ?? 'groupe-inconnu';
        });

        $votesByGroup = $votes->groupBy(function ($vote): string {
            return $vote->deputy?->group?->slug ?? 'groupe-inconnu';
        });

        return $deputiesByGroup
            ->map(function (EloquentCollection $groupDeputies, string $groupSlug) use ($votesByGroup): array {
                $firstDeputy = $groupDeputies->first();
                $group = $firstDeputy?->group;
                $groupVotes = $votesByGroup->get($groupSlug, new EloquentCollection);
                $votedDeputies = $groupVotes->pluck('deputy.id')->filter()->unique()->count();
                $groupTotal = $groupDeputies->count();

                return [
                    'slug' => $group?->slug ?? 'groupe-inconnu',
                    'nom' => $group?->nom ?? 'Groupe inconnu',
                    'couleur' => $group?->couleur,
                    'pour' => $this->countVotesByPosition($groupVotes, 'POUR'),
                    'contre' => $this->countVotesByPosition($groupVotes, 'CONTRE'),
                    'abstention' => $this->countVotesByPosition($groupVotes, 'ABSTENTION'),
                    'non_votant' => max($groupTotal - $votedDeputies, 0),
                    'total' => $groupTotal,
                ];
            })
            ->sortBy('nom')
            ->values()
            ->all();
    }

    private function votePool(): ?EloquentCollection
    {
        if (! ($this->relationLoaded('votes') && $this->votes instanceof EloquentCollection)) {
            return null;
        }

        return $this->votes
            ->filter(function ($vote): bool {
                return in_array(strtoupper((string) $vote->position), ['POUR', 'CONTRE', 'ABSTENTION'], true);
            })
            ->values();
    }

    private function deputiesCount(): ?int
    {
        $deputies = $this->institution?->relationLoaded('deputies') && $this->institution->deputies instanceof EloquentCollection
            ? $this->institution->deputies
            : null;

        if ($deputies === null) {
            return null;
        }

        return $deputies->filter(function ($deputy): bool {
            return (bool) ($deputy->actif ?? true);
        })->count();
    }

    /**
     * @param  EloquentCollection<int, mixed>  $votes
     */
    private function countVotesByPosition(EloquentCollection $votes, string $position): int
    {
        return $votes->filter(function ($vote) use ($position): bool {
            return strtoupper((string) $vote->position) === $position;
        })->count();
    }
}

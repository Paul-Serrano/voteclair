<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DeputyResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'slug' => $this->slug,
            'nom' => $this->nom,
            'prenom' => $this->prenom,
            'profession' => $this->profession,
            'photo_url' => $this->photo_url,
            'twitter' => $this->twitter,
            'group' => $this->whenLoaded('group', fn (): array => [
                'slug' => $this->group->slug,
                'nom' => $this->group->nom,
                'couleur' => $this->group->couleur,
            ]),
            'circonscription' => $this->whenLoaded('circonscription', fn (): ?array => $this->circonscription ? [
                'nom' => $this->circonscription->nom,
                'departement' => $this->circonscription->departement,
                'departement_name' => $this->circonscription->departement_name,
            ] : null),
            'stats' => [
                'presence' => $this->stats_presence,
                'presence_solennel' => $this->stats_presence_solennel,
                'loyaute' => $this->stats_loyaute,
                'participation' => $this->stats_participation,
                'interventions' => $this->stats_interventions,
                'amendements' => $this->stats_amendements,
                'amendements_adoptes' => $this->stats_amendements_adoptes,
                'questions' => $this->stats_questions,
            ],
            'political_profile' => [
                'most_frequent_vote' => data_get($this->resource, 'political_profile.most_frequent_vote'),
                'most_frequent_vote_count' => (int) (data_get($this->resource, 'political_profile.most_frequent_vote_count') ?? 0),
                'group_proximity_rate' => data_get($this->resource, 'political_profile.group_proximity_rate'),
                'group_proximity_votes_count' => (int) (data_get($this->resource, 'political_profile.group_proximity_votes_count') ?? 0),
                'top_topics' => collect(data_get($this->resource, 'political_profile.top_topics', []))
                    ->map(static fn ($item): array => [
                        'label' => (string) data_get($item, 'label', ''),
                        'count' => (int) data_get($item, 'count', 0),
                    ])
                    ->values()
                    ->all(),
                'presence_rate' => $this->stats_presence,
                'loyalty_rate' => $this->stats_loyaute,
            ],
            'resume_ia' => $this->resume_ia,
            'parcours_ia' => $this->parcours_ia,
            'positions_cles_ia' => $this->positions_cles_ia,
            'faits_notables_ia' => $this->faits_notables_ia,
        ];
    }
}

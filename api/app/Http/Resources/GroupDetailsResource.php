<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupDetailsResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $membersCount = $this->members_count ?? $this->stats_membres_actifs ?? 0;

        return [
            'id' => $this->id,
            'slug' => $this->slug,
            'nom' => $this->nom,
            'nom_complet' => $this->nom_complet,
            'couleur' => $this->couleur,
            'logo_url' => $this->logo_url,
            'position' => $this->position,
            'membres_count' => (int) $membersCount,
            'institution' => $this->whenLoaded('institution', fn (): array => [
                'slug' => $this->institution->slug,
                'nom' => $this->institution->nom,
                'pays' => $this->institution->pays,
            ]),
            'stats' => [
                'presence' => (int) ($this->stats_presence_moyenne ?? 0),
                'presence_solennelle' => (int) ($this->stats_presence_solennel_moyenne ?? 0),
                'loyaute' => (int) ($this->stats_loyaute_moyenne ?? 0),
                'cohesion' => (int) ($this->stats_cohesion ?? 0),
                'participation' => (int) ($this->stats_participation ?? 0),
                'votes_pour' => (int) ($this->stats_votes_pour ?? 0),
                'votes_contre' => (int) ($this->stats_votes_contre ?? 0),
                'votes_abstention' => (int) ($this->stats_votes_abstention ?? 0),
                'votes_absent' => (int) ($this->stats_votes_absent ?? 0),
            ],
        ];
    }
}
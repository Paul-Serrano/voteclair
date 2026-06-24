<?php

namespace App\Http\Resources;

use App\Models\Deputy;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FavoriteActivityResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var Deputy|null $deputy */
        $deputy = $this['deputy'] ?? null;
        /** @var Vote|null $latestVote */
        $latestVote = $this['latest_vote'] ?? null;

        return [
            'deputy' => $deputy === null ? null : [
                'slug' => $deputy->slug,
                'nom' => $deputy->nom,
                'prenom' => $deputy->prenom,
                'photo_url' => $deputy->photo_url,
            ],
            'latest_vote' => $latestVote === null ? null : [
                'id' => $latestVote->id,
                'position' => $latestVote->position,
                'scrutin' => [
                    'id' => $latestVote->scrutin?->id,
                    'titre' => $latestVote->scrutin?->titre,
                    'date' => $latestVote->scrutin?->date?->toIso8601String(),
                ],
            ],
        ];
    }
}

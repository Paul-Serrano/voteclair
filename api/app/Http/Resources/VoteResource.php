<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class VoteResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'position' => $this->position,
            'delegated' => $this->delegated,
            'scrutin' => $this->whenLoaded('scrutin', fn (): array => [
                'id' => $this->scrutin->id,
                'numero' => $this->scrutin->numero,
                'titre' => $this->scrutin->titre,
                'date' => $this->scrutin->date?->toDateString(),
                'sort' => $this->scrutin->sort,
            ]),
            'deputy' => $this->whenLoaded('deputy', fn (): array => [
                'slug' => $this->deputy->slug,
                'nom' => $this->deputy->nom,
                'prenom' => $this->deputy->prenom,
            ]),
        ];
    }
}

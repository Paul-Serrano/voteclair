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
            'group' => $this->whenLoaded('group', fn (): array => [
                'slug' => $this->group->slug,
                'nom' => $this->group->nom,
            ]),
            'circonscription' => $this->whenLoaded('circonscription', fn (): ?array => $this->circonscription ? [
                'nom' => $this->circonscription->nom,
            ] : null),
            'stats' => [
                'presence' => $this->stats_presence,
                'loyaute' => $this->stats_loyaute,
            ],
            'resume_ia' => $this->resume_ia,
        ];
    }
}

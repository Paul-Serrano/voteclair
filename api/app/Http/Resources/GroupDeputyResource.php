<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupDeputyResource extends JsonResource
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
            'photo_url' => $this->photo_url,
            'stats_presence' => $this->stats_presence,
        ];
    }
}
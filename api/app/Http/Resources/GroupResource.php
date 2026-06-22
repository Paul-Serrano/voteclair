<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GroupResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'slug' => $this->slug,
            'nom' => $this->nom,
            'nom_complet' => $this->nom_complet,
            'couleur' => $this->couleur,
            'logo_url' => $this->logo_url,
            'position' => $this->position,
        ];
    }
}

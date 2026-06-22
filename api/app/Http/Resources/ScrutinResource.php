<?php

namespace App\Http\Resources;

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
            'resume_ia' => $this->resume_ia,
            'demandeur_texte' => $this->demandeur_texte,
            'source_url' => $this->source_url,
            'dossier' => [
                'titre' => $this->dossier_titre,
                'url' => $this->dossier_url,
            ],
        ];
    }
}

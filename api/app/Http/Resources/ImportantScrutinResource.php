<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ImportantScrutinResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'numero' => (int) ($this->numero ?? 0),
            'titre' => $this->titre,
            'date_scrutin' => $this->date?->toIso8601String(),
            'importance_score' => (int) ($this->importance_score ?? 0),
            'sort' => $this->sort,
        ];
    }
}

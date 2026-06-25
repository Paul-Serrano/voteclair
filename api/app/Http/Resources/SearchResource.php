<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;

class SearchResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $deputies = Collection::make($this->resource['deputies'] ?? [])
            ->map(function ($deputy): array {
                return [
                    'slug' => $deputy->slug,
                    'nom' => $deputy->nom,
                    'prenom' => $deputy->prenom,
                    'photo_url' => $deputy->photo_url,
                    'group' => $deputy->group?->nom,
                ];
            })
            ->values()
            ->all();

        $groups = Collection::make($this->resource['groups'] ?? [])
            ->map(function ($group): array {
                return [
                    'slug' => $group->slug,
                    'nom' => $group->nom,
                    'couleur' => $group->couleur,
                    'members_count' => (int) ($group->members_count ?? 0),
                ];
            })
            ->values()
            ->all();

        $scrutins = Collection::make($this->resource['scrutins'] ?? [])
            ->map(function ($scrutin): array {
                return [
                    'id' => $scrutin->id,
                    'numero' => (int) ($scrutin->numero ?? 0),
                    'titre' => $scrutin->titre,
                    'date' => $scrutin->date?->toDateString(),
                    'sort' => $scrutin->sort,
                    'importance_score' => (int) ($scrutin->importance_score ?? 0),
                ];
            })
            ->values()
            ->all();

        return [
            'deputies' => $deputies,
            'groups' => $groups,
            'scrutins' => $scrutins,
        ];
    }
}
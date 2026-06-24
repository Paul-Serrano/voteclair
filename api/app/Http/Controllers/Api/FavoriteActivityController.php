<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FavoriteActivityResource;
use App\Models\Deputy;
use App\Models\Vote;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

#[ApiGroup('Favorites', description: 'Activité récente des députés favoris', weight: 45)]
class FavoriteActivityController extends Controller
{
    #[Endpoint(
        operationId: 'favorites.activity',
        title: 'Lister l\'activité récente des favoris',
        description: 'Retourne le dernier vote connu pour chaque député favori.'
    )]
    #[QueryParameter('slugs', 'Slugs de députés séparés par des virgules.', required: false, example: 'nadege-abomangoli,xavier-albertini')]
    #[Response(200, 'Liste des activités récentes des favoris.', type: 'array')]
    public function index(Request $request): AnonymousResourceCollection
    {
        $rawSlugs = trim((string) $request->query('slugs', ''));
        if ($rawSlugs === '') {
            return FavoriteActivityResource::collection(collect());
        }

        $slugs = collect(explode(',', $rawSlugs))
            ->map(fn (string $slug): string => trim($slug))
            ->filter()
            ->unique()
            ->values();

        if ($slugs->isEmpty()) {
            return FavoriteActivityResource::collection(collect());
        }

        $deputies = Deputy::query()
            ->whereIn('slug', $slugs)
            ->get(['id', 'slug', 'nom', 'prenom', 'photo_url'])
            ->keyBy('id');

        if ($deputies->isEmpty()) {
            return FavoriteActivityResource::collection(collect());
        }

        // Preload relations to avoid N+1 while keeping one latest vote per deputy.
        $votes = Vote::query()
            ->select('votes.*')
            ->join('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
            ->whereIn('votes.deputy_id', $deputies->keys())
            ->with([
                'deputy:id,slug,nom,prenom,photo_url',
                'scrutin:id,titre,date',
            ])
            ->orderByDesc('scrutins.date')
            ->orderByDesc('votes.id')
            ->get();

        $items = $votes
            ->unique('deputy_id')
            ->map(function (Vote $vote): array {
                return [
                    'deputy' => $vote->deputy,
                    'latest_vote' => $vote,
                ];
            })
            ->sortByDesc(fn (array $item): int => (int) ($item['latest_vote']->scrutin?->date?->getTimestamp() ?? 0))
            ->values();

        return FavoriteActivityResource::collection($items);
    }
}

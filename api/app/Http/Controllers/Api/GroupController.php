<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\GroupDeputyResource;
use App\Http\Resources\GroupDetailsResource;
use App\Http\Resources\GroupResource;
use App\Models\Deputy;
use App\Models\Group;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\PathParameter;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

#[ApiGroup('Groups', description: 'Groupes parlementaires', weight: 10)]
class GroupController extends Controller
{
    #[Endpoint(
        operationId: 'groups.index',
        title: 'Lister les groupes',
        description: 'Retourne la liste des groupes triés par ordre.'
    )]
    #[Response(200, 'Réponse JSON contenant la liste des groupes.', type: 'array')]
    public function index(): AnonymousResourceCollection
    {
        return GroupResource::collection(
            Group::query()
                ->withCount([
                    'deputies as members_count' => function ($query): void {
                        $query->where('actif', true);
                    },
                ])
                ->orderBy('ordre')
                ->get()
        );
    }

    #[Endpoint(
        operationId: 'groups.show',
        title: 'Afficher un groupe',
        description: 'Retourne le détail d\'un groupe parlementaire à partir de son slug.'
    )]
    #[PathParameter('slug', 'Slug du groupe.', required: true, example: 'lfi-nfp')]
    #[Response(200, 'Détail du groupe.', type: 'array')]
    #[Response(404, 'Groupe introuvable.', type: 'array')]
    public function show(string $slug): GroupDetailsResource
    {
        $group = Group::query()
            ->where('slug', $slug)
            ->with(['institution:id,slug,nom,pays'])
            ->withCount([
                'deputies as members_count' => function ($query): void {
                    $query->where('actif', true);
                },
            ])
            ->firstOrFail();

        return new GroupDetailsResource($group);
    }

    #[Endpoint(
        operationId: 'groups.deputies',
        title: 'Lister les députés d\'un groupe',
        description: 'Retourne la liste paginée des membres actifs d\'un groupe.'
    )]
    #[PathParameter('slug', 'Slug du groupe.', required: true, example: 'lfi-nfp')]
    #[QueryParameter('page', 'Numéro de page de pagination.', required: false, example: 1)]
    #[Response(200, 'Réponse paginée des membres du groupe.', type: 'array')]
    #[Response(404, 'Groupe introuvable.', type: 'array')]
    public function deputies(string $slug): AnonymousResourceCollection
    {
        $group = Group::query()
            ->where('slug', $slug)
            ->firstOrFail(['id']);

        $deputies = Deputy::query()
            ->select(['id', 'slug', 'nom', 'prenom', 'photo_url', 'stats_presence'])
            ->where('groupe_id', $group->id)
            ->where('actif', true)
            ->orderBy('nom')
            ->orderBy('prenom')
            ->paginate();

        return GroupDeputyResource::collection($deputies);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\GroupResource;
use App\Models\Group;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
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
                ->orderBy('ordre')
                ->get()
        );
    }
}

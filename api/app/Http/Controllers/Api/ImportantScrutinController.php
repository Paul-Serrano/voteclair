<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ImportantScrutinResource;
use App\Models\Scrutin;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Illuminate\Support\Facades\Cache;

#[ApiGroup('Scrutins', description: 'Scrutins importants', weight: 31)]
class ImportantScrutinController extends Controller
{
    #[Endpoint(
        operationId: 'scrutins.important',
        title: 'Lister les scrutins importants',
        description: 'Retourne les scrutins triés par score d\'importance décroissant.'
    )]
    #[QueryParameter('limit', 'Nombre maximum de scrutins retournés.', required: false, example: 20)]
    #[Response(200, 'Liste des scrutins importants.', type: 'array')]
    public function index(Request $request): AnonymousResourceCollection
    {
        $limit = (int) $request->query('limit', 20);
        $limit = max(1, min(100, $limit));

        $scrutins = Cache::remember("scrutins:important:{$limit}", 3600, function () use ($limit) {
            return Scrutin::query()
                ->select(['id', 'numero', 'titre', 'date', 'sort', 'importance_score'])
                ->where('importance_score', '>', 0)
                ->orderByDesc('importance_score')
                ->orderByDesc('numero')
                ->limit($limit)
                ->get();
        });

        return ImportantScrutinResource::collection($scrutins);
    }
}

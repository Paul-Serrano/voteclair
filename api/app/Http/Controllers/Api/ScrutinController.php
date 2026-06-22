<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ScrutinCollection;
use App\Http\Resources\ScrutinResource;
use App\Http\Resources\VoteCollection;
use App\Models\Scrutin;
use App\Models\Vote;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\PathParameter;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

#[ApiGroup('Scrutins', description: 'Scrutins et votes associés', weight: 30)]
class ScrutinController extends Controller
{
    #[Endpoint(
        operationId: 'scrutins.index',
        title: 'Lister les scrutins',
        description: 'Retourne une collection paginée de scrutins avec filtres par texte, résultat et plage de dates.'
    )]
    #[QueryParameter('search', 'Filtre texte sur le titre du scrutin.', required: false, example: 'budget')]
    #[QueryParameter('sort', 'Filtre par résultat du scrutin.', required: false, example: 'ADOPTE')]
    #[QueryParameter('from', 'Date de début (YYYY-MM-DD).', required: false, type: 'string', format: 'date', example: '2026-01-01')]
    #[QueryParameter('to', 'Date de fin (YYYY-MM-DD).', required: false, type: 'string', format: 'date', example: '2026-12-31')]
    #[QueryParameter('page', 'Numéro de page de pagination.', required: false, example: 1)]
    #[Response(200, 'Réponse paginée de scrutins.', type: 'array')]
    public function index(Request $request): ScrutinCollection
    {
        $search = trim((string) $request->query('search', ''));
        $sort = trim((string) $request->query('sort', ''));
        $from = trim((string) $request->query('from', ''));
        $to = trim((string) $request->query('to', ''));

        $query = Scrutin::query();

        if ($search !== '') {
            $query->whereRaw('LOWER(titre) LIKE ?', ['%'.Str::lower($search).'%']);
        }

        if (in_array($sort, ['ADOPTE', 'REJETE'], true)) {
            $query->where('sort', $sort);
        }

        if ($from !== '') {
            $query->whereDate('date', '>=', $from);
        }

        if ($to !== '') {
            $query->whereDate('date', '<=', $to);
        }

        $query->latest('date');

        return new ScrutinCollection($query->paginate());
    }

    #[Endpoint(
        operationId: 'scrutins.show',
        title: 'Afficher un scrutin',
        description: 'Retourne le détail d\'un scrutin à partir de son identifiant.'
    )]
    #[PathParameter('scrutin', 'Identifiant du scrutin (UUID).', required: true, example: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')]
    #[Response(200, 'Détail du scrutin.', type: 'array')]
    #[Response(404, 'Scrutin introuvable.', type: 'array')]
    public function show(Scrutin $scrutin): ScrutinResource
    {
        return new ScrutinResource($scrutin);
    }

    #[Endpoint(
        operationId: 'scrutins.votes',
        title: 'Lister les votes d\'un scrutin',
        description: 'Retourne les votes d\'un scrutin avec pagination.'
    )]
    #[PathParameter('scrutin', 'Identifiant du scrutin (UUID).', required: true, example: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa')]
    #[QueryParameter('page', 'Numéro de page de pagination.', required: false, example: 1)]
    #[Response(200, 'Réponse paginée de votes du scrutin.', type: 'array')]
    #[Response(404, 'Scrutin introuvable.', type: 'array')]
    public function votes(Scrutin $scrutin): VoteCollection
    {
        $votes = Vote::query()
            ->where('scrutin_id', $scrutin->id)
            ->with('deputy:id,slug,nom,prenom')
            ->paginate();

        return new VoteCollection($votes);
    }
}

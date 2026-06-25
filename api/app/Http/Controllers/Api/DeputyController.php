<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DeputyCollection;
use App\Http\Resources\DeputyComparisonResource;
use App\Http\Resources\DeputyResource;
use App\Http\Resources\VoteCollection;
use App\Models\Deputy;
use App\Models\Vote;
use App\Services\Deputies\DeputyComparisonService;
use App\Services\Deputies\DeputyPoliticalProfileService;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\PathParameter;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

#[ApiGroup('Deputies', description: 'Députés et leurs votes', weight: 20)]
class DeputyController extends Controller
{
    #[Endpoint(
        operationId: 'deputies.compare',
        title: 'Comparer deux députés',
        description: 'Compare les comportements de vote de deux députés.'
    )]
    #[QueryParameter('left_slug', 'Slug du député A.', required: true, example: 'nadege-abomangoli')]
    #[QueryParameter('right_slug', 'Slug du député B.', required: true, example: 'xavier-albertini')]
    #[Response(200, 'Comparaison de députés.', type: 'object')]
    #[Response(422, 'Paramètres invalides.', type: 'object')]
    public function compare(Request $request, DeputyComparisonService $comparisonService): DeputyComparisonResource
    {
        $validated = $request->validate([
            'left_slug' => ['required', 'string', 'exists:deputies,slug', 'different:right_slug'],
            'right_slug' => ['required', 'string', 'exists:deputies,slug', 'different:left_slug'],
        ]);

        $left = Deputy::query()->where('slug', $validated['left_slug'])->firstOrFail();
        $right = Deputy::query()->where('slug', $validated['right_slug'])->firstOrFail();

        $result = $comparisonService->compare($left, $right);

        return new DeputyComparisonResource($result);
    }

    #[Endpoint(
        operationId: 'deputies.index',
        title: 'Lister les députés',
        description: 'Retourne une collection paginée de députés, filtrable par recherche et groupe.'
    )]
    #[QueryParameter('search', 'Filtre texte sur nom/prénom (insensible à la casse).', required: false, example: 'dupont')]
    #[QueryParameter('group', 'Slug du groupe parlementaire.', required: false, example: 'renaissance')]
    #[QueryParameter('page', 'Numéro de page de pagination.', required: false, example: 1)]
    #[Response(200, 'Réponse paginée de députés.', type: 'array')]
    public function index(Request $request): DeputyCollection
    {
        $search = trim((string) $request->query('search', ''));
        $groupSlug = trim((string) $request->query('group', ''));

        $query = Deputy::query()
            ->with(['group:id,slug,nom,couleur', 'circonscription:id,nom']);

        if ($search !== '') {
            $query->where(function ($q) use ($search): void {
                $needle = '%'.Str::lower($search).'%';
                $q->whereRaw('LOWER(nom) LIKE ?', [$needle])
                    ->orWhereRaw('LOWER(prenom) LIKE ?', [$needle]);
            });
        }

        if ($groupSlug !== '') {
            $query->whereHas('group', function ($q) use ($groupSlug): void {
                $q->where('slug', $groupSlug);
            });
        }

        return new DeputyCollection($query->paginate());
    }

    #[Endpoint(
        operationId: 'deputies.show',
        title: 'Afficher un député',
        description: 'Retourne le détail d\'un député à partir de son slug.'
    )]
    #[PathParameter('deputy', 'Slug du député.', required: true, example: 'jean-dupont')]
    #[Response(200, 'Détail du député.', type: 'array')]
    #[Response(404, 'Député introuvable.', type: 'array')]
    public function show(Deputy $deputy, DeputyPoliticalProfileService $politicalProfileService): DeputyResource
    {
        $deputy->loadMissing(['group:id,slug,nom,couleur', 'circonscription:id,nom,departement,departement_name']);
        $deputy->setAttribute('political_profile', $politicalProfileService->build($deputy));

        return new DeputyResource($deputy);
    }

    #[Endpoint(
        operationId: 'deputies.votes',
        title: 'Lister les votes d\'un député',
        description: 'Retourne les votes d\'un député, triés par numéro de scrutin décroissant.'
    )]
    #[PathParameter('deputy', 'Slug du député.', required: true, example: 'jean-dupont')]
    #[QueryParameter('page', 'Numéro de page de pagination.', required: false, example: 1)]
    #[Response(200, 'Réponse paginée de votes du député.', type: 'array')]
    #[Response(404, 'Député introuvable.', type: 'array')]
    public function votes(Deputy $deputy): VoteCollection
    {
        $query = Vote::query()
            ->select('votes.*')
            ->join('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
            ->where('votes.deputy_id', $deputy->id)
            ->with('scrutin:id,numero,titre,date,sort,importance_score')
            ->orderByDesc('scrutins.numero');

        return new VoteCollection($query->paginate());
    }
}

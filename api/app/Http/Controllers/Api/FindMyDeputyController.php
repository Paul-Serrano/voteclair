<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FindMyDeputyResource;
use App\Services\Deputies\FindMyDeputyService;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;

#[ApiGroup('Deputies', description: 'Députés et leurs votes', weight: 20)]
class FindMyDeputyController extends Controller
{
    #[Endpoint(
        operationId: 'findMyDeputy.index',
        title: 'Trouver mon député',
        description: 'Trouve le ou les députés correspondant à un code postal.'
    )]
    #[QueryParameter('postal_code', 'Code postal à rechercher.', required: true, example: '13008')]
    #[QueryParameter('institution_id', 'Filtre optionnel par institution.', required: false, example: '11111111-1111-1111-1111-111111111111')]
    #[Response(200, 'Résultat de la recherche.', type: 'object')]
    #[Response(404, 'Aucun représentant trouvé.', type: 'object')]
    #[Response(422, 'Paramètres invalides.', type: 'object')]
    public function index(Request $request, FindMyDeputyService $findMyDeputyService): FindMyDeputyResource
    {
        $validated = $request->validate([
            'postal_code' => ['required', 'digits:5'],
            'institution_id' => ['nullable', 'string', 'exists:institutions,id'],
        ]);

        $result = $findMyDeputyService->findByPostalCode(
            $validated['postal_code'],
            $validated['institution_id'] ?? null
        );

        abort_if($result === null, 404, 'Aucun représentant trouvé.');

        return new FindMyDeputyResource($result);
    }
}
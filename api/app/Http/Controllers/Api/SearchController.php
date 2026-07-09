<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\SearchResource;
use App\Models\Deputy;
use App\Models\Group;
use App\Models\Scrutin;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\QueryParameter;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

#[ApiGroup('Search', description: 'Recherche globale députés, groupes et scrutins', weight: 40)]
class SearchController extends Controller
{
    #[Endpoint(
        operationId: 'search.index',
        title: 'Recherche globale',
        description: 'Retourne des résultats catégorisés pour députés, groupes et scrutins.'
    )]
    #[QueryParameter('q', 'Texte recherché.', required: false, example: 'retraites')]
    #[Response(200, 'Résultats de recherche catégorisés.', type: 'array')]
    public function search(Request $request): SearchResource
    {
        $query = trim((string) $request->query('q', ''));
        if ($query === '') {
            return new SearchResource([
                'deputies' => [],
                'groups' => [],
                'scrutins' => [],
            ]);
        }

        $isPgsql = DB::connection()->getDriverName() === 'pgsql';
        $like = '%'.$query.'%';
        $lowerLike = '%'.mb_strtolower($query).'%';

        $deputies = Deputy::query()
            ->select(['id', 'slug', 'nom', 'prenom', 'photo_url', 'groupe_id'])
            ->with(['group:id,nom'])
            ->where(function ($q) use ($isPgsql, $like, $lowerLike): void {
                if ($isPgsql) {
                    $q->whereRaw('nom ILIKE ?', [$like])
                        ->orWhereRaw('prenom ILIKE ?', [$like])
                        ->orWhereRaw("(prenom || ' ' || nom) ILIKE ?", [$like])
                        ->orWhereRaw("(nom || ' ' || prenom) ILIKE ?", [$like]);

                    return;
                }

                $q->whereRaw('LOWER(nom) LIKE ?', [$lowerLike])
                    ->orWhereRaw('LOWER(prenom) LIKE ?', [$lowerLike])
                    ->orWhereRaw("LOWER(prenom || ' ' || nom) LIKE ?", [$lowerLike])
                    ->orWhereRaw("LOWER(nom || ' ' || prenom) LIKE ?", [$lowerLike]);
            })
            ->orderBy('nom')
            ->limit(10)
            ->get();

        $groups = Group::query()
            ->select(['id', 'slug', 'nom', 'nom_complet', 'couleur'])
            ->withCount([
                'deputies as members_count' => function ($q): void {
                    $q->where('actif', true);
                },
            ])
            ->where(function ($q) use ($isPgsql, $like, $lowerLike): void {
                if ($isPgsql) {
                    $q->whereRaw('nom ILIKE ?', [$like])
                        ->orWhereRaw('nom_complet ILIKE ?', [$like])
                        ->orWhereRaw('slug ILIKE ?', [$like]);

                    return;
                }

                $q->whereRaw('LOWER(nom) LIKE ?', [$lowerLike])
                    ->orWhereRaw('LOWER(nom_complet) LIKE ?', [$lowerLike])
                    ->orWhereRaw('LOWER(slug) LIKE ?', [$lowerLike]);
            })
            ->orderBy('nom')
            ->limit(10)
            ->get();

        $scrutins = Scrutin::query()
            ->select(['id', 'numero', 'titre', 'date', 'sort', 'importance_score', 'resume_ia'])
            ->where(function ($q) use ($isPgsql, $like, $lowerLike): void {
                if ($isPgsql) {
                    $q->whereRaw('titre ILIKE ?', [$like])
                        ->orWhereRaw('resume_ia ILIKE ?', [$like]);

                    return;
                }

                $q->whereRaw('LOWER(titre) LIKE ?', [$lowerLike])
                    ->orWhereRaw('LOWER(resume_ia) LIKE ?', [$lowerLike]);
            })
            ->orderByDesc('numero')
            ->limit(20)
            ->get();

        return new SearchResource([
            'deputies' => $deputies,
            'groups' => $groups,
            'scrutins' => $scrutins,
        ]);
    }
}

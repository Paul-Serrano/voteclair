<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DashboardResource;
use App\Models\Deputy;
use App\Models\Group;
use App\Models\Scrutin;
use App\Models\Vote;
use Dedoc\Scramble\Attributes\Endpoint;
use Dedoc\Scramble\Attributes\Group as ApiGroup;
use Dedoc\Scramble\Attributes\Response;
use Illuminate\Support\Facades\Cache;

#[ApiGroup('Dashboard', description: 'Données de tableau de bord', weight: 10)]
class DashboardController extends Controller
{
    #[Endpoint(
        operationId: 'dashboard.index',
        title: 'Tableau de bord',
        description: 'Retourne les statistiques générales et l\'activité récente de l\'Assemblée.'
    )]
    #[Response(200, 'Données du tableau de bord.', type: 'object')]
    public function index(): DashboardResource
    {
        $data = Cache::remember('dashboard:data:v2', 3600, function (): array {
            return [
                'stats' => [
                    'deputies' => Deputy::count(),
                    'groups' => Group::count(),
                    'scrutins' => Scrutin::count(),
                    'votes' => Vote::count(),
                ],
                'latest_scrutins' => Scrutin::query()
                    ->select('id', 'numero', 'titre', 'date', 'sort')
                    ->orderByDesc('numero')
                    ->limit(10)
                    ->get()
                    ->toArray(),
                'top_groups' => Group::query()
                    ->select('slug', 'nom', 'couleur')
                    ->withCount('deputies')
                    ->orderByDesc('deputies_count')
                    ->limit(5)
                    ->get()
                    ->map(function ($group) {
                        return [
                            'slug' => $group->slug,
                            'nom' => $group->nom,
                            'couleur' => $group->couleur,
                            'members_count' => $group->deputies_count,
                        ];
                    })
                    ->toArray(),
                'recent_activity' => (function (): array {
                    $lastScrutin = Scrutin::query()
                        ->select('id', 'numero', 'titre', 'date')
                        ->orderByDesc('date')
                        ->first();

                    if (!$lastScrutin) {
                        return ['last_scrutin_date' => null, 'last_scrutin_title' => null];
                    }

                    return [
                        'last_scrutin_date' => $lastScrutin->date,
                        'last_scrutin_title' => $lastScrutin->titre,
                    ];
                })(),
            ];
        });

        return new DashboardResource((object) $data);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\DeputyCollection;
use App\Http\Resources\DeputyResource;
use App\Http\Resources\VoteCollection;
use App\Models\Deputy;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class DeputyController extends Controller
{
    public function index(Request $request): DeputyCollection
    {
        $search = trim((string) $request->query('search', ''));
        $groupSlug = trim((string) $request->query('group', ''));

        $query = Deputy::query()
            ->with(['group:id,slug,nom', 'circonscription:id,nom']);

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

    public function show(Deputy $deputy): DeputyResource
    {
        $deputy->loadMissing(['group:id,slug,nom', 'circonscription:id,nom']);

        return new DeputyResource($deputy);
    }

    public function votes(Deputy $deputy): VoteCollection
    {
        $query = Vote::query()
            ->select('votes.*')
            ->join('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
            ->where('votes.deputy_id', $deputy->id)
            ->with('scrutin:id,numero,titre,date')
            ->orderByDesc('scrutins.date');

        return new VoteCollection($query->paginate());
    }
}

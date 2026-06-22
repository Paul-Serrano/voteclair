<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\ScrutinCollection;
use App\Http\Resources\ScrutinResource;
use App\Http\Resources\VoteCollection;
use App\Models\Scrutin;
use App\Models\Vote;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ScrutinController extends Controller
{
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

    public function show(Scrutin $scrutin): ScrutinResource
    {
        return new ScrutinResource($scrutin);
    }

    public function votes(Scrutin $scrutin): VoteCollection
    {
        $votes = Vote::query()
            ->where('scrutin_id', $scrutin->id)
            ->with('deputy:id,slug,nom,prenom')
            ->paginate();

        return new VoteCollection($votes);
    }
}

<?php

namespace App\Services\Deputies;

use App\Models\Deputy;
use App\Models\PostalCode;
use App\Models\Vote;
use Illuminate\Support\Facades\Cache;

class FindMyDeputyService
{
    public function findByPostalCode(string $postalCode, ?string $institutionId = null): ?array
    {
        $normalizedPostalCode = trim($postalCode);
        $cacheKey = sprintf(
            'find-my-deputy:v1:%s:%s',
            $normalizedPostalCode,
            $institutionId ?? 'any'
        );

        return Cache::remember($cacheKey, now()->addDay(), function () use ($normalizedPostalCode, $institutionId): ?array {
            $postalCodeRecord = PostalCode::query()
                ->with([
                    'institution:id,slug,nom,pays',
                    'circonscription.institution:id,slug,nom,pays',
                ])
                ->where('postal_code', $normalizedPostalCode)
                ->when($institutionId !== null, function ($query) use ($institutionId): void {
                    $query->where('institution_id', $institutionId);
                })
                ->orderByRaw('institution_id IS NULL DESC')
                ->orderBy('institution_id')
                ->first();

            if ($postalCodeRecord === null || $postalCodeRecord->circonscription === null) {
                return null;
            }

            $institution = $postalCodeRecord->institution ?? $postalCodeRecord->circonscription->institution;
            if ($institution === null) {
                return null;
            }

            $deputies = Deputy::query()
                ->with(['group:id,slug,nom,couleur'])
                ->where('institution_id', $institution->id)
                ->where('circonscription_id', $postalCodeRecord->circonscription->id)
                ->where('actif', true)
                ->orderBy('nom')
                ->orderBy('prenom')
                ->get();

            if ($deputies->isEmpty()) {
                return null;
            }

            return [
                'postal_code' => $normalizedPostalCode,
                'institution' => [
                    'id' => $institution->id,
                    'slug' => $institution->slug,
                    'nom' => $institution->nom,
                    'pays' => $institution->pays,
                ],
                'circonscription' => [
                    'id' => $postalCodeRecord->circonscription->id,
                    'nom' => $postalCodeRecord->circonscription->nom,
                    'departement' => $postalCodeRecord->circonscription->departement,
                    'departement_name' => $postalCodeRecord->circonscription->departement_name,
                    'numero' => $postalCodeRecord->circonscription->numero,
                ],
                'deputies' => $deputies->map(fn (Deputy $deputy): array => $this->buildDeputyPayload($deputy))->values()->all(),
            ];
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function buildDeputyPayload(Deputy $deputy): array
    {
        $latestVotes = Vote::query()
            ->select('votes.*')
            ->join('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
            ->where('votes.deputy_id', $deputy->id)
            ->with('scrutin:id,numero,titre,date,sort,importance_score')
            ->orderByDesc('scrutins.numero')
            ->orderByDesc('scrutins.date')
            ->limit(5)
            ->get();

        return [
            'slug' => $deputy->slug,
            'prenom' => $deputy->prenom,
            'nom' => $deputy->nom,
            'photo_url' => $deputy->photo_url,
            'profession' => $deputy->profession,
            'stats_presence' => $deputy->stats_presence,
            'stats_loyaute' => $deputy->stats_loyaute,
            'stats_participation' => $deputy->stats_participation,
            'group' => $deputy->group ? [
                'slug' => $deputy->group->slug,
                'nom' => $deputy->group->nom,
                'couleur' => $deputy->group->couleur,
            ] : null,
            'latest_votes' => $latestVotes->map(function (Vote $vote): array {
                return [
                    'scrutin_id' => $vote->scrutin_id,
                    'position' => strtoupper((string) $vote->position),
                    'delegated' => (bool) $vote->delegated,
                    'scrutin' => [
                        'id' => $vote->scrutin?->id,
                        'numero' => $vote->scrutin?->numero,
                        'titre' => $vote->scrutin?->titre,
                        'date' => $vote->scrutin?->date?->toDateString(),
                        'sort' => $vote->scrutin?->sort,
                        'importance_score' => (int) ($vote->scrutin?->importance_score ?? 0),
                    ],
                ];
            })->values()->all(),
        ];
    }
}
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FindMyDeputyResource extends JsonResource
{
    public static $wrap = null;

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'postal_code' => data_get($this->resource, 'postal_code'),
            'institution' => data_get($this->resource, 'institution'),
            'circonscription' => data_get($this->resource, 'circonscription'),
            'deputies' => collect(data_get($this->resource, 'deputies', []))
                ->map(function ($deputy): array {
                    return [
                        'slug' => data_get($deputy, 'slug'),
                        'prenom' => data_get($deputy, 'prenom'),
                        'nom' => data_get($deputy, 'nom'),
                        'photo_url' => data_get($deputy, 'photo_url'),
                        'profession' => data_get($deputy, 'profession'),
                        'stats_presence' => data_get($deputy, 'stats_presence'),
                        'stats_loyaute' => data_get($deputy, 'stats_loyaute'),
                        'stats_participation' => data_get($deputy, 'stats_participation'),
                        'group' => data_get($deputy, 'group'),
                        'latest_votes' => collect(data_get($deputy, 'latest_votes', []))
                            ->map(function ($vote): array {
                                return [
                                    'scrutin_id' => data_get($vote, 'scrutin_id'),
                                    'position' => data_get($vote, 'position'),
                                    'delegated' => (bool) data_get($vote, 'delegated', false),
                                    'scrutin' => data_get($vote, 'scrutin'),
                                ];
                            })
                            ->values()
                            ->all(),
                    ];
                })
                ->values()
                ->all(),
        ];
    }
}

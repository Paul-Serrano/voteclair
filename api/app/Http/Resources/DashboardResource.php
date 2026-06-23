<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'stats' => $this->stats,
            'latest_scrutins' => $this->latest_scrutins,
            'top_groups' => $this->top_groups,
            'recent_activity' => $this->recent_activity,
        ];
    }
}

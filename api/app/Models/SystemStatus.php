<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SystemStatus extends Model
{
    protected $table = 'system_status';

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'queue_pending_jobs' => 'integer',
            'queue_failed_jobs' => 'integer',
            'last_sync_duration_ms' => 'integer',
            'last_scrutins_imported' => 'integer',
            'last_votes_imported' => 'integer',
            'last_deputies_updated' => 'integer',
            'last_groups_updated' => 'integer',
            'last_successful_sync_at' => 'datetime',
            'last_failed_sync_at' => 'datetime',
        ];
    }
}

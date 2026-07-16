<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SystemEvent extends Model
{
    public const UPDATED_AT = null;

    protected $table = 'system_events';

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'context' => 'array',
            'duration_ms' => 'integer',
            'created_at' => 'datetime',
        ];
    }
}

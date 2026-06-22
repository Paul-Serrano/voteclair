<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Vote extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'delegated' => 'boolean',
        ];
    }

    public function deputy(): BelongsTo
    {
        return $this->belongsTo(Deputy::class);
    }

    public function scrutin(): BelongsTo
    {
        return $this->belongsTo(Scrutin::class);
    }
}

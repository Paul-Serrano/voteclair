<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Institution extends Model
{
    use HasFactory;
    use HasUuids;

    protected $keyType = 'string';

    public $incrementing = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'actif' => 'boolean',
            'last_synced_at' => 'datetime',
        ];
    }

    public function groups(): HasMany
    {
        return $this->hasMany(Group::class);
    }

    public function deputies(): HasMany
    {
        return $this->hasMany(Deputy::class);
    }

    public function scrutins(): HasMany
    {
        return $this->hasMany(Scrutin::class);
    }

    public function circonscriptions(): HasMany
    {
        return $this->hasMany(Circonscription::class);
    }

    public function postalCodes(): HasMany
    {
        return $this->hasMany(PostalCode::class);
    }
}

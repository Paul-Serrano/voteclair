<?php

namespace App\Services\Sync;

use App\Models\SyncState;

class SyncStateService
{
    public function get(string $key): ?string
    {
        $value = SyncState::query()
            ->where('key', $key)
            ->value('value');

        return is_string($value) ? $value : null;
    }

    public function set(string $key, string $value): void
    {
        SyncState::query()->updateOrCreate(
            ['key' => $key],
            ['value' => $value]
        );
    }

    public function has(string $key): bool
    {
        return SyncState::query()->where('key', $key)->exists();
    }
}

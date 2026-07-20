<?php

namespace App\Services\Sync;

use DateTimeInterface;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

abstract class BaseSyncService
{
    protected function chamber(): string
    {
        return (string) config('voteclair.sync.chamber', 'assemblee');
    }

    protected function institutionIdForChamber(string $chamber): string
    {
        return match (strtolower($chamber)) {
            'assemblee' => '11111111-1111-1111-1111-111111111111',
            'senat' => '22222222-2222-2222-2222-222222222222',
            default => throw new \RuntimeException("Unsupported chamber: {$chamber}"),
        };
    }

    protected function nowIso(): string
    {
        return now()->toDateTimeString();
    }

    protected function nowStateValue(): string
    {
        return now()->toIso8601String();
    }

    protected function parseStateDate(?string $value): ?Carbon
    {
        if (! is_string($value) || trim($value) === '') {
            return null;
        }

        try {
            return Carbon::parse($value);
        } catch (\Throwable) {
            return null;
        }
    }

    /**
     * @param  array<string, mixed>  $item
     * @param  array<int, string>  $dateFields
     */
    protected function isItemNewerThanSince(array $item, ?DateTimeInterface $since, array $dateFields): bool
    {
        if ($since === null) {
            return true;
        }

        $hasComparableField = false;

        foreach ($dateFields as $field) {
            $value = data_get($item, $field);
            if (! is_string($value) || trim($value) === '') {
                continue;
            }

            try {
                $hasComparableField = true;
                if (Carbon::parse($value)->gt($since)) {
                    return true;
                }
            } catch (\Throwable) {
                continue;
            }
        }

        return ! $hasComparableField;
    }

    protected function nullableInt(mixed $value): ?int
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (int) $value;
    }

    protected function nullableString(mixed $value): ?string
    {
        if ($value === null || $value === '') {
            return null;
        }

        return (string) $value;
    }

    /**
     * @param  array<int, array<string, mixed>>  $rows
     * @param  array<int, string>  $uniqueBy
     * @param  array<int, string>  $updateColumns
     */
    protected function upsertInChunks(string $table, array $rows, array $uniqueBy, array $updateColumns): int
    {
        if ($rows === []) {
            return 0;
        }

        $batchSize = max(1, (int) config('voteclair.sync.batch_size', 100));
        $written = 0;

        foreach (array_chunk($rows, $batchSize) as $chunk) {
            $countBefore = (int) DB::table($table)->count();

            DB::transaction(function () use ($table, $chunk, $uniqueBy, $updateColumns): void {
                DB::table($table)->upsert($chunk, $uniqueBy, $updateColumns);
            });

            $countAfter = (int) DB::table($table)->count();

            if ($countAfter === $countBefore) {
                $firstRow = $chunk[0];
                $sampleExists = false;

                if ($firstRow !== []) {
                    $query = DB::table($table);

                    foreach ($uniqueBy as $column) {
                        $query->where($column, $firstRow[$column] ?? null);
                    }

                    $sampleExists = $query->exists();
                }

                $this->logError('Upsert chunk did not change visible row count', [
                    'table' => $table,
                    'chunk_size' => count($chunk),
                    'count_before' => $countBefore,
                    'count_after' => $countAfter,
                    'unique_by' => $uniqueBy,
                    'sample_exists' => $sampleExists,
                    'sample_unique_values' => array_intersect_key($firstRow, array_flip($uniqueBy)),
                ]);
            }

            $written += count($chunk);
        }

        return $written;
    }

    protected function tableIsEmpty(string $table): bool
    {
        return DB::table($table)->limit(1)->doesntExist();
    }

    /**
     * @param  array<string, mixed>  $context
     */
    protected function logInfo(string $message, array $context = []): void
    {
        Log::channel('voteclair')->info($message, $context);
    }

    /**
     * @param  array<string, mixed>  $context
     */
    protected function logError(string $message, array $context = []): void
    {
        Log::channel('voteclair')->error($message, $context);
    }
}

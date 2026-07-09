<?php

namespace App\Console\Commands\Clair;

use Illuminate\Console\Command;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Arr;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

abstract class BaseClairImportCommand extends Command
{
    protected function client(): PendingRequest
    {
        $baseUrl = rtrim((string) env('CLAIR_API_BASE_URL', 'https://clair-production.up.railway.app'), '/');

        return Http::baseUrl($baseUrl)
            ->acceptJson()
            ->connectTimeout((int) env('CLAIR_API_CONNECT_TIMEOUT', 10))
            ->timeout((int) env('CLAIR_API_TIMEOUT', 30));
    }

    /**
     * @return array<string, mixed>
     */
    protected function fetchJsonWithRetry(string $path, array $query = []): array
    {
        $maxAttempts = max(1, (int) env('CLAIR_API_MAX_ATTEMPTS', 4));
        $baseBackoffMs = max(100, (int) env('CLAIR_API_BACKOFF_MS', 1000));

        $attempt = 0;
        do {
            $attempt++;

            $response = $this->client()->get($path, $query);
            $status = $response->status();

            if ($response->successful()) {
                return $response->json() ?? [];
            }

            $retryable = in_array($status, [429, 500, 502, 503, 504], true);
            if (! $retryable || $attempt >= $maxAttempts) {
                $response->throw();
            }

            $waitMs = $this->retryDelayMs($response, $attempt, $baseBackoffMs);
            $this->logInfo('Retrying API request', [
                'path' => $path,
                'query' => $query,
                'status' => $status,
                'attempt' => $attempt,
                'wait_ms' => $waitMs,
            ]);

            usleep($waitMs * 1000);
        } while ($attempt < $maxAttempts);

        return [];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    protected function fetchItems(string $path, array $query = []): array
    {
        $payload = $this->fetchJsonWithRetry($path, $query);

        return $this->extractItemsFromPayload($payload);
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    protected function fetchAllItems(string $path, array $query = [], ?int $maxItems = null): array
    {
        $pageParam = (string) env('CLAIR_API_PAGE_PARAM', 'page');
        $limitParam = (string) env('CLAIR_API_LIMIT_PARAM', 'limit');
        $pageSize = max(1, (int) env('CLAIR_API_PAGE_SIZE', 100));
        $maxPages = max(1, (int) env('CLAIR_API_MAX_PAGES', 50));
        $maxItems = $maxItems ?? max(1, (int) env('CLAIR_API_MAX_ITEMS', 5000));

        $page = 1;
        $allItems = [];
        $seenSignatures = [];

        while ($page <= $maxPages) {
            $pageQuery = array_merge($query, [
                $pageParam => $page,
                $limitParam => $pageSize,
            ]);

            $payload = $this->fetchJsonWithRetry($path, $pageQuery);
            $items = $this->extractItemsFromPayload($payload);

            if (empty($items)) {
                break;
            }

            $signature = $this->pageSignature($items);
            if ($signature !== null && isset($seenSignatures[$signature])) {
                $this->logInfo('Stopping paginated fetch on repeated page signature', [
                    'path' => $path,
                    'query' => $query,
                    'page' => $page,
                    'signature' => $signature,
                ]);

                break;
            }

            if ($signature !== null) {
                $seenSignatures[$signature] = true;
            }

            $allItems = array_merge($allItems, $items);

            if (count($allItems) >= $maxItems) {
                $allItems = array_slice($allItems, 0, $maxItems);
                $this->logInfo('Stopping paginated fetch on max items', [
                    'path' => $path,
                    'query' => $query,
                    'max_items' => $maxItems,
                ]);

                break;
            }

            if (! $this->hasNextPage($payload, $page, count($items), $pageSize)) {
                break;
            }

            $page++;
        }

        return $allItems;
    }

    /**
     * @param  array<int, array<string, mixed>>  $items
     */
    protected function pageSignature(array $items): ?string
    {
        $first = $items[0] ?? null;
        if (! is_array($first)) {
            return null;
        }

        $identifier = $first['id'] ?? $first['slug'] ?? $first['numero'] ?? null;

        return is_scalar($identifier) ? (string) $identifier.'|'.count($items) : null;
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    protected function extractItemsFromPayload(mixed $payload): array
    {
        if (is_array($payload) && array_is_list($payload)) {
            return $payload;
        }

        if (! is_array($payload)) {
            throw new RuntimeException('Unexpected CLAIR API payload type.');
        }

        foreach (['data', 'items', 'results'] as $key) {
            $items = Arr::get($payload, $key);

            if (is_array($items) && array_is_list($items)) {
                return $items;
            }
        }

        if (isset($payload[0]) && is_array($payload[0])) {
            return $payload;
        }

        return [];
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    protected function hasNextPage(array $payload, int $currentPage, int $count, int $pageSize): bool
    {
        $metaPage = (int) ($payload['meta']['page'] ?? $payload['meta']['currentPage'] ?? 0);
        $metaTotalPages = (int) ($payload['meta']['totalPages'] ?? $payload['meta']['lastPage'] ?? 0);
        if ($metaTotalPages > 0) {
            return ($metaPage > 0 ? $metaPage : $currentPage) < $metaTotalPages;
        }

        $paginationPage = (int) ($payload['pagination']['page'] ?? 0);
        $paginationTotalPages = (int) ($payload['pagination']['totalPages'] ?? $payload['pagination']['lastPage'] ?? 0);
        if ($paginationTotalPages > 0) {
            return ($paginationPage > 0 ? $paginationPage : $currentPage) < $paginationTotalPages;
        }

        if (is_array($payload['links'] ?? null) && ! empty($payload['links']['next'])) {
            return true;
        }

        return $count >= $pageSize;
    }

    protected function retryDelayMs(?Response $response, int $attempt, int $baseBackoffMs): int
    {
        $retryAfter = $response?->header('Retry-After');
        if (is_string($retryAfter) && ctype_digit($retryAfter)) {
            return max(100, (int) $retryAfter * 1000);
        }

        return $baseBackoffMs * (2 ** max(0, $attempt - 1));
    }

    protected function institutionIdForChamber(string $chamber): string
    {
        return match (strtolower($chamber)) {
            'assemblee' => '11111111-1111-1111-1111-111111111111',
            'senat' => '22222222-2222-2222-2222-222222222222',
            default => throw new RuntimeException("Unsupported chamber: {$chamber}"),
        };
    }

    protected function institutionSlugForChamber(string $chamber): string
    {
        return match (strtolower($chamber)) {
            'assemblee' => 'assemblee-nationale',
            'senat' => 'senat',
            default => throw new RuntimeException("Unsupported chamber: {$chamber}"),
        };
    }

    protected function nowIso(): string
    {
        return now()->toDateTimeString();
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

    protected function runImport(string $name, callable $callback): int
    {
        $startedAt = microtime(true);
        $this->logInfo('Import started', [
            'import' => $name,
            'options' => $this->options(),
            'arguments' => $this->arguments(),
        ]);

        try {
            $result = $callback();
            $exitCode = is_int($result) ? $result : self::SUCCESS;

            $this->logInfo('Import finished', [
                'import' => $name,
                'exit_code' => $exitCode,
                'duration_ms' => (int) ((microtime(true) - $startedAt) * 1000),
            ]);

            return $exitCode;
        } catch (Throwable $e) {
            $this->logError('Import failed', [
                'import' => $name,
                'duration_ms' => (int) ((microtime(true) - $startedAt) * 1000),
                'exception_class' => $e::class,
                'exception_message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            $this->error('Import failed: '.$e->getMessage());

            return self::FAILURE;
        }
    }

    protected function logInfo(string $message, array $context = []): void
    {
        $this->safeLog('info', $message, $context);
    }

    protected function logError(string $message, array $context = []): void
    {
        $this->safeLog('error', $message, $context);
    }

    protected function safeLog(string $level, string $message, array $context = []): void
    {
        try {
            $channel = (string) env('CLAIR_IMPORT_LOG_CHANNEL', 'stderr');
            Log::channel($channel)->{$level}('[clair-import] '.$message, $context);
        } catch (Throwable $e) {
            $this->warn('[clair-import] log fallback: '.$message.' ('.$e->getMessage().')');
        }
    }
}

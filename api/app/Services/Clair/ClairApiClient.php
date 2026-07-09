<?php

namespace App\Services\Clair;

use DateTimeInterface;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;
use Illuminate\Support\Arr;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;

class ClairApiClient
{
    public function client(): PendingRequest
    {
        $baseUrl = rtrim((string) config('services.clair.base_url', 'https://clair-production.up.railway.app'), '/');

        return Http::baseUrl($baseUrl)
            ->acceptJson()
            ->connectTimeout((int) config('services.clair.connect_timeout', 10))
            ->timeout((int) config('services.clair.timeout', 30))
            ->retry(
                1,
                0,
                throw: false,
            );
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getGroups(string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate('/api/v1/groupes', ['chambre' => $chamber]);
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getUpdatedGroups(DateTimeInterface $since, string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate(
            '/api/v1/groupes',
            [
                'chambre' => $chamber,
                'updatedSince' => $since->format(DATE_ATOM),
            ],
            max(1, (int) config('services.clair.incremental_recent_pages', 5)),
        );
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getDeputies(string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate('/api/v1/deputes', ['chambre' => $chamber]);
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getUpdatedDeputies(DateTimeInterface $since, string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate(
            '/api/v1/deputes',
            [
                'chambre' => $chamber,
                'updatedSince' => $since->format(DATE_ATOM),
            ],
            max(1, (int) config('services.clair.incremental_recent_pages', 5)),
        );
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getScrutins(string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate('/api/v1/scrutins', ['chambre' => $chamber]);
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getUpdatedScrutins(DateTimeInterface $since, string $chamber = 'assemblee'): \Generator
    {
        yield from $this->paginate(
            '/api/v1/scrutins',
            [
                'chambre' => $chamber,
                'updatedSince' => $since->format(DATE_ATOM),
            ],
            max(1, (int) config('services.clair.incremental_recent_pages', 5)),
        );
    }

    /**
     * @param  iterable<int>  $numbers
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getVotes(iterable $numbers): \Generator
    {
        foreach ($numbers as $numero) {
            $payload = $this->requestJson('/api/v1/scrutins/'.(int) $numero);
            yield (int) $numero => $this->normalizeVotesPayload($payload);
        }
    }

    /**
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    public function getUpdatedVotes(DateTimeInterface $since, string $chamber = 'assemblee'): \Generator
    {
        $numbers = [];

        foreach (
            $this->paginate(
                '/api/v1/scrutins',
                [
                    'chambre' => $chamber,
                    'updatedSince' => $since->format(DATE_ATOM),
                ],
                max(1, (int) config('services.clair.incremental_recent_pages', 5)),
            ) as $items
        ) {
            foreach ($items as $item) {
                $numero = (int) ($item['numero'] ?? 0);
                if ($numero <= 0) {
                    continue;
                }

                if (! $this->isItemUpdatedSince($item, $since, ['updatedAt', 'sourceUpdatedAt', 'date', 'createdAt'])) {
                    continue;
                }

                $numbers[$numero] = true;
            }
        }

        if ($numbers === []) {
            return;
        }

        krsort($numbers, SORT_NUMERIC);
        yield from $this->getVotes(array_keys($numbers));
    }

    /**
     * @param  array<string, mixed>  $query
     * @return \Generator<int, array<int, array<string, mixed>>>
     */
    private function paginate(string $path, array $query = [], ?int $maxPagesOverride = null): \Generator
    {
        $pageParam = (string) config('services.clair.page_param', 'page');
        $limitParam = (string) config('services.clair.limit_param', 'limit');
        $pageSize = max(1, (int) config('services.clair.page_size', 100));
        $defaultMaxPages = max(1, (int) config('services.clair.max_pages', 500));
        $maxPages = $maxPagesOverride === null
            ? $defaultMaxPages
            : max(1, min($defaultMaxPages, $maxPagesOverride));
        $seenSignatures = [];

        for ($page = 1; $page <= $maxPages; $page++) {
            $payload = $this->requestJson($path, array_merge($query, [
                $pageParam => $page,
                $limitParam => $pageSize,
            ]));

            $this->throttle();

            $items = $this->extractItemsFromPayload($payload);
            if ($items === []) {
                break;
            }

            $signature = $this->pageSignature($items);
            if ($signature !== null && isset($seenSignatures[$signature])) {
                break;
            }

            if ($signature !== null) {
                $seenSignatures[$signature] = true;
            }

            yield $page => $items;

            if (! $this->hasNextPage($payload, $page, count($items), $pageSize)) {
                break;
            }
        }
    }

    /**
     * @param  array<string, mixed>  $query
     * @return array<string, mixed>
     */
    private function requestJson(string $path, array $query = []): array
    {
        $maxAttempts = max(1, (int) config('services.clair.max_attempts', 4));
        $baseBackoffMs = max(100, (int) config('services.clair.backoff_ms', 1000));

        for ($attempt = 1; $attempt <= $maxAttempts; $attempt++) {
            $response = $this->client()->get($path, $query);

            if ($response->successful()) {
                return $response->json() ?? [];
            }

            $retryable = in_array($response->status(), [429, 500, 502, 503, 504], true);
            if (! $retryable || $attempt === $maxAttempts) {
                $this->throwIfRetryableFailure($response, $path, $query);
            }

            $waitMs = $this->retryDelayMs($response, $attempt, $baseBackoffMs);
            Log::channel('voteclair')->warning('CLAIR API retry scheduled', [
                'path' => $path,
                'query' => $query,
                'status' => $response->status(),
                'attempt' => $attempt,
                'wait_ms' => $waitMs,
            ]);
            usleep($waitMs * 1000);
        }

        throw new RuntimeException(sprintf('CLAIR API request failed for %s', $path));
    }

    /**
     * @param  array<string, mixed>  $query
     */
    private function throwIfRetryableFailure(Response $response, string $path, array $query): never
    {
        throw new RuntimeException(sprintf(
            'CLAIR API request failed for %s with status %d and query %s',
            $path,
            $response->status(),
            json_encode($query, JSON_THROW_ON_ERROR)
        ));
    }

    private function retryDelayMs(?Response $response, int $attempt, int $baseBackoffMs): int
    {
        $retryAfter = $response?->header('Retry-After');
        if (is_string($retryAfter) && ctype_digit($retryAfter)) {
            return max(100, (int) $retryAfter * 1000);
        }

        return $baseBackoffMs * (2 ** max(0, $attempt - 1));
    }

    private function throttle(): void
    {
        $throttleMs = max(0, (int) config('services.clair.throttle_ms', 6500));
        if ($throttleMs > 0) {
            usleep($throttleMs * 1000);
        }
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function extractItemsFromPayload(mixed $payload): array
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
     * @param  array<int, array<string, mixed>>  $items
     */
    private function pageSignature(array $items): ?string
    {
        $first = $items[0] ?? null;
        if (! is_array($first)) {
            return null;
        }

        $identifier = $first['id'] ?? $first['slug'] ?? $first['numero'] ?? null;

        return is_scalar($identifier) ? (string) $identifier.'|'.count($items) : null;
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function hasNextPage(array $payload, int $currentPage, int $count, int $pageSize): bool
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

    /**
     * @return array<int, array<string, mixed>>
     */
    private function normalizeVotesPayload(mixed $payload): array
    {
        if (! is_array($payload)) {
            return [];
        }

        if (isset($payload['data']) && is_array($payload['data'])) {
            return [$payload['data']];
        }

        if (array_is_list($payload)) {
            return $payload;
        }

        if (
            isset($payload['sourceData']) ||
            isset($payload['ventilationVotes']) ||
            isset($payload['votesByPosition']) ||
            isset($payload['scrutinId']) ||
            isset($payload['scrutinNb']) ||
            isset($payload['id']) ||
            isset($payload['numero'])
        ) {
            return [$payload];
        }

        foreach (['data', 'items', 'results'] as $key) {
            $items = $payload[$key] ?? null;
            if (is_array($items) && array_is_list($items)) {
                return $items;
            }
        }

        return [];
    }

    /**
     * @param  array<string, mixed>  $item
     * @param  array<int, string>  $dateFields
     */
    private function isItemUpdatedSince(array $item, DateTimeInterface $since, array $dateFields): bool
    {
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
}

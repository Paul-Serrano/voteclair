<?php

namespace App\Services\Scrutins\Rules;

use App\Models\Scrutin;
use App\Services\Scrutins\Contracts\ImportanceRule;

class KeywordImportanceRule implements ImportanceRule
{
    /**
     * @param  array<int, string>  $keywords
     */
    public function __construct(
        private readonly array $keywords,
        private readonly int $points,
    ) {}

    public function score(Scrutin $scrutin): int
    {
        $haystack = mb_strtolower(trim((string) $scrutin->titre));
        if ($haystack === '') {
            return 0;
        }

        foreach ($this->keywords as $keyword) {
            if (str_contains($haystack, mb_strtolower($keyword))) {
                return $this->points;
            }
        }

        return 0;
    }
}

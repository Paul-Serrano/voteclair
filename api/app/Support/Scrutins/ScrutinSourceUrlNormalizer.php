<?php

namespace App\Support\Scrutins;

final class ScrutinSourceUrlNormalizer
{
    public static function normalize(?string $url): ?string
    {
        if ($url === null || trim($url) === '') {
            return null;
        }

        $trimmed = trim($url);

        return preg_replace(
            '#^(https://www\.assemblee-nationale\.fr/dyn/\d+/scrutins/)[A-Z0-9]*V(\d+)([?\#].*)?$#i',
            '$1$2$3',
            $trimmed,
        ) ?? $trimmed;
    }
}
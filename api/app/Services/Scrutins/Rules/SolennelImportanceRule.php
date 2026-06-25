<?php

namespace App\Services\Scrutins\Rules;

use App\Models\Scrutin;
use App\Services\Scrutins\Contracts\ImportanceRule;

class SolennelImportanceRule implements ImportanceRule
{
    public function score(Scrutin $scrutin): int
    {
        $title = mb_strtolower((string) $scrutin->titre);
        $demandeur = mb_strtolower((string) ($scrutin->demandeur_texte ?? ''));

        return str_contains($title, 'solennel') || str_contains($demandeur, 'solennel')
            ? 50
            : 0;
    }
}

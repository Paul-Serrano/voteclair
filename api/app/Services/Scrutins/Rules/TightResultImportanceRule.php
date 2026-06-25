<?php

namespace App\Services\Scrutins\Rules;

use App\Models\Scrutin;
use App\Services\Scrutins\Contracts\ImportanceRule;

class TightResultImportanceRule implements ImportanceRule
{
    public function score(Scrutin $scrutin): int
    {
        $pour = (int) ($scrutin->nombre_pour ?? 0);
        $contre = (int) ($scrutin->nombre_contre ?? 0);

        if ($pour === 0 && $contre === 0) {
            return 0;
        }

        return abs($pour - $contre) < 20 ? 30 : 0;
    }
}

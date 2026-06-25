<?php

namespace App\Services\Scrutins\Rules;

use App\Models\Scrutin;
use App\Services\Scrutins\Contracts\ImportanceRule;

class HighParticipationImportanceRule implements ImportanceRule
{
    public function score(Scrutin $scrutin): int
    {
        $votesExprimes = (int) ($scrutin->nombre_pour ?? 0) + (int) ($scrutin->nombre_contre ?? 0);

        return $votesExprimes > 500 ? 20 : 0;
    }
}

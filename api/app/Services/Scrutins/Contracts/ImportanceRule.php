<?php

namespace App\Services\Scrutins\Contracts;

use App\Models\Scrutin;

interface ImportanceRule
{
    public function score(Scrutin $scrutin): int;
}

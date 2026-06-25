<?php

namespace App\Services\Scrutins;

use App\Models\Scrutin;
use App\Services\Scrutins\Contracts\ImportanceRule;
use App\Services\Scrutins\Rules\HighParticipationImportanceRule;
use App\Services\Scrutins\Rules\KeywordImportanceRule;
use App\Services\Scrutins\Rules\SolennelImportanceRule;
use App\Services\Scrutins\Rules\TightResultImportanceRule;

class ImportanceScoringService
{
    /**
     * @var array<int, ImportanceRule>
     */
    private array $rules;

    /**
     * @param  array<int, ImportanceRule>|null  $rules
     */
    public function __construct(?array $rules = null)
    {
        // Extensible: adding new criteria only requires a new rule and registration here.
        $this->rules = $rules ?? [
            new SolennelImportanceRule(),
            new KeywordImportanceRule(['censure'], 100),
            new KeywordImportanceRule(['finances', 'budget'], 80),
            new KeywordImportanceRule(['retraites'], 70),
            new KeywordImportanceRule(['immigration'], 70),
            new KeywordImportanceRule(['constitution', 'constitutionnelle'], 90),
            new HighParticipationImportanceRule(),
            new TightResultImportanceRule(),
        ];
    }

    public function calculate(Scrutin $scrutin): int
    {
        $score = 0;

        foreach ($this->rules as $rule) {
            $score += max(0, $rule->score($scrutin));
        }

        return max(0, $score);
    }
}

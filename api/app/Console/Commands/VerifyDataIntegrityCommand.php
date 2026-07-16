<?php

namespace App\Console\Commands;

use App\Jobs\CreateSystemEventJob;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class VerifyDataIntegrityCommand extends Command
{
    protected $signature = 'voteclair:verify-integrity';

    protected $description = 'Run weekly data integrity checks for core VoteClair entities';

    public function handle(): int
    {
        $issues = [];

        $orphanDeputies = DB::table('deputies')
            ->leftJoin('groups', 'groups.id', '=', 'deputies.groupe_id')
            ->whereNull('groups.id')
            ->count();

        if ($orphanDeputies > 0) {
            $issues[] = sprintf('Orphan deputies without group: %d', $orphanDeputies);
        }

        $orphanVotes = DB::table('votes')
            ->leftJoin('scrutins', 'scrutins.id', '=', 'votes.scrutin_id')
            ->whereNull('scrutins.id')
            ->count();

        if ($orphanVotes > 0) {
            $issues[] = sprintf('Orphan votes without scrutin: %d', $orphanVotes);
        }

        $duplicates = DB::table('votes')
            ->select('scrutin_id', 'deputy_id', DB::raw('COUNT(*) as duplicate_count'))
            ->groupBy('scrutin_id', 'deputy_id')
            ->having('duplicate_count', '>', 1)
            ->count();

        if ($duplicates > 0) {
            $issues[] = sprintf('Duplicate vote tuples (scrutin_id,deputy_id): %d', $duplicates);
        }

        if ($issues === []) {
            $this->info('Data integrity check passed.');

            return self::SUCCESS;
        }

        foreach ($issues as $issue) {
            $this->error($issue);
        }

        CreateSystemEventJob::dispatchSync(
            type: 'database.error',
            level: 'error',
            message: 'Weekly integrity check failed',
            context: ['issues' => $issues],
        );

        return self::FAILURE;
    }
}

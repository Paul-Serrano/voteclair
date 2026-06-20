<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('votes', function (Blueprint $table) {
            $table->bigIncrements('id');
            $table->foreignUuid('scrutin_id')->constrained('scrutins');
            $table->foreignUuid('deputy_id')->constrained('deputies');
            $table->boolean('delegated')->default(false);
            $table->timestamps();

            $table->unique(['scrutin_id', 'deputy_id']);
            $table->index('scrutin_id');
            $table->index('deputy_id');
        });

        DB::statement('ALTER TABLE votes ADD COLUMN position vote_position NOT NULL');
        DB::statement('CREATE INDEX votes_position_index ON votes (position)');
    }

    public function down(): void
    {
        Schema::dropIfExists('votes');
    }
};

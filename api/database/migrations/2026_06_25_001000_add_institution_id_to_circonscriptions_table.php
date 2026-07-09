<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('circonscriptions', function (Blueprint $table): void {
            $table->foreignUuid('institution_id')
                ->nullable()
                ->after('id')
                ->constrained('institutions');

            $table->index('institution_id');
        });
    }

    public function down(): void
    {
        Schema::table('circonscriptions', function (Blueprint $table): void {
            $table->dropConstrainedForeignId('institution_id');
        });
    }
};

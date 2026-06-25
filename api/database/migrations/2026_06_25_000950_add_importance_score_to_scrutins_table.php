<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('scrutins', function (Blueprint $table): void {
            $table->integer('importance_score')->default(0)->after('sort');
        });
    }

    public function down(): void
    {
        Schema::table('scrutins', function (Blueprint $table): void {
            $table->dropColumn('importance_score');
        });
    }
};

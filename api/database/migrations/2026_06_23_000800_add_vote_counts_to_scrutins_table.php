<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('scrutins', function (Blueprint $table): void {
            $table->integer('nombre_votants')->default(0)->after('sort');
            $table->integer('nombre_pour')->default(0)->after('nombre_votants');
            $table->integer('nombre_contre')->default(0)->after('nombre_pour');
            $table->integer('nombre_abstention')->default(0)->after('nombre_contre');
        });
    }

    public function down(): void
    {
        Schema::table('scrutins', function (Blueprint $table): void {
            $table->dropColumn([
                'nombre_votants',
                'nombre_pour',
                'nombre_contre',
                'nombre_abstention',
            ]);
        });
    }
};

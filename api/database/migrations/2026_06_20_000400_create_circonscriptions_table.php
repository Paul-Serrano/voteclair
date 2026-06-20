<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('circonscriptions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('departement', 5);
            $table->string('departement_name', 255)->nullable();
            $table->integer('numero');
            $table->string('nom', 255);
            $table->timestamp('last_synced_at')->nullable();
            $table->timestamps();

            $table->index('departement');
            $table->index('numero');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('circonscriptions');
    }
};

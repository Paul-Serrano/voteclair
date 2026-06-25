<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('postal_codes', function (Blueprint $table): void {
            $table->bigIncrements('id');
            $table->string('postal_code', 10);
            $table->string('departement_code', 5);
            $table->foreignUuid('institution_id')->nullable()->constrained('institutions');
            $table->foreignUuid('circonscription_id')->constrained('circonscriptions');
            $table->timestamps();

            $table->index('postal_code');
            $table->index('departement_code');
            $table->unique(['postal_code', 'institution_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('postal_codes');
    }
};
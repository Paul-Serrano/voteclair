<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('system_events', function (Blueprint $table): void {
            $table->id();
            $table->string('type', 100)->index();
            $table->string('level', 20)->default('info')->index();
            $table->text('message');

            if (Schema::getConnection()->getDriverName() === 'pgsql') {
                $table->jsonb('context')->nullable();
            } else {
                $table->json('context')->nullable();
            }

            $table->unsignedBigInteger('duration_ms')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->index('created_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('system_events');
    }
};

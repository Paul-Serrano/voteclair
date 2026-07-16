<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('system_status', function (Blueprint $table): void {
            $table->id();
            $table->string('api_version', 50)->nullable();
            $table->string('clair_data_version', 100)->nullable();
            $table->string('database_status', 20)->default('unknown');
            $table->string('redis_status', 20)->default('unknown');
            $table->string('queue_status', 20)->default('unknown');
            $table->unsignedInteger('queue_pending_jobs')->default(0);
            $table->unsignedInteger('queue_failed_jobs')->default(0);
            $table->timestamp('last_successful_sync_at')->nullable();
            $table->timestamp('last_failed_sync_at')->nullable();
            $table->string('last_sync_status', 20)->default('idle');
            $table->unsignedBigInteger('last_sync_duration_ms')->nullable();
            $table->unsignedInteger('last_scrutins_imported')->default(0);
            $table->unsignedInteger('last_votes_imported')->default(0);
            $table->unsignedInteger('last_deputies_updated')->default(0);
            $table->unsignedInteger('last_groups_updated')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('system_status');
    }
};

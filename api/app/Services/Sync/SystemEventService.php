<?php

namespace App\Services\Sync;

use App\Models\SystemEvent;
use Illuminate\Support\Facades\Log;

class SystemEventService
{
    /**
     * @param  array<string, mixed>  $context
     */
    public function record(
        string $type,
        string $level,
        string $message,
        array $context = [],
        ?int $durationMs = null,
    ): SystemEvent {
        $event = SystemEvent::query()->create([
            'type' => $type,
            'level' => $level,
            'message' => $message,
            'context' => $context === [] ? null : $context,
            'duration_ms' => $durationMs,
        ]);

        $logContext = [
            'event_type' => $type,
            'event_level' => $level,
            'duration_ms' => $durationMs,
            'context' => $context,
        ];

        if ($level === 'error' || $level === 'critical') {
            Log::channel('voteclair')->error($message, $logContext);
        } elseif ($level === 'warning') {
            Log::channel('voteclair')->warning($message, $logContext);
        } else {
            Log::channel('voteclair')->info($message, $logContext);
        }

        return $event;
    }
}

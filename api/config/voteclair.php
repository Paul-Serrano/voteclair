<?php

return [
    'version' => env('API_VERSION', '1.0.0-beta'),
    'clair_data_version' => env('CLAIR_DATA_VERSION', 'unknown'),
    'sync' => [
        'chamber' => env('CLAIR_SYNC_CHAMBER', 'assemblee'),
        'batch_size' => (int) env('CLAIR_SYNC_BATCH_SIZE', 100),
        'votes_limit' => (int) env('CLAIR_SYNC_VOTES_LIMIT', 0),
    ],
];

<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'clair' => [
        'base_url' => env('CLAIR_API_BASE_URL', 'https://clair-production.up.railway.app'),
        'connect_timeout' => (int) env('CLAIR_API_CONNECT_TIMEOUT', 10),
        'timeout' => (int) env('CLAIR_API_TIMEOUT', 30),
        'incremental_recent_pages' => (int) env('CLAIR_API_INCREMENTAL_RECENT_PAGES', 5),
        'page_param' => env('CLAIR_API_PAGE_PARAM', 'page'),
        'limit_param' => env('CLAIR_API_LIMIT_PARAM', 'limit'),
        'page_size' => (int) env('CLAIR_API_PAGE_SIZE', 100),
        'max_pages' => (int) env('CLAIR_API_MAX_PAGES', 500),
        'max_attempts' => (int) env('CLAIR_API_MAX_ATTEMPTS', 4),
        'backoff_ms' => (int) env('CLAIR_API_BACKOFF_MS', 1000),
        'throttle_ms' => (int) env('CLAIR_API_THROTTLE_MS', 6500),
    ],

];

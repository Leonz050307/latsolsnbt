<?php
return [
    'app_name' => 'Latsol SNBT Daily',
    'base_url' => 'https://latsolsnbt.candubelajar.my.id',
    'timezone' => 'Asia/Jakarta',
    'db_host' => getenv('DB_HOST') ?: 'localhost',
    'db_name' => getenv('DB_NAME') ?: 'latsol',
    'db_user' => getenv('DB_USER') ?: 'latsol_user',
    'db_pass' => getenv('DB_PASS') ?: 'secret',
    'session_lifetime' => 604800,
    'csrf' => [
        'token_name' => '_csrf',
        'storage_key' => 'csrf_token',
    ],
    'security' => [
        'rate_limit' => [
            'login' => ['max' => 5, 'window' => 60],
            'api' => ['max' => 60, 'window' => 60],
        ],
    ],
    'timers' => [
        'kejar_waktu' => 420,
        'santai' => 1200,
    ],
    'sse' => [
        'enabled' => true,
        'retry' => 4000,
    ],
    'ai' => [
        'provider' => getenv('AI_PROVIDER') ?: 'openai',
        'api_key' => getenv('AI_API_KEY') ?: '',
        'model' => getenv('AI_MODEL') ?: 'gpt-4o-mini',
        'endpoint' => getenv('AI_ENDPOINT') ?: 'https://api.openai.com/v1/chat/completions',
        'timeout' => 20,
    ],
];

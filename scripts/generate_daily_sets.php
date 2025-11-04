<?php
require __DIR__ . '/../app/Helpers.php';

spl_autoload_register(function ($class) {
    $prefix = 'App\\';
    $baseDir = __DIR__ . '/../app/';
    if (strpos($class, $prefix) !== 0) {
        return;
    }
    $relative = substr($class, strlen($prefix));
    $file = $baseDir . str_replace('\\', '/', $relative) . '.php';
    if (file_exists($file)) {
        require $file;
    }
});

$config = require __DIR__ . '/../app/Config/config.php';
date_default_timezone_set($config['timezone']);

$pdo = App\Core\Database::pdo();

$subtests = $pdo->query('SELECT id FROM subtests WHERE is_active = 1')->fetchAll(PDO::FETCH_COLUMN);

$client = new App\Services\AIClient($config['ai']);
$generator = new App\Services\QuestionGenerator($client);

$date = date('Y-m-d', strtotime('+0 day'));
foreach ($subtests as $subtestId) {
    foreach (['kejar_waktu', 'santai'] as $mode) {
        try {
            $generator->generateDaily((int) $subtestId, $mode, $date);
            echo "Generated {$mode} for subtest {$subtestId}\n";
        } catch (Throwable $e) {
            echo "Failed {$mode} for subtest {$subtestId}: " . $e->getMessage() . "\n";
        }
    }
}

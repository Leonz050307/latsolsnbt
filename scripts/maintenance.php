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
$date = $_SERVER['argv'][1] ?? date('Y-m-d');

$rows = $pdo->query('SELECT DISTINCT subtest_id, mode FROM attempts WHERE for_date = ' . $pdo->quote($date))->fetchAll(PDO::FETCH_ASSOC);
foreach ($rows as $row) {
    $scores = App\Models\Attempt::scoreboard((int) $row['subtest_id'], $row['mode'], $date, 50);
    App\Models\Scoreboard::store((int) $row['subtest_id'], $row['mode'], $date, ['top' => $scores]);
    echo "Rebuilt scoreboard for subtest {$row['subtest_id']} mode {$row['mode']}\n";
}

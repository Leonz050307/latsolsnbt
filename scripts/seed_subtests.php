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

$subtests = [
    ['slug' => 'penalaran-umum', 'name' => 'Penalaran Umum', 'description' => 'Mengukur kemampuan bernalar logis dan analitis.'],
    ['slug' => 'pengetahuan-umum', 'name' => 'Pengetahuan & Pemahaman Umum', 'description' => 'Memahami wacana akademik, isu terkini, dan literasi informasi.'],
    ['slug' => 'penalaran-matematika', 'name' => 'Penalaran Matematika', 'description' => 'Soal matematika yang menekankan penalaran dan pemecahan masalah.'],
    ['slug' => 'literasi-bahasa-indonesia', 'name' => 'Literasi Bahasa Indonesia', 'description' => 'Menguji kemampuan membaca kritis teks bahasa Indonesia.'],
    ['slug' => 'literasi-bahasa-inggris', 'name' => 'Literasi Bahasa Inggris', 'description' => 'Mengukur literasi dan pemahaman teks berbahasa Inggris.'],
];

foreach ($subtests as $subtest) {
    $stmt = $pdo->prepare('INSERT IGNORE INTO subtests (slug, name, description) VALUES (?, ?, ?)');
    $stmt->execute([$subtest['slug'], $subtest['name'], $subtest['description']]);
}

echo "Seeded subtests." . PHP_EOL;

<?php
if (!isset($title)) {
    $title = 'Latsol SNBT Daily';
}
$config = require __DIR__ . '/../../Config/config.php';
$csrfToken = \App\Core\CSRF::token();
?>
<!DOCTYPE html>
<html lang="id" class="dark">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf" content="<?= $csrfToken ?>">
    <title><?= sanitize($title) ?> - <?= sanitize($config['app_name']) ?></title>
    <link rel="stylesheet" href="/assets/css/app.css">
    <script>
        window.csrfToken = '<?= $csrfToken ?>';
    </script>
    <script defer src="/assets/js/app.js"></script>
</head>
<body class="bg-gradient">
    <header class="navbar-glass">
        <div class="container">
            <a href="/" class="brand">SNBT Daily</a>
            <nav>
                <a href="/scoreboard" class="nav-link">Scoreboard</a>
                <?php if (\App\Core\Auth::user()): ?>
                    <a href="/dashboard" class="nav-link">Dashboard</a>
                    <form method="POST" action="/logout" class="inline">
                        <?= csrf_field() ?>
                        <button type="submit" class="btn btn-ghost">Keluar</button>
                    </form>
                <?php else: ?>
                    <a href="/login" class="nav-link">Masuk</a>
                    <a href="/register" class="btn btn-primary">Daftar</a>
                <?php endif; ?>
            </nav>
        </div>
    </header>
    <main class="main-content">
        <?php include $viewPath; ?>
    </main>
    <footer class="footer">
        <div class="container">
            <p>&copy; <?= date('Y') ?> <?= sanitize($config['app_name']) ?>. Dibangun untuk latihan SNBT harian.</p>
        </div>
    </footer>
</body>
</html>

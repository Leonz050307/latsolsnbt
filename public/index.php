<?php
use App\Controllers\AdminController;
use App\Controllers\ApiController;
use App\Controllers\AttemptController;
use App\Controllers\AuthController;
use App\Controllers\BattleController;
use App\Controllers\DashboardController;
use App\Controllers\SSEController;
use App\Core\Router;

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

session_start();

$router = new Router();

$router->get('/', function () {
    view('home/index', ['title' => 'Beranda']);
});

$authController = new AuthController();
$router->get('/login', [$authController, 'showLogin']);
$router->post('/login', [$authController, 'login']);
$router->get('/register', [$authController, 'showRegister']);
$router->post('/register', [$authController, 'register']);
$router->post('/logout', [$authController, 'logout']);

$dashboardController = new DashboardController();
$router->get('/dashboard', [$dashboardController, 'index']);

$router->get('/attempt', function () {
    view('attempt/play', ['title' => 'Attempt Harian']);
});

$attemptController = new AttemptController();
$router->post('/attempt/start', [$attemptController, 'start']);
$router->post('/attempt/answer', [$attemptController, 'answer']);
$router->post('/attempt/submit', [$attemptController, 'submit']);
$router->get('/attempt/status', [$attemptController, 'status']);

$router->get('/scoreboard', function () {
    $subtests = App\Models\Subtest::allActive();
    view('scoreboard/index', ['title' => 'Scoreboard', 'subtests' => $subtests]);
});

$apiController = new ApiController();
$router->get('/api/scoreboard', [$apiController, 'scoreboard']);

$battleController = new BattleController();
$router->post('/battle/join', [$battleController, 'join']);
$router->get('/battle/status', [$battleController, 'status']);

$sseController = new SSEController();
$router->get('/sse/scoreboard', [$sseController, 'scoreboard']);
$router->get('/sse/battle', [$sseController, 'battle']);

$adminController = new AdminController();
$router->get('/admin', [$adminController, 'index']);
$router->post('/admin/generate_daily', [$adminController, 'generateDaily']);

$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);

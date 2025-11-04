<?php
namespace App\Controllers;

use App\Core\Auth;
use App\Core\CSRF;
use App\Models\Subtest;
use App\Services\AIClient;
use App\Services\QuestionGenerator;

class AdminController
{
    public function index(): void
    {
        Auth::requireRole(['admin', 'moderator']);
        $subtests = Subtest::allActive();
        view('admin/index', ['title' => 'Admin', 'subtests' => $subtests]);
    }

    public function generateDaily(): void
    {
        Auth::requireRole(['admin', 'moderator']);
        CSRF::mustValidate();
        $subtestId = (int) ($_POST['subtest_id'] ?? 0);
        $mode = $_POST['mode'] === 'kejar_waktu' ? 'kejar_waktu' : 'santai';
        $date = $_POST['date'] ?? date('Y-m-d');
        $config = require __DIR__ . '/../Config/config.php';
        $client = new AIClient($config['ai']);
        $generator = new QuestionGenerator($client);
        try {
            $generator->generateDaily($subtestId, $mode, $date);
            jsonResponse(200, ['message' => 'Daily set generated']);
        } catch (\Throwable $e) {
            jsonResponse(500, ['error' => $e->getMessage()]);
        }
    }
}

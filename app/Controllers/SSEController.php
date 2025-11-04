<?php
namespace App\Controllers;

use App\Models\Attempt;
use App\Models\Battle;

class SSEController
{
    public function scoreboard(): void
    {
        $config = require __DIR__ . '/../Config/config.php';
        if (!$config['sse']['enabled']) {
            http_response_code(503);
            exit('SSE disabled');
        }
        $subtestId = (int) ($_GET['subtest_id'] ?? 0);
        $mode = $_GET['mode'] === 'kejar_waktu' ? 'kejar_waktu' : 'santai';
        $date = $_GET['date'] ?? date('Y-m-d');
        header('Content-Type: text/event-stream');
        header('Cache-Control: no-cache');
        header('Connection: keep-alive');
        echo 'retry: ' . (int) $config['sse']['retry'] . "\n\n";
        while (true) {
            $rows = Attempt::scoreboard($subtestId, $mode, $date, 50);
            $payload = json_encode(['top' => $rows], JSON_UNESCAPED_UNICODE);
            echo 'data: ' . $payload . "\n\n";
            @ob_flush();
            @flush();
            sleep(4);
        }
    }

    public function battle(): void
    {
        $config = require __DIR__ . '/../Config/config.php';
        if (!$config['sse']['enabled']) {
            http_response_code(503);
            exit('SSE disabled');
        }
        $battleId = (int) ($_GET['battle_id'] ?? 0);
        header('Content-Type: text/event-stream');
        header('Cache-Control: no-cache');
        header('Connection: keep-alive');
        echo 'retry: ' . (int) $config['sse']['retry'] . "\n\n";
        while (true) {
            $participants = Battle::participants($battleId);
            $payload = json_encode(['participants' => $participants], JSON_UNESCAPED_UNICODE);
            echo 'data: ' . $payload . "\n\n";
            @ob_flush();
            @flush();
            sleep(4);
        }
    }
}

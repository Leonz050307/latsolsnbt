<?php
namespace App\Controllers;

use App\Models\Attempt;
use App\Models\Scoreboard;

class ApiController
{
    public function scoreboard(): void
    {
        $subtestId = (int) ($_GET['subtest_id'] ?? 0);
        $mode = $_GET['mode'] === 'kejar_waktu' ? 'kejar_waktu' : 'santai';
        $date = $_GET['date'] ?? date('Y-m-d');
        if (!$subtestId) {
            jsonResponse(422, ['error' => 'bad_request']);
            return;
        }
        $cached = Scoreboard::cached($subtestId, $mode, $date);
        if (!$cached) {
            $rows = Attempt::scoreboard($subtestId, $mode, $date, 50);
            Scoreboard::store($subtestId, $mode, $date, ['top' => $rows]);
            $cached = ['top' => $rows];
        }
        jsonResponse(200, $cached);
    }
}

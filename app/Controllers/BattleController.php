<?php
namespace App\Controllers;

use App\Core\Auth;
use App\Core\CSRF;
use App\Services\Matchmaker;
use App\Models\Battle;

class BattleController
{
    private Matchmaker $matchmaker;

    public function __construct()
    {
        $this->matchmaker = new Matchmaker();
    }

    public function join(): void
    {
        CSRF::mustValidate();
        $user = Auth::user();
        if (!$user) {
            jsonResponse(401, ['error' => 'Unauthenticated']);
            return;
        }
        $subtestId = (int) ($_POST['subtest_id'] ?? 0);
        $mode = $_POST['mode'] === 'kejar_waktu' ? 'kejar_waktu' : 'santai';
        $deviceHash = $_POST['device_hash'] ?? '';
        if (!$subtestId || !$deviceHash) {
            jsonResponse(422, ['error' => 'bad_request']);
            return;
        }
        try {
            $result = $this->matchmaker->queue($subtestId, $mode, (int) $user['id'], $deviceHash);
            jsonResponse(200, $result);
        } catch (\RuntimeException $e) {
            jsonResponse(409, ['error' => $e->getMessage()]);
        }
    }

    public function status(): void
    {
        $user = Auth::user();
        if (!$user) {
            jsonResponse(401, ['error' => 'Unauthenticated']);
            return;
        }
        $battleId = (int) ($_GET['battle_id'] ?? 0);
        if (!$battleId) {
            jsonResponse(422, ['error' => 'bad_request']);
            return;
        }
        $participants = Battle::participants($battleId);
        jsonResponse(200, [
            'battle_id' => $battleId,
            'participants' => $participants,
        ]);
    }
}

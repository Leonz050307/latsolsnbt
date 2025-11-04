<?php
namespace App\Services;

use App\Models\Battle;
use App\Models\DailySet;
use RuntimeException;

class Matchmaker
{
    public function queue(int $subtestId, string $mode, int $userId, string $deviceHash): array
    {
        $daily = DailySet::findForToday($subtestId, $mode);
        if (!$daily) {
            throw new RuntimeException('Daily set unavailable');
        }
        $room = Battle::findWaiting($subtestId, $mode);
        if (!$room) {
            $battleId = Battle::create($subtestId, $mode);
            Battle::join($battleId, $userId, $deviceHash);
            Battle::logEvent($battleId, $userId, 'join', ['message' => 'Menunggu lawan']);
            return ['battle_id' => $battleId, 'status' => 'waiting'];
        }
        Battle::join((int) $room['id'], $userId, $deviceHash);
        $participants = Battle::participants((int) $room['id']);
        if (count($participants) >= 2) {
            Battle::updateStatus((int) $room['id'], 'active');
            Battle::logEvent((int) $room['id'], $userId, 'match_start', ['participants' => $participants]);
            return ['battle_id' => (int) $room['id'], 'status' => 'active'];
        }
        return ['battle_id' => (int) $room['id'], 'status' => 'waiting'];
    }
}

<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class Battle
{
    public static function findWaiting(int $subtestId, string $mode): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM battle_rooms WHERE subtest_id = ? AND mode = ? AND for_date = CURDATE() AND status = "waiting" LIMIT 1');
        $stmt->execute([$subtestId, $mode]);
        $room = $stmt->fetch();
        return $room ?: null;
    }

    public static function create(int $subtestId, string $mode): int
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO battle_rooms (subtest_id, mode, for_date) VALUES (?, ?, CURDATE())');
        $stmt->execute([$subtestId, $mode]);
        return (int) $pdo->lastInsertId();
    }

    public static function join(int $battleId, int $userId, string $deviceHash): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO battle_participants (battle_id, user_id, device_hash) VALUES (?, ?, ?)');
        $stmt->execute([$battleId, $userId, $deviceHash]);
    }

    public static function participants(int $battleId): array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT p.*, u.username FROM battle_participants p JOIN users u ON u.id = p.user_id WHERE p.battle_id = ? ORDER BY p.joined_at');
        $stmt->execute([$battleId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function updateStatus(int $battleId, string $status): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('UPDATE battle_rooms SET status = ?, started_at = IF(? = "active", NOW(), started_at) WHERE id = ?');
        $stmt->execute([$status, $status, $battleId]);
    }

    public static function logEvent(int $battleId, int $userId, string $type, array $payload): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO battle_events (battle_id, user_id, event_type, payload) VALUES (?, ?, ?, ?)');
        $stmt->execute([$battleId, $userId, $type, json_encode($payload, JSON_UNESCAPED_UNICODE)]);
    }
}

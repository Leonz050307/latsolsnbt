<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class Scoreboard
{
    public static function cached(int $subtestId, string $mode, string $date): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT payload FROM scoreboard_cache WHERE subtest_id = ? AND mode = ? AND for_date = ? LIMIT 1');
        $stmt->execute([$subtestId, $mode, $date]);
        $payload = $stmt->fetchColumn();
        return $payload ? json_decode($payload, true) : null;
    }

    public static function store(int $subtestId, string $mode, string $date, array $data): void
    {
        $pdo = Database::pdo();
        $json = json_encode($data, JSON_UNESCAPED_UNICODE);
        $stmt = $pdo->prepare('INSERT INTO scoreboard_cache (subtest_id, mode, for_date, payload, built_at) VALUES (?, ?, ?, ?, NOW())
            ON DUPLICATE KEY UPDATE payload = VALUES(payload), built_at = NOW()');
        $stmt->execute([$subtestId, $mode, $date, $json]);
    }
}

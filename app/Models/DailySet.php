<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class DailySet
{
    public static function findForToday(int $subtestId, string $mode): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM daily_sets WHERE subtest_id = ? AND mode = ? AND for_date = CURDATE() LIMIT 1');
        $stmt->execute([$subtestId, $mode]);
        $daily = $stmt->fetch();
        return $daily ?: null;
    }

    public static function findForDate(int $subtestId, string $mode, string $date): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM daily_sets WHERE subtest_id = ? AND mode = ? AND for_date = ? LIMIT 1');
        $stmt->execute([$subtestId, $mode, $date]);
        $daily = $stmt->fetch();
        return $daily ?: null;
    }
}

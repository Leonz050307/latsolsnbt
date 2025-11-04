<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class User
{
    public static function findByEmail(string $email): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM users WHERE email = ? LIMIT 1');
        $stmt->execute([$email]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    public static function find(int $id): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM users WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $user = $stmt->fetch();
        return $user ?: null;
    }

    public static function leaderboardCandidates(string $startDate, string $endDate): array
    {
        $pdo = Database::pdo();
        $sql = 'SELECT u.id, u.username, SUM(a.score) as total_score FROM attempts a JOIN users u ON u.id = a.user_id
                WHERE a.for_date BETWEEN ? AND ? AND a.status = "submitted" GROUP BY u.id ORDER BY total_score DESC LIMIT 50';
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$startDate, $endDate]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}

<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class Subtest
{
    public static function allActive(): array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->query('SELECT id, slug, name, description FROM subtests WHERE is_active = 1 ORDER BY name');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function find(int $id): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM subtests WHERE id = ? AND is_active = 1 LIMIT 1');
        $stmt->execute([$id]);
        $subtest = $stmt->fetch();
        return $subtest ?: null;
    }
}

<?php
namespace App\Models;

use App\Core\Database;
use PDO;

class Attempt
{
    public static function findById(int $id): ?array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM attempts WHERE id = ? LIMIT 1');
        $stmt->execute([$id]);
        $attempt = $stmt->fetch();
        return $attempt ?: null;
    }

    public static function existsToday(int $userId, string $deviceHash): bool
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT id FROM attempts WHERE (user_id = ? OR device_hash = ?) AND for_date = CURDATE() LIMIT 1');
        $stmt->execute([$userId, $deviceHash]);
        return (bool) $stmt->fetchColumn();
    }

    public static function create(int $userId, int $subtestId, string $mode, string $deviceHash): int
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO attempts (user_id, subtest_id, for_date, mode, device_hash) VALUES (?, ?, CURDATE(), ?, ?)');
        $stmt->execute([$userId, $subtestId, $mode, $deviceHash]);
        return (int) $pdo->lastInsertId();
    }

    public static function attachQuestions(int $attemptId, array $questions): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO attempt_items (attempt_id, question_id) VALUES (?, ?)');
        foreach ($questions as $question) {
            $stmt->execute([$attemptId, $question['id']]);
        }
    }

    public static function saveAnswer(int $attemptId, int $questionId, string $choice, bool $isCorrect): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('UPDATE attempt_items SET chosen = ?, is_correct = ?, responded_at = NOW() WHERE attempt_id = ? AND question_id = ?');
        $stmt->execute([$choice, $isCorrect ? 1 : 0, $attemptId, $questionId]);
    }

    public static function finalize(int $attemptId): array
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT SUM(is_correct) AS score FROM attempt_items WHERE attempt_id = ?');
        $stmt->execute([$attemptId]);
        $score = (int) $stmt->fetchColumn();
        $pdo->prepare('UPDATE attempts SET score = ?, finished_at = NOW(), duration_seconds = TIMESTAMPDIFF(SECOND, started_at, NOW()), status = "submitted" WHERE id = ?')
            ->execute([$score, $attemptId]);
        return ['score' => $score];
    }

    public static function scoreboard(int $subtestId, string $mode, string $date, int $limit = 50): array
    {
        $pdo = Database::pdo();
        $sql = 'SELECT u.username, a.score, a.duration_seconds FROM attempts a JOIN users u ON u.id = a.user_id WHERE a.subtest_id = ? AND a.for_date = ? AND a.mode = ? AND a.status = "submitted" ORDER BY a.score DESC, a.duration_seconds ASC LIMIT ' . (int) $limit;
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$subtestId, $date, $mode]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}

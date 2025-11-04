<?php
namespace App\Models;

use App\Core\Database;

class Question
{
    public static function questionsForDaily(int $dailySetId): array
    {
        $pdo = Database::pdo();
        $sql = 'SELECT q.id, q.number, q.stem, q.correct_choice, q.explanation, c.label, c.content FROM questions q
                JOIN choices c ON c.question_id = q.id WHERE q.daily_set_id = ? ORDER BY q.number ASC, c.label ASC';
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$dailySetId]);
        $rows = $stmt->fetchAll();
        return reshape_questions($rows);
    }
}

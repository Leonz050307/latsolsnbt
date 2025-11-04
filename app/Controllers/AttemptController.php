<?php
namespace App\Controllers;

use App\Core\Auth;
use App\Core\CSRF;
use App\Models\Attempt;
use App\Models\DailySet;
use App\Models\Question;
use App\Models\Subtest;
use Exception;

class AttemptController
{
    public function start(): void
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
        $pdo = \App\Core\Database::pdo();
        $pdo->beginTransaction();
        try {
            if (Attempt::existsToday((int) $user['id'], $deviceHash)) {
                throw new Exception('attempt_exists');
            }
            $daily = DailySet::findForToday($subtestId, $mode);
            if (!$daily) {
                throw new Exception('daily_not_ready');
            }
            $questions = Question::questionsForDaily((int) $daily['id']);
            $attemptId = Attempt::create((int) $user['id'], $subtestId, $mode, $deviceHash);
            Attempt::attachQuestions($attemptId, $questions);
            $pdo->commit();
            jsonResponse(200, [
                'attempt_id' => $attemptId,
                'questions' => array_map(static function ($question) {
                    unset($question['correct_choice']);
                    return $question;
                }, $questions),
                'mode' => $mode,
            ]);
        } catch (Exception $e) {
            $pdo->rollBack();
            jsonResponse(409, ['error' => $e->getMessage()]);
        }
    }

    public function answer(): void
    {
        CSRF::mustValidate();
        $user = Auth::user();
        if (!$user) {
            jsonResponse(401, ['error' => 'Unauthenticated']);
            return;
        }
        $attemptId = (int) ($_POST['attempt_id'] ?? 0);
        $questionId = (int) ($_POST['question_id'] ?? 0);
        $choice = $_POST['choice'] ?? '';
        if (!$attemptId || !$questionId || !in_array($choice, ['A', 'B', 'C', 'D', 'E'], true)) {
            jsonResponse(422, ['error' => 'bad_request']);
            return;
        }
        $attempt = Attempt::findById($attemptId);
        if (!$attempt || (int) $attempt['user_id'] !== (int) $user['id']) {
            jsonResponse(403, ['error' => 'forbidden']);
            return;
        }
        if ($attempt['status'] !== 'ongoing') {
            jsonResponse(409, ['error' => 'attempt_closed']);
            return;
        }
        $pdo = \App\Core\Database::pdo();
        $stmt = $pdo->prepare('SELECT correct_choice FROM questions WHERE id = ? LIMIT 1');
        $stmt->execute([$questionId]);
        $correct = $stmt->fetchColumn();
        $isCorrect = $correct === $choice;
        Attempt::saveAnswer($attemptId, $questionId, $choice, $isCorrect);
        jsonResponse(200, ['saved' => true]);
    }

    public function submit(): void
    {
        CSRF::mustValidate();
        $user = Auth::user();
        if (!$user) {
            jsonResponse(401, ['error' => 'Unauthenticated']);
            return;
        }
        $attemptId = (int) ($_POST['attempt_id'] ?? 0);
        $attempt = Attempt::findById($attemptId);
        if (!$attempt || (int) $attempt['user_id'] !== (int) $user['id']) {
            jsonResponse(403, ['error' => 'forbidden']);
            return;
        }
        $result = Attempt::finalize($attemptId);
        jsonResponse(200, $result);
    }

    public function status(): void
    {
        $user = Auth::user();
        if (!$user) {
            jsonResponse(401, ['error' => 'Unauthenticated']);
            return;
        }
        $attemptId = (int) ($_GET['id'] ?? 0);
        $attempt = Attempt::findById($attemptId);
        if (!$attempt || (int) $attempt['user_id'] !== (int) $user['id']) {
            jsonResponse(403, ['error' => 'forbidden']);
            return;
        }
        jsonResponse(200, [
            'status' => $attempt['status'],
            'score' => $attempt['score'],
            'started_at' => $attempt['started_at'],
            'finished_at' => $attempt['finished_at'],
        ]);
    }
}

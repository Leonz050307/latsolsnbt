<?php
namespace App\Services;

use App\Core\Database;
use App\Models\Subtest;
use RuntimeException;

class QuestionGenerator
{
    private AIClient $client;

    public function __construct(AIClient $client)
    {
        $this->client = $client;
    }

    public function generateDaily(int $subtestId, string $mode, string $date): array
    {
        $subtest = Subtest::find($subtestId);
        if (!$subtest) {
            throw new RuntimeException('Subtest not found');
        }
        $prompt = $this->buildPrompt($subtest['name'], $mode, $date);
        $response = $this->client->generate([
            ['role' => 'system', 'content' => 'Anda adalah generator soal SNBT terpercaya.'],
            ['role' => 'user', 'content' => $prompt],
        ]);
        $content = $response['choices'][0]['message']['content'] ?? '';
        $data = json_decode($content, true);
        if (!is_array($data) || empty($data['questions']) || count($data['questions']) !== 5) {
            throw new RuntimeException('Invalid AI response');
        }
        $this->storeDailySet($subtestId, $mode, $date, $prompt, $response['model'] ?? '');
        $dailySetId = (int) Database::pdo()->lastInsertId();
        $this->storeQuestions($dailySetId, $data['questions']);
        return ['daily_set_id' => $dailySetId];
    }

    private function buildPrompt(string $subtestName, string $mode, string $date): string
    {
        $modeLabel = $mode === 'kejar_waktu' ? 'Kejar Waktu (durasi 7 menit)' : 'Santai (durasi 20 menit)';
        return <<<PROMPT
Anda adalah generator soal SNBT subtest {$subtestName} untuk tanggal {$date} mode {$modeLabel}.
Buat 5 soal pilihan ganda, bahasa Indonesia baku, kesulitan menengah, sesuai kisi-kisi SNBT terbaru.
Keluarkan JSON valid dengan struktur:
{
  "questions": [
    {
      "number": 1,
      "stem": "...",
      "choices": {"A": "...", "B": "...", "C": "...", "D": "...", "E": "..."},
      "correct": "C",
      "explanation": "..."
    }, ...
  ]
}
Pastikan tidak ada duplikasi, tanpa hak cipta, logis, dapat diselesaikan tanpa alat.
PROMPT;
    }

    private function storeDailySet(int $subtestId, string $mode, string $date, string $prompt, string $model): void
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('INSERT INTO daily_sets (subtest_id, for_date, mode, ai_prompt, ai_model) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE ai_prompt = VALUES(ai_prompt), ai_model = VALUES(ai_model), created_at = NOW()');
        $stmt->execute([$subtestId, $date, $mode, $prompt, $model]);
    }

    private function storeQuestions(int $dailySetId, array $questions): void
    {
        $pdo = Database::pdo();
        $pdo->prepare('DELETE FROM questions WHERE daily_set_id = ?')->execute([$dailySetId]);
        foreach ($questions as $question) {
            $number = (int) $question['number'];
            $stem = $question['stem'] ?? '';
            $correct = $question['correct'] ?? '';
            $explanation = $question['explanation'] ?? null;
            if (!$stem || !in_array($correct, ['A', 'B', 'C', 'D', 'E'], true)) {
                throw new RuntimeException('Invalid question payload');
            }
            $stmt = $pdo->prepare('INSERT INTO questions (daily_set_id, number, stem, correct_choice, explanation) VALUES (?, ?, ?, ?, ?)');
            $stmt->execute([$dailySetId, $number, $stem, $correct, $explanation]);
            $questionId = (int) $pdo->lastInsertId();
            foreach ($question['choices'] as $label => $content) {
                $pdo->prepare('INSERT INTO choices (question_id, label, content) VALUES (?, ?, ?)')
                    ->execute([$questionId, $label, $content]);
            }
        }
    }
}

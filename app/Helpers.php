<?php
use App\Core\CSRF;

if (!function_exists('view')) {
    function view(string $template, array $data = []): void
    {
        extract($data, EXTR_SKIP);
        $viewPath = __DIR__ . '/Views/' . $template . '.php';
        if (!file_exists($viewPath)) {
            http_response_code(500);
            echo 'View not found';
            return;
        }
        include __DIR__ . '/Views/layouts/base.php';
    }
}

if (!function_exists('section')) {
    function section(string $template, array $data = []): void
    {
        extract($data, EXTR_SKIP);
        $viewPath = __DIR__ . '/Views/' . $template . '.php';
        if (file_exists($viewPath)) {
            include $viewPath;
        }
    }
}

if (!function_exists('jsonResponse')) {
    function jsonResponse(int $status, array $payload): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode(['ok' => $status >= 200 && $status < 300, 'data' => $payload], JSON_UNESCAPED_UNICODE);
    }
}

if (!function_exists('device_hash')) {
    function device_hash(string $userAgent, string $ipSubnet, string $uuid): string
    {
        return hash('sha256', $userAgent . '|' . $ipSubnet . '|' . $uuid);
    }
}

if (!function_exists('csrf_field')) {
    function csrf_field(): string
    {
        return CSRF::input();
    }
}

if (!function_exists('sanitize')) {
    function sanitize(string $value): string
    {
        return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
    }
}

if (!function_exists('reshape_questions')) {
    function reshape_questions(array $rows): array
    {
        $questions = [];
        foreach ($rows as $row) {
            $id = (int) $row['id'];
            if (!isset($questions[$id])) {
                $questions[$id] = [
                    'id' => $id,
                    'number' => (int) $row['number'],
                    'stem' => $row['stem'],
                    'explanation' => $row['explanation'] ?? null,
                    'correct_choice' => $row['correct_choice'],
                    'choices' => [],
                ];
            }
            $questions[$id]['choices'][$row['label']] = $row['content'];
        }
        usort($questions, static function ($a, $b) {
            return $a['number'] <=> $b['number'];
        });
        return array_values($questions);
    }
}

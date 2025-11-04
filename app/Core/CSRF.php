<?php
namespace App\Core;

class CSRF
{
    public static function token(): string
    {
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }
        if (empty($_SESSION['csrf_token'])) {
            $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
        }
        return $_SESSION['csrf_token'];
    }

    public static function input(): string
    {
        $config = require __DIR__ . '/../Config/config.php';
        $tokenName = $config['csrf']['token_name'];
        $token = self::token();
        return '<input type="hidden" name="' . htmlspecialchars($tokenName, ENT_QUOTES, 'UTF-8') . '" value="' . $token . '">';
    }

    public static function validate(): bool
    {
        $config = require __DIR__ . '/../Config/config.php';
        $tokenName = $config['csrf']['token_name'];
        if (session_status() !== PHP_SESSION_ACTIVE) {
            session_start();
        }
        $token = $_POST[$tokenName] ?? $_GET[$tokenName] ?? '';
        return hash_equals($_SESSION['csrf_token'] ?? '', $token);
    }

    public static function mustValidate(): void
    {
        if (!self::validate()) {
            http_response_code(419);
            exit('CSRF token mismatch');
        }
    }
}

<?php
namespace App\Core;

use DateTimeImmutable;
use Exception;

class Auth
{
    public static function user(): ?array
    {
        if (empty($_COOKIE['sid'])) {
            return null;
        }
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT u.*, s.expires_at, s.ip, s.user_agent FROM sessions s JOIN users u ON u.id = s.user_id WHERE s.id = ? AND s.expires_at > NOW() LIMIT 1');
        $stmt->execute([$_COOKIE['sid']]);
        $user = $stmt->fetch();
        if (!$user) {
            return null;
        }
        return $user;
    }

    public static function requireRole(array $roles): void
    {
        $user = self::user();
        if (!$user || !in_array($user['role'], $roles, true)) {
            http_response_code(403);
            exit('Forbidden');
        }
    }

    public static function login(string $email, string $password): bool
    {
        $pdo = Database::pdo();
        $stmt = $pdo->prepare('SELECT * FROM users WHERE email = ? AND is_active = 1 LIMIT 1');
        $stmt->execute([$email]);
        $user = $stmt->fetch();
        if (!$user || !password_verify($password, $user['password_hash'])) {
            return false;
        }
        $config = require __DIR__ . '/../Config/config.php';
        $sid = bin2hex(random_bytes(32));
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $ip = $_SERVER['REMOTE_ADDR'] ?? '';
        $expires = new DateTimeImmutable('+' . $config['session_lifetime'] . ' seconds');
        $pdo->prepare('INSERT INTO sessions (id, user_id, ip, user_agent, expires_at) VALUES (?, ?, ?, ?, ?)')
            ->execute([$sid, $user['id'], $ip, mb_substr($ua, 0, 255), $expires->format('Y-m-d H:i:s')]);
        self::setSessionCookie($sid, $config['session_lifetime']);
        $pdo->prepare('UPDATE users SET last_login_at = NOW() WHERE id = ?')->execute([$user['id']]);
        return true;
    }

    public static function register(array $data): array
    {
        $pdo = Database::pdo();
        $pdo->beginTransaction();
        try {
            $passwordHash = password_hash($data['password'], PASSWORD_BCRYPT, ['cost' => 12]);
            $stmt = $pdo->prepare('INSERT INTO users (email, username, password_hash) VALUES (?, ?, ?)');
            $stmt->execute([$data['email'], $data['username'], $passwordHash]);
            $userId = (int) $pdo->lastInsertId();
            $pdo->commit();
            return ['id' => $userId];
        } catch (Exception $e) {
            $pdo->rollBack();
            throw $e;
        }
    }

    public static function logout(): void
    {
        if (!empty($_COOKIE['sid'])) {
            $pdo = Database::pdo();
            $pdo->prepare('DELETE FROM sessions WHERE id = ?')->execute([$_COOKIE['sid']]);
            setcookie('sid', '', time() - 3600, '/', '', isset($_SERVER['HTTPS']), true);
        }
    }

    private static function setSessionCookie(string $sid, int $lifetime): void
    {
        $secure = !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off';
        setcookie('sid', $sid, [
            'expires' => time() + $lifetime,
            'path' => '/',
            'domain' => '',
            'secure' => $secure,
            'httponly' => true,
            'samesite' => 'Lax',
        ]);
    }
}

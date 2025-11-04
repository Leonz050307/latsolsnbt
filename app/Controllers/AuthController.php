<?php
namespace App\Controllers;

use App\Core\Auth;
use App\Core\CSRF;
use App\Core\RateLimiter;
use App\Models\User;
use Exception;

class AuthController
{
    public function showLogin(): void
    {
        view('auth/login', ['title' => 'Masuk']);
    }

    public function login(): void
    {
        CSRF::mustValidate();
        $config = require __DIR__ . '/../Config/config.php';
        $key = 'login_' . ($_SERVER['REMOTE_ADDR'] ?? '');
        if (!RateLimiter::check($key, $config['security']['rate_limit']['login']['max'], $config['security']['rate_limit']['login']['window'])) {
            view('auth/login', ['title' => 'Masuk', 'error' => 'Terlalu banyak percobaan. Coba lagi nanti.']);
            return;
        }
        $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL) ?: '';
        $password = $_POST['password'] ?? '';
        if (!$email || !$password) {
            view('auth/login', ['title' => 'Masuk', 'error' => 'Email dan password wajib diisi.']);
            return;
        }
        if (!Auth::login($email, $password)) {
            view('auth/login', ['title' => 'Masuk', 'error' => 'Kredensial tidak valid.']);
            return;
        }
        header('Location: /dashboard');
        exit;
    }

    public function showRegister(): void
    {
        view('auth/register', ['title' => 'Daftar']);
    }

    public function register(): void
    {
        CSRF::mustValidate();
        $email = filter_input(INPUT_POST, 'email', FILTER_SANITIZE_EMAIL) ?: '';
        $username = trim($_POST['username'] ?? '');
        $password = $_POST['password'] ?? '';
        $confirm = $_POST['password_confirmation'] ?? '';
        if (!$email || !$username || !$password) {
            view('auth/register', ['title' => 'Daftar', 'error' => 'Semua field wajib diisi.']);
            return;
        }
        if ($password !== $confirm) {
            view('auth/register', ['title' => 'Daftar', 'error' => 'Konfirmasi password tidak cocok.']);
            return;
        }
        if (User::findByEmail($email)) {
            view('auth/register', ['title' => 'Daftar', 'error' => 'Email sudah terdaftar.']);
            return;
        }
        try {
            Auth::register(compact('email', 'username', 'password'));
            view('auth/login', ['title' => 'Masuk', 'success' => 'Pendaftaran berhasil. Silakan masuk.']);
        } catch (Exception $e) {
            view('auth/register', ['title' => 'Daftar', 'error' => 'Gagal daftar: ' . $e->getMessage()]);
        }
    }

    public function logout(): void
    {
        CSRF::mustValidate();
        Auth::logout();
        header('Location: /');
        exit;
    }
}

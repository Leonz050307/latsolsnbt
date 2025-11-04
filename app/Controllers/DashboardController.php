<?php
namespace App\Controllers;

use App\Core\Auth;
use App\Models\Subtest;

class DashboardController
{
    public function index(): void
    {
        $user = Auth::user();
        if (!$user) {
            header('Location: /login');
            exit;
        }
        $subtests = Subtest::allActive();
        view('dashboard/index', [
            'title' => 'Dashboard',
            'user' => $user,
            'subtests' => $subtests,
        ]);
    }
}

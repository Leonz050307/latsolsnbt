<section class="auth">
    <div class="container">
        <div class="auth-card glass-card">
            <h1>Daftar Akun</h1>
            <?php if (!empty($error)): ?>
                <div class="alert alert-danger"><?= sanitize($error) ?></div>
            <?php endif; ?>
            <form method="POST" action="/register">
                <?= csrf_field() ?>
                <label>Email
                    <input type="email" name="email" required>
                </label>
                <label>Username
                    <input type="text" name="username" required>
                </label>
                <label>Password
                    <input type="password" name="password" required minlength="8">
                </label>
                <label>Konfirmasi Password
                    <input type="password" name="password_confirmation" required minlength="8">
                </label>
                <button type="submit" class="btn btn-primary w-full">Daftar</button>
            </form>
            <p class="switch">Sudah punya akun? <a href="/login">Masuk</a>.</p>
        </div>
    </div>
</section>

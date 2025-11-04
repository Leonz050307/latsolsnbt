<section class="auth">
    <div class="container">
        <div class="auth-card glass-card">
            <h1>Masuk</h1>
            <?php if (!empty($error)): ?>
                <div class="alert alert-danger"><?= sanitize($error) ?></div>
            <?php elseif (!empty($success)): ?>
                <div class="alert alert-success"><?= sanitize($success) ?></div>
            <?php endif; ?>
            <form method="POST" action="/login">
                <?= csrf_field() ?>
                <label>Email
                    <input type="email" name="email" required>
                </label>
                <label>Password
                    <input type="password" name="password" required>
                </label>
                <button type="submit" class="btn btn-primary w-full">Masuk</button>
            </form>
            <p class="switch">Belum punya akun? <a href="/register">Daftar sekarang</a>.</p>
        </div>
    </div>
</section>

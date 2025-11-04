<section class="dashboard">
    <div class="container">
        <h1>Selamat datang, <?= sanitize($user['username']) ?>!</h1>
        <p>Pilih subtest SNBT untuk attempt harianmu. Setiap subtest berisi 5 soal.</p>
        <div class="subtest-grid">
            <?php foreach ($subtests as $subtest): ?>
                <div class="glass-card subtest-card">
                    <h3><?= sanitize($subtest['name']) ?></h3>
                    <p><?= sanitize($subtest['description'] ?? 'Materi latihan SNBT fokus pada kompetensi inti. ') ?></p>
                    <div class="actions">
                        <button class="btn btn-primary" data-subtest="<?= (int) $subtest['id'] ?>" data-mode="kejar_waktu">Kejar Waktu</button>
                        <button class="btn btn-secondary" data-subtest="<?= (int) $subtest['id'] ?>" data-mode="santai">Santai</button>
                        <button class="btn btn-ghost battle" data-subtest="<?= (int) $subtest['id'] ?>">Battle</button>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <div id="attempt-result" class="attempt-result"></div>
    </div>
</section>

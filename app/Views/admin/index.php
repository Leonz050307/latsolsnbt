<section class="admin">
    <div class="container">
        <h1>Panel Admin</h1>
        <p>Generate set harian dari AI untuk subtest berikut.</p>
        <div class="glass-card">
            <form id="generate-daily" method="POST" action="/admin/generate_daily">
                <?= csrf_field() ?>
                <label>Subtest
                    <select name="subtest_id">
                        <?php foreach ($subtests as $subtest): ?>
                            <option value="<?= (int) $subtest['id'] ?>"><?= sanitize($subtest['name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </label>
                <label>Mode
                    <select name="mode">
                        <option value="kejar_waktu">Kejar Waktu</option>
                        <option value="santai">Santai</option>
                    </select>
                </label>
                <label>Tanggal
                    <input type="date" name="date" value="<?= date('Y-m-d') ?>">
                </label>
                <button type="submit" class="btn btn-primary">Generate</button>
            </form>
            <div id="generate-status"></div>
        </div>
    </div>
</section>

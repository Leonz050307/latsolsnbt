<section class="scoreboard">
    <div class="container">
        <h1>Scoreboard Harian</h1>
        <form class="filters glass-card" id="scoreboard-filter">
            <label>Subtest
                <select name="subtest_id" id="filter-subtest">
                    <?php foreach ($subtests as $subtest): ?>
                        <option value="<?= (int) $subtest['id'] ?>"><?= sanitize($subtest['name']) ?></option>
                    <?php endforeach; ?>
                </select>
            </label>
            <label>Mode
                <select name="mode" id="filter-mode">
                    <option value="kejar_waktu">Kejar Waktu</option>
                    <option value="santai">Santai</option>
                </select>
            </label>
            <label>Tanggal
                <input type="date" name="date" id="filter-date" value="<?= date('Y-m-d') ?>">
            </label>
        </form>
        <div class="glass-card table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>Peringkat</th>
                        <th>Username</th>
                        <th>Skor</th>
                        <th>Durasi (detik)</th>
                    </tr>
                </thead>
                <tbody id="scoreboard-body"></tbody>
            </table>
        </div>
    </div>
</section>

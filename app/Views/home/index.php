<section class="hero">
    <div class="container hero-grid">
        <div class="hero-copy glass-card">
            <span class="badge">Latihan SNBT Harian</span>
            <h1>Asah kemampuanmu setiap hari dengan soal terbaru SNBT.</h1>
            <p>Ambil 5 soal per subtest setiap hari, ikuti mode Kejar Waktu atau Santai, dan raih gelar Sepuh di leaderboard.</p>
            <div class="cta-group">
                <a class="btn btn-primary" href="/register">Mulai Sekarang</a>
                <a class="btn btn-secondary" href="/scoreboard">Lihat Scoreboard</a>
                <button id="btn-lofi" class="btn btn-ghost">▶️ Play Lofi</button>
            </div>
        </div>
        <div class="hero-bento">
            <div class="bento-card glass-card">
                <h3>Subtest SNBT Populer</h3>
                <ul>
                    <li>Penalaran Umum</li>
                    <li>Pengetahuan &amp; Pemahaman Umum</li>
                    <li>Penalaran Matematika</li>
                    <li>Literasi Bahasa Indonesia</li>
                    <li>Literasi Bahasa Inggris</li>
                </ul>
            </div>
            <div class="bento-card glass-card">
                <h3>Leaderboard</h3>
                <p>Top 50 otomatis diperbarui setiap 5 detik melalui SSE.</p>
            </div>
            <div class="bento-card glass-card">
                <h3>Mode</h3>
                <p><strong>Kejar Waktu:</strong> 7 menit<br><strong>Santai:</strong> 20 menit</p>
            </div>
            <div class="bento-card glass-card">
                <h3>Battle Mode</h3>
                <p>Matchmaking acak, lawan real-time, tanpa websocket.</p>
            </div>
        </div>
    </div>
    <div id="yt-holder" class="hidden"></div>
</section>
<section class="features">
    <div class="container grid">
        <div class="feature-card glass-card">
            <h3>Soal AI Terverifikasi</h3>
            <p>Pertanyaan digenerate AI sesuai kisi-kisi SNBT dan divalidasi otomatis.</p>
        </div>
        <div class="feature-card glass-card">
            <h3>Anti-Cheat Device Binding</h3>
            <p>Satu akun dan satu perangkat hanya satu attempt per hari dengan fingerprint aman.</p>
        </div>
        <div class="feature-card glass-card">
            <h3>Premium Mentoring</h3>
            <p>Tanyakan admin untuk paket premium via WhatsApp.</p>
            <a class="btn btn-secondary" href="https://wa.me/6281234567890?text=Halo+Admin,+saya+mau+upgrade+Premium" target="_blank" rel="noopener">Hubungi Admin</a>
        </div>
    </div>
</section>
<script>
let ytPlayer, lofiOn = false;
const btn = document.getElementById('btn-lofi');
if (btn) {
    btn.addEventListener('click', async () => {
        if (!window.YT) {
            const s = document.createElement('script');
            s.src = 'https://www.youtube.com/iframe_api';
            document.head.appendChild(s);
            await new Promise(resolve => {
                window.onYouTubeIframeAPIReady = () => {
                    ytPlayer = new YT.Player('yt-holder', {
                        height: '0',
                        width: '0',
                        videoId: '5qap5aO4i9A',
                        playerVars: { rel: 0, modestbranding: 1 }
                    });
                    resolve();
                };
            });
        }
        if (ytPlayer && !lofiOn) {
            ytPlayer.mute();
            ytPlayer.playVideo();
            ytPlayer.unMute();
            lofiOn = true;
            btn.textContent = '⏸️ Pause Lofi';
        } else if (ytPlayer) {
            ytPlayer.pauseVideo();
            lofiOn = false;
            btn.textContent = '▶️ Play Lofi';
        }
    });
}
</script>

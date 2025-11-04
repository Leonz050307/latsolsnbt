# latsolsnbt

Repositori ini berisi skema SQL untuk basis data latsolsnbt berbasis MariaDB/MySQL.
Skema ini membuat seluruh tabel utama (users, subtests, daily_sets, dsb.), menambahkan
blueprint materi UTBK-SNBT 2025, serta menyiapkan prompt AI untuk menghasilkan soal harian.

## Isi skema

- Definisi tabel autentikasi, sesi, percobaan, dan battle sesuai struktur produksi.
- Tabel blueprint baru: `subtest_blueprints`, `subtest_components`, `subtest_topics`,
  `component_topics`, dan `subtest_prompt_templates` yang menaut ke `subtests`.
- Seed subtest SNBT 2025 lengkap dengan jumlah soal, durasi, komponen, dan kisi-kisi topik.
- Template prompt AI untuk mode *kejar waktu* dan *santai* di setiap subtes.
- Perintah `INSERT ... SELECT` yang otomatis membuat entri `daily_sets` untuk tanggal hari ini
  agar pengguna tidak lagi menerima galat `daily_not_ready` ketika memilih mode latihan.

Jalankan `schema.sql` pada server MariaDB/MySQL (disarankan versi 10.6+/8.0+) untuk
menginisialisasi atau memperbarui basis data latsolsnbt.

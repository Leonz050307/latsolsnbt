SET NAMES utf8mb4;
SET time_zone = '+07:00';

-- Seed default admin user
INSERT INTO users (id, email, username, password_hash, role, created_at, is_active)
VALUES
  (
    1,
    'admin@example.com',
    'admin',
    '$2y$12$/ijpF5TD5P.NusIxjCz8DOEqFSEeRxlbU1jcS1i0IA0MTqnr3eUR.',
    'admin',
    NOW(),
    1
  )
ON DUPLICATE KEY UPDATE
  email = VALUES(email),
  username = VALUES(username),
  password_hash = VALUES(password_hash),
  role = VALUES(role),
  is_active = VALUES(is_active);

-- Seed subtests
INSERT INTO subtests (id, slug, name, description, is_active)
VALUES
  (1, 'penalaran-umum', 'Penalaran Umum', 'Latihan harian untuk penalaran umum.', 1),
  (2, 'literasi-matematika', 'Literasi Matematika', 'Pemahaman konsep dasar matematika.', 1),
  (3, 'literasi-bahasa', 'Literasi Bahasa', 'Kemampuan memahami bacaan kompleks.', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  is_active = VALUES(is_active);

-- Seed daily set untuk Penalaran Umum tanggal 2024-01-01
INSERT INTO daily_sets (id, subtest_id, for_date, mode, ai_prompt, ai_model, created_at)
VALUES
  (
    1,
    1,
    '2024-01-01',
    'kejar_waktu',
    'Buat 3 soal penalaran umum tingkat menengah dalam bahasa Indonesia.',
    'gpt-4',
    NOW()
  )
ON DUPLICATE KEY UPDATE
  ai_prompt = VALUES(ai_prompt),
  ai_model = VALUES(ai_model);

-- Seed questions untuk daily set Penalaran Umum
INSERT INTO questions (id, daily_set_id, number, stem, explanation, correct_choice, created_at)
VALUES
  (
    1,
    1,
    1,
    'Jika semua siswa rajin belajar, dan Budi adalah seorang siswa, pernyataan apa yang pasti benar?',
    'Sebagai siswa, Budi termasuk ke dalam kelompok yang rajin belajar.',
    'A',
    NOW()
  ),
  (
    2,
    1,
    2,
    'Urutan huruf berikut mengikuti pola tertentu: A, C, F, J, .... Huruf apa yang seharusnya muncul berikutnya?',
    'Selisih antar huruf bertambah satu: +2, +3, +4, sehingga huruf berikutnya adalah O.',
    'C',
    NOW()
  ),
  (
    3,
    1,
    3,
    'Dua pernyataan: (1) Semua penulis suka membaca. (2) Rina tidak suka membaca. Kesimpulan apa yang paling tepat?',
    'Jika Rina tidak suka membaca, maka ia bukan penulis.',
    'B',
    NOW()
  )
ON DUPLICATE KEY UPDATE
  stem = VALUES(stem),
  explanation = VALUES(explanation),
  correct_choice = VALUES(correct_choice);

-- Seed choices untuk setiap pertanyaan
INSERT INTO choices (id, question_id, label, content)
VALUES
  (1, 1, 'A', 'Budi rajin belajar.'),
  (2, 1, 'B', 'Budi tidak rajin belajar.'),
  (3, 1, 'C', 'Tidak dapat disimpulkan apakah Budi rajin.'),
  (4, 1, 'D', 'Budi bukan siswa.'),
  (5, 2, 'A', 'Huruf L'),
  (6, 2, 'B', 'Huruf M'),
  (7, 2, 'C', 'Huruf O'),
  (8, 2, 'D', 'Huruf Q'),
  (9, 3, 'A', 'Rina adalah penulis.'),
  (10, 3, 'B', 'Rina bukan penulis.'),
  (11, 3, 'C', 'Rina suka membaca.'),
  (12, 3, 'D', 'Rina seorang editor.')
ON DUPLICATE KEY UPDATE
  content = VALUES(content);

-- Seed attempt contoh untuk admin pada daily set
INSERT INTO attempts (id, user_id, subtest_id, for_date, mode, started_at, finished_at, device_hash, score, duration_seconds, status)
VALUES
  (
    1,
    1,
    1,
    '2024-01-01',
    'kejar_waktu',
    NOW(),
    NOW(),
    'd41d8cd98f00b204e9800998ecf8427e',
    3,
    180,
    'submitted'
  )
ON DUPLICATE KEY UPDATE
  score = VALUES(score),
  duration_seconds = VALUES(duration_seconds),
  status = VALUES(status);

-- Seed attempt items untuk attempt contoh
INSERT INTO attempt_items (id, attempt_id, question_id, chosen, is_correct, responded_at)
VALUES
  (1, 1, 1, 'A', 1, NOW()),
  (2, 1, 2, 'C', 1, NOW()),
  (3, 1, 3, 'B', 1, NOW())
ON DUPLICATE KEY UPDATE
  chosen = VALUES(chosen),
  is_correct = VALUES(is_correct),
  responded_at = VALUES(responded_at);

-- Schema SQL for UTBK-SNBT subtests, topic blueprints, and AI prompt templates
-- Compatible with MariaDB/MySQL deployments used by latsolsnbt

SET NAMES utf8mb4;
SET time_zone = '+07:00';

-- Core authentication and activity tables
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(190) UNIQUE NOT NULL,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('user','sepuh','moderator','admin') NOT NULL DEFAULT 'user',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL,
  last_login_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS sessions (
  id CHAR(64) PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX (user_id),
  INDEX (expires_at)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS device_binds (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  device_hash CHAR(64) NOT NULL,
  first_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen_at DATETIME NULL,
  UNIQUE KEY uniq_user_device (user_id, device_hash),
  INDEX (device_hash),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS bans (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  reason VARCHAR(255) NULL,
  until DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subtests (
  id SMALLINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  slug VARCHAR(64) UNIQUE NOT NULL,
  name VARCHAR(128) NOT NULL,
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS daily_sets (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  for_date DATE NOT NULL,
  mode ENUM('kejar_waktu','santai') NOT NULL,
  ai_prompt TEXT NOT NULL,
  ai_model VARCHAR(64) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_daily (subtest_id, for_date, mode),
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS questions (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  daily_set_id BIGINT UNSIGNED NOT NULL,
  number TINYINT UNSIGNED NOT NULL,
  stem TEXT NOT NULL,
  image_url VARCHAR(255) NULL,
  explanation TEXT NULL,
  correct_choice CHAR(1) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_qno (daily_set_id, number),
  FOREIGN KEY (daily_set_id) REFERENCES daily_sets(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS choices (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  question_id BIGINT UNSIGNED NOT NULL,
  label CHAR(1) NOT NULL,
  content TEXT NOT NULL,
  UNIQUE KEY uniq_choice (question_id, label),
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attempts (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  for_date DATE NOT NULL,
  mode ENUM('kejar_waktu','santai') NOT NULL,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  finished_at DATETIME NULL,
  device_hash CHAR(64) NOT NULL,
  score TINYINT UNSIGNED NULL,
  duration_seconds INT UNSIGNED NULL,
  status ENUM('ongoing','submitted','forfeit') NOT NULL DEFAULT 'ongoing',
  UNIQUE KEY uniq_user_day (user_id, for_date),
  UNIQUE KEY uniq_device_day (device_hash, for_date),
  INDEX (subtest_id, for_date),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attempt_items (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  attempt_id BIGINT UNSIGNED NOT NULL,
  question_id BIGINT UNSIGNED NOT NULL,
  chosen CHAR(1) NULL,
  is_correct TINYINT(1) NULL,
  responded_at DATETIME NULL,
  UNIQUE KEY uniq_attempt_question (attempt_id, question_id),
  FOREIGN KEY (attempt_id) REFERENCES attempts(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS battle_rooms (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  for_date DATE NOT NULL,
  mode ENUM('kejar_waktu','santai') NOT NULL,
  status ENUM('waiting','active','finished','cancelled') NOT NULL DEFAULT 'waiting',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  started_at DATETIME NULL,
  finished_at DATETIME NULL,
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE,
  INDEX (subtest_id, for_date, status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS battle_participants (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  battle_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  device_hash CHAR(64) NOT NULL,
  joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  score TINYINT UNSIGNED NULL,
  duration_seconds INT UNSIGNED NULL,
  is_winner TINYINT(1) NULL,
  UNIQUE KEY uniq_battle_user (battle_id, user_id),
  FOREIGN KEY (battle_id) REFERENCES battle_rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS battle_events (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  battle_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  event_type VARCHAR(32) NOT NULL,
  payload JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX (battle_id, created_at),
  FOREIGN KEY (battle_id) REFERENCES battle_rooms(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS scoreboard_cache (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  for_date DATE NOT NULL,
  mode ENUM('kejar_waktu','santai') NOT NULL,
  payload JSON NOT NULL,
  built_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_board (subtest_id, for_date, mode)
) ENGINE=InnoDB;

-- Blueprint metadata for UTBK-SNBT 2025
CREATE TABLE IF NOT EXISTS subtest_blueprints (
  subtest_id SMALLINT UNSIGNED PRIMARY KEY,
  total_questions SMALLINT UNSIGNED NOT NULL,
  duration_minutes DECIMAL(5,2) NOT NULL,
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subtest_components (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  name VARCHAR(128) NOT NULL,
  description TEXT NULL,
  question_count SMALLINT UNSIGNED NULL,
  duration_minutes DECIMAL(5,2) NULL,
  UNIQUE KEY uniq_subtest_component (subtest_id, name),
  INDEX idx_subtest_components_subtest (subtest_id),
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subtest_topics (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  topic VARCHAR(256) NOT NULL,
  UNIQUE KEY uniq_subtest_topic (subtest_id, topic),
  INDEX idx_subtest_topics_subtest (subtest_id),
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS component_topics (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  component_id BIGINT UNSIGNED NOT NULL,
  topic VARCHAR(256) NOT NULL,
  UNIQUE KEY uniq_component_topic (component_id, topic),
  INDEX idx_component_topics_component (component_id),
  FOREIGN KEY (component_id) REFERENCES subtest_components(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS subtest_prompt_templates (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  subtest_id SMALLINT UNSIGNED NOT NULL,
  mode ENUM('kejar_waktu','santai') NOT NULL,
  prompt TEXT NOT NULL,
  UNIQUE KEY uniq_subtest_mode (subtest_id, mode),
  FOREIGN KEY (subtest_id) REFERENCES subtests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Seed UTBK-SNBT 2025 subtests
INSERT INTO subtests (slug, name, description, is_active)
VALUES
  ('penalaran-umum', 'Penalaran Umum', 'Mengukur kemampuan memecahkan masalah baru, bernalar abstrak, dan menyusun strategi secara logis melalui penalaran induktif, deduktif, serta kuantitatif.', 1),
  ('pengetahuan-dan-pemahaman-umum', 'Pengetahuan dan Pemahaman Umum', 'Menilai kemampuan memahami, mengomunikasikan, dan mengaitkan pengetahuan penting dalam konteks budaya Indonesia.', 1),
  ('kemampuan-memahami-bacaan-dan-menulis', 'Kemampuan Memahami Bacaan dan Menulis', 'Mengukur kelancaran membaca serta keterampilan menulis untuk memahami dan mengekspresikan gagasan secara tertulis.', 1),
  ('pengetahuan-kuantitatif', 'Pengetahuan Kuantitatif', 'Menilai penguasaan matematika dasar, pemecahan masalah, dan penggunaan informasi kuantitatif dalam berbagai konteks.', 1),
  ('literasi-bahasa-indonesia', 'Literasi Bahasa Indonesia', 'Mengukur literasi membaca teks Bahasa Indonesia, meliputi pemahaman, evaluasi, dan refleksi terhadap berbagai jenis teks.', 1),
  ('literasi-bahasa-inggris', 'Literasi Bahasa Inggris', 'Menilai kemampuan memahami, mengevaluasi, dan merefleksikan teks berbahasa Inggris secara kritis.', 1),
  ('penalaran-matematika', 'Penalaran Matematika', 'Menekankan proses memformulasikan, menerapkan, dan menginterpretasikan konsep matematika untuk memecahkan masalah kontekstual.', 1)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  is_active = VALUES(is_active);

-- Cache subtest identifiers for reuse
SET @subtest_pu := (SELECT id FROM subtests WHERE slug = 'penalaran-umum');
SET @subtest_ppu := (SELECT id FROM subtests WHERE slug = 'pengetahuan-dan-pemahaman-umum');
SET @subtest_kmbm := (SELECT id FROM subtests WHERE slug = 'kemampuan-memahami-bacaan-dan-menulis');
SET @subtest_pk := (SELECT id FROM subtests WHERE slug = 'pengetahuan-kuantitatif');
SET @subtest_lbi := (SELECT id FROM subtests WHERE slug = 'literasi-bahasa-indonesia');
SET @subtest_lbe := (SELECT id FROM subtests WHERE slug = 'literasi-bahasa-inggris');
SET @subtest_pmat := (SELECT id FROM subtests WHERE slug = 'penalaran-matematika');

-- Blueprint totals per subtest
INSERT INTO subtest_blueprints (subtest_id, total_questions, duration_minutes)
VALUES
  (@subtest_pu, 30, 30.00),
  (@subtest_ppu, 20, 15.00),
  (@subtest_kmbm, 20, 25.00),
  (@subtest_pk, 20, 20.00),
  (@subtest_lbi, 30, 42.50),
  (@subtest_lbe, 20, 20.00),
  (@subtest_pmat, 20, 30.00)
ON DUPLICATE KEY UPDATE
  total_questions = VALUES(total_questions),
  duration_minutes = VALUES(duration_minutes);

-- Components for Penalaran Umum
INSERT INTO subtest_components (subtest_id, name, description, question_count, duration_minutes)
VALUES
  (@subtest_pu, 'Penalaran Induktif', 'Mengamati fakta untuk menemukan pola, prinsip, dan aturan yang mendasari situasi baru.', 10, 10.00),
  (@subtest_pu, 'Penalaran Deduktif', 'Menggunakan premis dan prinsip yang diketahui untuk menarik simpulan logis.', 10, 10.00),
  (@subtest_pu, 'Penalaran Kuantitatif', 'Menarik simpulan berdasarkan informasi kuantitatif menggunakan konsep matematika sederhana.', 10, 10.00)
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  question_count = VALUES(question_count),
  duration_minutes = VALUES(duration_minutes);

-- Cache component identifiers for Penalaran Umum
SET @component_pu_induktif := (
  SELECT id FROM subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Induktif'
);
SET @component_pu_deduktif := (
  SELECT id FROM subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Deduktif'
);
SET @component_pu_kuantitatif := (
  SELECT id FROM subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Kuantitatif'
);

-- Topics tied to Penalaran Umum components
INSERT INTO component_topics (component_id, topic)
VALUES
  (@component_pu_induktif, 'Kesesuaian pernyataan'),
  (@component_pu_induktif, 'Sebab-akibat')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

INSERT INTO component_topics (component_id, topic)
VALUES
  (@component_pu_deduktif, 'Simpulan logis'),
  (@component_pu_deduktif, 'Penalaran analitik')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

INSERT INTO component_topics (component_id, topic)
VALUES
  (@component_pu_kuantitatif, 'Perbandingan kuantitas'),
  (@component_pu_kuantitatif, 'Hubungan matematika sederhana'),
  (@component_pu_kuantitatif, 'Aritmetika dasar (penjumlahan, pengurangan, perkalian, pembagian)')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Pengetahuan dan Pemahaman Umum
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_ppu, 'Ide pokok dan makna'),
  (@subtest_ppu, 'Kata dan bentuk kata'),
  (@subtest_ppu, 'Kesesuaian wacana'),
  (@subtest_ppu, 'Hubungan antar paragraf'),
  (@subtest_ppu, 'Sinonim')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Kemampuan Memahami Bacaan dan Menulis
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_kmbm, 'Ide pokok'),
  (@subtest_kmbm, 'Kepaduan wacana'),
  (@subtest_kmbm, 'Kalimat efektif'),
  (@subtest_kmbm, 'Ejaan dan konjungsi'),
  (@subtest_kmbm, 'Makna kata'),
  (@subtest_kmbm, 'Bentuk kata'),
  (@subtest_kmbm, 'Simpulan')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Pengetahuan Kuantitatif
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_pk, 'Bilangan'),
  (@subtest_pk, 'Aljabar dan fungsi'),
  (@subtest_pk, 'Geometri'),
  (@subtest_pk, 'Statistika dan peluang')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Literasi Bahasa Indonesia
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_lbi, 'Teks personal inspiratif'),
  (@subtest_lbi, 'Menentukan inti bacaan'),
  (@subtest_lbi, 'Menyimpulkan isi bacaan'),
  (@subtest_lbi, 'Makna teks umum'),
  (@subtest_lbi, 'Makna kontekstual kata'),
  (@subtest_lbi, 'Tema dalam teks sastra'),
  (@subtest_lbi, 'Unsur eksplanatif teks populer saintek'),
  (@subtest_lbi, 'Unsur eksplanatif teks sosial humaniora'),
  (@subtest_lbi, 'Nilai dalam teks sastra'),
  (@subtest_lbi, 'Unsur proses dalam bacaan eksplanatif'),
  (@subtest_lbi, 'Sebab-akibat dalam bacaan eksplanatif'),
  (@subtest_lbi, 'Kelengkapan paparan kekhasan objek bahasan'),
  (@subtest_lbi, 'Keakuratan paparan kelebihan dan kekurangan objek bahasan'),
  (@subtest_lbi, 'Ketepatan opini atas objek bahasan dalam bacaan ulasan'),
  (@subtest_lbi, 'Gagasan pendirian relevan atau tidak relevan dalam bacaan argumentatif'),
  (@subtest_lbi, 'Fakta, data, dan simpulan relevan atau tidak relevan dalam bacaan argumentatif'),
  (@subtest_lbi, 'Inferensi meyakinkan dalam bacaan argumentatif')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Literasi Bahasa Inggris
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_lbe, 'Reading literacy focus'),
  (@subtest_lbe, 'Menentukan inti bacaan berbahasa Inggris'),
  (@subtest_lbe, 'Menyimpulkan isi bacaan berbahasa Inggris'),
  (@subtest_lbe, 'Makna teks umum berbahasa Inggris'),
  (@subtest_lbe, 'Makna kontekstual kata berbahasa Inggris'),
  (@subtest_lbe, 'Tema dan nilai dalam teks sastra berbahasa Inggris'),
  (@subtest_lbe, 'Unsur eksplanatif teks populer saintek dan sosial humaniora'),
  (@subtest_lbe, 'Gagasan pendirian dan inferensi dalam bacaan argumentatif berbahasa Inggris')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Topics for Penalaran Matematika
INSERT INTO subtest_topics (subtest_id, topic)
VALUES
  (@subtest_pmat, 'Bilangan: representasi, sifat urutan, operasi hitung'),
  (@subtest_pmat, 'Himpunan dan pola bilangan'),
  (@subtest_pmat, 'Aljabar dan fungsi'),
  (@subtest_pmat, 'Aritmetika sosial, perbandingan, dan rasio'),
  (@subtest_pmat, 'Persamaan garis lurus, fungsi, persamaan, dan pertidaksamaan'),
  (@subtest_pmat, 'Pengukuran dan geometri: garis, sudut, bangun datar, bangun ruang'),
  (@subtest_pmat, 'Data dan ketidakpastian: statistika deskriptif, aturan pencacahan, peluang')
ON DUPLICATE KEY UPDATE
  topic = VALUES(topic);

-- Prompt templates for AI question generation per mode
INSERT INTO subtest_prompt_templates (subtest_id, mode, prompt)
VALUES
  (@subtest_pu, 'kejar_waktu', 'Buat 30 soal pilihan ganda Penalaran Umum SNBT. Bagi rata menjadi 3 komponen: penalaran induktif, penalaran deduktif, penalaran kuantitatif. Masing-masing komponen memuat 10 soal bernomor berurutan, opsi A-D, dan satu jawaban benar. Soal menekankan ketepatan konsep dan dapat diselesaikan dalam rata-rata 1 menit. Sertakan pembahasan singkat yang langsung ke inti strategi.
Topik penalaran induktif: kesesuaian pernyataan, sebab-akibat.
Topik penalaran deduktif: simpulan logis, penalaran analitik.
Topik penalaran kuantitatif: perbandingan kuantitas, hubungan matematika sederhana, aritmetika dasar.'),
  (@subtest_pu, 'santai', 'Susun 30 soal pilihan ganda Penalaran Umum SNBT dengan pembahasan mendalam. Bagi rata menjadi penalaran induktif, penalaran deduktif, dan penalaran kuantitatif. Gunakan opsi A-D dan sertakan uraian langkah-langkah agar peserta memahami pola penalaran.
Induktif: kesesuaian pernyataan, sebab-akibat.
Deduktif: simpulan logis, penalaran analitik.
Kuantitatif: perbandingan kuantitas, hubungan matematika sederhana, aritmetika dasar.'),
  (@subtest_ppu, 'kejar_waktu', 'Buat 20 soal pilihan ganda Pengetahuan dan Pemahaman Umum SNBT dengan waktu pengerjaan 15 menit. Fokus pada ide pokok dan makna, kata dan bentuk kata, kesesuaian wacana, hubungan antar paragraf, serta sinonim. Gunakan opsi A-D, sertakan jawaban benar, dan pembahasan ringkas yang menonjolkan poin penting.'),
  (@subtest_ppu, 'santai', 'Susun 20 soal pilihan ganda Pengetahuan dan Pemahaman Umum SNBT dengan pembahasan detail. Bahas ide pokok dan makna, kata dan bentuk kata, kesesuaian wacana, hubungan antar paragraf, dan sinonim. Gunakan opsi A-D dan berikan penjelasan komprehensif untuk tiap jawaban.'),
  (@subtest_kmbm, 'kejar_waktu', 'Buat 20 soal pilihan ganda Kemampuan Memahami Bacaan dan Menulis SNBT dengan batas waktu 25 menit. Topik: ide pokok, kepaduan wacana, kalimat efektif, ejaan dan konjungsi, makna kata, bentuk kata, simpulan. Gunakan opsi A-D dan pembahasan ringkas yang menekankan strategi membaca cepat.'),
  (@subtest_kmbm, 'santai', 'Susun 20 soal pilihan ganda Kemampuan Memahami Bacaan dan Menulis SNBT dengan pembahasan lengkap. Topik meliputi ide pokok, kepaduan wacana, kalimat efektif, ejaan dan konjungsi, makna kata, bentuk kata, serta simpulan. Gunakan opsi A-D dan jelaskan alasan tiap pilihan.'),
  (@subtest_pk, 'kejar_waktu', 'Buat 20 soal pilihan ganda Pengetahuan Kuantitatif SNBT untuk 20 menit. Bahas bilangan, aljabar dan fungsi, geometri, serta statistika dan peluang. Gunakan opsi A-D, sertakan jawaban benar, dan paparkan pembahasan ringkas berorientasi trik cepat.'),
  (@subtest_pk, 'santai', 'Susun 20 soal pilihan ganda Pengetahuan Kuantitatif SNBT dengan penjelasan menyeluruh. Topik: bilangan, aljabar dan fungsi, geometri, statistika dan peluang. Gunakan opsi A-D dan uraikan langkah penyelesaian secara detail.'),
  (@subtest_lbi, 'kejar_waktu', 'Buat 30 soal pilihan ganda Literasi Bahasa Indonesia SNBT untuk 42,5 menit. Cakup teks personal inspiratif, inti bacaan, simpulan, makna teks umum, makna kontekstual kata, tema dan nilai sastra, unsur eksplanatif saintek dan sosial humaniora, proses, sebab-akibat, ulasan, argumentatif, serta inferensi. Gunakan opsi A-D dan berikan pembahasan singkat fokus pada strategi cepat memahami teks.'),
  (@subtest_lbi, 'santai', 'Susun 30 soal pilihan ganda Literasi Bahasa Indonesia SNBT dengan pembahasan komprehensif. Bahas teks personal inspiratif, inti dan simpulan bacaan, makna umum dan kontekstual, tema dan nilai sastra, unsur eksplanatif saintek dan sosial humaniora, proses dan sebab-akibat, ulasan, argumentatif, serta inferensi. Gunakan opsi A-D dan jelaskan analisis teks secara detail.'),
  (@subtest_lbe, 'kejar_waktu', 'Buat 20 soal pilihan ganda Literasi Bahasa Inggris SNBT berdurasi 20 menit. Fokus pada pemahaman bacaan, penentuan inti, simpulan, makna umum, makna kontekstual, tema dan nilai sastra, unsur eksplanatif saintek maupun sosial humaniora, serta argumentasi. Gunakan opsi A-D dengan pembahasan ringkas berbahasa Indonesia yang menekankan strategi cepat.'),
  (@subtest_lbe, 'santai', 'Susun 20 soal pilihan ganda Literasi Bahasa Inggris SNBT dengan pembahasan detail. Soroti pemahaman bacaan, inti, simpulan, makna umum dan kontekstual, tema serta nilai sastra, unsur eksplanatif saintek dan sosial humaniora, dan analisis argumentatif. Gunakan opsi A-D dan sertakan penjelasan menyeluruh.'),
  (@subtest_pmat, 'kejar_waktu', 'Buat 20 soal pilihan ganda Penalaran Matematika SNBT untuk 30 menit. Gunakan konteks AKM: formulasi, penerapan, interpretasi. Topik: bilangan dan operasinya, himpunan dan pola, aljabar dan fungsi, aritmetika sosial dan rasio, garis lurus dan pertidaksamaan, geometri ruang dan ukur, statistika, aturan pencacahan, peluang. Gunakan opsi A-D dan pembahasan singkat menonjolkan strategi cepat.'),
  (@subtest_pmat, 'santai', 'Susun 20 soal pilihan ganda Penalaran Matematika SNBT dengan pembahasan lengkap. Tekankan proses formulate-employ-interpret pada topik bilangan, himpunan, pola, aljabar, fungsi, aritmetika sosial, rasio, garis lurus, pertidaksamaan, geometri, statistika, pencacahan, dan peluang. Gunakan opsi A-D dan jelaskan langkah sistematis.')
ON DUPLICATE KEY UPDATE
  prompt = VALUES(prompt);

-- Auto-create today\'s daily sets when missing so mode switches avoid daily_not_ready
INSERT INTO daily_sets (subtest_id, for_date, mode, ai_prompt, ai_model)
SELECT p.subtest_id, CURDATE(), p.mode, p.prompt, 'gpt-4.1-mini'
FROM subtest_prompt_templates p
LEFT JOIN daily_sets existing
  ON existing.subtest_id = p.subtest_id
  AND existing.for_date = CURDATE()
  AND existing.mode = p.mode
WHERE existing.id IS NULL;


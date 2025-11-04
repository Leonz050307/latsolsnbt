-- Schema SQL for SNBT subtests, components, topics, and question prompts (MySQL 8 compatible)

CREATE TABLE IF NOT EXISTS snbt_subtests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    code VARCHAR(16) NOT NULL,
    name VARCHAR(128) NOT NULL,
    category VARCHAR(64) NOT NULL,
    total_questions SMALLINT NOT NULL CHECK (total_questions > 0),
    duration_minutes DECIMAL(5,2) NOT NULL CHECK (duration_minutes > 0),
    description TEXT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_snbt_subtests_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS snbt_subtest_components (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subtest_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    question_count SMALLINT CHECK (question_count >= 0),
    duration_minutes DECIMAL(5,2) CHECK (duration_minutes >= 0),
    PRIMARY KEY (id),
    UNIQUE KEY uq_snbt_subtest_components_subtest_name (subtest_id, name),
    KEY idx_snbt_subtest_components_subtest (subtest_id),
    CONSTRAINT fk_snbt_subtest_components_subtest
        FOREIGN KEY (subtest_id) REFERENCES snbt_subtests (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS snbt_subtest_topics (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subtest_id BIGINT UNSIGNED NOT NULL,
    topic VARCHAR(256) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_snbt_subtest_topics_subtest_topic (subtest_id, topic),
    KEY idx_snbt_subtest_topics_subtest (subtest_id),
    CONSTRAINT fk_snbt_subtest_topics_subtest
        FOREIGN KEY (subtest_id) REFERENCES snbt_subtests (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS snbt_component_topics (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    component_id BIGINT UNSIGNED NOT NULL,
    topic VARCHAR(256) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_snbt_component_topics_component_topic (component_id, topic),
    KEY idx_snbt_component_topics_component (component_id),
    CONSTRAINT fk_snbt_component_topics_component
        FOREIGN KEY (component_id) REFERENCES snbt_subtest_components (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS snbt_subtest_prompts (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    subtest_id BIGINT UNSIGNED NOT NULL,
    prompt TEXT NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_snbt_subtest_prompts_subtest (subtest_id),
    CONSTRAINT fk_snbt_subtest_prompts_subtest
        FOREIGN KEY (subtest_id) REFERENCES snbt_subtests (id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed the SNBT 2025 subtests
INSERT INTO snbt_subtests AS new (code, name, category, total_questions, duration_minutes, description)
VALUES
    ('PU', 'Penalaran Umum', 'Tes Potensi Skolastik', 30, 30.00, 'Mengukur kemampuan memecahkan masalah baru, bernalar abstrak, dan menyusun strategi secara logis melalui penalaran induktif, deduktif, serta kuantitatif.'),
    ('PPU', 'Pengetahuan dan Pemahaman Umum', 'Tes Potensi Skolastik', 20, 15.00, 'Menilai kemampuan memahami, mengomunikasikan, dan mengaitkan pengetahuan penting dalam konteks budaya Indonesia.'),
    ('KMBM', 'Kemampuan Memahami Bacaan dan Menulis', 'Tes Potensi Skolastik', 20, 25.00, 'Mengukur kelancaran membaca serta keterampilan menulis untuk memahami dan mengekspresikan gagasan secara tertulis.'),
    ('PK', 'Pengetahuan Kuantitatif', 'Tes Potensi Skolastik', 20, 20.00, 'Menilai penguasaan matematika dasar, pemecahan masalah, dan penggunaan informasi kuantitatif dalam berbagai konteks.'),
    ('LBI', 'Literasi Bahasa Indonesia', 'Tes Literasi', 30, 42.50, 'Mengukur literasi membaca teks Bahasa Indonesia, meliputi pemahaman, evaluasi, dan refleksi terhadap berbagai jenis teks.'),
    ('LBE', 'Literasi Bahasa Inggris', 'Tes Literasi', 20, 20.00, 'Menilai kemampuan memahami, mengevaluasi, dan merefleksikan teks berbahasa Inggris secara kritis.'),
    ('PMAT', 'Penalaran Matematika', 'Tes Literasi', 20, 30.00, 'Menekankan proses memformulasikan, menerapkan, dan menginterpretasikan konsep matematika untuk memecahkan masalah kontekstual.')
ON DUPLICATE KEY UPDATE
    name = new.name,
    category = new.category,
    total_questions = new.total_questions,
    duration_minutes = new.duration_minutes,
    description = new.description;

-- Cache subtest identifiers for reuse
SET @subtest_pu := (SELECT id FROM snbt_subtests WHERE code = 'PU');
SET @subtest_ppu := (SELECT id FROM snbt_subtests WHERE code = 'PPU');
SET @subtest_kmbm := (SELECT id FROM snbt_subtests WHERE code = 'KMBM');
SET @subtest_pk := (SELECT id FROM snbt_subtests WHERE code = 'PK');
SET @subtest_lbi := (SELECT id FROM snbt_subtests WHERE code = 'LBI');
SET @subtest_lbe := (SELECT id FROM snbt_subtests WHERE code = 'LBE');
SET @subtest_pmat := (SELECT id FROM snbt_subtests WHERE code = 'PMAT');

-- Components for Penalaran Umum
INSERT INTO snbt_subtest_components AS new (subtest_id, name, description, question_count, duration_minutes)
VALUES
    (@subtest_pu, 'Penalaran Induktif', 'Mengamati fakta untuk menemukan pola, prinsip, dan aturan yang mendasari situasi baru.', 10, 10.00),
    (@subtest_pu, 'Penalaran Deduktif', 'Menggunakan premis dan prinsip yang diketahui untuk menarik simpulan logis.', 10, 10.00),
    (@subtest_pu, 'Penalaran Kuantitatif', 'Menarik simpulan berdasarkan informasi kuantitatif menggunakan konsep matematika sederhana.', 10, 10.00)
ON DUPLICATE KEY UPDATE
    description = new.description,
    question_count = new.question_count,
    duration_minutes = new.duration_minutes;

-- Cache component identifiers for Penalaran Umum
SET @component_pu_induktif := (
    SELECT id FROM snbt_subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Induktif'
);
SET @component_pu_deduktif := (
    SELECT id FROM snbt_subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Deduktif'
);
SET @component_pu_kuantitatif := (
    SELECT id FROM snbt_subtest_components WHERE subtest_id = @subtest_pu AND name = 'Penalaran Kuantitatif'
);

-- Topics tied to Penalaran Umum components
INSERT INTO snbt_component_topics AS new (component_id, topic)
VALUES
    (@component_pu_induktif, 'Kesesuaian pernyataan'),
    (@component_pu_induktif, 'Sebab-akibat')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

INSERT INTO snbt_component_topics AS new (component_id, topic)
VALUES
    (@component_pu_deduktif, 'Simpulan logis'),
    (@component_pu_deduktif, 'Penalaran analitik')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

INSERT INTO snbt_component_topics AS new (component_id, topic)
VALUES
    (@component_pu_kuantitatif, 'Perbandingan kuantitas'),
    (@component_pu_kuantitatif, 'Hubungan matematika sederhana'),
    (@component_pu_kuantitatif, 'Aritmetika dasar (penjumlahan, pengurangan, perkalian, pembagian)')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Pengetahuan dan Pemahaman Umum
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_ppu, 'Ide pokok makna'),
    (@subtest_ppu, 'Kata dan bentuk kata'),
    (@subtest_ppu, 'Kesesuaian wacana'),
    (@subtest_ppu, 'Hubungan antar paragraf'),
    (@subtest_ppu, 'Sinonim')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Kemampuan Memahami Bacaan dan Menulis
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_kmbm, 'Ide pokok'),
    (@subtest_kmbm, 'Kepaduan wacana'),
    (@subtest_kmbm, 'Kalimat efektif'),
    (@subtest_kmbm, 'Ejaan dan konjungsi'),
    (@subtest_kmbm, 'Makna kata'),
    (@subtest_kmbm, 'Bentuk kata'),
    (@subtest_kmbm, 'Simpulan')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Pengetahuan Kuantitatif
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_pk, 'Bilangan'),
    (@subtest_pk, 'Aljabar dan fungsi'),
    (@subtest_pk, 'Geometri'),
    (@subtest_pk, 'Statistika dan peluang')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Literasi Bahasa Indonesia
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_lbi, 'Teks personal inspiratif'),
    (@subtest_lbi, 'Menentukan inti bacaan'),
    (@subtest_lbi, 'Menyimpulkan isi bacaan'),
    (@subtest_lbi, 'Makna teks umum'),
    (@subtest_lbi, 'Makna kontekstual kata'),
    (@subtest_lbi, 'Tema dalam teks sastra'),
    (@subtest_lbi, 'Unsur eksplanatif teks populer sains dan teknologi'),
    (@subtest_lbi, 'Unsur eksplanatif teks sosial humaniora'),
    (@subtest_lbi, 'Nilai dalam teks sastra'),
    (@subtest_lbi, 'Unsur proses dalam bacaan eksplanatif'),
    (@subtest_lbi, 'Sebab-akibat dalam bacaan eksplanatif'),
    (@subtest_lbi, 'Kelengkapan paparan kekhasan objek bahasan dalam ulasan'),
    (@subtest_lbi, 'Keakuratan paparan kelebihan dan kekurangan objek bahasan'),
    (@subtest_lbi, 'Ketepatan opini atas objek bahasan dalam bacaan ulasan'),
    (@subtest_lbi, 'Gagasan pendirian relevan/tidak relevan dalam bacaan argumentatif'),
    (@subtest_lbi, 'Fakta, data, dan simpulan relevan/tidak relevan dalam bacaan argumentatif'),
    (@subtest_lbi, 'Inferensi meyakinkan dalam bacaan argumentatif')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Literasi Bahasa Inggris
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_lbe, 'Reading literacy focus'),
    (@subtest_lbe, 'Contextual meaning of words'),
    (@subtest_lbe, 'Main idea identification'),
    (@subtest_lbe, 'Summarizing passages'),
    (@subtest_lbe, 'Evaluating arguments and opinions'),
    (@subtest_lbe, 'Interpreting data within texts')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Topics for Penalaran Matematika
INSERT INTO snbt_subtest_topics AS new (subtest_id, topic)
VALUES
    (@subtest_pmat, 'Bilangan: representasi, sifat urutan, operasi hitung'),
    (@subtest_pmat, 'Himpunan'),
    (@subtest_pmat, 'Pola bilangan'),
    (@subtest_pmat, 'Aljabar dan fungsi'),
    (@subtest_pmat, 'Bentuk aljabar'),
    (@subtest_pmat, 'Aritmetika sosial'),
    (@subtest_pmat, 'Perbandingan dan rasio'),
    (@subtest_pmat, 'Persamaan garis lurus'),
    (@subtest_pmat, 'Fungsi'),
    (@subtest_pmat, 'Persamaan dan pertidaksamaan'),
    (@subtest_pmat, 'Pengukuran dan geometri: garis dan sudut'),
    (@subtest_pmat, 'Bangun datar'),
    (@subtest_pmat, 'Bangun ruang'),
    (@subtest_pmat, 'Data dan ketidakpastian: statistika deskriptif'),
    (@subtest_pmat, 'Aturan pencacahan'),
    (@subtest_pmat, 'Teori peluang')
ON DUPLICATE KEY UPDATE
    topic = new.topic;

-- Question generation prompts per subtest
INSERT INTO snbt_subtest_prompts AS new (subtest_id, prompt)
VALUES
    (@subtest_pu, 'Buat satu soal pilihan ganda Bahasa Indonesia untuk subtes Penalaran Umum (PU). Pastikan soal mengukur kemampuan penalaran induktif, deduktif, atau kuantitatif sesuai kisi-kisi resmi. Sertakan konteks singkat, empat opsi jawaban (A-D), dan tandai jawaban benar.'),
    (@subtest_ppu, 'Susun satu soal pilihan ganda yang menilai Pengetahuan dan Pemahaman Umum (PPU). Gunakan wacana atau pernyataan terkait budaya Indonesia dan uji aspek ide pokok, kata/bentuk kata, kesesuaian wacana, hubungan antar paragraf, atau sinonim.'),
    (@subtest_kmbm, 'Kembangkan satu soal yang menguji Kemampuan Memahami Bacaan dan Menulis (KMBM). Berikan teks ringkas, lalu ajukan pertanyaan yang menuntut identifikasi ide pokok, kepaduan, kalimat efektif, atau simpulan. Sertakan empat opsi jawaban dan kunci yang benar.'),
    (@subtest_pk, 'Tulis satu soal Pengetahuan Kuantitatif (PK) berbentuk pemecahan masalah numerasi dasar. Gunakan konteks kehidupan sehari-hari dan fokus pada bilangan, aljabar, geometri, atau statistika. Sediakan empat opsi dan kunci jawaban.'),
    (@subtest_lbi, 'Buat satu soal Literasi Bahasa Indonesia (LBI) yang menilai kemampuan memahami dan mengevaluasi teks. Sertakan paragraf pendek lalu ajukan pertanyaan dengan empat opsi jawaban yang mengeksplorasi makna, konteks, atau unsur teks.'),
    (@subtest_lbe, 'Rancang satu soal Literasi Bahasa Inggris (LBE) berbentuk bacaan pendek beserta pertanyaan yang menilai kemampuan memahami ide utama, makna kontekstual, atau evaluasi argumen. Sediakan empat opsi jawaban dan kunci.'),
    (@subtest_pmat, 'Susun satu soal Penalaran Matematika (PMAT) yang memerlukan proses memformulasikan, menerapkan, dan menginterpretasikan konsep matematika. Gunakan konteks nyata, sertakan langkah penyelesaian pada kunci jawaban, dan sediakan empat opsi pilihan.')
ON DUPLICATE KEY UPDATE
    prompt = new.prompt;

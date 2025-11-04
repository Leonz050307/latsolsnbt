-- Schema SQL for SNBT subtests, components, topics, and question prompts

CREATE TABLE IF NOT EXISTS snbt_subtests (
    id SERIAL PRIMARY KEY,
    code VARCHAR(16) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    category VARCHAR(64) NOT NULL,
    total_questions SMALLINT NOT NULL CHECK (total_questions > 0),
    duration_minutes NUMERIC(5,2) NOT NULL CHECK (duration_minutes > 0),
    description TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS snbt_subtest_components (
    id SERIAL PRIMARY KEY,
    subtest_id INTEGER NOT NULL REFERENCES snbt_subtests(id) ON DELETE CASCADE,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    question_count SMALLINT CHECK (question_count >= 0),
    duration_minutes NUMERIC(5,2) CHECK (duration_minutes >= 0),
    UNIQUE (subtest_id, name)
);

CREATE TABLE IF NOT EXISTS snbt_subtest_topics (
    id SERIAL PRIMARY KEY,
    subtest_id INTEGER NOT NULL REFERENCES snbt_subtests(id) ON DELETE CASCADE,
    topic VARCHAR(256) NOT NULL,
    UNIQUE (subtest_id, topic)
);

CREATE TABLE IF NOT EXISTS snbt_component_topics (
    id SERIAL PRIMARY KEY,
    component_id INTEGER NOT NULL REFERENCES snbt_subtest_components(id) ON DELETE CASCADE,
    topic VARCHAR(256) NOT NULL,
    UNIQUE (component_id, topic)
);

CREATE TABLE IF NOT EXISTS snbt_subtest_prompts (
    id SERIAL PRIMARY KEY,
    subtest_id INTEGER NOT NULL REFERENCES snbt_subtests(id) ON DELETE CASCADE,
    prompt TEXT NOT NULL,
    UNIQUE (subtest_id)
);

INSERT INTO snbt_subtests (code, name, category, total_questions, duration_minutes, description) VALUES
    ('PU', 'Penalaran Umum', 'Tes Potensi Skolastik', 30, 30, 'Mengukur kemampuan memecahkan masalah baru, bernalar abstrak, dan menyusun strategi secara logis melalui penalaran induktif, deduktif, serta kuantitatif.'),
    ('PPU', 'Pengetahuan dan Pemahaman Umum', 'Tes Potensi Skolastik', 20, 15, 'Menilai kemampuan memahami, mengomunikasikan, dan mengaitkan pengetahuan penting dalam konteks budaya Indonesia.'),
    ('KMBM', 'Kemampuan Memahami Bacaan dan Menulis', 'Tes Potensi Skolastik', 20, 25, 'Mengukur kelancaran membaca serta keterampilan menulis untuk memahami dan mengekspresikan gagasan secara tertulis.'),
    ('PK', 'Pengetahuan Kuantitatif', 'Tes Potensi Skolastik', 20, 20, 'Menilai penguasaan matematika dasar, pemecahan masalah, dan penggunaan informasi kuantitatif dalam berbagai konteks.'),
    ('LBI', 'Literasi Bahasa Indonesia', 'Tes Literasi', 30, 42.5, 'Mengukur literasi membaca teks Bahasa Indonesia, meliputi pemahaman, evaluasi, dan refleksi terhadap berbagai jenis teks.'),
    ('LBE', 'Literasi Bahasa Inggris', 'Tes Literasi', 20, 20, 'Menilai kemampuan memahami, mengevaluasi, dan merefleksikan teks berbahasa Inggris secara kritis.'),
    ('PMAT', 'Penalaran Matematika', 'Tes Literasi', 20, 30, 'Menekankan proses memformulasikan, menerapkan, dan menginterpretasikan konsep matematika untuk memecahkan masalah kontekstual.')
ON CONFLICT (code) DO UPDATE
SET name = EXCLUDED.name,
    category = EXCLUDED.category,
    total_questions = EXCLUDED.total_questions,
    duration_minutes = EXCLUDED.duration_minutes,
    description = EXCLUDED.description;

-- Penalaran Umum components and topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PU'
)
INSERT INTO snbt_subtest_components (subtest_id, name, description, question_count, duration_minutes)
SELECT subtest.id, 'Penalaran Induktif', 'Mengamati fakta untuk menemukan pola, prinsip, dan aturan yang mendasari situasi baru.', 10, 10
FROM subtest
ON CONFLICT (subtest_id, name) DO UPDATE
SET description = EXCLUDED.description,
    question_count = EXCLUDED.question_count,
    duration_minutes = EXCLUDED.duration_minutes;

WITH component AS (
    SELECT c.id FROM snbt_subtest_components c
    JOIN snbt_subtests s ON s.id = c.subtest_id AND s.code = 'PU'
    WHERE c.name = 'Penalaran Induktif'
)
INSERT INTO snbt_component_topics (component_id, topic)
SELECT component.id, topic
FROM component
CROSS JOIN (VALUES
    ('Kesesuaian pernyataan'),
    ('Sebab-akibat')
) AS topics(topic)
ON CONFLICT (component_id, topic) DO NOTHING;

WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PU'
)
INSERT INTO snbt_subtest_components (subtest_id, name, description, question_count, duration_minutes)
SELECT subtest.id, 'Penalaran Deduktif', 'Menggunakan premis dan prinsip yang diketahui untuk menarik simpulan logis.', 10, 10
FROM subtest
ON CONFLICT (subtest_id, name) DO UPDATE
SET description = EXCLUDED.description,
    question_count = EXCLUDED.question_count,
    duration_minutes = EXCLUDED.duration_minutes;

WITH component AS (
    SELECT c.id FROM snbt_subtest_components c
    JOIN snbt_subtests s ON s.id = c.subtest_id AND s.code = 'PU'
    WHERE c.name = 'Penalaran Deduktif'
)
INSERT INTO snbt_component_topics (component_id, topic)
SELECT component.id, topic
FROM component
CROSS JOIN (VALUES
    ('Simpulan logis'),
    ('Penalaran analitik')
) AS topics(topic)
ON CONFLICT (component_id, topic) DO NOTHING;

WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PU'
)
INSERT INTO snbt_subtest_components (subtest_id, name, description, question_count, duration_minutes)
SELECT subtest.id, 'Penalaran Kuantitatif', 'Menarik simpulan berdasarkan informasi kuantitatif menggunakan konsep matematika sederhana.', 10, 10
FROM subtest
ON CONFLICT (subtest_id, name) DO UPDATE
SET description = EXCLUDED.description,
    question_count = EXCLUDED.question_count,
    duration_minutes = EXCLUDED.duration_minutes;

WITH component AS (
    SELECT c.id FROM snbt_subtest_components c
    JOIN snbt_subtests s ON s.id = c.subtest_id AND s.code = 'PU'
    WHERE c.name = 'Penalaran Kuantitatif'
)
INSERT INTO snbt_component_topics (component_id, topic)
SELECT component.id, topic
FROM component
CROSS JOIN (VALUES
    ('Perbandingan kuantitas'),
    ('Hubungan matematika sederhana'),
    ('Aritmetika dasar (penjumlahan, pengurangan, perkalian, pembagian)')
) AS topics(topic)
ON CONFLICT (component_id, topic) DO NOTHING;

-- Pengetahuan dan Pemahaman Umum topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PPU'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Ide pokok makna'),
    ('Kata dan bentuk kata'),
    ('Kesesuaian wacana'),
    ('Hubungan antar paragraf'),
    ('Sinonim')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Kemampuan Memahami Bacaan dan Menulis topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'KMBM'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Ide pokok'),
    ('Kepaduan wacana'),
    ('Kalimat efektif'),
    ('Ejaan dan konjungsi'),
    ('Makna kata'),
    ('Bentuk kata'),
    ('Simpulan')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Pengetahuan Kuantitatif topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PK'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Bilangan'),
    ('Aljabar dan fungsi'),
    ('Geometri'),
    ('Statistika dan peluang')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Literasi Bahasa Indonesia topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'LBI'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Teks personal inspiratif'),
    ('Menentukan inti bacaan'),
    ('Menyimpulkan isi bacaan'),
    ('Makna teks umum'),
    ('Makna kontekstual kata'),
    ('Tema dalam teks sastra'),
    ('Unsur eksplanatif teks populer sains dan teknologi'),
    ('Unsur eksplanatif teks sosial humaniora'),
    ('Nilai dalam teks sastra'),
    ('Unsur proses dalam bacaan eksplanatif'),
    ('Sebab-akibat dalam bacaan eksplanatif'),
    ('Kelengkapan paparan kekhasan objek bahasan dalam ulasan'),
    ('Keakuratan paparan kelebihan dan kekurangan objek bahasan'),
    ('Ketepatan opini atas objek bahasan dalam bacaan ulasan'),
    ('Gagasan pendirian relevan/tidak relevan dalam bacaan argumentatif'),
    ('Fakta, data, dan simpulan relevan/tidak relevan dalam bacaan argumentatif'),
    ('Inferensi meyakinkan dalam bacaan argumentatif')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Literasi Bahasa Inggris topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'LBE'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Reading literacy focus'),
    ('Contextual meaning of words'),
    ('Main idea identification'),
    ('Summarizing passages'),
    ('Evaluating arguments and opinions'),
    ('Interpreting data within texts')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Penalaran Matematika topics
WITH subtest AS (
    SELECT id FROM snbt_subtests WHERE code = 'PMAT'
)
INSERT INTO snbt_subtest_topics (subtest_id, topic)
SELECT subtest.id, topic
FROM subtest
CROSS JOIN (VALUES
    ('Bilangan: representasi, sifat urutan, operasi hitung'),
    ('Himpunan'),
    ('Pola bilangan'),
    ('Aljabar dan fungsi'),
    ('Bentuk aljabar'),
    ('Aritmetika sosial'),
    ('Perbandingan dan rasio'),
    ('Persamaan garis lurus'),
    ('Fungsi'),
    ('Persamaan dan pertidaksamaan'),
    ('Pengukuran dan geometri: garis dan sudut'),
    ('Bangun datar'),
    ('Bangun ruang'),
    ('Data dan ketidakpastian: statistika deskriptif'),
    ('Aturan pencacahan'),
    ('Teori peluang')
) AS topics(topic)
ON CONFLICT (subtest_id, topic) DO NOTHING;

-- Question generation prompts for each subtest
INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Buat satu soal pilihan ganda Bahasa Indonesia untuk subtes Penalaran Umum (PU). Pastikan soal mengukur kemampuan penalaran induktif, deduktif, atau kuantitatif sesuai kisi-kisi resmi. Sertakan konteks singkat, empat opsi jawaban (A-D), dan tandai jawaban benar.'
FROM snbt_subtests
WHERE code = 'PU'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Susun satu soal pilihan ganda yang menilai Pengetahuan dan Pemahaman Umum (PPU). Gunakan wacana atau pernyataan terkait budaya Indonesia dan uji aspek ide pokok, kata/bentuk kata, kesesuaian wacana, hubungan antar paragraf, atau sinonim.'
FROM snbt_subtests
WHERE code = 'PPU'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Kembangkan satu soal yang menguji Kemampuan Memahami Bacaan dan Menulis (KMBM). Berikan teks ringkas, lalu ajukan pertanyaan yang menuntut identifikasi ide pokok, kepaduan, kalimat efektif, atau simpulan. Sertakan empat opsi jawaban dan kunci yang benar.'
FROM snbt_subtests
WHERE code = 'KMBM'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Tulis satu soal Pengetahuan Kuantitatif (PK) berbentuk pemecahan masalah numerasi dasar. Gunakan konteks kehidupan sehari-hari dan fokus pada bilangan, aljabar, geometri, atau statistika. Sediakan empat opsi dan kunci jawaban.'
FROM snbt_subtests
WHERE code = 'PK'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Buat satu soal Literasi Bahasa Indonesia (LBI) yang menilai kemampuan memahami dan mengevaluasi teks. Sertakan paragraf pendek lalu ajukan pertanyaan dengan empat opsi jawaban yang mengeksplorasi makna, konteks, atau unsur teks.'
FROM snbt_subtests
WHERE code = 'LBI'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Rancang satu soal Literasi Bahasa Inggris (LBE) berbentuk bacaan pendek beserta pertanyaan yang menilai kemampuan memahami ide utama, makna kontekstual, atau evaluasi argumen. Sediakan empat opsi jawaban dan kunci.'
FROM snbt_subtests
WHERE code = 'LBE'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

INSERT INTO snbt_subtest_prompts (subtest_id, prompt)
SELECT id,
       'Susun satu soal Penalaran Matematika (PMAT) yang memerlukan proses memformulasikan, menerapkan, dan menginterpretasikan konsep matematika. Gunakan konteks nyata, sertakan langkah penyelesaian pada kunci jawaban, dan sediakan empat opsi pilihan.'
FROM snbt_subtests
WHERE code = 'PMAT'
ON CONFLICT (subtest_id) DO UPDATE SET prompt = EXCLUDED.prompt;

-- На всякий случай зафиксируем таймзону
SET TIME ZONE 'UTC';

-- 1. Образовательные программы
CREATE TABLE programs (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(20)  NOT NULL UNIQUE,
    name        VARCHAR(255) NOT NULL,
    degree      VARCHAR(50),
    note        TEXT,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 2. Учебные группы
CREATE TABLE groups (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL UNIQUE,
    year_start  INT,
    program_id  INT          NOT NULL REFERENCES programs(id),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 3. Студенты
CREATE TABLE students (
    id           SERIAL PRIMARY KEY,
    last_name    VARCHAR(100) NOT NULL,
    first_name   VARCHAR(100) NOT NULL,
    middle_name  VARCHAR(100),
    record_book  VARCHAR(20)  NOT NULL UNIQUE,
    group_id     INT          NOT NULL REFERENCES groups(id),
    email        VARCHAR(150),
    is_active    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 4. Преподаватели
CREATE TABLE teachers (
    id           SERIAL PRIMARY KEY,
    last_name    VARCHAR(100) NOT NULL,
    first_name   VARCHAR(100) NOT NULL,
    middle_name  VARCHAR(100),
    position     VARCHAR(100),
    email        VARCHAR(150),
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 5. Дисциплины
CREATE TABLE disciplines (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(20),
    name        VARCHAR(255) NOT NULL,
    hours_total INT,
    program_id  INT REFERENCES programs(id),
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 6. Сеансы проверки остаточных знаний
CREATE TABLE test_sessions (
    id             SERIAL PRIMARY KEY,
    discipline_id  INT         NOT NULL REFERENCES disciplines(id),
    group_id       INT         NOT NULL REFERENCES groups(id),
    teacher_id     INT         NOT NULL REFERENCES teachers(id),
    academic_year  VARCHAR(9)  NOT NULL,   -- формат "2024/2025"
    semester       SMALLINT    NOT NULL CHECK (semester IN (1,2)),
    date_conducted DATE        NOT NULL,
    max_score      NUMERIC(5,2) NOT NULL DEFAULT 100,
    pass_score     NUMERIC(5,2),
    note           TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. Вопросы
CREATE TABLE questions (
    id              SERIAL PRIMARY KEY,
    test_session_id INT          NOT NULL REFERENCES test_sessions(id),
    question_text   TEXT         NOT NULL,
    question_type   VARCHAR(20)  NOT NULL DEFAULT 'single'
        CHECK (question_type IN ('single','multiple','open')),
    max_points      NUMERIC(5,2) NOT NULL DEFAULT 1,
    order_index     INT
);

-- 8. Варианты ответов
CREATE TABLE answer_options (
    id           SERIAL PRIMARY KEY,
    question_id  INT   NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    option_text  TEXT  NOT NULL,
    is_correct   BOOLEAN NOT NULL DEFAULT FALSE,
    order_index  INT
);

-- 9. Попытки студентов
CREATE TABLE student_attempts (
    id              SERIAL PRIMARY KEY,
    student_id      INT          NOT NULL REFERENCES students(id),
    test_session_id INT          NOT NULL REFERENCES test_sessions(id),
    attempt_no      SMALLINT     NOT NULL DEFAULT 1,
    start_time      TIMESTAMPTZ  NOT NULL DEFAULT now(),
    end_time        TIMESTAMPTZ,
    total_score     NUMERIC(5,2),
    is_passed       BOOLEAN,
    CONSTRAINT uq_attempt UNIQUE (student_id, test_session_id, attempt_no)
);

-- 10. Ответы студентов
CREATE TABLE student_answers (
    id                  SERIAL PRIMARY KEY,
    student_attempt_id  INT          NOT NULL REFERENCES student_attempts(id)
                                      ON DELETE CASCADE,
    question_id         INT          NOT NULL REFERENCES questions(id),
    selected_option_id  INT          REFERENCES answer_options(id),
    open_answer_text    TEXT,
    points_earned       NUMERIC(5,2)
);

-- 11. Итоговые результаты по сеансу
CREATE TABLE test_results (
    id               SERIAL PRIMARY KEY,
    student_id       INT          NOT NULL REFERENCES students(id),
    test_session_id  INT          NOT NULL REFERENCES test_sessions(id),
    best_score       NUMERIC(5,2) NOT NULL,
    attempts_count   INT          NOT NULL,
    last_attempt_id  INT          REFERENCES student_attempts(id),
    grade            VARCHAR(5),
    CONSTRAINT uq_result UNIQUE (student_id, test_session_id)
);

-- 3.1. Образовательные программы
INSERT INTO programs (code, name, degree, note)
VALUES
  ('09.03.01', 'Информатика и вычислительная техника', 'бакалавр', NULL),
  ('38.03.02', 'Менеджмент', 'бакалавр', NULL),
  ('01.03.02', 'Прикладная математика и информатика', 'бакалавр', NULL);

-- 3.2. Группы
INSERT INTO groups (name, year_start, program_id)
VALUES
  ('ИВТ-101', 2022, 1),
  ('ИВТ-102', 2022, 1),
  ('МН-201', 2021, 2),
  ('ПМИ-101', 2022, 3);

-- 3.3. Студенты
INSERT INTO students (last_name, first_name, middle_name, record_book, group_id, email)
VALUES
  ('Иванов',   'Иван',   'Иванович', 'RB0001', 1, 'ivanov@example.com'),
  ('Петров',   'Пётр',   'Петрович', 'RB0002', 1, 'petrov@example.com'),
  ('Сидорова', 'Анна',   'Алексеевна','RB0003', 2, 'sidorova@example.com'),
  ('Кузнецов', 'Олег',   'Викторович','RB0004', 3, 'kuznetsov@example.com'),
  ('Смирнов',  'Дмитрий','Игоревич', 'RB0005', 4, 'smirnov@example.com');

-- 3.4. Преподаватели
INSERT INTO teachers (last_name, first_name, middle_name, position, email)
VALUES
  ('Сергеев',  'Сергей', 'Николаевич', 'доцент', 'sergeev@example.com'),
  ('Алексеева','Мария',  'Игоревна',   'старший преподаватель', 'alekseeva@example.com');

-- 3.5. Дисциплины
INSERT INTO disciplines (code, name, hours_total, program_id)
VALUES
  ('ДИСЦ001', 'Программирование', 144, 1),
  ('ДИСЦ002', 'Базы данных',      108, 1),
  ('ДИСЦ003', 'Менеджмент',       108, 2);

-- 3.6. Сеансы проверки
INSERT INTO test_sessions (
  discipline_id, group_id, teacher_id,
  academic_year, semester, date_conducted,
  max_score, pass_score, note
)
VALUES
  -- Тест по программированию для ИВТ-101
  (1, 1, 1, '2024/2025', 1, '2024-10-15', 100, 60, 'Промежуточная проверка'),
  -- Тест по базам данных для ИВТ-101
  (2, 1, 2, '2024/2025', 2, '2025-02-10', 100, 70, 'Итоговая проверка'),
  -- Тест по менеджменту для МН-201
  (3, 3, 1, '2024/2025', 1, '2024-11-20', 100, 50, 'Промежуточная');

-- 3.7. Вопросы (предположим, по тесту id=1 и id=2)
INSERT INTO questions (test_session_id, question_text, question_type, max_points, order_index)
VALUES
  -- Тест 1 (id=1)
  (1, 'Что такое переменная в программировании?', 'single', 5, 1),
  (1, 'Какие типы циклов бывают в языке X?', 'multiple', 5, 2),
  (1, 'Опишите разницу между компиляцией и интерпретацией.', 'open', 10, 3),

  -- Тест 2 (id=2)
  (2, 'Что такое первичный ключ?', 'single', 5, 1),
  (2, 'Что означает нормализация БД?', 'open', 10, 2);

-- 3.8. Варианты ответов (для single/multiple вопросов)
-- Вопрос 1 (id=1)
INSERT INTO answer_options (question_id, option_text, is_correct, order_index)
VALUES
  (1, 'Именованная область памяти', TRUE, 1),
  (1, 'Файл с кодом программы', FALSE, 2),
  (1, 'Часть процессора', FALSE, 3);

-- Вопрос 2 (id=2)
INSERT INTO answer_options (question_id, option_text, is_correct, order_index)
VALUES
  (2, 'for', TRUE, 1),
  (2, 'while', TRUE, 2),
  (2, 'loop', FALSE, 3),
  (2, 'repeat-until', TRUE, 4);

-- Вопрос 4 (id=4)
INSERT INTO answer_options (question_id, option_text, is_correct, order_index)
VALUES
  (4, 'Поле, однозначно идентифицирующее запись', TRUE, 1),
  (4, 'Поле, содержащее текст', FALSE, 2);

-- 3.9. Попытки студентов (примеры для теста id=1 и id=2)
-- Пусть студенты id=1,2,3 писали тест 1, а 1 и 2 писали тест 2
INSERT INTO student_attempts (student_id, test_session_id, attempt_no, start_time, end_time, total_score, is_passed)
VALUES
  (1, 1, 1, '2024-10-15 10:00', '2024-10-15 10:30', 80, TRUE),
  (2, 1, 1, '2024-10-15 10:05', '2024-10-15 10:35', 55, FALSE),
  (3, 1, 1, '2024-10-15 10:10', '2024-10-15 10:40', 65, TRUE),

  (1, 2, 1, '2025-02-10 09:00', '2025-02-10 09:40', 90, TRUE),
  (2, 2, 1, '2025-02-10 09:10', '2025-02-10 09:50', 60, FALSE);

-- 3.10. Ответы студентов (упрощённо, не на все вопросы)
-- Для простоты считаем, что points_earned уже посчитаны
INSERT INTO student_answers (student_attempt_id, question_id, selected_option_id, open_answer_text, points_earned)
VALUES
  -- Студент 1, тест 1 (attempt id=1)
  (1, 1, 1, NULL, 5),
  (1, 2, 1, NULL, 2),
  (1, 3, NULL, 'Компиляция создаёт исполняемый файл...', 8),

  -- Студент 2, тест 1 (attempt id=2)
  (2, 1, 2, NULL, 0),
  (2, 2, 3, NULL, 0),
  (2, 3, NULL, 'Не знаю', 0),

  -- Студент 3, тест 1 (attempt id=3)
  (3, 1, 1, NULL, 5),
  (3, 2, 1, NULL, 3),
  (3, 3, NULL, '...', 7),

  -- Студент 1, тест 2 (attempt id=4)
  (4, 4, 7, NULL, 5), -- допустим id=7 - правильный вариант
  (4, 5, NULL, 'Процесс приведения структуры БД к нормальным формам', 9),

  -- Студент 2, тест 2 (attempt id=5)
  (5, 4, 8, NULL, 0),
  (5, 5, NULL, '...', 6);

-- 3.11. Итоговые результаты (test_results)
-- (в реальной системе они вычислялись бы на основе попыток)
INSERT INTO test_results (student_id, test_session_id, best_score, attempts_count, last_attempt_id, grade)
VALUES
  (1, 1, 80, 1, 1, '4'),
  (2, 1, 55, 1, 2, '3'),
  (3, 1, 65, 1, 3, '4'),
  (1, 2, 90, 1, 4, '5'),
  (2, 2, 60, 1, 5, '3');

-- 4.1. Список студентов с группой и программой
SELECT
    s.id,
    s.last_name,
    s.first_name,
    s.middle_name,
    s.record_book,
    g.name       AS group_name,
    p.code       AS program_code,
    p.name       AS program_name
FROM students s
JOIN groups g      ON s.group_id = g.id
JOIN programs p    ON g.program_id = p.id
ORDER BY g.name, s.last_name, s.first_name;

--4.2. Дисциплины, по которым уже проводилась проверка
SELECT DISTINCT
    d.id,
    d.code,
    d.name
FROM disciplines d
JOIN test_sessions ts ON ts.discipline_id = d.id
ORDER BY d.name;

--4.3. Сеансы тестирования с дисциплиной, группой и преподавателем
SELECT
    ts.id,
    ts.academic_year,
    ts.semester,
    ts.date_conducted,
    d.name          AS discipline,
    g.name          AS group_name,
    CONCAT(t.last_name, ' ', t.first_name, ' ', COALESCE(t.middle_name, '')) AS teacher
FROM test_sessions ts
JOIN disciplines d ON ts.discipline_id = d.id
JOIN groups g      ON ts.group_id = g.id
JOIN teachers t    ON ts.teacher_id = t.id
ORDER BY ts.date_conducted DESC;

--4.4. Результаты студентов по конкретному сеансу
-- Пример: сеанс с id = 1
SELECT
    s.record_book,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    tr.best_score,
    tr.grade,
    tr.attempts_count
FROM test_results tr
JOIN students s ON tr.student_id = s.id
WHERE tr.test_session_id = 1
ORDER BY tr.best_score DESC;

--4.5. Средний балл по сеансу и процент сдачи
-- Пример: сеанс с id = 1
SELECT
    ts.id,
    d.name  AS discipline,
    g.name  AS group_name,
    AVG(sa.total_score) AS avg_score,
    100.0 * AVG(CASE WHEN sa.is_passed THEN 1 ELSE 0 END) AS pass_percent
FROM test_sessions ts
JOIN disciplines d       ON ts.discipline_id = d.id
JOIN groups g            ON ts.group_id = g.id
JOIN student_attempts sa ON sa.test_session_id = ts.id
WHERE ts.id = 1
GROUP BY ts.id, d.name, g.name;

--4.6. История попыток конкретного студента по сеансу
-- Пример: студент id = 1, сеанс id = 1
SELECT
    sa.id           AS attempt_id,
    sa.attempt_no,
    sa.start_time,
    sa.end_time,
    sa.total_score,
    sa.is_passed
FROM student_attempts sa
WHERE sa.student_id = 1
  AND sa.test_session_id = 1
ORDER BY sa.attempt_no;

--4.7. Студенты, не сдавшие конкретный тест
-- считаем, что "не сдал" = best_score < pass_score
-- :p_session_id – id сеанса
-- Пример: сеанс id = 1
SELECT
    s.record_book,
    CONCAT(s.last_name, ' ', s.first_name) AS student_name,
    tr.best_score,
    tr.grade
FROM test_results tr
JOIN students s       ON tr.student_id = s.id
JOIN test_sessions ts ON ts.id = tr.test_session_id
WHERE tr.test_session_id = 1
  AND tr.best_score < ts.pass_score
ORDER BY tr.best_score;


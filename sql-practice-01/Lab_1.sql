-- Поставщики (S)
CREATE TABLE Provider (
    Id CHAR(2) PRIMARY KEY,      -- S1, S2, ...
    Surname TEXT,
    Status INT,
    City TEXT
);

-- Детали (P)
CREATE TABLE Detail (
    Id CHAR(2) PRIMARY KEY,      -- P1, P2, ...
    Name TEXT,
    Color TEXT,
    Weight INT,
    City TEXT
);

-- Изделия (J)
CREATE TABLE Product (
    Id CHAR(2) PRIMARY KEY,      -- J1, J2, ...
    Name TEXT,
    City TEXT
);

-- Поставки (SPJ)
CREATE TABLE Supply (
    Id SERIAL PRIMARY KEY,
    ID_provider CHAR(2) REFERENCES Provider(Id),
    ID_detail   CHAR(2) REFERENCES Detail(Id),
    ID_product  CHAR(2) REFERENCES Product(Id),
    Quantity INT
);

-- ===== ДАННЫЕ =====

INSERT INTO Provider (Id, Surname, Status, City) VALUES
    ('S1', 'Смит',  20, 'Лондон'),
    ('S2', 'Джонс', 10, 'Париж'),
    ('S3', 'Блейк', 30, 'Париж'),
    ('S4', 'Кларк', 20, 'Лондон'),
    ('S5', 'Адамс', 30, 'Атенс');

INSERT INTO Detail (Id, Name, Color, Weight, City) VALUES
    ('P1', 'Гайка',    'Красный', 12, 'Лондон'),
    ('P2', 'Болт',     'Зеленый', 17, 'Париж'),
    ('P3', 'Винт',     'Голубой', 17, 'Рим'),
    ('P4', 'Винт',     'Красный', 14, 'Лондон'),
    ('P5', 'Кулачок',  'Голубой', 12, 'Париж'),
    ('P6', 'Блюм',     'Красный', 19, 'Лондон');

INSERT INTO Product (Id, Name, City) VALUES
    ('J1', 'Сортировщик',                    'Париж'),
    ('J2', 'Перфоратор',                     'Рим'),
    ('J3', 'Считыватель',                    'Атенс'),
    ('J4', 'Консоль',                        'Атенс'),
    ('J5', 'Сортировочно-подборочная машина','Лондон'),
    ('J6', 'Терминал',                       'Осло'),
    ('J7', 'Лента',                          'Лондон');

INSERT INTO Supply (ID_provider, ID_detail, ID_product, Quantity) VALUES
    ('S1', 'P1', 'J1', 200),
    ('S1', 'P1', 'J4', 700),
    ('S2', 'P3', 'J1', 400),
    ('S2', 'P3', 'J2', 200),
    ('S2', 'P3', 'J3', 200),
    ('S2', 'P3', 'J4', 500),
    ('S2', 'P3', 'J5', 600),
    ('S2', 'P3', 'J6', 400),
    ('S2', 'P3', 'J7', 800),
    ('S2', 'P5', 'J2', 100),
    ('S3', 'P3', 'J1', 200),
    ('S3', 'P4', 'J2', 500),
    ('S4', 'P6', 'J3', 300),
    ('S4', 'P6', 'J7', 300),
    ('S5', 'P2', 'J2', 200),
    ('S5', 'P2', 'J4', 100),
    ('S5', 'P5', 'J5', 500),
    ('S5', 'P5', 'J7', 100),
    ('S5', 'P6', 'J2', 200),
    ('S5', 'P1', 'J4', 100),
    ('S5', 'P3', 'J4', 200),
    ('S5', 'P4', 'J4', 800),
    ('S5', 'P5', 'J4', 400),
    ('S5', 'P6', 'J4', 500);

	
-- 1.1. Номера поставщиков из Парижа, имеющих состояние больше 20.
SELECT Id
FROM Provider
WHERE City = 'Париж' AND Status > 20;

-- 1.2. Номера и состояние парижских поставщиков,
--      упорядоченные по убыванию состояния.
SELECT Id, Status
FROM Provider
WHERE City = 'Париж'
ORDER BY Status DESC;

-- 1.3. Полный список изделий.
SELECT *
FROM Product;

-- 1.4. Полный список изделий, изготавливаемых в Лондоне.
SELECT *
FROM Product
WHERE City = 'Лондон';

-- 1.5. Упорядоченный список номеров поставщиков,
--      поставляющих детали для изделия J1 (Сортировщик).
SELECT DISTINCT ID_provider
FROM Supply
WHERE ID_product = 'J1'
ORDER BY ID_provider;

-- 1.6. Список всех поставок, где количество деталей
--      в диапазоне от 300 до 750 включительно.
SELECT *
FROM Supply
WHERE Quantity BETWEEN 300 AND 750;

-- 1.7. Список всех комбинаций «цвет детали», «город» без повторений.
SELECT DISTINCT Color, City
FROM Detail;

-- 1.8. Номера поставщиков из Парижа, имеющих состояние больше 20.
SELECT Id
FROM Provider
WHERE City = 'Париж' AND Status > 20;

-- 1.9. Сведения о деталях, вес которых в диапазоне от 16 до 19.
SELECT *
FROM Detail
WHERE Weight BETWEEN 16 AND 19;

-- 1.10. Сведения о деталях, вес которых равен 12, 16 или 18.
SELECT *
FROM Detail
WHERE Weight IN (12, 16, 18);

-- 1.11. Список всех поставок, в которых количество не является NULL.
SELECT *
FROM Supply
WHERE Quantity IS NOT NULL;


-- 2.1. Детали, вес которых находится в диапазоне от 16 до 19.
SELECT *
FROM Detail
WHERE Weight BETWEEN 16 AND 19;

-- 2.2. Детали, вес которых 16, 12 или 17.
SELECT *
FROM Detail
WHERE Weight IN (12, 16, 17);

-- 2.3. Все поставки, в которых количество не является неопределённым значением.
SELECT *
FROM Supply
WHERE Quantity IS NOT NULL;

-- 2.4. Номера изделий и города, где они изготавливаются,
--      такие, что 2-й буквой названия города является «о».
SELECT Id, City
FROM Product
WHERE City LIKE '_о%';

-- 2.5. Все детали, название которых начинается с «Б».
SELECT *
FROM Detail
WHERE Name LIKE 'Б%';


-- 3.1. Триплеты поставщик-деталь-изделие, все из одного города.
SELECT pr.Id       AS provider_id,
       d.Id        AS detail_id,
       p.Id        AS product_id
FROM Provider pr, Detail d, Product p
WHERE pr.City = d.City
  AND d.City  = p.City;

-- 3.2. Триплеты поставщик-деталь-изделие, не соразмещённые.
SELECT pr.Id AS provider_id,
       d.Id  AS detail_id,
       p.Id  AS product_id
FROM Provider pr, Detail d, Product p
WHERE NOT (pr.City = d.City AND d.City = p.City);

-- 3.3. В триплете поставщик, деталь и изделие не попарно соразмещены.
SELECT pr.Id AS provider_id,
       d.Id  AS detail_id,
       p.Id  AS product_id
FROM Provider pr, Detail d, Product p
WHERE pr.City <> d.City
  AND pr.City <> p.City
  AND d.City  <> p.City;

-- 3.4. Поставщики и детали, размещённые в одном городе.
SELECT *
FROM Provider pr
JOIN Detail d ON pr.City = d.City;

-- 3.5. Поставщики и детали: город поставщика следует
--      за городом детали по алфавиту.
SELECT *
FROM Provider pr
JOIN Detail d ON pr.City > d.City;

-- 3.6. Поставщики и детали соразмещены, кроме поставщиков со статусом = 20.
SELECT *
FROM Provider pr
JOIN Supply s ON pr.Id = s.ID_provider
JOIN Detail d ON s.ID_detail = d.Id
WHERE pr.City = d.City
  AND pr.Status <> 20;

-- 3.7. Пары городов: поставщик из первого города поставляет деталь,
--      находящуюся во втором городе.
SELECT DISTINCT pr.City AS provider_city,
       d.City  AS detail_city
FROM Provider pr
JOIN Supply s ON pr.Id = s.ID_provider
JOIN Detail d ON s.ID_detail = d.Id;

-- 3.8. Номера деталей, поставляемых из Лондона
--      для изделий, изготовляемых в Лондоне.
SELECT DISTINCT s.ID_detail
FROM Supply s
JOIN Provider pr ON s.ID_provider = pr.Id
JOIN Product p   ON s.ID_product  = p.Id
WHERE pr.City = 'Лондон'
  AND p.City  = 'Лондон';

-- 3.9. Номера деталей, поставляемых поставщиками из Лондона.
SELECT DISTINCT s.ID_detail
FROM Supply s
JOIN Provider pr ON s.ID_provider = pr.Id
WHERE pr.City = 'Лондон';

-- 3.10. Пары городов (1-й — город поставщика, 2-й — город изделия).
SELECT DISTINCT pr.City AS provider_city,
       p.City           AS product_city
FROM Supply s
JOIN Provider pr ON s.ID_provider = pr.Id
JOIN Product p   ON s.ID_product  = p.Id;

-- 3.11. Пары номеров деталей, поставляемых одним поставщиком.
SELECT DISTINCT a.ID_detail, b.ID_detail
FROM Supply a
JOIN Supply b ON a.ID_provider = b.ID_provider
WHERE a.ID_detail < b.ID_detail;


-- 4. Подзапросы

-- 4.1. Фамилии поставщиков, которые поставляют деталь P2.
SELECT Surname
FROM Provider
WHERE Id IN (
    SELECT ID_provider
    FROM Supply
    WHERE ID_detail = 'P2'
);

-- 4.2. Фамилии поставщиков, которые поставляют хотя бы одну красную деталь.
SELECT DISTINCT pr.Surname
FROM Provider pr
WHERE pr.Id IN (
    SELECT s.ID_provider
    FROM Supply s
    JOIN Detail d ON s.ID_detail = d.Id
    WHERE d.Color = 'Красный'
);


-- 5. Стандартные функции

-- 5.1. Общее количество поставщиков.
SELECT COUNT(*) FROM Provider;

-- 5.2. Количество поставщиков для детали P2.
SELECT COUNT(DISTINCT ID_provider)
FROM Supply
WHERE ID_detail = 'P2';

-- 5.3. Номера поставщиков со статусом меньше максимального статуса.
SELECT Id
FROM Provider
WHERE Status < (SELECT MAX(Status) FROM Provider);

-- 5.4. Поставщики, у которых статус >= среднего по их городу.
SELECT Id, Status, City
FROM Provider pr1
WHERE Status >= (
    SELECT AVG(Status)
    FROM Provider pr2
    WHERE pr2.City = pr1.City
);


-- 6. Использование GROUP BY

-- 6.1. Общий объём поставок для каждой детали.
SELECT ID_detail, SUM(Quantity) AS total_quantity
FROM Supply
GROUP BY ID_detail;

-- 6.2. То же, но без учёта поставок поставщика S1.
SELECT ID_detail, SUM(Quantity) AS total_quantity
FROM Supply
WHERE ID_provider <> 'S1'
GROUP BY ID_detail;


-- 7. Использование HAVING и UNION

-- 7.1. Номера деталей, поставляемых более чем одним поставщиком.
SELECT ID_detail
FROM Supply
GROUP BY ID_detail
HAVING COUNT(DISTINCT ID_provider) > 1;

-- 7.3. Номера деталей, которые имеют вес > 16
--      либо поставляются поставщиком S2, либо и то и другое.
SELECT Id
FROM Detail
WHERE Weight > 16
UNION
SELECT ID_detail
FROM Supply
WHERE ID_provider = 'S2';

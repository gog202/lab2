-- Задание 1. Выбрать номера компьютерных лабораторий, с вакантной должностью заведующего лабораторией.
SELECT laboratory_id 
FROM laboratories 
WHERE activity_type = 'Компьютерная' 
  AND head_of_laboratory IS NULL;


-- Задание 2. Выбрать номера всех лабораторий, входящих в состав выпускающих кафедр.
SELECT l.laboratory_id 
FROM laboratories l
INNER JOIN departments d ON l.department_id = d.department_id
WHERE d.is_graduating_department = TRUE;


-- Задание 3. Создать таблицу, содержащую данные 1 запроса с указанием кафедр, к которым относятся лаборатории, и данных из таблицы «лаборатории».
DROP TABLE IF EXISTS selected_laboratories;

CREATE TABLE selected_laboratories (
    laboratory_id integer,
    laboratory_name character varying(255),
    activity_type character varying(255),
    head_of_laboratory character varying(255),
    workstations_count integer,
    has_equipment boolean,
    department_id integer,
    department_name character varying(255),
    faculty_code character varying(10),
    is_graduating_department boolean
);

INSERT INTO selected_laboratories (
    laboratory_id, laboratory_name, activity_type, head_of_laboratory, 
    workstations_count, has_equipment, department_id, 
    department_name, faculty_code, is_graduating_department
)
SELECT 
    l.laboratory_id, l.laboratory_name, l.activity_type, l.head_of_laboratory, 
    l.workstations_count, l.has_equipment, l.department_id, 
    d.department_name, d.faculty_code, d.is_graduating_department
FROM laboratories l
LEFT JOIN departments d ON l.department_id = d.department_id
WHERE l.activity_type = 'Компьютерная' 
  AND l.head_of_laboratory IS NULL;


-- Задание 4. Добавить в созданную таблицу все лаборатории кафедр, названия которых начинаются на согласные буквы.
INSERT INTO selected_laboratories (
    laboratory_id, laboratory_name, activity_type, head_of_laboratory, 
    workstations_count, has_equipment, department_id, 
    department_name, faculty_code, is_graduating_department
)
SELECT 
    l.laboratory_id, l.laboratory_name, l.activity_type, l.head_of_laboratory, 
    l.workstations_count, l.has_equipment, l.department_id, 
    d.department_name, d.faculty_code, d.is_graduating_department
FROM laboratories l
RIGHT JOIN departments d ON l.department_id = d.department_id
WHERE d.department_name ~* '^[БВГДЖЗЙКЛМНПРСТФХЦЧШЩBCDFGHJKLMNPQRSTVWXYZ]'
  AND l.laboratory_id IS NOT NULL;


-- Задание 5. Увеличить количество рабочих мест в 2 раза всем лабораториям, имеющим проектное оборудование.
UPDATE selected_laboratories
SET workstations_count = workstations_count * 2
WHERE has_equipment = TRUE;


-- Задание 6.  Из созданной таблицы удалить все записи для лабораторий, находящихся на 2 этаже. 
ALTER TABLE selected_laboratories ADD COLUMN IF NOT EXISTS floor integer;

DELETE FROM selected_laboratories
WHERE floor = 2;


-- Задание 7. Посчитать количество лабораторий и среднее количество оборудованных рабочих мест в лабораториях на каждой кафедре. 
-- Искусственное нарушение ссылочной целостности данных
ALTER TABLE laboratories DROP CONSTRAINT IF EXISTS laboratories_department_id_fkey;

INSERT INTO laboratories (
    laboratory_id, laboratory_name, activity_type, head_of_laboratory, 
    workstations_count, has_equipment, department_id
) VALUES (
    999, 'Лаборатория без кафедры', 'Компьютерная', NULL, 
    15, TRUE, 9999
);

-- Запрос, выявляющий нарушение ссылочной целостности данных (с помощью LEFT JOIN)
SELECT l.laboratory_id, l.laboratory_name, l.department_id AS invalid_department_id
FROM laboratories l
LEFT JOIN departments d ON l.department_id = d.department_id
WHERE d.department_id IS NULL;

-- Подсчет количества лабораторий и среднего числа рабочих мест на каждой кафедре (с учетом кафедр без лабораторий через RIGHT JOIN)
SELECT d.department_id,
       d.department_name,
       COUNT(l.laboratory_id) AS laboratories_count, 
       COALESCE(ROUND(AVG(l.workstations_count), 2), 0) AS avg_workstations
FROM laboratories l
RIGHT JOIN departments d ON l.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- Восстановление ссылочной целостности данных
DELETE FROM laboratories
WHERE department_id NOT IN (SELECT department_id FROM departments);

ALTER TABLE laboratories 
ADD CONSTRAINT laboratories_department_id_fkey 
FOREIGN KEY (department_id) REFERENCES departments (department_id);

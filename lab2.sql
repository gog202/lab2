-- Задание 1. Выбрать номера компьютерных лабораторий, с вакантной должностью заведующего
лабораторией.

SELECT laboratory_id 
FROM laboratories 
WHERE activity_type = 'Компьютерная' 
  AND head_of_laboratory IS NULL;



-- Задание 2. Выбрать номера всех лабораторий, входящих в состав выпускающих кафедр.

SELECT l.laboratory_id 
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE d.is_graduating_department = TRUE;



-- Задание 3. Создать таблицу, содержащую данные 1 запроса с указанием кафедр, к которым
относятся лаборатории, и данных из таблицы «лаборатории».


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
JOIN departments d ON l.department_id = d.department_id
WHERE l.activity_type = 'Компьютерная' 
  AND l.head_of_laboratory IS NULL;

-- Задание 4. Добавить в созданную таблицу все лаборатории кафедр, названия которых начинаются
на согласные буквы.


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
JOIN departments d ON l.department_id = d.department_id
WHERE d.department_name ~* '^[БВГДЖЗЙКЛМНПРСТФХЦЧШЩBCDFGHJKLMNPQRSTVWXYZ]';



-- Задание 5. Увеличить количество рабочих мест (workstations_count) в 2 раза 
-- всем лабораториям в созданной таблице, имеющим проектное оборудование.

UPDATE selected_laboratories
SET workstations_count = workstations_count * 2
WHERE has_equipment = TRUE;



-- Задание 6. Увеличить количество рабочих мест в 2 раза всем лабораториям, имеющим проектное
оборудование. 


ALTER TABLE selected_laboratories ADD COLUMN IF NOT EXISTS floor integer;

DELETE FROM selected_laboratories
WHERE floor = 2;



-- Задание 7. Посчитать количество лабораторий и среднее количество оборудованных рабочих мест
в лабораториях на каждой кафедре.

SELECT department_id, 
       COUNT(*) AS laboratories_count, 
       ROUND(AVG(workstations_count), 2) AS avg_workstations -- Округление до 2 знаков для красоты
FROM laboratories
GROUP BY department_id;

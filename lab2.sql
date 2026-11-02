-- Задание 1. Выбрать номера компьютерных лабораторий с вакантной должностью 

SELECT laboratory_id 
FROM laboratories 
WHERE activity_type = 'Компьютерная' 
  AND head_of_laboratory IS NULL;



-- Задание 2. Выбрать номера всех лабораторий, входящих в состав выпускающих кафедр.

SELECT l.laboratory_id 
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE d.is_graduating_department = TRUE;



-- Задание 3. Создать новую таблицу (selected_laboratories), содержащую данные 


DROP TABLE IF EXISTS selected_laboratories;

SELECT l.*, d.department_name, d.faculty_code, d.is_graduating_department
INTO selected_laboratories
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE l.activity_type = 'Компьютерная' 
  AND l.head_of_laboratory IS NULL;



-- Задание 4. Добавить в созданную таблицу все лаборатории кафедр, 


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



-- Задание 6. Из созданной таблицы удалить все записи для лабораторий, 

-- Шаг А
ALTER TABLE selected_laboratories ADD COLUMN IF NOT EXISTS floor integer;

-- Шаг Б
DELETE FROM selected_laboratories
WHERE floor = 2;



-- Задание 7. Посчитать количество лабораторий и среднее количество оборудованных 

SELECT department_id, 
       COUNT(*) AS laboratories_count, 
       ROUND(AVG(workstations_count), 2) AS avg_workstations -- Округление до 2 знаков для красоты
FROM laboratories
GROUP BY department_id;

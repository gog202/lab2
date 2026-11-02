
--1. Выбрать номера компьютерных лабораторий с вакантной должностью заведующего лабораторией--

sql
SELECT laboratory_id 
FROM laboratories 
WHERE (activity_type ILIKE '%компьютерная%' OR laboratory_name ILIKE '%компьютерная%')
  AND (head_of_laboratory IS NULL OR head_of_laboratory = '');


--2. Выбрать номера всех лабораторий, входящих в состав выпускающих кафедр--

sql
SELECT l.laboratory_id 
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE d.is_graduating_department = TRUE;


--3. Создать таблицу, содержащую данные 1-го запроса с указанием кафедр, к которым относятся лаборатории, и данных из таблицы «лаборатории»--

sql
CREATE TABLE lab_vacancies AS
SELECT 
    l.*, 
    d.department_name, 
    d.faculty_code
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE (l.activity_type ILIKE '%компьютерная%' OR l.laboratory_name ILIKE '%компьютерная%')
  AND (l.head_of_laboratory IS NULL OR l.head_of_laboratory = '');


--4. Добавить в созданную таблицу все лаборатории кафедр, названия которых начинаются на согласные буквы--

sql
INSERT INTO lab_vacancies
SELECT 
    l.*, 
    d.department_name, 
    d.faculty_code
FROM laboratories l
JOIN departments d ON l.department_id = d.department_id
WHERE d.department_name ~* '^[бвгджзйклмнпрстфхцчшщ]';


--5. Увеличить количество рабочих мест в 2 раза всем лабораториям, имеющим проектное оборудование--

sql
UPDATE lab_vacancies
SET workstations_count = workstations_count * 2
WHERE has_equipment = TRUE;

--6. Из созданной таблицы удалить все записи для лабораторий, находящихся на 2 этаже--

sql
DELETE FROM lab_vacancies
WHERE laboratory_id :: text LIKE '2%';


--7. Посчитать количество лабораторий и среднее количество оборудованных рабочих мест в лабораториях на каждой кафедре--

sql
SELECT 
    department_id,
    COUNT(laboratory_id) AS total_laboratories,
    ROUND(AVG(workstations_count), 2) AS avg_workstations
FROM laboratories
GROUP BY department_id;
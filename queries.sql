-- 
-- Autor: Jesús 
-- Fecha: Enero 2026
-- Descripción: Consultas SQL de ejemplo para GradesDB
--              Cubre conceptos de consultas simples y avanzadas
-- 

USE gradesDB;
-- BLOQUE SELECT
SELECT * FROM subjects;

-- Busca la asignatura con acrónimo ‘IISSI-1’
SELECT * FROM subjects s WHERE s.acronym="IISSI-1";

-- Recupera solo las columnas de nombre y acrónimo de todas las asignaturas.
SELECT s.subject_name, s.acronym FROM subjects s;

-- Filtra las asignaturas que son de tipo ‘Formación Básica’.
SELECT s.subject_name,s.acronym,s.subject_type FROM subjects s WHERE s.subject_type="Formación Básica";

-- BLOQUE JOIN 

-- Recupera los estudiantes que accedieron por Selectividad, mostrando su información personal completa.
SELECT  p.first_name,p.last_name,st.access_method FROM students st JOIN people p ON st.student_id=p.person_id WHERE st.access_method="Selectividad";

-- Busca todos los profesores con categoría ‘Catedrático’.

SELECT p.first_name,p.last_name,pr.category FROM people p JOIN professors pr ON p.person_id=pr.professor_id WHERE pr.category="Catedrático";

-- BLOQUE VIEW
 
-- Vista v_professors
-- Combina información de profesores con sus datos personales.

CREATE OR REPLACE VIEW v_professors AS SELECT pr.professor_id,pr.category,p.person_id,p.dni,p.first_name,p.last_name,p.age,p.email 
FROM professors pr JOIN people p ON pr.professor_id=p.person_id;

-- Vista v_students
CREATE OR REPLACE VIEW v_students AS SELECT st.student_id,st.access_method,p.person_id,p.dni,p.first_name,p.last_name,p.age,p.email
 FROM students st JOIN people p ON st.student_id=p.person_id;

-- BLOQUE FUNCIONES AGREGADAS

-- Consulta 7: Media de notas
-- Calcular la nota media del grupo con ID 1.
SELECT AVG(g.grade_value) AS average_grade FROM grades g WHERE g.group_id=1;

-- Consulta 8: Suma de créditos
-- Sumar todos los créditos de las asignaturas del grado con ID 3 (Tecnologías Informáticas).

SELECT SUM(s.credits) AS total_credits FROM subjects s WHERE s.degree_id=3;

-- Consulta 9: Contar registros
-- Contar cuántos estudiantes hay en la base de datos.

SELECT COUNT(*) AS total_students FROM students;

-- Consulta 10: Contar con agrupación básica
-- Contar cuántos grupos hay de cada tipo de actividad.

SELECT activity, COUNT(*) AS total_groups FROM groups g GROUP BY g.activity;

-- Consulta 11: Valor máximo
-- Encontrar la nota más alta registrada en la base de datos.

SELECT MAX(g.grade_value) AS max_grade FROM grades g;

-- Consulta 12: Valor mínimo
-- Encontrar la nota más baja registrada.

SELECT MIN(g.grade_value) AS min_grade FROM grades g;

-- BLOQUE CONDICIONES MULTIPLES 

-- Consulta 13: OR lógico
-- Buscar notas que sean suspensos (< 5) o excelentes (> 9).
SELECT g.grade_id, g.grade_value, g.exam_call FROM grades g WHERE g.grade_value < 5 OR g.grade_value > 9;

-- Consulta 14: BETWEEN


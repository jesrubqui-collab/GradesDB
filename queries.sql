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
-- Buscar notas entre 5 y 7 (aprobados y notables bajos).
SELECT g.grade_id, g.grade_value, g.exam_call FROM grades g WHERE g.grade_value BETWEEN 5 AND 7;

-- Consulta 15: IN
-- Buscar asignaturas que tengan exactamente 6 o 12 créditos.

SELECT s.subject_name,s.credits FROM subjects s WHERE s.credits IN (6 ,12);

-- Consulta 16: Rango de edad
-- Buscar personas entre 20 y 30 años.

SELECT p.first_name, p.last_name, p.age FROM people p WHERE p.age BETWEEN 20 AND 30;

-- BLOQUE DISTINCT: Eliminación de duplicados

-- Consulta 17: Nombres únicos de grupos
-- Obtener la lista de nombres de grupos sin repeticiones.

SELECT DISTINCT g.group_name FROM groups g;

-- Consulta 18: Tipos de asignatura
-- Listar los diferentes tipos de asignatura existentes.

SELECT DISTINCT s.subject_type FROM subjects s; 

-- Consulta 19: Años académicos
-- Listar los años académicos para los que hay grupos creados, ordenados descendentemente.

SELECT DISTINCT g.academic_year FROM groups g ORDER BY g.academic_year DESC;

-- BLOQUE SUBCONSULTA

-- Consulta 20: Agregado filtrado
-- Encontrar la nota más alta del estudiante con ID 6.

SELECT MAX(g.grade_value) AS max_grade FROM grades g WHERE g.student_id=6;

-- Consulta 21: IN con subconsulta
-- Encontrar qué estudiantes están matriculados en grupos del año 2024.

SELECT DISTINCT ge.student_id
FROM groups_enrollments ge
WHERE ge.group_id IN (
    SELECT g.group_id 
    FROM groups g 
    WHERE g.academic_year = 2024
);

-- Consulta 22: Comparación con agregado
-- Encontrar asignaturas que tengan más créditos que el promedio.

SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (SELECT AVG(credits) FROM subjects);

-- BLOQUE LIKE

-- Consulta 23: Terminación de cadena
-- Buscar personas cuyo DNI termina en la letra A.

SELECT p.first_name, p.last_name, p.dni
FROM people p
WHERE p.dni LIKE '%A';

-- Consulta 24: Inicio de cadena
-- Filtrar asignaturas cuyo nombre empieza con la palabra “Fundamentos”.

SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

-- Consulta 25: Longitud exacta
-- Buscar personas cuyo nombre tiene exactamente 5 letras.

SELECT p.first_name, p.last_name
FROM people p
WHERE p.first_name LIKE '_____';

-- BLOQUE FECHAS 

-- Consulta 26: Filtro por año
-- Buscar grupos del año académico 2024.

SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year = 2024;

-- Consulta 27: Rango de años
-- Buscar grupos entre 2020 y 2023, ordenados por año.

SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;

-- VISTAS COMPLEJAS

-- Vista v_grades_with_honors
-- Filtra solo las notas con matrícula de honor.

CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

-- Vista v_student_grades
-- Información completa de notas de estudiantes.

CREATE OR REPLACE VIEW v_student_grades AS
SELECT 
    p.person_id,
    p.first_name,
    p.last_name,
    p.dni,
    g.grade_value,
    g.exam_call,
    g.with_honors,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym,
    s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Vista v_professor_loads
-- Información de profesores con sus cargas docentes.

CREATE OR REPLACE VIEW v_professor_loads AS
SELECT
    p.person_id,
    p.first_name,
    p.last_name,
    pr.category,
    tl.credits AS teaching_credits,
    gr.group_name,
    gr.activity,
    gr.academic_year,
    s.subject_name,
    s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Vista v_degree_students
-- Estudiantes por grado con su información completa.

CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT
    d.degree_id,
    d.degree_name,
    p.person_id,
    p.first_name,
    p.last_name,
    st.access_method,
    gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN groups_enrollments ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

-- Consulta 28: Uso de vistas
-- Contar cuántas matrículas de honor hay en total usando la vista creada.

SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

-- Consulta 29: Agregación sobre vista
-- Calcular la nota media de cada estudiante usando v_student_grades.

SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;

-- BLOQUE ORDER BY, LIMIT y OFFSET: Control de resultados

-- Consulta 30: Ordenación ascendente
-- Ordenar todas las notas de menor a mayor valor.

SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;

-- Consulta 31: Ordenación descendente
-- Ordenar las notas de mayor a menor.

SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

-- Consulta 32: Limitación de resultados
-- Mostrar solo las 5 notas más altas.

SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;

-- Consulta 33: Ordenación múltiple
-- Listar notas aprobadas ordenadas por apellido y nombre del estudiante.

SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;

-- Consulta 34: Paginación básica
-- Implementa paginación mostrando las notas 6-10 (segunda página de 5 elementos).

SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

-- Consulta 35: Tercera página
-- Mostrar las notas 11-15 (tercera página).

SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

-- Consulta 36: Ordenación con criterios mixtos
-- Ordenar grupos por año (descendente) y luego por nombre (ascendente).

SELECT g.group_name, g.activity, g.academic_year
FROM groups g
ORDER BY g.academic_year DESC, g.group_name ASC;

-- BLOQUE JOIN: Consultas avanzadas con múltiples tablas

-- Consulta 37: JOIN con tabla intermedia
-- Listar estudiantes y los grupos en los que están matriculados.

SELECT 
    st.first_name,
    st.last_name,
    gr.group_name,
    gr.activity,
    gr.academic_year
FROM v_students st
JOIN groups_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id;

-- Consulta 38: JOIN uno a muchos
-- Mostrar asignaturas junto con el nombre de su grado.

SELECT 
    d.degree_name,
    s.subject_name,
    s.acronym,
    s.credits,
    s.course,
    s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;

-- Consulta 39: JOIN múltiple
-- Mostrar notas con nombres de estudiante y asignatura.

SELECT 
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    g.grade_value,
    g.exam_call,
    gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Consulta 40: JOIN con agregación
-- Listar profesores y los grupos que enseñan.

SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    s.subject_name,
    gr.group_name,
    gr.activity,
    tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- Consulta 41: DISTINCT con JOIN
-- Mostrar qué estudiantes están matriculados en qué asignaturas.

SELECT DISTINCT
    st.first_name,
    st.last_name,
    s.subject_name,
    s.acronym,
    gr.academic_year
FROM v_students st
JOIN groups_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

-- Consulta 42: LEFT JOIN
-- Mostrar todos los estudiantes, incluso si no tienen notas registradas.

SELECT 
    st.first_name,
    st.last_name,
    g.grade_value,
    g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;  -- LEFT JOIN incluye todas las filas de la tabla izquierda (v_students). Aunque no haya coincidencias en la tabla derecha (grades). Las columnas de grades serán NULL para estudiantes sin notas. INNER JOIN (o simplemente JOIN) solo incluye filas con coincidencia en ambas tablas.


-- BLOQUE GROUP BY: Agrupación y agregación

-- Consulta 43: Agregación por grupo
-- Calcular la nota media y total de notas por estudiante.

SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- Consulta 44: Conteo por categoría
-- Contar cuántos estudiantes hay por cada método de acceso.

SELECT 
    st.access_method,
    COUNT(*) AS total_students
FROM students st
GROUP BY st.access_method;

-- Consulta 45: Agregación con JOIN
-- Contar cuántas asignaturas tiene cada grado.

SELECT 
    d.degree_name,
    COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- Consulta 46: Conteo por entidad
-- Contar cuántos grupos tiene cada asignatura.

SELECT 
    s.subject_name,
    s.acronym,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- Consulta 47: Promedio por categoría
-- Calcular la nota media en cada convocatoria de examen.

SELECT 
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
GROUP BY g.exam_call;

-- Consulta 48: Agrupación múltiple
-- Desglosa la nota media por asignatura y convocatoria.

SELECT 
    s.subject_name,
    g.exam_call,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
GROUP BY s.subject_id, s.subject_name, g.exam_call
ORDER BY s.subject_name, g.exam_call;

-- Consulta 49: COUNT DISTINCT
-- Contar cuántos estudiantes distintos hay en cada año académico.

SELECT 
    gr.academic_year,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM groups gr
JOIN groups_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- Consulta 50: Suma por grupo
-- Sumar los créditos que imparte cada profesor.

SELECT 
    pr.first_name,
    pr.last_name,
    pr.category,
    SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category;

-- BLOQUE HAVING: Filtrado de grupos

-- Consulta 51: Filtro por agregado
-- Mostrar solo estudiantes cuya nota media supera el 7.

SELECT 
    st.first_name,
    st.last_name,
    AVG(g.grade_value) AS average_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING AVG(g.grade_value) > 7;    -- No se puede usar WHERE para filtrar por agregados.

-- Consulta 52: Conteo con umbral
-- Filtrar asignaturas que tienen más de 3 grupos creados.

SELECT 
    s.subject_name,
    COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(*) > 3;

-- Consulta 53: Filtro de tamaño de grupo
-- Identificar grupos con más de 15 estudiantes matriculados.

SELECT 
    gr.group_name,
    gr.activity,
    COUNT(*) AS total_students
FROM groups gr
JOIN groups_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity
HAVING COUNT(*) > 15;

-- Consulta 54: Promedio con filtro
-- Filtrar asignaturas cuya nota media es superior a 5.5.

SELECT 
    s.subject_name,
    AVG(g.grade_value) AS average_grade,
    COUNT(*) AS total_grades
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
HAVING AVG(g.grade_value) > 5.5;

-- BLOQUE Consultas complejas combinadas

-- Consulta 55: Top N con filtros
-- Encontrar las tres asignaturas con más estudiantes matriculados en grupos del año 2024.

SELECT 
    s.subject_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN groups_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY s.subject_id, s.subject_name
ORDER BY total_students DESC, s.subject_name ASC
LIMIT 3;

-- Consulta 56: Condición especial con agregado
-- Identificar estudiantes con más de 1 matrícula de honor.

SELECT 
    st.first_name,
    st.last_name,
    COUNT(*) AS total_honors
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
WHERE g.with_honors = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(*) > 1;

-- Consulta 57: Ranking con múltiples JOIN
-- Ordenar grados por número de estudiantes matriculados en 2024.

SELECT 
    d.degree_name,
    COUNT(DISTINCT ge.student_id) AS total_students
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN groups_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY COUNT(DISTINCT ge.student_id) DESC;

-- Consulta 58: Máximo por grupo
-- Mostrar la nota más alta de cada estudiante, ordenada descendentemente.

SELECT 
    st.first_name,
    st.last_name,
    MAX(g.grade_value) AS max_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
ORDER BY MAX(g.grade_value) DESC;

-- Consulta 59: Análisis de carga docente
-- Identificar profesores que imparten en más de 1 grupo.

SELECT 
    pr.first_name,
    pr.last_name,
    COUNT(DISTINCT tl.group_id) AS total_groups
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING COUNT(DISTINCT tl.group_id) > 1;

-- Consulta 60: Subconsulta con GROUP BY
-- Mostrar asignaturas que pertenecen a grados con más de 15 asignaturas.

SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id
    FROM subjects
    GROUP BY degree_id
    HAVING COUNT(*) > 15
);



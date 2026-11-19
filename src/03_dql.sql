-- =====================================================================
-- 03_dql.sql  |  Consultas de los reportes (DQL)
-- Cada consulta indica en lenguaje natural lo que responde y la historia
-- de usuario que cubre. Todas filtran por el semestre activo (HU-07) salvo
-- la R6, que muestra tambien semestres anteriores.
-- Esquema en estricta Tercera Forma Normal (3FN): SCORE no contiene group_id,
-- el grupo se obtiene por activity_exercise -> activity -> course_group.
-- Requiere Oracle 12c o superior: FETCH FIRST n ROWS ONLY equivale a TOP n.
-- Cobertura: GROUP BY, INNER JOIN, LEFT JOIN, ORDER BY, TOP y funciones de ventana.
-- =====================================================================

-- ---------------------------------------------------------------------
-- R1. Estudiantes registrados por grupo (HU-02, HU-06, HU-07, HU-14)
-- Lista los estudiantes matriculados en los grupos del semestre activo,
-- con su grupo, profesor, categoria actual y fecha de registro, ordenados
-- por grupo y nombre. Es el listado base que ve el profesor y el que se
-- exporta en el PDF de la HU-14.
-- Tecnicas: INNER JOIN multiple y ORDER BY.
-- ---------------------------------------------------------------------
SELECT g.name                 AS grupo,
       u.name                 AS estudiante,
       u.institutional_email  AS correo,
       lr.name                AS categoria,
       us.name                AS estado_cuenta,
       pu.name                AS profesor,
       e.registration_date    AS fecha_registro
FROM enrollment e
INNER JOIN course_group g ON g.id = e.group_id
INNER JOIN semester sem   ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st     ON st.id = e.student_id
INNER JOIN app_user u     ON u.id = st.id
INNER JOIN user_status us ON us.id = u.status_id
INNER JOIN level_rank lr  ON lr.id = st.current_level_id
INNER JOIN professor p    ON p.id = g.professor_id
INNER JOIN app_user pu    ON pu.id = p.id
ORDER BY g.name, u.name;

-- ---------------------------------------------------------------------
-- R2. Podium: 5 mejores estudiantes por grupo (HU-12)
-- Suma los puntos de cada estudiante en su grupo del semestre activo y
-- conserva solo las cinco primeras posiciones de cada grupo. Si hay
-- empates comparten posicion, por lo que un grupo podria mostrar mas de 5.
-- 3FN: Navega score -> activity_exercise -> activity -> course_group.
-- Tecnicas: GROUP BY, INNER JOIN, funcion de ventana RANK y ORDER BY.
-- ---------------------------------------------------------------------
WITH puntos AS (
    SELECT g.id AS group_id, g.name AS grupo, st.id AS student_id,
           u.name AS estudiante, SUM(sc.points) AS total_puntos
    FROM score sc
    INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
    INNER JOIN activity a           ON a.id = ae.activity_id
    INNER JOIN course_group g       ON g.id = a.group_id
    INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
    INNER JOIN student st           ON st.id = sc.student_id
    INNER JOIN app_user u           ON u.id = st.id
    GROUP BY g.id, g.name, st.id, u.name
),
ranking AS (
    SELECT p.*, RANK() OVER (PARTITION BY p.group_id ORDER BY p.total_puntos DESC) AS posicion
    FROM puntos p
)
SELECT grupo, posicion, estudiante, total_puntos
FROM ranking
WHERE posicion <= 5
ORDER BY grupo, posicion, estudiante;

-- ---------------------------------------------------------------------
-- R3. TOP 10 de estudiantes del semestre (HU-12, HU-13)
-- Muestra los 10 estudiantes con mas puntos acumulados en el semestre
-- activo, sin importar el grupo, con su categoria y numero de ejercicios
-- resueltos. Desempata por nombre.
-- 3FN: Navega score -> activity_exercise -> activity -> course_group.
-- Tecnicas: GROUP BY, INNER JOIN, ORDER BY y TOP (FETCH FIRST 10 ROWS ONLY).
-- ---------------------------------------------------------------------
SELECT u.name AS estudiante,
       g.name AS grupo,
       lr.name AS categoria,
       COUNT(sc.id) AS ejercicios_resueltos,
       SUM(sc.points) AS total_puntos
FROM score sc
INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
INNER JOIN activity a           ON a.id = ae.activity_id
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st           ON st.id = sc.student_id
INNER JOIN app_user u           ON u.id = st.id
INNER JOIN level_rank lr        ON lr.id = st.current_level_id
GROUP BY u.name, g.name, lr.name
ORDER BY total_puntos DESC, u.name
FETCH FIRST 10 ROWS ONLY;

-- ---------------------------------------------------------------------
-- R4. Historial de puntos con acumulado (HU-11)
-- Para cada estudiante lista los puntos obtenidos por ejercicio y fecha en
-- el semestre activo, junto con el total acumulado en el tiempo; sirve para
-- graficar la evolucion. Para ver un solo estudiante, descomente el filtro.
-- Tecnicas: INNER JOIN, funcion de ventana SUM acumulada y ORDER BY.
-- ---------------------------------------------------------------------
SELECT u.name AS estudiante,
       g.name AS grupo,
       a.name AS actividad,
       DBMS_LOB.SUBSTR(ex.statement, 60, 1) AS ejercicio,
       d.label AS dificultad,
       sc.award_date AS fecha,
       sc.points AS puntos,
       SUM(sc.points) OVER (PARTITION BY sc.student_id
                            ORDER BY sc.award_date, sc.id) AS puntos_acumulados
FROM score sc
INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
INNER JOIN activity a           ON a.id = ae.activity_id
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st           ON st.id = sc.student_id
INNER JOIN app_user u           ON u.id = st.id
INNER JOIN exercise ex          ON ex.id = ae.exercise_id
INNER JOIN difficulty_scale d   ON d.id = ex.difficulty_id
-- WHERE st.id = 101
ORDER BY u.name, sc.award_date;

-- ---------------------------------------------------------------------
-- R5. Desempeno por estudiante y metricas del grupo (HU-13, HU-14, HU-15)
-- Incluye TODOS los estudiantes matriculados, tambien los que aun no han
-- recibido puntos (aparecen con 0). Para cada uno muestra puntos totales,
-- ejercicios resueltos y su porcentaje frente a los ejercicios disponibles
-- del grupo; ademas calcula dos metricas del grupo: promedio de puntos y
-- tasa de participacion (estudiantes con al menos un ejercicio resuelto).
-- Tecnicas: LEFT JOIN, GROUP BY, CTE y funciones de ventana.
-- ---------------------------------------------------------------------
WITH disponibles AS (
    SELECT a.group_id, COUNT(ae.id) AS total_ejercicios
    FROM activity a
    INNER JOIN activity_status ast  ON ast.id = a.status_id AND ast.name <> 'BORRADOR'
    INNER JOIN activity_exercise ae ON ae.activity_id = a.id
    GROUP BY a.group_id
),
por_estudiante AS (
    SELECT g.id AS group_id, g.name AS grupo, st.id AS student_id,
           u.name AS estudiante, lr.name AS categoria,
           NVL(SUM(sc.points), 0) AS puntos_totales,
           COUNT(sc.id) AS ejercicios_resueltos
    FROM enrollment e
    INNER JOIN course_group g ON g.id = e.group_id
    INNER JOIN semester sem   ON sem.id = g.semester_id AND sem.active = 1
    INNER JOIN student st     ON st.id = e.student_id
    INNER JOIN app_user u     ON u.id = st.id
    INNER JOIN level_rank lr  ON lr.id = st.current_level_id
    LEFT JOIN (
        SELECT sc.student_id, a.group_id, sc.points, sc.id
        FROM score sc
        INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
        INNER JOIN activity a           ON a.id = ae.activity_id
    ) sc ON sc.student_id = e.student_id AND sc.group_id = e.group_id
    GROUP BY g.id, g.name, st.id, u.name, lr.name
)
SELECT pe.grupo,
       pe.estudiante,
       pe.categoria,
       pe.puntos_totales,
       pe.ejercicios_resueltos,
       d.total_ejercicios AS ejercicios_disponibles,
       ROUND(100 * pe.ejercicios_resueltos / NULLIF(d.total_ejercicios, 0), 1) AS pct_ejercicios_resueltos,
       ROUND(AVG(pe.puntos_totales) OVER (PARTITION BY pe.group_id), 1) AS promedio_puntos_grupo,
       ROUND(100 * SUM(CASE WHEN pe.ejercicios_resueltos > 0 THEN 1 ELSE 0 END)
                       OVER (PARTITION BY pe.group_id)
                 / COUNT(*) OVER (PARTITION BY pe.group_id), 1) AS tasa_participacion_grupo
FROM por_estudiante pe
LEFT JOIN disponibles d ON d.group_id = pe.group_id
ORDER BY pe.grupo, pe.puntos_totales DESC, pe.estudiante;

-- ---------------------------------------------------------------------
-- R6. Participacion por actividad (HU-08, HU-13, HU-16)
-- Para cada actividad, incluso las que estan en borrador o no tienen
-- puntajes, muestra su estado, el grupo, cuantos estudiantes estan
-- matriculados, cuantos participaron, la tasa de participacion y los puntos
-- totales otorgados. Incluye semestres anteriores; los mas recientes primero.
-- Tecnicas: LEFT JOIN (actividades sin puntajes), GROUP BY, COUNT DISTINCT y ORDER BY.
-- ---------------------------------------------------------------------
SELECT sem.name AS semestre,
       g.name AS grupo,
       a.name AS actividad,
       ast.name AS estado,
       NVL(ins.total, 0) AS estudiantes_inscritos,
       COUNT(DISTINCT sc.student_id) AS estudiantes_participantes,
       ROUND(100 * COUNT(DISTINCT sc.student_id) / NULLIF(ins.total, 0), 1) AS tasa_participacion,
       NVL(SUM(sc.points), 0) AS puntos_otorgados
FROM activity a
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id
INNER JOIN activity_status ast  ON ast.id = a.status_id
LEFT JOIN (SELECT group_id, COUNT(*) AS total
           FROM enrollment
           GROUP BY group_id) ins ON ins.group_id = a.group_id
LEFT JOIN activity_exercise ae  ON ae.activity_id = a.id
LEFT JOIN score sc              ON sc.activity_exercise_id = ae.id
GROUP BY sem.name, sem.start_date, g.name, a.name, a.start_date, ast.name, ins.total
ORDER BY sem.start_date DESC, g.name, a.start_date;

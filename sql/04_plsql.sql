-- 04_plsql.sql: funciones, procedimientos y triggers (PL/SQL)
-- Ejecutar DESPUES de 01_ddl.sql y 02_dml.sql. En SQL Developer usar "Ejecutar script" (F5).
-- Codigos de error personalizados: -20001 a -20007 y -20010 a -20011.
-- FUNCION fn_total_puntos
-- Funcionalidad: devuelve el total de puntos de un estudiante en un semestre.
-- Si no se indica semestre usa el semestre activo (HU-07). Devuelve 0 si el
-- estudiante no tiene puntajes o si no hay semestre activo.
-- Parametros: p_student_id (estudiante), p_semester_id (opcional).
-- Uso: SELECT fn_total_puntos(101) FROM dual;
CREATE OR REPLACE FUNCTION fn_total_puntos (
    p_student_id  IN NUMBER,
    p_semester_id IN NUMBER DEFAULT NULL
) RETURN NUMBER
IS
    v_semester_id semester.id%TYPE := p_semester_id;
    v_total       NUMBER;
BEGIN
    IF v_semester_id IS NULL THEN
        SELECT id INTO v_semester_id FROM semester WHERE active = 1;
    END IF;
    SELECT NVL(SUM(sc.points), 0)
      INTO v_total
      FROM score sc
      INNER JOIN course_group g ON g.id = sc.group_id
     WHERE sc.student_id = p_student_id
       AND g.semester_id = v_semester_id;
    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;  -- no existe semestre activo
END fn_total_puntos;
/
-- FUNCION fn_nivel_por_puntos
-- Funcionalidad: devuelve el id de la categoria de desempeno (Principiante,
-- Killer, Pro) que corresponde a una cantidad de puntos segun los rangos de
-- LEVEL_RANK (HU-15). Si ningun rango aplica devuelve la categoria mas baja.
-- Uso: SELECT fn_nivel_por_puntos(150) FROM dual;
CREATE OR REPLACE FUNCTION fn_nivel_por_puntos (
    p_points IN NUMBER
) RETURN NUMBER
IS
    v_level_id level_rank.id%TYPE;
BEGIN
    SELECT id
      INTO v_level_id
      FROM level_rank
     WHERE p_points >= min_points
       AND (max_points IS NULL OR p_points <= max_points)
     ORDER BY min_points DESC
     FETCH FIRST 1 ROW ONLY;
    RETURN v_level_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        SELECT id INTO v_level_id FROM level_rank ORDER BY min_points FETCH FIRST 1 ROW ONLY;
        RETURN v_level_id;
END fn_nivel_por_puntos;
/
-- PROCEDIMIENTO sp_asignar_puntos
-- Funcionalidad: registra los puntos de un estudiante en un ejercicio de una
-- actividad (HU-10). Valida que: los puntos sean positivos, el ejercicio
-- exista, la actividad este ACTIVA, el profesor sea quien dicta la actividad,
-- el estudiante este matriculado en el grupo y no exista ya un puntaje para
-- ese estudiante y ejercicio (evita la doble asignacion). No hace COMMIT:
-- la transaccion la controla quien lo invoca. Tras insertar, el trigger
-- trg_score_actualiza_nivel recalcula la categoria del estudiante.
CREATE OR REPLACE PROCEDURE sp_asignar_puntos (
    p_student_id           IN NUMBER,
    p_activity_exercise_id IN NUMBER,
    p_professor_id         IN NUMBER,
    p_points               IN NUMBER,
    p_redemption_code      IN VARCHAR2 DEFAULT NULL
)
IS
    v_group_id       activity.group_id%TYPE;
    v_activity_prof  activity.professor_id%TYPE;
    v_status_name    activity_status.name%TYPE;
    v_dummy          NUMBER;
BEGIN
    IF p_points IS NULL OR p_points <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Los puntos deben ser un numero positivo.');
    END IF;
    BEGIN
        SELECT a.group_id, a.professor_id, ast.name
          INTO v_group_id, v_activity_prof, v_status_name
          FROM activity_exercise ae
          INNER JOIN activity a          ON a.id = ae.activity_id
          INNER JOIN activity_status ast ON ast.id = a.status_id
         WHERE ae.id = p_activity_exercise_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'El ejercicio de la actividad no existe.');
    END;
    IF v_status_name <> 'ACTIVA' THEN
        RAISE_APPLICATION_ERROR(-20003, 'Solo se asignan puntos en actividades ACTIVAS. Estado actual: ' || v_status_name);
    END IF;
    IF v_activity_prof <> p_professor_id THEN
        RAISE_APPLICATION_ERROR(-20004, 'El profesor no es el responsable de esta actividad.');
    END IF;
    BEGIN
        SELECT 1 INTO v_dummy
          FROM enrollment
         WHERE student_id = p_student_id
           AND group_id = v_group_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20005, 'El estudiante no esta matriculado en el grupo de la actividad.');
    END;
    BEGIN
        INSERT INTO score (points, award_date, student_id, activity_exercise_id,
                           professor_id, group_id, redemption_code)
        VALUES (p_points, SYSTIMESTAMP, p_student_id, p_activity_exercise_id,
                p_professor_id, v_group_id, p_redemption_code);
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20006, 'El estudiante ya tiene puntos en este ejercicio o el codigo ya fue usado.');
    END;
END sp_asignar_puntos;
/
-- PROCEDIMIENTO sp_recalcular_niveles
-- Funcionalidad: recalcula la categoria (current_level_id) de todos los
-- estudiantes a partir de sus puntos en el semestre activo, usando
-- fn_total_puntos y fn_nivel_por_puntos. Util al cambiar de semestre o
-- cuando se modifican los rangos de LEVEL_RANK (HU-15). No hace COMMIT.
CREATE OR REPLACE PROCEDURE sp_recalcular_niveles
IS
BEGIN
    FOR r IN (SELECT id FROM student) LOOP
        UPDATE student
           SET current_level_id = fn_nivel_por_puntos(fn_total_puntos(r.id))
         WHERE id = r.id;
    END LOOP;
END sp_recalcular_niveles;
/
-- PROCEDIMIENTO sp_activar_semestre
-- Funcionalidad: declara activo un semestre y desactiva el anterior, de modo
-- que siempre haya uno solo (HU-07), y recalcula las categorias de los
-- estudiantes para el nuevo periodo. Falla si el semestre no existe. No hace COMMIT.
CREATE OR REPLACE PROCEDURE sp_activar_semestre (
    p_semester_id IN NUMBER
)
IS
    v_existe NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_existe FROM semester WHERE id = p_semester_id;
    IF v_existe = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'El semestre indicado no existe.');
    END IF;
    UPDATE semester SET active = 0 WHERE active = 1 AND id <> p_semester_id;
    UPDATE semester SET active = 1 WHERE id = p_semester_id;
    sp_recalcular_niveles;
END sp_activar_semestre;
/
-- TRIGGER trg_app_user_valida_correo
-- Funcionalidad: regla de la HU-01. Antes de insertar o cambiar el correo o
-- el tipo de un usuario, si es ESTUDIANTE exige que el correo pertenezca al
-- dominio u.icesi.edu.co; si no, rechaza la operacion. Profesores y
-- administradores pueden usar otro correo institucional.
CREATE OR REPLACE TRIGGER trg_app_user_valida_correo
BEFORE INSERT OR UPDATE OF institutional_email, user_type_id ON app_user
FOR EACH ROW
DECLARE
    v_tipo user_type.name%TYPE;
BEGIN
    SELECT name INTO v_tipo FROM user_type WHERE id = :NEW.user_type_id;
    IF v_tipo = 'ESTUDIANTE'
       AND NOT REGEXP_LIKE(:NEW.institutional_email, '@u\.icesi\.edu\.co$', 'i') THEN
        RAISE_APPLICATION_ERROR(-20010, 'Los estudiantes deben registrarse con un correo del dominio u.icesi.edu.co.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'El tipo de usuario indicado no existe.');
END trg_app_user_valida_correo;
/
-- TRIGGER trg_score_actualiza_nivel (compuesto)
-- Funcionalidad: HU-15. Cada vez que se inserta, modifica o elimina un
-- puntaje, recalcula automaticamente la categoria del estudiante afectado.
-- Se usa un trigger compuesto: la seccion por fila solo guarda los ids de
-- los estudiantes y la seccion posterior a la sentencia hace el calculo,
-- lo que evita el error de tabla mutante (ORA-04091) al consultar SCORE.
CREATE OR REPLACE TRIGGER trg_score_actualiza_nivel
FOR INSERT OR UPDATE OR DELETE ON score
COMPOUND TRIGGER
    TYPE t_ids IS TABLE OF score.student_id%TYPE INDEX BY PLS_INTEGER;
    g_ids t_ids;
    AFTER EACH ROW IS
    BEGIN
        IF DELETING THEN
            g_ids(g_ids.COUNT + 1) := :OLD.student_id;
        ELSE
            g_ids(g_ids.COUNT + 1) := :NEW.student_id;
        END IF;
    END AFTER EACH ROW;
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. g_ids.COUNT LOOP
            UPDATE student
               SET current_level_id = fn_nivel_por_puntos(fn_total_puntos(g_ids(i)))
             WHERE id = g_ids(i);
        END LOOP;
        g_ids.DELETE;
    END AFTER STATEMENT;
END trg_score_actualiza_nivel;
/

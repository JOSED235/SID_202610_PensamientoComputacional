-- 05_pruebas_plsql.sql: pruebas de las funciones, procedimientos y triggers de 04_plsql.sql
-- Ejecutar despues de 01_ddl.sql, 02_dml.sql y 04_plsql.sql. En SQL Developer usar "Ejecutar script" (F5).
-- Cada prueba imprime OK o FALLO y al final se informa cuantas fallaron.
-- Los valores esperados salen de los datos de 02_dml.sql. El script termina con ROLLBACK, asi que no deja cambios.
SET SERVEROUTPUT ON
DECLARE
    v_fallos PLS_INTEGER := 0;
    v_num    NUMBER;
    v_id     NUMBER;
    PROCEDURE verificar (p_nombre IN VARCHAR2, p_ok IN BOOLEAN) IS
    BEGIN
        IF p_ok THEN
            DBMS_OUTPUT.PUT_LINE('OK    ' || p_nombre);
        ELSE
            v_fallos := v_fallos + 1;
            DBMS_OUTPUT.PUT_LINE('FALLO ' || p_nombre);
        END IF;
    END verificar;
    -- Ejecuta una sentencia que debe terminar con el codigo de error indicado.
    PROCEDURE espera_error (p_nombre IN VARCHAR2, p_codigo IN NUMBER, p_sentencia IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sentencia;
        verificar(p_nombre || ' (no lanzo error)', FALSE);
    EXCEPTION
        WHEN OTHERS THEN
            verificar(p_nombre, SQLCODE = p_codigo);
    END espera_error;
    FUNCTION nivel_de (p_student_id IN NUMBER) RETURN NUMBER IS
        v_nivel student.current_level_id%TYPE;
    BEGIN
        SELECT current_level_id INTO v_nivel FROM student WHERE id = p_student_id;
        RETURN v_nivel;
    END nivel_de;
BEGIN
    -- fn_total_puntos
    verificar('fn_total_puntos: el estudiante 101 suma 244 en el semestre activo', fn_total_puntos(101) = 244);
    verificar('fn_total_puntos: un estudiante sin puntajes devuelve 0', fn_total_puntos(105) = 0);
    verificar('fn_total_puntos: acepta un semestre explicito', fn_total_puntos(121, 2) = 6);
    -- fn_nivel_por_puntos: limites de los rangos 0-99, 100-299 y 300 en adelante
    verificar('fn_nivel_por_puntos: 0 y 99 son Principiante', fn_nivel_por_puntos(0) = 1 AND fn_nivel_por_puntos(99) = 1);
    verificar('fn_nivel_por_puntos: 100 y 299 son Killer', fn_nivel_por_puntos(100) = 2 AND fn_nivel_por_puntos(299) = 2);
    verificar('fn_nivel_por_puntos: 300 es Pro', fn_nivel_por_puntos(300) = 3);
    -- sp_asignar_puntos y trg_score_actualiza_nivel: el estudiante 104 tiene 123 puntos (Killer) y recibe 200 en la actividad activa
    sp_asignar_puntos(104, 7, 11, 200, 'PRUEBA-0001');
    SELECT COUNT(*) INTO v_num FROM score WHERE student_id = 104 AND activity_exercise_id = 7 AND group_id = 1 AND points = 200;
    verificar('sp_asignar_puntos: registra el puntaje con el grupo de la actividad', v_num = 1);
    verificar('trg_score_actualiza_nivel: al insertar, 104 sube a Pro', nivel_de(104) = 3);
    UPDATE score SET points = 10 WHERE student_id = 104 AND activity_exercise_id = 7;
    verificar('trg_score_actualiza_nivel: al modificar, 104 vuelve a Killer', nivel_de(104) = 2);
    DELETE FROM score WHERE student_id IN (112, 113);
    verificar('trg_score_actualiza_nivel: al eliminar varias filas, 112 y 113 bajan a Principiante', nivel_de(112) = 1 AND nivel_de(113) = 1);
    -- sp_asignar_puntos: cada validacion debe rechazar la operacion con su codigo
    espera_error('sp_asignar_puntos: rechaza puntos no positivos', -20001, 'BEGIN sp_asignar_puntos(105, 7, 11, 0); END;');
    espera_error('sp_asignar_puntos: rechaza un ejercicio de actividad inexistente', -20002, 'BEGIN sp_asignar_puntos(105, 9999, 11, 10); END;');
    espera_error('sp_asignar_puntos: rechaza una actividad CERRADA', -20003, 'BEGIN sp_asignar_puntos(105, 1, 11, 10); END;');
    espera_error('sp_asignar_puntos: rechaza a un profesor que no dicta la actividad', -20004, 'BEGIN sp_asignar_puntos(105, 7, 12, 10); END;');
    espera_error('sp_asignar_puntos: rechaza a un estudiante de otro grupo', -20005, 'BEGIN sp_asignar_puntos(107, 7, 11, 10); END;');
    espera_error('sp_asignar_puntos: rechaza la doble asignacion', -20006, 'BEGIN sp_asignar_puntos(101, 7, 11, 10); END;');
    espera_error('sp_asignar_puntos: rechaza un codigo ya usado', -20006, q'[BEGIN sp_asignar_puntos(105, 7, 11, 10, 'PRUEBA-0001'); END;]');
    -- trg_app_user_valida_correo
    espera_error('trg_app_user_valida_correo: rechaza a un estudiante con correo externo', -20010,
        q'[INSERT INTO app_user (name, institutional_email, password_hash, status_id, user_type_id) VALUES ('Prueba Externa', 'prueba@gmail.com', RPAD('x', 60, 'x'), 1, 1)]');
    espera_error('trg_app_user_valida_correo: rechaza cambiar el correo de un estudiante a otro dominio', -20010,
        q'[UPDATE app_user SET institutional_email = 'valentina@icesi.edu.co' WHERE id = 101]');
    espera_error('trg_app_user_valida_correo: rechaza un tipo de usuario inexistente', -20011,
        q'[INSERT INTO app_user (name, institutional_email, password_hash, status_id, user_type_id) VALUES ('Prueba Tipo', 'tipo@u.icesi.edu.co', RPAD('x', 60, 'x'), 1, 99)]');
    INSERT INTO app_user (name, institutional_email, password_hash, status_id, user_type_id)
    VALUES ('Prueba Valida', 'prueba.valida@u.icesi.edu.co', RPAD('x', 60, 'x'), 1, 1)
    RETURNING id INTO v_id;
    verificar('trg_app_user_valida_correo: acepta a un estudiante del dominio u.icesi.edu.co', v_id >= 1000);
    INSERT INTO app_user (name, institutional_email, password_hash, status_id, user_type_id)
    VALUES ('Prueba Profesor', 'prueba.profesor@icesi.edu.co', RPAD('x', 60, 'x'), 1, 2)
    RETURNING id INTO v_id;
    verificar('trg_app_user_valida_correo: acepta a un profesor con correo icesi.edu.co', v_id >= 1000);
    -- sp_activar_semestre y sp_recalcular_niveles: al activar 2026-1 nadie conserva los puntos de 2026-2
    sp_activar_semestre(2);
    SELECT COUNT(*), MAX(id) INTO v_num, v_id FROM semester WHERE active = 1;
    verificar('sp_activar_semestre: queda un solo semestre activo y es el indicado', v_num = 1 AND v_id = 2);
    verificar('sp_recalcular_niveles: 101 pasa a Principiante en el nuevo semestre', nivel_de(101) = 1);
    espera_error('sp_activar_semestre: rechaza un semestre inexistente', -20007, 'BEGIN sp_activar_semestre(9999); END;');
    DBMS_OUTPUT.PUT_LINE('Pruebas con fallo: ' || v_fallos);
END;
/
ROLLBACK;

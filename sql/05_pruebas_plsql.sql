-- =====================================================================
-- 05_pruebas_plsql.sql | Banco de Pruebas Automatizadas de PL/SQL
-- Ejecutar en SQL Developer o SQL*Plus con "Ejecutar script" (F5)
-- DESPUES de 01_ddl.sql, 02_dml.sql y 04_plsql.sql.
-- Termina SIEMPRE con ROLLBACK para preservar la integridad de los datos.
-- =====================================================================

SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT =====================================================================
PROMPT INICIO DE PRUEBAS DE OBJETOS PL/SQL
PROMPT =====================================================================

DECLARE
    v_total NUMBER;
    v_nivel NUMBER;
    v_error_count NUMBER := 0;
    v_pass_count  NUMBER := 0;

    PROCEDURE assert_true(p_condition BOOLEAN, p_test_name VARCHAR2) IS
    BEGIN
        IF p_condition THEN
            DBMS_OUTPUT.PUT_LINE('[OK] ' || p_test_name);
            v_pass_count := v_pass_count + 1;
        ELSE
            DBMS_OUTPUT.PUT_LINE('[FALLO] ' || p_test_name);
            v_error_count := v_error_count + 1;
        END IF;
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- 1. Pruebas de la Funcion fn_total_puntos ---');
    -- Estudiante 101 en semestre activo (debe tener > 0 puntos)
    v_total := fn_total_puntos(101);
    assert_true(v_total > 0, 'fn_total_puntos(101) devuelve puntos positivos en semestre activo (' || v_total || ' pts)');

    -- Estudiante sin puntos (estudiante 105)
    v_total := fn_total_puntos(105);
    assert_true(v_total = 0, 'fn_total_puntos(105) devuelve 0 para estudiante sin calificar');

    -- Estudiante en semestre especifico inactivo (semestre 2)
    v_total := fn_total_puntos(121, 2);
    assert_true(v_total = 6, 'fn_total_puntos(121, 2) devuelve 6 puntos en semestre 2026-1');

    DBMS_OUTPUT.PUT_LINE('--- 2. Pruebas de la Funcion fn_nivel_por_puntos ---');
    v_nivel := fn_nivel_por_puntos(0);
    assert_true(v_nivel = 1, 'fn_nivel_por_puntos(0) retorna nivel 1 (Principiante)');

    v_nivel := fn_nivel_por_puntos(99);
    assert_true(v_nivel = 1, 'fn_nivel_por_puntos(99) retorna nivel 1 (Principiante)');

    v_nivel := fn_nivel_por_puntos(100);
    assert_true(v_nivel = 2, 'fn_nivel_por_puntos(100) retorna nivel 2 (Killer)');

    v_nivel := fn_nivel_por_puntos(299);
    assert_true(v_nivel = 2, 'fn_nivel_por_puntos(299) retorna nivel 2 (Killer)');

    v_nivel := fn_nivel_por_puntos(300);
    assert_true(v_nivel = 3, 'fn_nivel_por_puntos(300) retorna nivel 3 (Pro)');

    v_nivel := fn_nivel_por_puntos(1000);
    assert_true(v_nivel = 3, 'fn_nivel_por_puntos(1000) retorna nivel 3 (Pro)');

    DBMS_OUTPUT.PUT_LINE('--- 3. Pruebas del Procedimiento sp_asignar_puntos ---');
    -- Caso 3.1: Asignacion valida
    BEGIN
        sp_asignar_puntos(
            p_student_id           => 105,
            p_activity_exercise_id => 7,  -- Actividad 3 (ACTIVA), Grupo 1, dictada por profesor 11
            p_professor_id         => 11,
            p_points               => 25,
            p_redemption_code      => 'TEST-CODE-PRUEBA-01'
        );
        assert_true(TRUE, 'sp_asignar_puntos inserta puntaje exitosamente para estudiante matriculado');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(FALSE, 'sp_asignar_puntos fallo en caso valido: ' || SQLERRM);
    END;

    -- Caso 3.2: Puntos negativos o cero (debe fallar con error -20001)
    BEGIN
        sp_asignar_puntos(105, 7, 11, -10, 'TEST-NEG');
        assert_true(FALSE, 'sp_asignar_puntos debio fallar con puntos negativos');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(SQLCODE = -20001, 'sp_asignar_puntos rechaza puntos negativos (-20001): ' || SQLERRM);
    END;

    -- Caso 3.3: Profesor no responsable (debe fallar con error -20004)
    BEGIN
        sp_asignar_puntos(105, 7, 12, 15, 'TEST-PROF-DIFF');
        assert_true(FALSE, 'sp_asignar_puntos debio fallar por profesor incorrecto');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(SQLCODE = -20004, 'sp_asignar_puntos valida profesor responsable (-20004): ' || SQLERRM);
    END;

    -- Caso 3.4: Estudiante no matriculado en el grupo (debe fallar con error -20005)
    BEGIN
        sp_asignar_puntos(112, 7, 11, 20, 'TEST-NOT-ENROLLED'); -- Estudiante 112 pertenece al grupo 3, no al grupo 1
        assert_true(FALSE, 'sp_asignar_puntos debio fallar por estudiante no matriculado');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(SQLCODE = -20005, 'sp_asignar_puntos valida matricula en el grupo (-20005): ' || SQLERRM);
    END;

    -- Caso 3.5: Actividad no activa (Actividad 9 esta en BORRADOR, debe fallar con error -20003)
    BEGIN
        sp_asignar_puntos(117, 23, 14, 15, 'TEST-BORRADOR');
        assert_true(FALSE, 'sp_asignar_puntos debio fallar en actividad en borrador');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(SQLCODE = -20003, 'sp_asignar_puntos rechaza actividades no activas (-20003): ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('--- 4. Pruebas del Trigger trg_app_user_valida_correo ---');
    -- Caso 4.1: Estudiante con correo valido (@u.icesi.edu.co)
    BEGIN
        INSERT INTO app_user (id, name, institutional_email, photo_url, password_hash, status_id, user_type_id)
        VALUES (999, 'Estudiante Test', 'estudiante.test@u.icesi.edu.co', NULL, '$2b$12$abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456', 1, 1);
        assert_true(TRUE, 'trg_app_user_valida_correo permite estudiante con dominio u.icesi.edu.co');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(FALSE, 'Fallo insercion de estudiante valido: ' || SQLERRM);
    END;

    -- Caso 4.2: Estudiante con correo no institucional (gmail.com, debe fallar con -20010)
    BEGIN
        INSERT INTO app_user (id, name, institutional_email, photo_url, password_hash, status_id, user_type_id)
        VALUES (998, 'Estudiante Invalido', 'trampa@gmail.com', NULL, '$2b$12$abcdef1234567890abcdef1234567890abcdef1234567890abcdef123456', 1, 1);
        assert_true(FALSE, 'trg_app_user_valida_correo debio rechazar correo gmail para estudiante');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(SQLCODE = -20010, 'trg_app_user_valida_correo rechaza correo no institucional (-20010): ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('--- 5. Pruebas del Trigger Compuesto trg_score_actualiza_nivel ---');
    -- Verificamos nivel previo del estudiante 105 (es 1: Principiante)
    SELECT current_level_id INTO v_nivel FROM student WHERE id = 105;
    assert_true(v_nivel >= 1, 'Nivel actual del estudiante 105 verificado');

    -- Se le insertan puntos suficientes para ascender a Killer (>= 100 puntos)
    INSERT INTO score (id, points, award_date, student_id, activity_exercise_id, professor_id, redemption_code)
    VALUES (999, 120, SYSTIMESTAMP, 105, 8, 11, 'TEST-PROMO-KILLER');

    -- El trigger debe recalcular su nivel a 2 (Killer) de manera automatica sin mutar la tabla
    SELECT current_level_id INTO v_nivel FROM student WHERE id = 105;
    assert_true(v_nivel = 2, 'trg_score_actualiza_nivel ascendio al estudiante 105 a nivel 2 (Killer)');

    DBMS_OUTPUT.PUT_LINE('--- 6. Pruebas de sp_activar_semestre y sp_recalcular_niveles ---');
    BEGIN
        sp_activar_semestre(2); -- Activar semestre 2026-1
        SELECT COUNT(*) INTO v_total FROM semester WHERE active = 1;
        assert_true(v_total = 1, 'sp_activar_semestre garantiza exactamente 1 semestre activo');
    EXCEPTION
        WHEN OTHERS THEN
            assert_true(FALSE, 'Fallo sp_activar_semestre: ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('=====================================================================');
    DBMS_OUTPUT.PUT_LINE('RESUMEN DE PRUEBAS: ' || v_pass_count || ' APROBADAS, ' || v_error_count || ' FALLIDAS');
    DBMS_OUTPUT.PUT_LINE('=====================================================================');

    IF v_error_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20999, 'Existen pruebas fallidas en la suite de PL/SQL.');
    END IF;
END;
/

-- FINALIZACION SEGURA: Se descartan todas las modificaciones de prueba
ROLLBACK;
PROMPT [OK] ROLLBACK ejecutado con exito. La base de datos conserva su estado original.

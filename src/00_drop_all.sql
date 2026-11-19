-- =====================================================================
-- 00_drop_all.sql | Eliminacion total de objetos para reinicio limpio
-- Ejecutar como usuario del esquema antes de re-ejecutar 01_ddl.sql
-- =====================================================================

-- Desactivar y eliminar triggers especificos
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_score_actualiza_nivel';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER trg_app_user_valida_correo';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Eliminar procedimientos
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE sp_activar_semestre';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE sp_recalcular_niveles';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE sp_asignar_puntos';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Eliminar funciones
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION fn_nivel_por_puntos';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION fn_total_puntos';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- Eliminar tablas en orden con CASCADE CONSTRAINTS PURGE
BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables 
        WHERE table_name IN (
            'SCORE', 'ACTIVITY_EXERCISE', 'ACTIVITY', 'EXERCISE',
            'ENROLLMENT', 'COURSE_GROUP', 'STUDENT', 'PROFESSOR',
            'ADMINISTRATOR', 'APP_USER', 'SEMESTER', 'LEVEL_RANK',
            'DIFFICULTY_SCALE', 'ACTIVITY_STATUS', 'USER_STATUS', 'USER_TYPE'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

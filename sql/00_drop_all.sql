-- 00_drop_all.sql: elimina los objetos del proyecto para volver a ejecutar los scripts desde cero
-- Borra solo los objetos que crean 01_ddl.sql y 04_plsql.sql, por nombre; no toca nada mas del esquema.
-- Si un objeto no existe se ignora el error, de modo que el script se puede ejecutar varias veces.
-- Los triggers y los indices se eliminan junto con sus tablas.
DECLARE
    PROCEDURE eliminar (p_sentencia IN VARCHAR2) IS
    BEGIN
        EXECUTE IMMEDIATE p_sentencia;
    EXCEPTION
        WHEN OTHERS THEN
            -- ORA-00942: la tabla no existe. ORA-04043: el procedimiento o la funcion no existe.
            IF SQLCODE NOT IN (-942, -4043) THEN
                RAISE;
            END IF;
    END eliminar;
BEGIN
    eliminar('DROP PROCEDURE sp_activar_semestre');
    eliminar('DROP PROCEDURE sp_recalcular_niveles');
    eliminar('DROP PROCEDURE sp_asignar_puntos');
    eliminar('DROP FUNCTION fn_nivel_por_puntos');
    eliminar('DROP FUNCTION fn_total_puntos');
    eliminar('DROP TABLE score CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE activity_exercise CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE activity CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE exercise CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE enrollment CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE course_group CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE semester CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE student CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE professor CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE administrator CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE app_user CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE level_rank CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE difficulty_scale CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE activity_status CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE user_status CASCADE CONSTRAINTS PURGE');
    eliminar('DROP TABLE user_type CASCADE CONSTRAINTS PURGE');
END;
/

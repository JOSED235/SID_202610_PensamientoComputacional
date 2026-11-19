# Registro de seguimiento del proyecto

Las reuniones del equipo fueron presenciales y no se levantaron actas formales. Este registro reconstruye el seguimiento de cada entrega a partir de evidencia verificable: el historial de commits del repositorio, los metadatos de los archivos de Oracle Data Modeler y la retroalimentación del docente que quedó documentada en [`modelo_relacional.md`](modelo_relacional.md). Para cada entrega se indica qué se cumplió, qué cambió, qué dificultades aparecieron y cómo se redistribuyeron las tareas. Los roles están en [`acuerdos_equipo.md`](acuerdos_equipo.md).

## Historial de commits

| Commit | Fecha | Autor | Contenido |
|---|---|---|---|
| `2f7dba4` | 2026-09-06 | JOSED235 | Creación del repositorio (GitHub Classroom) |
| `cd784af` | 2026-09-06 | Jose David Rodríguez | Entrega 0 y 1: documento de requerimientos y diseño del MER en Data Modeler |
| `eb4a734` | 2026-09-06 | Jose David Rodríguez | Ajuste del MER: exportación en PDF y zip de las fuentes |
| `8ac9b24` | 2026-11-15 | Jose David Rodríguez | Entrega 3: scripts SQL y PL/SQL, riesgos de IAg, modelo relacional corregido y reorganización del repositorio |
| `d805c8f` | 2026-11-18 | carlospasinga | Ajustes a los scripts (SCORE en 3FN sin `group_id`, pruebas automatizadas) y PDF y `.dmd` del modelo relacional |
| (esta versión) | 2026-11-18 | Equipo | Cierre: estructura `doc/`, `model/` y `src/`, MER y MR regenerados desde la base real, evidencias de ejecución, normalización y presentación |

## Entrega 0: Caso de estudio (semana 2)

- **Qué se cumplió:** enunciado del caso, 17 historias de usuario con criterios de aceptación y prioridad, roles, cronograma y estrategia de trabajo ([`ProyectoFinalRequerimientosDef.docx`](ProyectoFinalRequerimientosDef.docx)).
- **Qué cambió:** nada respecto a lo planeado.
- **Dificultades:** delimitar el alcance a la base de datos y no a la aplicación web completa.
- **Redistribución:** no hubo; cada integrante asumió el rol definido.

## Entrega 1: MER (semana 5)

- **Qué se cumplió:** MER en Oracle Data Modeler con 8 entidades (USER, ADMINISTRATOR, PROFESSOR, STUDENT, GROUP, ACTIVITY, EXERCISE, SCORE), jerarquía de herencia de usuario y relaciones, exportado en PDF. Se conserva en [`model/anterior/`](../model/anterior/).
- **Qué cambió:** se subió primero el diseño y luego se agregó el PDF y el zip de las fuentes (`eb4a734`).
- **Dificultades:** representar los tres perfiles de estudiante y el semestre. En esta versión el semestre era un atributo del grupo (`academic_semester_date`) y el perfil un atributo del estudiante (`level`).
- **Redistribución:** el modelado se hizo en conjunto; el líder consolidó y subió los archivos al repositorio.

## Entrega 2: MR en 3FN (semana 10)

- **Qué se cumplió:** transformación a modelo relacional en Data Modeler. El archivo `PensamientoComputacionalMR.dmd` fue creado el 2026-10-06 por Santiago Vinazco (según sus metadatos). Se entregó por Saman.
- **Qué cambió respecto al MER:** aparecen las tablas SEMESTER, COURSE_GROUP, ENROLLMENT, LEVEL_RANK y ACTIVITY_EXERCISE (la relación muchos a muchos entre actividad y ejercicio). El perfil pasa a ser una categoría configurable (LEVEL_RANK).
- **Retroalimentación del docente:** (1) los atributos de estado y tipo deben ser tablas de dominio; (2) el modelo debe ser legible, organizado por módulos; (3) duda sobre el grupo G3 en dos semestres distintos.
- **Dificultades:** el MR se trabajó fuera del repositorio y solo se subió en la Entrega 3, por lo que el repositorio no refleja esa entrega en su momento.
- **Redistribución:** el desarrollador de base de datos asumió la transformación al MR en Data Modeler.

## Entrega 3: SQL y PL/SQL (semana 16)

- **Qué se cumplió:** DDL documentado (16 tablas), DML con datos de prueba, 6 reportes DQL, 2 funciones, 3 procedimientos y 2 triggers, pruebas automatizadas y documento de riesgos de IAg.
- **Qué cambió:**
  - Se atendió la retroalimentación del MR: tablas de dominio USER_TYPE, USER_STATUS, ACTIVITY_STATUS y DIFFICULTY_SCALE; nombre de grupo único por semestre `UNIQUE (name, semester_id)`; un solo semestre activo con índice único funcional.
  - En `d805c8f` se retiró `group_id` de SCORE porque dependía transitivamente de `activity_exercise_id` (violaba la 3FN).
  - En el cierre se regeneraron el MER y el MR a partir de la base de datos real, porque los PDF anteriores ya no coincidían con el DDL. En Oracle Data Modeler se importó `01_ddl.sql` (102 sentencias, 0 fallidas), se hizo ingeniería a modelo lógico y se reorganizaron ambos diagramas por módulos (`model/datamodeler/`).
- **Dificultades:**
  - Al ejecutar los scripts en Oracle se encontró el error `ORA-02438: Column check constraint cannot reference other columns` en LEVEL_RANK, que impedía crear la tabla y todas las que dependían de ella. Se corrigió convirtiendo el CHECK en restricción de tabla.
  - El PDF del MR (`Relationalcorregido.pdf`) seguía mostrando `SCORE.group_id` y no tenía las tablas de dominio.
- **Redistribución:** el documentador y responsable de calidad (Carlos Pasinga) asumió ajustes directos sobre los scripts y las pruebas (`d805c8f`), además de su rol de revisión.

## Estado final

| Requisito de la guía | Estado | Evidencia |
|---|---|---|
| DDL documentado | Cumplido | [`src/01_ddl.sql`](../src/01_ddl.sql), [log](evidencias/logs/01_ddl.log) |
| DML, al menos 10 registros por reporte | Cumplido | [`src/02_dml.sql`](../src/02_dml.sql), [resultados](evidencias/resultados_reportes.md) |
| DQL con agrupamiento, joins, ordenamiento y TOP | Cumplido | [`src/03_dql.sql`](../src/03_dql.sql) |
| Riesgos de IAg | Cumplido | [`Riesgos_uso_IAg.md`](Riesgos_uso_IAg.md) |
| Procedimiento, función y trigger documentados | Cumplido | [`src/04_plsql.sql`](../src/04_plsql.sql), [pruebas](evidencias/logs/05_pruebas_plsql.log) |
| MER y MR actualizados en Data Modeler (PDF y zip del `.dmd`) | Cumplido | [`model/datamodeler/`](../model/datamodeler/) |

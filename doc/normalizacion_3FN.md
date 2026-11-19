# Justificación de la tercera forma normal (3FN)

Este documento muestra que cada tabla de [`src/01_ddl.sql`](../src/01_ddl.sql) cumple la primera, segunda y tercera forma normal. El modelo está en [`model/mr/MR_3FN.pdf`](../model/mr/MR_3FN.pdf).

## Criterios

- **1FN:** todos los atributos son atómicos (un solo valor por celda), no hay grupos repetidos y cada tabla tiene llave primaria.
- **2FN:** está en 1FN y ningún atributo no clave depende de una parte de una llave compuesta (o de una llave candidata compuesta).
- **3FN:** está en 2FN y ningún atributo no clave depende de otro atributo no clave (no hay dependencias transitivas).

Todas las tablas usan una llave primaria sustituta simple (`id`), así que la 2FN respecto a la PK se cumple directamente. Por eso, en las tablas con llaves candidatas compuestas (por ejemplo `(student_id, group_id)` en ENROLLMENT) se revisa también que los demás atributos dependan de la llave candidata completa.

## Dependencias funcionales por tabla

| Tabla | Llaves candidatas | Dependencias funcionales | 1FN | 2FN | 3FN |
|---|---|---|---|---|---|
| USER_TYPE | id; name | id → name | Sí | Sí | Sí |
| USER_STATUS | id; name | id → name | Sí | Sí | Sí |
| ACTIVITY_STATUS | id; name | id → name | Sí | Sí | Sí |
| DIFFICULTY_SCALE | id | id → label | Sí | Sí | Sí |
| LEVEL_RANK | id; name | id → name, min_points, max_points | Sí | Sí | Sí |
| APP_USER | id; institutional_email | id → name, institutional_email, photo_url, password_hash, status_id, user_type_id | Sí | Sí | Sí |
| ADMINISTRATOR | id | (solo la llave) | Sí | Sí | Sí |
| PROFESSOR | id; employee_code | id → employee_code | Sí | Sí | Sí |
| STUDENT | id | id → current_level_id | Sí | Sí | Sí |
| SEMESTER | id; name | id → name, start_date, end_date, active | Sí | Sí | Sí |
| COURSE_GROUP | id; (name, semester_id) | id → name, semester_id, professor_id | Sí | Sí | Sí |
| ENROLLMENT | id; (student_id, group_id) | id → student_id, group_id, registration_date; (student_id, group_id) → registration_date | Sí | Sí | Sí |
| EXERCISE | id | id → statement, difficulty_id, level_id | Sí | Sí | Sí |
| ACTIVITY | id | id → name, start_date, end_date, status_id, professor_id, group_id | Sí | Sí | Sí |
| ACTIVITY_EXERCISE | id; (activity_id, exercise_id); (activity_id, order_num) | id → activity_id, exercise_id, order_num | Sí | Sí | Sí |
| SCORE | id; (student_id, activity_exercise_id); redemption_code | id → points, award_date, student_id, activity_exercise_id, professor_id, redemption_code | Sí | Sí | Sí |

## Por qué se cumple cada forma normal

### 1FN

- `statement` es un CLOB con el enunciado completo, un único valor por ejercicio.
- No hay listas en una columna: los ejercicios de una actividad son filas de ACTIVITY_EXERCISE, los estudiantes de un grupo son filas de ENROLLMENT y los puntos son filas de SCORE.
- El nombre completo del usuario se trata como un solo valor porque el sistema nunca consulta nombre y apellido por separado.

### 2FN

- En COURSE_GROUP, `professor_id` depende de la llave candidata completa `(name, semester_id)`: el G1 de 2026-1 y el G1 de 2026-2 pueden tener profesores distintos, así que no depende solo de `name`.
- En ENROLLMENT, `registration_date` depende de la pareja `(student_id, group_id)`, no del estudiante ni del grupo por separado.
- En ACTIVITY_EXERCISE, `order_num` depende de la pareja `(activity_id, exercise_id)`: el mismo ejercicio puede ocupar posiciones distintas en actividades distintas.
- En SCORE, `points`, `award_date` y `professor_id` dependen de la pareja `(student_id, activity_exercise_id)`: un estudiante recibe un único puntaje por ejercicio de una actividad.

### 3FN

- **SCORE sin `group_id`.** La versión anterior tenía `SCORE.group_id`, que generaba la dependencia transitiva `id → activity_exercise_id → activity_id → group_id`. Se eliminó: el grupo se obtiene por JOIN, y así un puntaje no puede quedar asociado a un grupo distinto al de su actividad.
- **Estados y tipos en tablas de dominio.** Con `status` como texto en APP_USER y ACTIVITY, el significado del estado se repetía en cada fila. Ahora la tabla solo guarda la FK y la descripción depende únicamente de la llave del catálogo.
- **Datos del profesor y del semestre fuera del grupo.** COURSE_GROUP guarda `professor_id` y `semester_id`, no el nombre del profesor ni las fechas del semestre, que dependen de sus propias llaves.
- **Dificultad y nivel del ejercicio.** EXERCISE guarda `difficulty_id` y `level_id`; la etiqueta de dificultad y los rangos de puntos están en sus tablas.
- **SCORE.professor_id no es transitivo.** Representa quién asignó el puntaje *en el momento de asignarlo*. `sp_asignar_puntos` exige que en ese momento sea el responsable de la actividad (error -20004), pero `ACTIVITY.professor_id` se puede cambiar después, por ejemplo si la actividad se reasigna a otro profesor. El puntaje debe conservar quién lo dio, así que en los datos guardados `activity_exercise_id` no determina `professor_id` y no hay dependencia transitiva. Es el mismo caso del precio histórico en una línea de factura: un valor que coincide al registrarse, pero que es un hecho propio de la fila.
- **`STUDENT.current_level_id`, desnormalización controlada.** La categoría se puede calcular a partir de los puntos y de LEVEL_RANK, pero ningún otro atributo de STUDENT la determina, así que la tabla sigue en 3FN. Es un dato derivado que se guarda por rendimiento y para mostrarlo en el perfil (HU-15). Su consistencia la mantiene el trigger compuesto `trg_score_actualiza_nivel`, que la recalcula ante cualquier INSERT, UPDATE o DELETE en SCORE.

## Verificación en el motor

Las reglas anteriores están implementadas como restricciones y se comprobaron en Oracle Database 23ai: los scripts se ejecutan sin errores ([logs](evidencias/logs/)), y las pruebas de [`src/05_pruebas_plsql.sql`](../src/05_pruebas_plsql.sql) verifican, entre otras, el rechazo de la doble asignación de puntos y el recálculo automático de la categoría (20 pruebas aprobadas, 0 fallidas).

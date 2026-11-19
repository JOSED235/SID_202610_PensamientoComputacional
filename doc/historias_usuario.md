# Historias de usuario

Especificación de requerimientos del sistema, transcrita de [`ProyectoFinalRequerimientosDef.docx`](ProyectoFinalRequerimientosDef.docx). Al final está la matriz de trazabilidad entre cada historia y los objetos de la base de datos que la soportan.

## HU-01

- **Actor:** Estudiante
- **Prioridad:** Alta

> Como estudiante, quiero registrarme e iniciar sesión con mi correo institucional (dominio u.icesi.edu.co), para acceder a la plataforma sin necesidad de integración con los sistemas de Icesi.

**Criterios de aceptación**

- El sistema rechaza el registro si el correo no pertenece al dominio u.icesi.edu.co.
- El sistema valida formato de correo y fortaleza de contraseña antes de crear la cuenta.
- Tras el registro exitoso, el estudiante puede iniciar sesión inmediatamente con sus credenciales.
- No existe validación contra un sistema externo de Icesi; solo se verifica el dominio del correo.

## HU-02

- **Actor:** Estudiante
- **Prioridad:** Alta

> Como estudiante, quiero seleccionar mi rol y el grupo en el que estoy matriculado (por ejemplo G1, G3, G5) durante el registro, para que la plataforma me asocie correctamente a mi curso.

**Criterios de aceptación**

- El formulario de registro presenta una lista de grupos vigentes en el semestre activo.
- El estudiante solo puede seleccionar un grupo al momento de registrarse.
- El grupo seleccionado queda asociado al perfil del estudiante y es visible para el profesor correspondiente.

## HU-03

- **Actor:** Estudiante
- **Prioridad:** Media

> Como estudiante, quiero completar mi perfil personal con nombre, correo y foto de perfil, para que mi identidad sea reconocible dentro de la plataforma.

**Criterios de aceptación**

- El estudiante puede cargar o cambiar su foto de perfil en formato JPG o PNG.
- Los campos nombre y correo son obligatorios; la foto es opcional.
- Los cambios de perfil se reflejan inmediatamente en la vista del estudiante y del profesor.

## HU-04

- **Actor:** Administrador
- **Prioridad:** Alta

> Como administrador, quiero dar de alta a los profesores en el sistema, para que ellos no puedan autoregistrarse y se mantenga el control de quién tiene ese rol.

**Criterios de aceptación**

- Solo un usuario con rol administrador puede crear cuentas de profesor.
- Al crear la cuenta, el administrador asigna correo institucional y datos básicos del profesor.
- El profesor recibe sus credenciales iniciales para el primer ingreso.

## HU-05

- **Actor:** Profesor
- **Prioridad:** Media

> Como profesor, quiero completar mi perfil de usuario y poder cambiar mi contraseña al ingresar por primera vez, para personalizar mi cuenta y proteger mi acceso.

**Criterios de aceptación**

- En el primer inicio de sesión, el sistema solicita completar el perfil antes de continuar.
- El profesor puede cambiar su contraseña en cualquier momento desde su perfil.
- La nueva contraseña cumple reglas mínimas de seguridad (longitud y complejidad).

## HU-06

- **Actor:** Profesor
- **Prioridad:** Alta

> Como profesor, quiero visualizar la lista de estudiantes registrados que pertenecen a los grupos que enseño en el semestre actual, para conocer quiénes participan en mis actividades.

**Criterios de aceptación**

- La lista solo incluye estudiantes registrados autónomamente en la plataforma (no toda la nómina oficial).
- La lista se filtra automáticamente por los grupos asignados al profesor en el semestre activo.
- El profesor puede distinguir visualmente cada grupo (ej. G5, G7) dentro de su lista.

## HU-07

- **Actor:** Sistema
- **Prioridad:** Alta

> Como sistema, quiero identificar automáticamente el semestre académico activo (por ejemplo 2025-2), para mostrar únicamente la información correspondiente a estudiantes y actividades de ese período.

**Criterios de aceptación**

- El semestre activo se calcula o configura sin intervención manual repetitiva.
- Los estudiantes y actividades de semestres anteriores no aparecen mezclados con los del semestre activo.
- Al iniciar un nuevo semestre, el sistema actualiza el período activo mostrado a todos los usuarios.

## HU-08

- **Actor:** Profesor
- **Prioridad:** Alta

> Como profesor, quiero crear actividades compuestas por uno o más ejercicios de programación, para organizar el trabajo que los estudiantes realizarán en clase.

**Criterios de aceptación**

- Una actividad puede agrupar uno o varios ejercicios existentes o nuevos.
- El profesor define el grupo o grupos destinatarios de la actividad antes de activarla.
- El profesor puede editar una actividad mientras no haya sido activada.

## HU-09

- **Actor:** Profesor
- **Prioridad:** Alta

> Como profesor, quiero definir para cada ejercicio una consigna detallada y un nivel de dificultad en una escala de 0 a 10, para orientar a los estudiantes según su perfil (principiante, killer, pro).

**Criterios de aceptación**

- El campo de consigna admite texto enriquecido (o al menos texto extenso) obligatorio.
- El nivel de dificultad solo acepta valores enteros entre 0 y 10.
- El profesor puede asociar el ejercicio a uno o varios perfiles de estudiante.

## HU-10

- **Actor:** Profesor
- **Prioridad:** Alta

> Como profesor, quiero un mecanismo ágil (código alfanumérico o lectura de QR) para asignar puntos a los estudiantes por cada ejercicio resuelto, para calificar sin fricción durante la clase.

**Criterios de aceptación**

- El profesor genera un código o QR único por ejercicio/actividad activa.
- Al validar el código o QR de un estudiante, el sistema asigna los puntos correspondientes en segundos.
- El sistema evita la doble asignación de puntos para el mismo ejercicio y estudiante.

## HU-11

- **Actor:** Estudiante
- **Prioridad:** Media

> Como estudiante, quiero consultar mi historial de puntos acumulados y métricas de desempeño en gráficos y tablas (evolución, ejercicios completados, comparativas semanales), para entender mi progreso en el curso.

**Criterios de aceptación**

- El historial muestra los puntos obtenidos por ejercicio y por fecha.
- Existe al menos un gráfico de evolución temporal y una comparativa semanal.
- Los datos mostrados corresponden únicamente al estudiante autenticado.

## HU-12

- **Actor:** Estudiante / Profesor
- **Prioridad:** Media

> Como estudiante o profesor, quiero ver un podium con los 5 mejores estudiantes por grupo, para reconocer el desempeño destacado dentro del curso.

**Criterios de aceptación**

- El estudiante solo visualiza el podium de su propio grupo.
- El profesor puede visualizar el podium de todos los grupos que enseña.
- El podium se actualiza automáticamente al registrarse nuevos puntos.

## HU-13

- **Actor:** Profesor
- **Prioridad:** Media

> Como profesor, quiero acceder a gráficos y tablas detalladas del desempeño de cada estudiante, además de estadísticas simples del grupo (mínimo 2 métricas, por ejemplo desempeño medio y tasa de participación), para evaluar el avance individual y colectivo.

**Criterios de aceptación**

- La vista detallada permite seleccionar un estudiante y ver su desempeño histórico.
- El grupo muestra al menos dos métricas agregadas definidas por el equipo.
- Las métricas se recalculan automáticamente con cada nueva actividad calificada.

## HU-14

- **Actor:** Profesor
- **Prioridad:** Media

> Como profesor, quiero exportar la información de rendimiento de mis estudiantes a un archivo PDF, para compartir o archivar los resultados fuera de la plataforma.

**Criterios de aceptación**

- El PDF generado incluye, como mínimo, nombre del estudiante, grupo y puntos acumulados.
- La exportación puede filtrarse por grupo y por período académico.
- El archivo se descarga correctamente en menos de unos segundos para un grupo típico.

## HU-15

- **Actor:** Sistema
- **Prioridad:** Media

> Como sistema, quiero ubicar automáticamente a cada estudiante en una categoría de desempeño (por ejemplo principiante, killer, pro) según su rendimiento, para reflejar su evolución dentro del curso.

**Criterios de aceptación**

- La categorización se recalcula cuando cambian los puntos o métricas del estudiante.
- Las reglas de clasificación son configurables o al menos documentadas por el equipo.
- El estudiante puede ver su categoría actual en su perfil.

## HU-16

- **Actor:** Estudiante
- **Prioridad:** Alta

> Como estudiante, quiero acceder a los ejercicios únicamente durante la ventana de tiempo activa de la actividad, y consultar después solo la información de actividades pasadas, para respetar los tiempos establecidos por el profesor.

**Criterios de aceptación**

- Fuera de la ventana activa, el estudiante no puede enviar o modificar respuestas.
- Una vez cerrada la actividad, el estudiante conserva acceso de solo lectura a sus resultados.
- El sistema muestra claramente el tiempo restante mientras la actividad está activa.

## HU-17

- **Actor:** Administrador
- **Prioridad:** Alta

> Como administrador, quiero contar con un panel administrativo para ver, editar, agregar o eliminar usuarios de la aplicación, para mantener el control general de la plataforma, considerando que los estudiantes pueden registrarse de forma autónoma.

**Criterios de aceptación**

- El panel permite operaciones CRUD completas sobre estudiantes, profesores y administradores.
- Solo usuarios con rol administrador tienen acceso a este panel.
- Toda acción de edición o eliminación queda registrada para trazabilidad.

## Matriz de trazabilidad

| HU | Tablas | Restricciones y objetos PL/SQL | Reportes |
|---|---|---|---|
| HU-01 | APP_USER, USER_TYPE, USER_STATUS | `uq_app_user_email`, `chk_app_user_pw_hash` (hash de 60 o más caracteres), trigger `trg_app_user_valida_correo` (dominio u.icesi.edu.co) | |
| HU-02 | ENROLLMENT, COURSE_GROUP, SEMESTER | `uq_enroll_student_group`, `uq_group_name_per_semester` | R1 |
| HU-03 | APP_USER | `photo_url` opcional; `name` e `institutional_email` NOT NULL | R1 |
| HU-04 | PROFESSOR, APP_USER | `uq_prof_code`; subtipo PROFESSOR creado solo por el administrador | |
| HU-05 | APP_USER | `password_hash` NOT NULL con longitud mínima | |
| HU-06 | ENROLLMENT, COURSE_GROUP, PROFESSOR | Filtro por semestre activo | R1 |
| HU-07 | SEMESTER | Índice único funcional `uq_semester_active_only_one`, procedimiento `sp_activar_semestre`, `fn_total_puntos` usa el semestre activo | R1 a R5 |
| HU-08 | ACTIVITY, ACTIVITY_EXERCISE, ACTIVITY_STATUS | `uq_ae_activity_exercise`, `uq_ae_activity_order`, `chk_activity_dates` | R6 |
| HU-09 | EXERCISE, DIFFICULTY_SCALE, LEVEL_RANK | `chk_diff_id_range` (0 a 10), `statement` CLOB NOT NULL | R4 |
| HU-10 | SCORE | `uq_score_student_exercise` (sin doble asignación), `uq_score_redemption_code`, procedimiento `sp_asignar_puntos` | R4 |
| HU-11 | SCORE | | R4 |
| HU-12 | SCORE, ENROLLMENT | | R2, R3 |
| HU-13 | SCORE, ENROLLMENT, ACTIVITY | | R3, R5, R6 |
| HU-14 | ENROLLMENT, SCORE | | R1, R5 |
| HU-15 | STUDENT, LEVEL_RANK | `fn_nivel_por_puntos`, `sp_recalcular_niveles`, trigger `trg_score_actualiza_nivel` | R5 |
| HU-16 | ACTIVITY, ACTIVITY_STATUS | `start_date` y `end_date` de la actividad; `sp_asignar_puntos` solo califica actividades ACTIVAS | R6 |
| HU-17 | APP_USER y subtipos | `ON DELETE CASCADE` de APP_USER a sus subtipos | |

Alcance de la base de datos frente a dos criterios: la HU-09 permite asociar un ejercicio a varios perfiles y el modelo asocia cada ejercicio a un perfil objetivo (`EXERCISE.level_id`); la trazabilidad de ediciones de la HU-17 queda para la capa de aplicación. Ambas decisiones se explican en [`modelo_relacional.md`](modelo_relacional.md#decisiones-de-diseño-y-alcance).

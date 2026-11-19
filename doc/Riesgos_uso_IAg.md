# Riesgos del uso de herramientas de IAg en el desarrollo de bases de datos
Documento de la Entrega 3. Describe los riesgos de usar IA generativa para actividades como diseñar esquemas, escribir scripts SQL y PL/SQL y generar datos de prueba, en un contexto profesional. La columna de ejemplo se refiere a este proyecto.
## 1. Riesgos y mitigaciones
| # | Riesgo | Qué puede pasar | Ejemplo en este proyecto | Mitigación |
|---|---|---|---|---|
| 1 | Alucinaciones y sintaxis incorrecta | La IA genera código que parece correcto pero falla o usa funciones que no existen en el motor | Mezclar `TOP` de SQL Server con `FETCH FIRST` de Oracle, o `LIMIT` de MySQL | Ejecutar todo en el motor real, revisar la documentación oficial y probar con `src/05_pruebas_plsql.sql` |
| 2 | Confusión de dialecto y versión | Sugiere características que no existen en la versión instalada | Columnas IDENTITY y `FETCH FIRST` exigen Oracle 12c o superior | Declarar la versión objetivo en el prompt y en el README |
| 3 | Errores de lógica silenciosos | La consulta corre pero devuelve resultados erróneos | Un JOIN que multiplica filas y duplica los puntos sumados, o un INNER JOIN que oculta estudiantes sin puntaje | Contrastar los resultados con cálculos manuales sobre datos pequeños; usar LEFT JOIN donde corresponde |
| 4 | Confidencialidad de datos | Al pegar datos reales en un servicio externo se exponen datos personales | Correos y nombres reales de estudiantes y profesores | Usar solo datos ficticios, como los de `src/02_dml.sql`; no compartir credenciales ni datos reales con la herramienta |
| 5 | Cumplimiento legal | Tratar datos personales sin autorización incumple la Ley 1581 de 2012 de Colombia | Subir listados reales del curso a una herramienta de IA | Anonimizar, conocer la política de retención de la herramienta y pedir autorización cuando aplique |
| 6 | Seguridad del código generado | Puede proponer prácticas inseguras | Guardar contraseñas en claro, concatenar texto en SQL dinámico con riesgo de inyección, otorgar privilegios excesivos | Exigir hash de contraseña con un CHECK, usar variables de enlace, revisar con criterio de seguridad |
| 7 | Rendimiento | Genera consultas correctas pero lentas | Falta de índices en llaves foráneas, subconsultas repetidas | Revisar planes de ejecución con `EXPLAIN PLAN` y crear los índices necesarios |
| 8 | Datos de prueba poco realistas | Los datos generados no cubren casos límite | Estudiantes sin puntos, actividades en borrador, grupos que se repiten entre semestres | Diseñar los casos a propósito y verificar que cada reporte tenga al menos 10 registros |
| 9 | Pérdida de criterio y dependencia | Quien no comprende el código no puede mantenerlo ni sustentarlo | No poder explicar por qué el trigger es compuesto y evita ORA-04091 | Todo el equipo debe entender y poder explicar cada elemento; revisión cruzada por pares |
| 10 | Autoría e integridad académica | Entregar como propio un producto generado sin declararlo | La actividad exige autoría propia del equipo y un nivel de uso permitido | Declarar el uso, mantener la bitácora de prompts y ajustar el uso al nivel permitido |
| 11 | Propiedad intelectual y licencias | El código generado puede parecerse a código con licencia | Fragmentos de ejemplos públicos reproducidos sin atribución | Revisar y reescribir el código, citar las fuentes cuando se usen |
| 12 | Sesgo y falta de contexto del negocio | La IA no conoce las reglas del curso y asume reglas genéricas | Rangos de las categorías Principiante, Killer y Pro inventados | Validar cada regla de negocio con las historias de usuario y con el profesor |
| 13 | No determinismo y trazabilidad | El mismo prompt da respuestas distintas y no se puede reproducir | Un script que funcionó una vez y no se sabe cómo se obtuvo | Versionar todo en el repositorio y registrar prompt, respuesta y cambios hechos |
## 2. Buenas prácticas que mitigan estos riesgos
- Tratar la salida de la IA como un borrador: se revisa, se ejecuta y se prueba antes de integrarla.
- Probar en el motor real, no confiar en que el código "se ve bien".
- Trabajar con datos ficticios y sin credenciales.
- Registrar en una bitácora los prompts usados, la respuesta obtenida y los cambios hechos por el equipo.
- Revisión por pares mediante pull requests antes de fusionar a `main`.
- Documentar cada procedimiento, función y trigger con su funcionalidad.
## 3. Uso de IAg en esta entrega
Se usó un asistente de IA generativa como apoyo para redactar y revisar los scripts SQL y PL/SQL, generar los datos de prueba y organizar la documentación del repositorio. Todos los datos son ficticios: no se compartieron con la herramienta datos reales de estudiantes o profesores ni credenciales. El registro de los prompts está en [`bitacora_prompts.md`](bitacora_prompts.md). Todos los scripts se ejecutaron en Oracle Database 23ai (ver [`evidencias/`](evidencias/)) y el equipo revisa cada script contra las historias de usuario antes de entregarlo y responde por su contenido en la sustentación.
## 4. Decisiones técnicas que tuvimos que validar
### 4.1 Un CHECK que "se veía bien" y no compilaba en Oracle (ORA-02438)
El DDL generado con apoyo de IA definía en LEVEL_RANK la restricción `max_points NUMBER CONSTRAINT chk_level_max_pts CHECK (max_points IS NULL OR max_points >= min_points)` como restricción **de columna**. Una primera comprobación en un motor distinto de Oracle no mostró error, porque otros motores lo aceptan. Al ejecutar el script en Oracle real, el motor respondió `ORA-02438: Column check constraint cannot reference other columns`: en Oracle un CHECK de columna no puede mencionar otra columna. La tabla no se creaba, y en cascada fallaban STUDENT, EXERCISE y todo lo que dependía de ellas (43 errores en el DDL y 175 en el DML).
- **Corrección:** declarar la restricción a nivel de tabla, después de las columnas.
- **Lección:** confirma los riesgos 1 y 2. Un script solo se considera validado cuando corre sin errores en el mismo motor y versión de producción, no en uno parecido.
### 4.2 Columna redundante que rompía la 3FN (`SCORE.group_id`)
La primera versión del modelo relacional incluía `group_id` en SCORE "para optimizar consultas". El equipo verificó la dependencia `activity_exercise_id → activity_id → group_id`: era transitiva, violaba la 3FN y además permitía registrar un puntaje en un grupo distinto al de su actividad. Se eliminó la columna y las consultas obtienen el grupo con JOIN. La justificación está en [`normalizacion_3FN.md`](normalizacion_3FN.md).
### 4.3 Conteos de los reportes
Cada reporte debe devolver al menos 10 filas. En lugar de aceptar el conteo que proponía la herramienta, se ejecutaron las consultas y se registraron los resultados reales: R1 20, R2 17, R3 10, R4 74, R5 20 y R6 11 filas ([resultados](evidencias/resultados_reportes.md)).

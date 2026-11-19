# Guion de la sustentación

Presentación: [`Sustentacion_SID_PensamientoComputacional.pptx`](Sustentacion_SID_PensamientoComputacional.pptx). Son 16 diapositivas para 12 minutos de exposición, dentro de los 30 minutos de la sustentación. Cada diapositiva tiene en las notas del orador quién la presenta y qué decir.

## Cumplimiento de la guía de sustentación

| Lo que pide la guía | Dónde se cumple |
|---|---|
| 1. Contexto y requerimientos: problema, alcance y requerimientos principales | Diapositiva 3 |
| 2. MER completo, entidades y relaciones principales, decisiones y ajustes durante el proyecto | Diapositivas 4 (MER completo) y 5 (decisiones; ajuste: el semestre pasó de atributo a entidad) |
| 3. Modelo relacional completo, transformación, claves, relaciones y justificación de la 3FN | Diapositivas 6 (MR completo), 7 (transformación y llaves) y 8 (3FN) |
| 4. Restricciones de integridad ligadas a reglas de negocio y descripción de los datos de prueba | Diapositiva 9 |
| 5. Todos los reportes, su utilidad, y SQL y resultados de las consultas más representativas | Diapositivas 10 (los 6 reportes), 11 (R2) y 12 (R5) |
| 6. Procedimiento, función y trigger: propósito, cuándo se ejecuta, qué hace y qué necesidad resuelve | Diapositivas 13 y 14 |
| 7. Uso de IAG, una decisión técnica validada y los riesgos profesionales | Diapositiva 15 |
| Duración de 12 minutos | Tiempos de la agenda: 1:30 + 1:30 + 2:00 + 1:30 + 2:30 + 2:00 + 1:00 = 12:00 |
| Todos los integrantes participan | Diapositiva 2: cada integrante presenta al menos una sección |
| Resultados reales de la ejecución | Diapositivas 10, 11, 12 y 14 usan los datos de [`../evidencias/`](../evidencias/) |
| Mostrar los tres tipos de objetos PL/SQL | Diapositiva 13 |
| Mostrar el MER y el MR completos, explicando solo lo relevante | Diapositivas 4 y 6, a pantalla completa. Tener abiertos los PDF de [`model/`](../../model/) para hacer zoom |
| No recorrer tabla por tabla ni leer los scripts | La presentación usa ejemplos, no listados |

## Ajustes finales a la presentación y su justificación

Antes de la sustentación se revisó la presentación contra la guía. Cada ajuste se hizo por una razón concreta, que se explica abajo. Todas las cifras de las diapositivas se verificaron contra los scripts: 16 PK, 20 FK, 13 UNIQUE, 9 CHECK, 1 índice único funcional y 10 índices en `src/01_ddl.sql`, 249 `INSERT` en `src/02_dml.sql` y `RESUMEN DE PRUEBAS: 20 APROBADAS, 0 FALLIDAS` en `doc/evidencias/logs/05_pruebas_plsql.log`.

| Diapositiva | Ajuste | Justificación |
|---|---|---|
| 3 | Se agregó la etiqueta "Caso original" | La guía de entregas pide declarar si el caso es original o adaptado. Antes solo estaba en las notas del orador; ahora se ve en pantalla y coincide con [`../caso_estudio.md`](../caso_estudio.md). |
| 4 | MER centrado, línea de notación y fuente del diagrama | La notación (`#`, `*`, `o`, pata de gallo, línea punteada) permite leer el diagrama sin explicarla de memoria. La fuente aclara que el diagrama viene del modelo de Data Modeler (ver la decisión 2). |
| 6 | Imagen del MR ajustada y fuente del diagrama | Igual que en la 4: se indica que es el mismo modelo relacional de Data Modeler. |
| 8 | Nueva viñeta sobre `SCORE.professor_id` | Era la pregunta más probable sobre la 3FN, porque se parece al caso de `group_id` que se eliminó. Ahora la presentación la responde antes de que la hagan (ver la decisión 1). |
| 11 | El SQL del podium es el de `src/03_dql.sql` | Antes era una versión simplificada (sin `student` ni `st.id`). La guía pide mostrar el SQL y los resultados reales; si el docente compara con el script, debe coincidir. Solo cambian los saltos de línea. |
| 12 | Código real de R5 y dos gráficas separadas | El fragmento anterior tenía `...` y no era SQL ejecutable; ahora se muestra la CTE `por_estudiante` tal como está en el script. La gráfica anterior ponía puntos y porcentajes en el mismo eje, lo que hacía comparar magnitudes que no se pueden comparar; ahora cada métrica tiene su gráfica. |
| 13 | Firma de cada objeto PL/SQL y nombres en colores de la paleta | La guía pide decir qué operaciones realiza cada objeto. Las firmas muestran los parámetros reales (`p_student_id`, `p_activity_exercise_id`, `p_professor_id`, `p_points`, `p_redemption_code`) y la estructura del trigger compuesto (`AFTER EACH ROW` y `AFTER STATEMENT`). Además se quitó un `·` suelto. |
| 15 | Una sola decisión técnica validada | La guía pide "una decisión técnica que tuvieron que validar". Se dejó la del CHECK de LEVEL_RANK (ORA-02438), que tiene evidencia medible: 43 sentencias del DDL y 175 del DML fallaban en cascada. La de `SCORE.group_id` queda en las notas como respuesta de respaldo. |

## Decisiones de diseño que se mantienen y cómo defenderlas

### 1. `SCORE.professor_id` se mantiene

**Duda:** `sp_asignar_puntos` exige que el profesor que califica sea el responsable de la actividad (-20004). Entonces, ¿no es `id → activity_exercise_id → activity_id → professor_id` una dependencia transitiva, igual que la de `group_id`?

**Respuesta:** No, porque la igualdad solo se exige *al insertar*. `ACTIVITY.professor_id` se puede cambiar después; por ejemplo, si un profesor deja el curso y la actividad se reasigna a otro. El puntaje debe seguir diciendo quién lo asignó, así que en los datos guardados `activity_exercise_id` no determina `professor_id`. Es un hecho histórico del puntaje, como el precio en una línea de factura: coincide con el del producto al facturar, pero no se recalcula si el precio cambia.

**Diferencia con `group_id`:** el grupo de un puntaje *nunca* puede ser distinto del grupo de su actividad, porque un puntaje en otro grupo sería un dato incorrecto. En cambio, quién calificó sí puede dejar de coincidir con el responsable actual de la actividad sin que el dato esté mal. Por eso `group_id` se eliminó y `professor_id` se mantiene.

**Alternativa evaluada:** eliminar la columna y obtener el profesor por la actividad. Se descartó porque una reasignación cambiaría en silencio quién aparece como calificador de puntajes ya dados, y se perdería la trazabilidad que pide la HU-17. Además obligaría a cambiar el DDL, los 81 puntajes del DML, el procedimiento y los dos modelos, e invalidaría los logs de ejecución que se presentan como evidencia.

### 2. Diagramas redibujados en lugar de las imágenes de Data Modeler

**Decisión:** las diapositivas 4 y 6 muestran los diagramas de `model/mer/MER_conceptual.pdf` y `model/mr/MR_3FN.pdf`, generados con Graphviz (`model/generar_diagramas.py`). Los de Data Modeler (`model/datamodeler/MER_datamodeler.pdf` y `MR_datamodeler.pdf`) se ven pequeños en el proyector y tienen cruces de líneas que dificultan explicarlos.

**Por qué es válido:** la guía exige el modelo hecho en Data Modeler en la carpeta `model`, y está completo: el `.dmd`, la carpeta del diseño, el `.zip` y los PDF. La presentación solo usa una versión más legible del mismo modelo. Se verificó que coinciden:

- Modelo lógico de Data Modeler: 16 entidades y 20 relaciones. Los tres subtipos de usuario están como relaciones 1:1 identificadoras, que el diagrama dibuja con línea punteada ("es un").
- Modelo relacional de Data Modeler: las mismas 16 tablas, con las mismas columnas, y 20 llaves foráneas, igual que el DDL.

Las diapositivas lo dicen en una nota al pie. Si el docente pide ver la herramienta, se abre `model/datamodeler/PensamientoComputacional.dmd`.

### 3. HU-09: un perfil objetivo por ejercicio

**Duda:** la HU-09 dice que un ejercicio se puede asociar a "uno o varios perfiles", pero `EXERCISE.level_id` es una sola FK.

**Respuesta:** fue una decisión de alcance documentada en [`../modelo_relacional.md`](../modelo_relacional.md#decisiones-de-diseño-y-alcance) (decisión 7) y en la matriz de trazabilidad de [`../historias_usuario.md`](../historias_usuario.md). Cada ejercicio tiene un perfil objetivo y la dificultad de 0 a 10 ya gradúa los ejercicios dentro de ese perfil; los datos de prueba y los reportes se construyeron así. Si se necesitaran varios perfiles, se agregaría una tabla asociativa `EXERCISE_LEVEL (exercise_id, level_id)` con PK compuesta y se quitaría `EXERCISE.level_id`. El resto del modelo no cambia, porque ninguna otra tabla ni consulta depende de esa columna.

## Reparto sugerido

| Sección | Expositor | Tiempo |
|---|---|---|
| Portada, agenda y 1. Contexto | Jose David Rodriguez | 1:30 |
| 2. MER | Jose David Valdez | 1:30 |
| 3. MR y 3FN | Jose David Valdez | 2:00 |
| 4. DDL y DML | Santiago Vinazco | 1:30 |
| 5. Reportes | Carlos Pasinga | 2:30 |
| 6. PL/SQL | Santiago Vinazco | 2:00 |
| 7. IAG y cierre | Carlos Pasinga y Jose David Rodriguez | 1:00 |

## Preparación antes de entrar

1. Base de datos cargada en SQL Developer con `src/01_ddl.sql`, `src/02_dml.sql` y `src/04_plsql.sql`.
2. Abiertos: `src/03_dql.sql`, `src/05_pruebas_plsql.sql`, `model/mer/MER_conceptual.pdf`, `model/mr/MR_3FN.pdf`, `doc/evidencias/resultados_reportes.md` y el diseño `model/datamodeler/PensamientoComputacional.dmd` en Data Modeler, por si piden ver el modelo en la herramienta.
3. Demo opcional, si sobra tiempo o lo piden: ejecutar `05_pruebas_plsql.sql` con F5 y mostrar `RESUMEN DE PRUEBAS: 20 APROBADAS, 0 FALLIDAS`.
4. Todos repasan el banco de preguntas de abajo: el docente puede preguntarle a cualquiera sobre cualquier parte.

## Banco de preguntas de práctica

### Modelado

**¿Por qué SCORE referencia ACTIVITY_EXERCISE y no EXERCISE?**
Porque se califica un ejercicio *dentro de una actividad*. El mismo ejercicio puede aparecer en varias actividades y un estudiante puede resolverlo en cada una. Con una sola FK a ACTIVITY_EXERCISE se sabe de qué ejercicio, de qué actividad y, por navegación, de qué grupo es el puntaje.

**¿Por qué ACTIVITY_EXERCISE tiene llave sustituta si ya tiene (activity_id, exercise_id)?**
Para que SCORE la referencie con una sola columna. La llave natural no se pierde: es `UNIQUE (activity_id, exercise_id)`.

**¿Cómo resolvieron la herencia de usuario?**
Con una tabla por subtipo. APP_USER guarda lo común y PROFESSOR, STUDENT y ADMINISTRATOR tienen como PK una FK a APP_USER con `ON DELETE CASCADE`. Así no hay columnas nulas que no aplican a un rol.

**¿Qué pasa con el G3 que existe en dos semestres?**
Es válido: la restricción es `UNIQUE (name, semester_id)`. El nombre se repite entre semestres, pero no dentro del mismo. En los datos, G1 y G3 existen en 2026-1 y 2026-2.

**¿Por qué los estados son tablas y no un CHECK con valores fijos?**
Fue la retroalimentación del docente. Además, con un catálogo se agrega o renombra un estado sin modificar la estructura, y la FK impide valores inválidos igual que un CHECK.

### Normalización

**Expliquen la 3FN con un ejemplo de su modelo.**
SCORE tenía `group_id`, que dependía de `activity_exercise_id` a través de la actividad: una dependencia transitiva. Lo eliminamos y el grupo se obtiene con JOIN. Ver [`../normalizacion_3FN.md`](../normalizacion_3FN.md).

**¿`current_level_id` no rompe la 3FN?**
No: ningún otro atributo de STUDENT lo determina. Es un dato derivado de los puntos que se almacena para mostrarlo en el perfil (HU-15). La redundancia está controlada: el trigger compuesto lo recalcula ante cualquier cambio en SCORE.

**¿Por qué SCORE.professor_id no es redundante con ACTIVITY.professor_id?**
Porque es un hecho histórico del puntaje: quién lo asignó en ese momento. `sp_asignar_puntos` exige que al insertar sea el responsable de la actividad, pero `ACTIVITY.professor_id` puede cambiar después si la actividad se reasigna, y el puntaje debe conservar quién lo dio. Por eso `activity_exercise_id` no lo determina. Ver la decisión 1 de este guion.

**¿Por qué EXERCISE tiene un solo perfil si la HU-09 permite varios?**
Fue una decisión de alcance: cada ejercicio tiene un perfil objetivo y la dificultad de 0 a 10 lo gradúa. Si se necesitaran varios, se agrega `EXERCISE_LEVEL (exercise_id, level_id)` sin tocar el resto del modelo. Ver la decisión 3 de este guion.

**¿Por qué el diagrama no es la imagen de Data Modeler?**
Es el mismo modelo redibujado para que se lea en el proyector: 16 entidades, 20 relaciones y 20 FK, verificados contra el `.dmd`. El modelo en Data Modeler está completo en `model/datamodeler/`. Ver la decisión 2 de este guion.

### SQL

**¿Dónde está el TOP?**
En R3: `FETCH FIRST 10 ROWS ONLY`, que es la sintaxis de Oracle 12c+ equivalente a `TOP 10` de SQL Server o `LIMIT 10` de MySQL.

**¿Por qué LEFT JOIN en R5 y R6?**
En R5, para no perder a los estudiantes matriculados sin puntos (aparecen con 0 y bajan la tasa de participación). En R6, para mostrar las actividades sin calificaciones, como la actividad en BORRADOR del G7.

**¿Diferencia entre RANK, DENSE_RANK y ROW_NUMBER?**
Ante un empate en el segundo puesto: RANK da 1, 2, 2, 4; DENSE_RANK da 1, 2, 2, 3; ROW_NUMBER da 1, 2, 3, 4. Usamos RANK para que los empatados compartan el puesto del podium.

**¿Por qué el filtro de RANK va en otra CTE y no en el WHERE?**
Las funciones de ventana se evalúan después del WHERE, así que no se pueden filtrar en el mismo nivel de consulta.

**¿Qué hace `NULLIF(x, 0)` en R5 y R6?**
Evita la división por cero: si el divisor es 0 devuelve NULL y el porcentaje queda NULL en vez de dar error.

**¿Por qué `DBMS_LOB.SUBSTR` en R4?**
`statement` es CLOB. Se muestran los primeros 60 caracteres porque un CLOB completo no se presenta bien en el listado.

### Integridad y DDL

**¿Cómo garantizan un solo semestre activo?**
Con un índice único funcional sobre `CASE WHEN active = 1 THEN 1 ELSE NULL END`. Oracle no indexa las filas cuya expresión es NULL, así que solo puede existir una fila con valor 1.

**¿Cómo evitan la doble asignación de puntos?**
Con `UNIQUE (student_id, activity_exercise_id)` en SCORE. El procedimiento captura `DUP_VAL_ON_INDEX` y devuelve el error -20006 con un mensaje claro.

**¿Por qué el CHECK de LEVEL_RANK es de tabla?**
Porque compara dos columnas (`max_points >= min_points`). En Oracle, un CHECK de columna no puede referenciar otra columna (ORA-02438); lo descubrimos al ejecutar en Oracle real.

### PL/SQL

**¿Por qué el trigger es compuesto?**
Un trigger por fila sobre SCORE no puede consultar SCORE mientras se está modificando: da ORA-04091 (tabla mutante). En el trigger compuesto, la sección AFTER EACH ROW solo guarda los ids de los estudiantes y la sección AFTER STATEMENT, cuando la tabla ya es estable, recalcula sus categorías.

**¿Por qué los procedimientos no hacen COMMIT?**
Para que la transacción la controle quien los invoca. Si la aplicación hace varias operaciones, todas se confirman o se deshacen juntas. Por eso las pruebas terminan con ROLLBACK.

**¿Qué pasa si `fn_total_puntos` se llama sin semestre activo?**
El `SELECT ... INTO` lanza NO_DATA_FOUND, que se captura y devuelve 0.

**¿Qué códigos de error usan?**
Del -20001 al -20007 en los procedimientos y -20010 y -20011 en el trigger de correo. Son el rango reservado por Oracle para `RAISE_APPLICATION_ERROR`.

**¿Qué pasa si un UPDATE cambia el estudiante de un puntaje?**
El trigger guarda tanto el estudiante nuevo como el anterior y recalcula la categoría de ambos.

### IAG

**¿Qué decisión técnica tuvieron que validar?**
La que se presenta es el CHECK de LEVEL_RANK: declarado como CHECK de columna comparaba `max_points` con `min_points`, pasó en otro motor y en Oracle dio ORA-02438; en cascada fallaban 43 sentencias del DDL y 175 del DML. Se corrigió como restricción de tabla y se volvió a ejecutar todo. Si piden otra: la columna `SCORE.group_id`, que se eliminó por romper la 3FN. Ver [`../Riesgos_uso_IAg.md`](../Riesgos_uso_IAg.md#4-decisiones-técnicas-que-tuvimos-que-validar).

**¿Qué riesgos ven en un contexto profesional?**
Código que parece correcto pero no corre en el motor real, errores lógicos silenciosos, exposición de datos personales (Ley 1581 de 2012) y perder el criterio para mantener y sustentar el código.

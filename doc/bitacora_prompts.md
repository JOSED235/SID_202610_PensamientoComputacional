# Bitácora de prompts de IAG

Registro del uso de herramientas de IA generativa en el proyecto, como lo pide la guía y como mitigación del riesgo 13 (no determinismo y trazabilidad) de [`Riesgos_uso_IAg.md`](Riesgos_uso_IAg.md). Para cada uso se anota la herramienta, el prompt, lo que respondió la herramienta y qué validó o cambió el equipo.

Reglas que se aplicaron en todos los usos:

- Solo se compartieron datos ficticios. No se entregaron a la herramienta datos reales de estudiantes, profesores ni credenciales.
- Toda salida se trató como borrador: el equipo la revisó contra las historias de usuario y la ejecutó en Oracle antes de integrarla.
- El código y la documentación finales son responsabilidad del equipo, que los sustenta.

## Entrega 0: planeación

| Herramienta | Uso | Validación del equipo |
|---|---|---|
| Asistente de IAG | Apoyo en planeación e ideación del caso y de la redacción de las historias de usuario, según el nivel de uso permitido en esa entrega | El caso, las historias y los acuerdos se redactaron y ajustaron por el equipo |

## Entrega 3: organización del repositorio y scripts (2026-11-15)

**Herramienta:** Claude Code (asistente de programación en la terminal).

| # | Prompt (textual, resumido donde es muy largo) | Respuesta de la herramienta | Validación y cambios del equipo |
|---|---|---|---|
| 1 | "Quiero que me ayudes a organizar todo esto, que trabajamos en una entrega, pero no se subió al repo, así que quedó todo desorganizado [...] también asegurarte de que tengamos todo esto" (se adjuntó la lista de requisitos de la Entrega 3) | Propuso la estructura del repositorio (`docs/`, `sql/`), redactó el documento de riesgos de IAg, ordenó los scripts y el README con la tabla de requisitos | El equipo revisó la estructura y los textos antes de subirlos |
| 2 | "Sí, haz el commit y el push, sin coautoría" | Creó el commit `8ac9b24` | Commit revisado por el líder del proyecto |

## Cierre del proyecto (2026-11-18)

**Herramienta:** Claude Code.

| # | Prompt (textual) | Respuesta de la herramienta | Validación y cambios del equipo |
|---|---|---|---|
| 3 | "Quiero que revises el estado total del proyecto y mires si tenemos todo lo que pide la guía [...] la idea es que esté exageradamente completa con absolutamente todo lo que pide" | Comparó la guía con el repositorio. Encontró que el PDF del MR no coincidía con el DDL (le faltaban las tablas de dominio y tenía `SCORE.group_id`), que el MER estaba desactualizado y que faltaban documentos de `doc/` | El equipo confirmó los hallazgos contra los archivos |
| 4 | "Quiero que me ayudes ahora con todo eso que nos falta" | Reorganizó el repositorio en `doc/`, `model/` y `src/`. Ejecutó los scripts en Oracle 23ai en Docker y encontró `ORA-02438` en LEVEL_RANK. Regeneró el MER y el MR desde el diccionario de datos y redactó la documentación y la presentación | El equipo decidió que el caso es original. Indicó que no hubo actas formales porque las reuniones fueron presenciales, así que el seguimiento se reconstruye desde los commits. Revisó la corrección del CHECK y los resultados reales de los reportes |
| 5 | "Para la presentación ten en cuenta todo lo que dice que debe tener para que no nos falte absolutamente nada" | Armó la presentación siguiendo las 7 secciones y las orientaciones de la guía, con los resultados reales | El equipo revisa el contenido y reparte las secciones entre los integrantes |
| 6 | "Si puedes, con base en la DB que realmente estamos trabajando, actualiza el MER y el MR si todavía hay alguno viejo por ahí" | Generó el MR leyendo `USER_TAB_COLUMNS` y `USER_CONSTRAINTS` de la base real y el MER conceptual equivalente. Movió los modelos anteriores a `model/anterior/` | El equipo validó que el MR tuviera 16 tablas y 20 FK, igual que el DDL |
| 7 | "Deja todo completamente listo para entregar, revisa los modelos que pusiste en las diapositivas que se ven exageradamente desordenados y poco legibles" | Rehízo los diagramas con disposición fija por módulos y líneas ortogonales, y preparó versiones para las diapositivas con letra más grande | El equipo revisó la legibilidad en la presentación |
| 8 | "Ahí te dejé abierto el Data Modeler para que puedas hacer directamente todo desde ahí y queden mejor los modelos" | Operó Data Modeler: importó el DDL, generó el modelo lógico, reubicó tablas y entidades por módulos sin que ninguna línea atraviese una caja, y exportó los PDF y el zip del diseño | El equipo abrió el `.dmd` y revisó los PDF |

## Revisión final de la sustentación (2026-11-19)

**Herramienta:** Claude Code.

| # | Prompt (textual) | Respuesta de la herramienta | Validación y cambios del equipo |
|---|---|---|---|
| 9 | "Revisa en la presentación cómo podríamos mejorarla, que esté todo lo que pide la rúbrica, que esté todo más limpio, completo, detallado" | Comparó las 16 diapositivas con la guía de sustentación. Confirmó que cubren las 7 secciones y señaló: SQL simplificado o con `...` en R2 y R5, una gráfica que mezclaba puntos y porcentajes en el mismo eje, la justificación contradictoria de `SCORE.professor_id`, el uso de diagramas que no son de Data Modeler y la diferencia de la HU-09 con `EXERCISE.level_id` | El equipo decidió mantener los diagramas redibujados porque se leen mejor en el proyector |
| 10 | "Aplica los cambios que puedas en el pptx" | Puso el SQL real de `src/03_dql.sql` en R2 y R5, separó la gráfica de métricas en dos, agregó la etiqueta de caso original, la notación del MER, las firmas de los objetos PL/SQL y dejó una sola decisión validada en la diapositiva de IAG | El equipo revisó las diapositivas renderizadas |
| 11 | "Corrige las cosas que consideres más importantes pero que realmente estén justificadas y me lo pongas en el archivo de guion para cada uno" | Verificó contra los scripts las cifras de la presentación (16 PK, 20 FK, 13 UNIQUE, 9 CHECK, 249 filas) y comparó el `.dmd` con los diagramas (16 entidades, 20 relaciones, 20 FK). Corrigió la justificación de `SCORE.professor_id` como dato histórico, agregó la nota de fuente a los diagramas y documentó cada ajuste y decisión en el guion | El equipo aceptó mantener `SCORE.professor_id` sin cambiar el esquema, porque cambiarlo invalidaría los logs de ejecución en Oracle |

## Lecciones

- La herramienta no detectó el error ORA-02438 mientras no se ejecutó en Oracle real; la validación en el motor fue indispensable.
- Las sugerencias de "optimizar" con columnas redundantes (como `SCORE.group_id`) deben contrastarse con la normalización.
- Registrar los prompts permitió reconstruir qué se hizo y por qué, aun sin actas formales de reunión.

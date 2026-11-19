# Plataforma de gamificación para Pensamiento Computacional

Proyecto del curso **Sistemas Intensivos en Datos 1**, Universidad Icesi, 2026-2.

El curso de Pensamiento Computacional de la Universidad Icesi usa recompensas para motivar a los estudiantes, pero cada profesor las maneja a su manera. Este proyecto diseña e implementa la base de datos Oracle de una plataforma que estandariza esa gamificación. La plataforma registra a los estudiantes, profesores y administradores, los semestres, los grupos y las matrículas, el banco de ejercicios, las actividades de clase y los puntos que asignan los profesores. Con esos datos genera el podium por grupo, el TOP 10 del semestre, el historial de puntos y las métricas de grupo, y clasifica automáticamente a cada estudiante como **Principiante**, **Killer** o **Pro**.

Repositorio: https://github.com/JOSED235/SID_202610_PensamientoComputacional

## Equipo

| Integrante | Código | GitHub | Rol |
|---|---|---|---|
| Jose David Rodriguez Pinilla | A00407151 | [JOSED235](https://github.com/JOSED235) | Líder de proyecto |
| Jose David Valdez | A00408018 | [K0R0Zz](https://github.com/K0R0Zz) | Modelado de datos |
| Santiago Vinazco Ortegon | A00410366 | [Svinazco100](https://github.com/Svinazco100) | Desarrollo de base de datos |
| Carlos Pasinga | A00412446 | [Sayan007-c](https://github.com/Sayan007-c) | Documentación y calidad |

## Estructura del repositorio

```
doc/     caso, requerimientos, acuerdos, seguimiento, bitácora de prompts, riesgos de IAg, normalización, evidencias y sustentación
model/   MER y modelo relacional: Data Modeler (.dmd, zip, PDF), diagramas legibles (PDF, PNG, SVG) y versiones anteriores
src/     scripts DDL, DML, DQL, PL/SQL y pruebas
```

### `doc/`

| Documento | Contenido | Entrega |
|---|---|---|
| [Caso de estudio](doc/caso_estudio.md) | Contexto, problema, objetivo, alcance, entidades, reportes y declaración de que el caso es **original** | 0 |
| [Historias de usuario](doc/historias_usuario.md) | HU-01 a HU-17 con criterios de aceptación y matriz de trazabilidad HU → tablas → PL/SQL → reportes | 0 |
| [Requerimientos (docx original)](doc/ProyectoFinalRequerimientosDef.docx) | Documento entregado por Saman | 0 |
| [Acuerdos del equipo](doc/acuerdos_equipo.md) | Roles, responsabilidades, cronograma y estrategia de trabajo | 0 |
| [Seguimiento](doc/seguimiento.md) | Por entrega: qué se cumplió, qué cambió, dificultades y redistribución de tareas | 1 a 3 |
| [Bitácora de prompts](doc/bitacora_prompts.md) | Prompts de IAG usados, respuesta y validación del equipo | 1 a 3 |
| [Modelo relacional](doc/modelo_relacional.md) | Tablas por módulo, cambios por la retroalimentación y decisiones de diseño | 2 y 3 |
| [Normalización 3FN](doc/normalizacion_3FN.md) | Dependencias funcionales y justificación de 1FN, 2FN y 3FN tabla por tabla | 2 y 3 |
| [Riesgos del uso de IAg](doc/Riesgos_uso_IAg.md) | 13 riesgos con ejemplo y mitigación, y las decisiones técnicas que tuvimos que validar | 3 |
| [Resultados de los reportes](doc/evidencias/resultados_reportes.md) | Resultado real de cada consulta en Oracle 23ai | 3 |
| [Logs de ejecución](doc/evidencias/logs/) | Salida de SQL*Plus de cada script | 3 |
| [Presentación](doc/sustentacion/Sustentacion_SID_PensamientoComputacional.pptx) y [guion](doc/sustentacion/guion_sustentacion.md) | Presentación de 12 minutos con las 7 secciones de la guía, guion por integrante y preguntas de práctica | Sustentación |

### `model/`

| Modelo | Imagen | Fuentes |
|---|---|---|
| MER conceptual | [PDF](model/mer/MER_conceptual.pdf) · [PNG](model/mer/MER_conceptual.png) | [SVG](model/mer/MER_conceptual.svg) · [Graphviz](model/mer/MER_conceptual.dot) |
| Modelo relacional en 3FN | [PDF](model/mr/MR_3FN.pdf) · [PNG](model/mr/MR_3FN.png) | [SVG](model/mr/MR_3FN.svg) · [Graphviz](model/mr/MR_3FN.dot) |
| **Data Modeler (fuentes oficiales)** | [MER](model/datamodeler/MER_datamodeler.pdf) · [MR](model/datamodeler/MR_datamodeler.pdf) | [`.dmd`](model/datamodeler/PensamientoComputacional.dmd) · [zip](model/datamodeler/PensamientoComputacional_datamodeler.zip) |
| Versiones anteriores (Entregas 1 y 2) | [MER](model/anterior/MER_anterior.pdf) · [MR](model/anterior/MR_anterior_Relationalcorregido.pdf) | [zip del MER](model/anterior/MER_PROYECTO_2_datamodeler.zip) |

### `src/`

| Script | Contenido |
|---|---|
| [00_drop_all.sql](src/00_drop_all.sql) | Elimina todos los objetos para ejecutar de nuevo desde cero |
| [01_ddl.sql](src/01_ddl.sql) | 16 tablas con PK, FK, UNIQUE y CHECK, índice único funcional, 10 índices y comentarios del diccionario de datos en cada tabla y columna |
| [02_dml.sql](src/02_dml.sql) | 249 filas de prueba ficticias: 1 administrador, 4 profesores, 24 estudiantes, 3 semestres, 6 grupos, 15 ejercicios, 11 actividades y 81 puntajes |
| [03_dql.sql](src/03_dql.sql) | 6 reportes, cada uno con su descripción en lenguaje natural |
| [04_plsql.sql](src/04_plsql.sql) | 2 funciones, 3 procedimientos y 2 triggers documentados |
| [05_pruebas_plsql.sql](src/05_pruebas_plsql.sql) | 20 pruebas automáticas de los objetos PL/SQL; termina con ROLLBACK |

## Cumplimiento de la Entrega 3

| Requisito de la guía | Dónde está | Verificación |
|---|---|---|
| Script DDL debidamente documentado | [01_ddl.sql](src/01_ddl.sql) | Ejecuta sin errores ([log](doc/evidencias/logs/01_ddl.log)) |
| DML con las tuplas para los reportes, al menos 10 registros por reporte | [02_dml.sql](src/02_dml.sql) | Reportes con 20, 17, 10, 74, 20 y 11 filas |
| DQL con agrupamiento, inner join, outer join, ordenamiento y al menos un TOP, con descripción en lenguaje natural | [03_dql.sql](src/03_dql.sql) | [Resultados](doc/evidencias/resultados_reportes.md) |
| Riesgos del uso de IAg en un contexto profesional | [Riesgos_uso_IAg.md](doc/Riesgos_uso_IAg.md) | |
| Al menos un procedimiento, una función y un trigger, documentados | [04_plsql.sql](src/04_plsql.sql) | 20 de 20 pruebas aprobadas ([log](doc/evidencias/logs/05_pruebas_plsql.log)) |
| Repositorio completo con README, `doc`, `model` y `src` | Este README | |

## Reportes

| Reporte | Historias | Técnicas SQL | Filas |
|---|---|---|---|
| R1 Estudiantes por grupo | HU-02, HU-06, HU-07, HU-14 | INNER JOIN múltiple, ORDER BY | 20 |
| R2 Podium por grupo (top 5) | HU-12 | CTE, GROUP BY, SUM, RANK() OVER (PARTITION BY) | 17 |
| R3 TOP 10 del semestre | HU-12, HU-13 | GROUP BY, COUNT, SUM, ORDER BY, **TOP** (`FETCH FIRST 10 ROWS ONLY`) | 10 |
| R4 Historial con acumulado | HU-11 | INNER JOIN, SUM() OVER (ORDER BY) acumulado | 74 |
| R5 Desempeño y métricas del grupo | HU-13, HU-14, HU-15 | **LEFT OUTER JOIN**, GROUP BY, NVL, AVG() OVER, tasa de participación | 20 |
| R6 Participación por actividad | HU-08, HU-13, HU-16 | **LEFT OUTER JOIN**, GROUP BY, COUNT(DISTINCT), NULLIF | 11 |

## Elementos PL/SQL

| Elemento | Tipo | Cuándo se ejecuta | Funcionalidad |
|---|---|---|---|
| `fn_total_puntos` | Función | Se invoca desde SQL o PL/SQL | Total de puntos de un estudiante en un semestre (por defecto el activo) |
| `fn_nivel_por_puntos` | Función | Se invoca desde SQL o PL/SQL | Categoría que corresponde a una cantidad de puntos según LEVEL_RANK |
| `sp_asignar_puntos` | Procedimiento | Lo llama la aplicación al validar el código del estudiante | Registra un puntaje validando puntos positivos, actividad ACTIVA, profesor responsable, matrícula y doble asignación (errores -20001 a -20006) |
| `sp_recalcular_niveles` | Procedimiento | Al cambiar los rangos de LEVEL_RANK o de semestre | Recalcula la categoría de todos los estudiantes |
| `sp_activar_semestre` | Procedimiento | Al iniciar un semestre | Deja un solo semestre activo y recalcula las categorías |
| `trg_app_user_valida_correo` | Trigger BEFORE INSERT/UPDATE por fila | Automático en APP_USER | Exige el dominio u.icesi.edu.co a los estudiantes (HU-01) |
| `trg_score_actualiza_nivel` | Trigger compuesto | Automático en INSERT, UPDATE o DELETE de SCORE | Recalcula la categoría del estudiante afectado sin el error de tabla mutante ORA-04091 (HU-15) |

## Cómo ejecutar

Requiere Oracle Database 12c o superior (usa columnas IDENTITY y `FETCH FIRST`). Probado en **Oracle Database 23ai Free**. Los scripts no llevan tildes para evitar problemas de codificación.

En SQL Developer, abrir cada archivo y ejecutarlo con "Ejecutar script" (F5), en este orden:

1. `src/00_drop_all.sql` (solo si ya existían los objetos)
2. `src/01_ddl.sql`
3. `src/02_dml.sql`
4. `src/04_plsql.sql`
5. `src/03_dql.sql`
6. `src/05_pruebas_plsql.sql`

`04_plsql.sql` va antes de `03_dql.sql` para que las consultas se ejecuten con los objetos PL/SQL ya creados, aunque los reportes no dependen de ellos.

Para probar sin instalar Oracle se puede usar Docker:

```bash
docker run -d --name sid-oracle -p 1521:1521 -e ORACLE_PASSWORD=<clave> -e APP_USER=sid -e APP_USER_PASSWORD=<clave> gvenzl/oracle-free:23-slim-faststart
# Conexión: usuario sid, servicio FREEPDB1, puerto 1521
```

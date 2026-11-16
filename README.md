# Plataforma de gamificación para Pensamiento Computacional
Proyecto del curso Sistemas Intensivos en Datos 1, Universidad Icesi. Base de datos Oracle para registrar los ejercicios, las actividades y los puntajes de los estudiantes del curso de Pensamiento Computacional, con podium por grupo y categorías de desempeño (Principiante, Killer y Pro).
Repositorio: https://github.com/JOSED235/SID_202610_PensamientoComputacional
## Equipo
| Integrante | Código | GitHub | Rol |
|---|---|---|---|
| Jose David Rodriguez Pinilla | A00407151 | JOSED235 | Líder de proyecto |
| Jose David Valdez | A00408018 | K0R0Zz | Modelado de datos |
| Santiago Vinazco Ortegon | A00410366 | Svinazco100 | Desarrollo de base de datos |
| Carlos Pasinga | A00412446 | Sayan007-c | Documentación y calidad |
## Contenido del repositorio
| Ruta | Entrega | Descripción |
|---|---|---|
| `docs/ProyectoFinalRequerimientosDef.docx` | 0 | Caso de estudio, historias de usuario HU-01 a HU-17, roles y cronograma |
| `docs/mer/` | 1 | Modelo entidad relación en Oracle Data Modeler (`MER PROYECTO 2.dmd`) y su exportación `M.E.Rl.pdf` |
| `docs/modelo_relacional.md` | 2 y 3 | Modelo relacional corregido, por módulos, con la lista de cambios y las tablas |
| `docs/Riesgos_uso_IAg.md` | 3 | Riesgos del uso de IAg en este tipo de actividades |
| `sql/00_drop_all.sql` | 3 | Elimina los objetos del proyecto para ejecutar de nuevo desde cero |
| `sql/01_ddl.sql` | 3 | Tablas, tablas de dominio, restricciones, índices y comentarios del diccionario de datos |
| `sql/02_dml.sql` | 3 | Datos de prueba ficticios |
| `sql/03_dql.sql` | 3 | Seis consultas de reportes, cada una con su descripción en lenguaje natural |
| `sql/04_plsql.sql` | 3 | 2 funciones, 3 procedimientos y 2 triggers documentados |
| `sql/05_pruebas_plsql.sql` | 3 | Pruebas de los elementos PL/SQL, termina con ROLLBACK |
## Entrega 3
| Requisito | Dónde está |
|---|---|
| Script DDL documentado | `sql/01_ddl.sql` |
| Script DML con al menos 10 registros por reporte | `sql/02_dml.sql` |
| Consultas DQL con agrupamiento, inner join, outer join, ordenamiento y TOP | `sql/03_dql.sql` |
| Riesgos del uso de herramientas de IAg | `docs/Riesgos_uso_IAg.md` |
| Procedimiento almacenado, función y trigger | `sql/04_plsql.sql` y `sql/05_pruebas_plsql.sql` |
## Reportes
| Reporte | Historias de usuario | Técnicas | Filas con los datos de prueba |
|---|---|---|---|
| R1 Estudiantes por grupo | HU-02, HU-06, HU-07 | INNER JOIN, ORDER BY | 20 |
| R2 Podium por grupo | HU-12 | GROUP BY, RANK | 17 |
| R3 TOP 10 del semestre | HU-12, HU-13 | GROUP BY, TOP con FETCH FIRST | 10 |
| R4 Historial con acumulado | HU-11 | SUM acumulada | 74 |
| R5 Desempeño y métricas del grupo | HU-13, HU-14, HU-15 | LEFT JOIN, GROUP BY, funciones de ventana | 20 |
| R6 Participación por actividad | HU-08, HU-13, HU-16 | LEFT JOIN, COUNT DISTINCT | 11 |
## Elementos PL/SQL
| Elemento | Tipo | Funcionalidad |
|---|---|---|
| `fn_total_puntos` | Función | Total de puntos de un estudiante en un semestre, por defecto el activo |
| `fn_nivel_por_puntos` | Función | Categoría que corresponde a una cantidad de puntos según `LEVEL_RANK` |
| `sp_asignar_puntos` | Procedimiento | Registra un puntaje después de validar actividad, profesor, matrícula y doble asignación |
| `sp_recalcular_niveles` | Procedimiento | Recalcula la categoría de todos los estudiantes |
| `sp_activar_semestre` | Procedimiento | Deja un solo semestre activo y recalcula las categorías |
| `trg_app_user_valida_correo` | Trigger | Exige el dominio u.icesi.edu.co en el correo de los estudiantes |
| `trg_score_actualiza_nivel` | Trigger compuesto | Actualiza la categoría del estudiante cuando cambian sus puntajes |
## Cómo ejecutar
Requiere Oracle Database 12c o superior, porque usa columnas IDENTITY y `FETCH FIRST`. Los scripts no llevan tildes para evitar problemas de codificación. Para empezar de nuevo se corre antes `sql/00_drop_all.sql`. En SQL Developer o SQL*Plus, ejecutar cada archivo con "Ejecutar script" (F5) en este orden:
1. `sql/01_ddl.sql`
2. `sql/02_dml.sql`
3. `sql/03_dql.sql`
4. `sql/04_plsql.sql`
5. `sql/05_pruebas_plsql.sql`

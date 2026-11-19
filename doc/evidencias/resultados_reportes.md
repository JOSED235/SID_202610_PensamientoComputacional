# Evidencia de ejecución de los reportes (DQL)

Resultados reales obtenidos al ejecutar `src/03_dql.sql` sobre Oracle Database 23.26.4.0.0 (contenedor `gvenzl/oracle-free`), después de cargar `01_ddl.sql`, `02_dml.sql` y `04_plsql.sql`. Fecha de ejecución: 2026-11-18.

## Resumen

| Reporte | Filas | Cumple mínimo de 10 |
|---|---|---|
| R1. Estudiantes registrados por grupo (HU-02, HU-06, HU-07, HU-14) | 20 | Sí |
| R2. Podium: 5 mejores estudiantes por grupo (HU-12) | 17 | Sí |
| R3. TOP 10 de estudiantes del semestre (HU-12, HU-13) | 10 | Sí |
| R4. Historial de puntos con acumulado (HU-11) | 74 | Sí |
| R5. Desempeno por estudiante y metricas del grupo (HU-13, HU-14, HU-15) | 20 | Sí |
| R6. Participacion por actividad (HU-08, HU-13, HU-16) | 11 | Sí |

## R1. Estudiantes registrados por grupo (HU-02, HU-06, HU-07, HU-14)

> Lista los estudiantes matriculados en los grupos del semestre activo, con su grupo, profesor, categoria actual y fecha de registro, ordenados por grupo y nombre. Es el listado base que ve el profesor y el que se exporta en el PDF de la HU-14. Tecnicas: INNER JOIN multiple y ORDER BY.

```sql
SELECT g.name                 AS grupo,
       u.name                 AS estudiante,
       u.institutional_email  AS correo,
       lr.name                AS categoria,
       us.name                AS estado_cuenta,
       pu.name                AS profesor,
       e.registration_date    AS fecha_registro
FROM enrollment e
INNER JOIN course_group g ON g.id = e.group_id
INNER JOIN semester sem   ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st     ON st.id = e.student_id
INNER JOIN app_user u     ON u.id = st.id
INNER JOIN user_status us ON us.id = u.status_id
INNER JOIN level_rank lr  ON lr.id = st.current_level_id
INNER JOIN professor p    ON p.id = g.professor_id
INNER JOIN app_user pu    ON pu.id = p.id
ORDER BY g.name, u.name;
```

**Filas devueltas: 20**

| GRUPO | ESTUDIANTE | CORREO | CATEGORIA | ESTADO_CUENTA | PROFESOR | FECHA_REGISTRO |
|---|---|---|---|---|---|---|
| G1 | Andres Felipe Mora | andres.mora@u.icesi.edu.co | Killer | ACTIVO | Laura Mejia Cardenas | 2026-08-05 13:08 |
| G1 | Camila Restrepo Salazar | camila.restrepo@u.icesi.edu.co | Principiante | ACTIVO | Laura Mejia Cardenas | 2026-08-06 14:15 |
| G1 | Daniel Ortiz Velez | daniel.ortiz@u.icesi.edu.co | Killer | ACTIVO | Laura Mejia Cardenas | 2026-08-07 15:22 |
| G1 | Mariana Gil Herrera | mariana.gil@u.icesi.edu.co | Killer | ACTIVO | Laura Mejia Cardenas | 2026-08-04 12:01 |
| G1 | Samuel Cardenas Londono | samuel.cardenas@u.icesi.edu.co | Killer | ACTIVO | Laura Mejia Cardenas | 2026-08-03 11:54 |
| G1 | Valentina Ospina Rojas | valentina.ospina@u.icesi.edu.co | Killer | ACTIVO | Laura Mejia Cardenas | 2026-08-08 10:47 |
| G3 | Isabela Munoz Arias | isabela.munoz@u.icesi.edu.co | Killer | ACTIVO | Ricardo Salcedo Ponce | 2026-08-04 09:43 |
| G3 | Juan Pablo Cifuentes | juan.cifuentes@u.icesi.edu.co | Killer | ACTIVO | Ricardo Salcedo Ponce | 2026-08-03 08:36 |
| G3 | Luciana Benitez Cruz | luciana.benitez@u.icesi.edu.co | Killer | ACTIVO | Ricardo Salcedo Ponce | 2026-08-06 11:57 |
| G3 | Mateo Zapata Giraldo | mateo.zapata@u.icesi.edu.co | Killer | ACTIVO | Ricardo Salcedo Ponce | 2026-08-05 10:50 |
| G3 | Sofia Navarro Duque | sofia.navarro@u.icesi.edu.co | Killer | ACTIVO | Ricardo Salcedo Ponce | 2026-08-08 16:29 |
| G5 | Gabriela Montoya Lasso | gabriela.montoya@u.icesi.edu.co | Killer | ACTIVO | Adriana Burbano Lemos | 2026-08-08 13:11 |
| G5 | Nicolas Aristizabal Mena | nicolas.aristizabal@u.icesi.edu.co | Principiante | ACTIVO | Adriana Burbano Lemos | 2026-08-03 14:18 |
| G5 | Paula Andrea Rios | paula.rios@u.icesi.edu.co | Killer | ACTIVO | Adriana Burbano Lemos | 2026-08-04 15:25 |
| G5 | Santiago Quintero Pardo | santiago.quintero@u.icesi.edu.co | Killer | ACTIVO | Adriana Burbano Lemos | 2026-08-07 12:04 |
| G5 | Sebastian Caicedo Mena | sebastian.caicedo@u.icesi.edu.co | Killer | ACTIVO | Adriana Burbano Lemos | 2026-08-05 16:32 |
| G7 | Emmanuel Henao Posada | emmanuel.henao@u.icesi.edu.co | Principiante | ACTIVO | Hector Fabio Marin | 2026-08-07 09:46 |
| G7 | Juliana Cortes Bedoya | juliana.cortes@u.icesi.edu.co | Principiante | ACTIVO | Hector Fabio Marin | 2026-08-08 10:53 |
| G7 | Manuela Escobar Toro | manuela.escobar@u.icesi.edu.co | Principiante | ACTIVO | Hector Fabio Marin | 2026-08-06 08:39 |
| G7 | Tomas Villegas Orozco | tomas.villegas@u.icesi.edu.co | Principiante | ACTIVO | Hector Fabio Marin | 2026-08-03 11:00 |

## R2. Podium: 5 mejores estudiantes por grupo (HU-12)

> Suma los puntos de cada estudiante en su grupo del semestre activo y conserva solo las cinco primeras posiciones de cada grupo. Si hay empates comparten posicion, por lo que un grupo podria mostrar mas de 5. 3FN: Navega score -> activity_exercise -> activity -> course_group. Tecnicas: GROUP BY, INNER JOIN, funcion de ventana RANK y ORDER BY.

```sql
WITH puntos AS (
    SELECT g.id AS group_id, g.name AS grupo, st.id AS student_id,
           u.name AS estudiante, SUM(sc.points) AS total_puntos
    FROM score sc
    INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
    INNER JOIN activity a           ON a.id = ae.activity_id
    INNER JOIN course_group g       ON g.id = a.group_id
    INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
    INNER JOIN student st           ON st.id = sc.student_id
    INNER JOIN app_user u           ON u.id = st.id
    GROUP BY g.id, g.name, st.id, u.name
),
ranking AS (
    SELECT p.*, RANK() OVER (PARTITION BY p.group_id ORDER BY p.total_puntos DESC) AS posicion
    FROM puntos p
)
SELECT grupo, posicion, estudiante, total_puntos
FROM ranking
WHERE posicion <= 5
ORDER BY grupo, posicion, estudiante;
```

**Filas devueltas: 17**

| GRUPO | POSICION | ESTUDIANTE | TOTAL_PUNTOS |
|---|---|---|---|
| G1 | 1 | Valentina Ospina Rojas | 244 |
| G1 | 2 | Samuel Cardenas Londono | 210 |
| G1 | 3 | Mariana Gil Herrera | 202 |
| G1 | 4 | Andres Felipe Mora | 123 |
| G1 | 5 | Daniel Ortiz Velez | 113 |
| G3 | 1 | Mateo Zapata Giraldo | 162 |
| G3 | 2 | Luciana Benitez Cruz | 160 |
| G3 | 3 | Sofia Navarro Duque | 142 |
| G3 | 4 | Juan Pablo Cifuentes | 123 |
| G3 | 5 | Isabela Munoz Arias | 110 |
| G5 | 1 | Paula Andrea Rios | 124 |
| G5 | 2 | Sebastian Caicedo Mena | 117 |
| G5 | 3 | Santiago Quintero Pardo | 113 |
| G5 | 4 | Gabriela Montoya Lasso | 104 |
| G7 | 1 | Emmanuel Henao Posada | 54 |
| G7 | 2 | Tomas Villegas Orozco | 34 |
| G7 | 3 | Manuela Escobar Toro | 20 |

## R3. TOP 10 de estudiantes del semestre (HU-12, HU-13)

> Muestra los 10 estudiantes con mas puntos acumulados en el semestre activo, sin importar el grupo, con su categoria y numero de ejercicios resueltos. Desempata por nombre. 3FN: Navega score -> activity_exercise -> activity -> course_group. Tecnicas: GROUP BY, INNER JOIN, ORDER BY y TOP (FETCH FIRST 10 ROWS ONLY).

```sql
SELECT u.name AS estudiante,
       g.name AS grupo,
       lr.name AS categoria,
       COUNT(sc.id) AS ejercicios_resueltos,
       SUM(sc.points) AS total_puntos
FROM score sc
INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
INNER JOIN activity a           ON a.id = ae.activity_id
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st           ON st.id = sc.student_id
INNER JOIN app_user u           ON u.id = st.id
INNER JOIN level_rank lr        ON lr.id = st.current_level_id
GROUP BY u.name, g.name, lr.name
ORDER BY total_puntos DESC, u.name
FETCH FIRST 10 ROWS ONLY;
```

**Filas devueltas: 10**

| ESTUDIANTE | GRUPO | CATEGORIA | EJERCICIOS_RESUELTOS | TOTAL_PUNTOS |
|---|---|---|---|---|
| Valentina Ospina Rojas | G1 | Killer | 6 | 244 |
| Samuel Cardenas Londono | G1 | Killer | 6 | 210 |
| Mariana Gil Herrera | G1 | Killer | 6 | 202 |
| Mateo Zapata Giraldo | G3 | Killer | 5 | 162 |
| Luciana Benitez Cruz | G3 | Killer | 5 | 160 |
| Sofia Navarro Duque | G3 | Killer | 5 | 142 |
| Paula Andrea Rios | G5 | Killer | 4 | 124 |
| Andres Felipe Mora | G1 | Killer | 5 | 123 |
| Juan Pablo Cifuentes | G3 | Killer | 5 | 123 |
| Sebastian Caicedo Mena | G5 | Killer | 4 | 117 |

## R4. Historial de puntos con acumulado (HU-11)

> Para cada estudiante lista los puntos obtenidos por ejercicio y fecha en el semestre activo, junto con el total acumulado en el tiempo; sirve para graficar la evolucion. Para ver un solo estudiante, descomente el filtro. Tecnicas: INNER JOIN, funcion de ventana SUM acumulada y ORDER BY. WHERE st.id = 101

```sql
SELECT u.name AS estudiante,
       g.name AS grupo,
       a.name AS actividad,
       DBMS_LOB.SUBSTR(ex.statement, 60, 1) AS ejercicio,
       d.label AS dificultad,
       sc.award_date AS fecha,
       sc.points AS puntos,
       SUM(sc.points) OVER (PARTITION BY sc.student_id
                            ORDER BY sc.award_date, sc.id) AS puntos_acumulados
FROM score sc
INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
INNER JOIN activity a           ON a.id = ae.activity_id
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id AND sem.active = 1
INNER JOIN student st           ON st.id = sc.student_id
INNER JOIN app_user u           ON u.id = st.id
INNER JOIN exercise ex          ON ex.id = ae.exercise_id
INNER JOIN difficulty_scale d   ON d.id = ex.difficulty_id
ORDER BY u.name, sc.award_date;
```

**Filas devueltas: 74**

| ESTUDIANTE | GRUPO | ACTIVIDAD | EJERCICIO | DIFICULTAD | FECHA | PUNTOS | PUNTOS_ACUMULADOS |
|---|---|---|---|---|---|---|---|
| Andres Felipe Mora | G1 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-12 08:47 | 8 | 8 |
| Andres Felipe Mora | G1 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-12 08:52 | 12 | 20 |
| Andres Felipe Mora | G1 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-12 08:57 | 27 | 47 |
| Andres Felipe Mora | G1 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-02 08:57 | 40 | 87 |
| Andres Felipe Mora | G1 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-02 09:02 | 36 | 123 |
| Daniel Ortiz Velez | G1 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-12 09:02 | 20 | 20 |
| Daniel Ortiz Velez | G1 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-12 09:07 | 24 | 44 |
| Daniel Ortiz Velez | G1 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-02 09:07 | 24 | 68 |
| Daniel Ortiz Velez | G1 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-02 09:12 | 45 | 113 |
| Emmanuel Henao Posada | G7 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-18 08:27 | 6 | 6 |
| Emmanuel Henao Posada | G7 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-18 08:32 | 18 | 24 |
| Emmanuel Henao Posada | G7 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-18 08:37 | 30 | 54 |
| Gabriela Montoya Lasso | G5 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-14 14:27 | 10 | 10 |
| Gabriela Montoya Lasso | G5 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-14 14:32 | 16 | 26 |
| Gabriela Montoya Lasso | G5 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-14 14:37 | 18 | 44 |
| Gabriela Montoya Lasso | G5 | Listas | Cuenta cuantas veces aparece cada elemento en una lista. | Avanzada baja | 2026-10-08 14:27 | 60 | 104 |
| Isabela Munoz Arias | G3 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-13 10:47 | 18 | 18 |
| Isabela Munoz Arias | G3 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-13 10:52 | 30 | 48 |
| Isabela Munoz Arias | G3 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-03 10:37 | 32 | 80 |
| Isabela Munoz Arias | G3 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-03 10:42 | 30 | 110 |
| Juan Pablo Cifuentes | G3 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-13 10:32 | 8 | 8 |
| Juan Pablo Cifuentes | G3 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-13 10:37 | 12 | 20 |
| Juan Pablo Cifuentes | G3 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-13 10:42 | 27 | 47 |
| Juan Pablo Cifuentes | G3 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-03 10:27 | 40 | 87 |
| Juan Pablo Cifuentes | G3 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-03 10:32 | 36 | 123 |
| Luciana Benitez Cruz | G3 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-13 11:07 | 10 | 10 |
| Luciana Benitez Cruz | G3 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-13 11:12 | 16 | 26 |
| Luciana Benitez Cruz | G3 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-03 11:02 | 36 | 62 |
| Luciana Benitez Cruz | G3 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-03 11:07 | 50 | 112 |
| Luciana Benitez Cruz | G3 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-03 11:12 | 48 | 160 |
| Manuela Escobar Toro | G7 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-18 08:17 | 8 | 8 |
| Manuela Escobar Toro | G7 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-18 08:22 | 12 | 20 |
| Mariana Gil Herrera | G1 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-12 08:37 | 10 | 10 |
| Mariana Gil Herrera | G1 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-12 08:42 | 16 | 26 |
| Mariana Gil Herrera | G1 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-02 08:42 | 36 | 62 |
| Mariana Gil Herrera | G1 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-02 08:47 | 50 | 112 |
| Mariana Gil Herrera | G1 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-02 08:52 | 48 | 160 |
| Mariana Gil Herrera | G1 | Ciclos | Usa un ciclo for para sumar los primeros n numeros naturales | Avanzada | 2026-11-13 08:32 | 42 | 202 |
| Mateo Zapata Giraldo | G3 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-13 10:57 | 9 | 9 |
| Mateo Zapata Giraldo | G3 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-13 11:02 | 24 | 33 |
| Mateo Zapata Giraldo | G3 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-03 10:47 | 24 | 57 |
| Mateo Zapata Giraldo | G3 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-03 10:52 | 45 | 102 |
| Mateo Zapata Giraldo | G3 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-03 10:57 | 60 | 162 |
| Paula Andrea Rios | G5 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-14 14:42 | 18 | 18 |
| Paula Andrea Rios | G5 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-14 14:47 | 30 | 48 |
| Paula Andrea Rios | G5 | Listas | Invierte el orden de una lista sin usar reverse ni slicing. | Intermedia alta | 2026-10-08 14:32 | 40 | 88 |
| Paula Andrea Rios | G5 | Listas | Cuenta cuantas veces aparece cada elemento en una lista. | Avanzada baja | 2026-10-08 14:37 | 36 | 124 |
| Samuel Cardenas Londono | G1 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-12 08:27 | 9 | 9 |
| Samuel Cardenas Londono | G1 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-12 08:32 | 24 | 33 |
| Samuel Cardenas Londono | G1 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-02 08:27 | 24 | 57 |
| Samuel Cardenas Londono | G1 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-02 08:32 | 45 | 102 |
| Samuel Cardenas Londono | G1 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-02 08:37 | 60 | 162 |
| Samuel Cardenas Londono | G1 | Ciclos | Muestra todos los numeros primos menores o iguales a n. | Muy avanzada | 2026-11-13 08:27 | 48 | 210 |
| Santiago Quintero Pardo | G5 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-14 14:17 | 9 | 9 |
| Santiago Quintero Pardo | G5 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-14 14:22 | 20 | 29 |
| Santiago Quintero Pardo | G5 | Listas | Invierte el orden de una lista sin usar reverse ni slicing. | Intermedia alta | 2026-10-08 14:17 | 30 | 59 |
| Santiago Quintero Pardo | G5 | Listas | Cuenta cuantas veces aparece cada elemento en una lista. | Avanzada baja | 2026-10-08 14:22 | 54 | 113 |
| Sebastian Caicedo Mena | G5 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-14 14:52 | 9 | 9 |
| Sebastian Caicedo Mena | G5 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-14 14:57 | 24 | 33 |
| Sebastian Caicedo Mena | G5 | Listas | Invierte el orden de una lista sin usar reverse ni slicing. | Intermedia alta | 2026-10-08 14:42 | 30 | 63 |
| Sebastian Caicedo Mena | G5 | Listas | Cuenta cuantas veces aparece cada elemento en una lista. | Avanzada baja | 2026-10-08 14:47 | 54 | 117 |
| Sofia Navarro Duque | G3 | Variables y tipos de datos | Escribe un programa que lea dos numeros enteros y muestre su | Basica | 2026-08-13 10:17 | 10 | 10 |
| Sofia Navarro Duque | G3 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-13 10:22 | 16 | 26 |
| Sofia Navarro Duque | G3 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-13 10:27 | 18 | 44 |
| Sofia Navarro Duque | G3 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-03 10:17 | 50 | 94 |
| Sofia Navarro Duque | G3 | Condicionales | Dados tres numeros, muestra el mayor sin usar la funcion max | Avanzada baja | 2026-09-03 10:22 | 48 | 142 |
| Tomas Villegas Orozco | G7 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-18 08:42 | 16 | 16 |
| Tomas Villegas Orozco | G7 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-18 08:47 | 18 | 34 |
| Valentina Ospina Rojas | G1 | Variables y tipos de datos | Calcula el area de un circulo a partir del radio ingresado p | Facil | 2026-08-12 08:17 | 18 | 18 |
| Valentina Ospina Rojas | G1 | Variables y tipos de datos | Convierte una temperatura en grados Celsius a grados Fahrenh | Intermedia baja | 2026-08-12 08:22 | 30 | 48 |
| Valentina Ospina Rojas | G1 | Condicionales | Clasifica una nota numerica entre 0.0 y 5.0 como aprobada o  | Intermedia | 2026-09-02 08:17 | 32 | 80 |
| Valentina Ospina Rojas | G1 | Condicionales | Determina si un anio dado es bisiesto. | Intermedia alta | 2026-09-02 08:22 | 30 | 110 |
| Valentina Ospina Rojas | G1 | Ciclos | Usa un ciclo for para sumar los primeros n numeros naturales | Avanzada | 2026-11-13 08:17 | 70 | 180 |
| Valentina Ospina Rojas | G1 | Ciclos | Muestra todos los numeros primos menores o iguales a n. | Muy avanzada | 2026-11-13 08:22 | 64 | 244 |

## R5. Desempeno por estudiante y metricas del grupo (HU-13, HU-14, HU-15)

> Incluye TODOS los estudiantes matriculados, tambien los que aun no han recibido puntos (aparecen con 0). Para cada uno muestra puntos totales, ejercicios resueltos y su porcentaje frente a los ejercicios disponibles del grupo; ademas calcula dos metricas del grupo: promedio de puntos y tasa de participacion (estudiantes con al menos un ejercicio resuelto). Tecnicas: LEFT JOIN, GROUP BY, CTE y funciones de ventana.

```sql
WITH disponibles AS (
    SELECT a.group_id, COUNT(ae.id) AS total_ejercicios
    FROM activity a
    INNER JOIN activity_status ast  ON ast.id = a.status_id AND ast.name <> 'BORRADOR'
    INNER JOIN activity_exercise ae ON ae.activity_id = a.id
    GROUP BY a.group_id
),
por_estudiante AS (
    SELECT g.id AS group_id, g.name AS grupo, st.id AS student_id,
           u.name AS estudiante, lr.name AS categoria,
           NVL(SUM(sc.points), 0) AS puntos_totales,
           COUNT(sc.id) AS ejercicios_resueltos
    FROM enrollment e
    INNER JOIN course_group g ON g.id = e.group_id
    INNER JOIN semester sem   ON sem.id = g.semester_id AND sem.active = 1
    INNER JOIN student st     ON st.id = e.student_id
    INNER JOIN app_user u     ON u.id = st.id
    INNER JOIN level_rank lr  ON lr.id = st.current_level_id
    LEFT JOIN (
        SELECT sc.student_id, a.group_id, sc.points, sc.id
        FROM score sc
        INNER JOIN activity_exercise ae ON ae.id = sc.activity_exercise_id
        INNER JOIN activity a           ON a.id = ae.activity_id
    ) sc ON sc.student_id = e.student_id AND sc.group_id = e.group_id
    GROUP BY g.id, g.name, st.id, u.name, lr.name
)
SELECT pe.grupo,
       pe.estudiante,
       pe.categoria,
       pe.puntos_totales,
       pe.ejercicios_resueltos,
       d.total_ejercicios AS ejercicios_disponibles,
       ROUND(100 * pe.ejercicios_resueltos / NULLIF(d.total_ejercicios, 0), 1) AS pct_ejercicios_resueltos,
       ROUND(AVG(pe.puntos_totales) OVER (PARTITION BY pe.group_id), 1) AS promedio_puntos_grupo,
       ROUND(100 * SUM(CASE WHEN pe.ejercicios_resueltos > 0 THEN 1 ELSE 0 END)
                       OVER (PARTITION BY pe.group_id)
                 / COUNT(*) OVER (PARTITION BY pe.group_id), 1) AS tasa_participacion_grupo
FROM por_estudiante pe
LEFT JOIN disponibles d ON d.group_id = pe.group_id
ORDER BY pe.grupo, pe.puntos_totales DESC, pe.estudiante;
```

**Filas devueltas: 20**

| GRUPO | ESTUDIANTE | CATEGORIA | PUNTOS_TOTALES | EJERCICIOS_RESUELTOS | EJERCICIOS_DISPONIBLES | PCT_EJERCICIOS_RESUELTOS | PROMEDIO_PUNTOS_GRUPO | TASA_PARTICIPACION_GRUPO |
|---|---|---|---|---|---|---|---|---|
| G1 | Valentina Ospina Rojas | Killer | 244 | 6 | 8 | 75 | 148.7 | 83.3 |
| G1 | Samuel Cardenas Londono | Killer | 210 | 6 | 8 | 75 | 148.7 | 83.3 |
| G1 | Mariana Gil Herrera | Killer | 202 | 6 | 8 | 75 | 148.7 | 83.3 |
| G1 | Andres Felipe Mora | Killer | 123 | 5 | 8 | 62.5 | 148.7 | 83.3 |
| G1 | Daniel Ortiz Velez | Killer | 113 | 4 | 8 | 50 | 148.7 | 83.3 |
| G1 | Camila Restrepo Salazar | Principiante | 0 | 0 | 8 | 0 | 148.7 | 83.3 |
| G3 | Mateo Zapata Giraldo | Killer | 162 | 5 | 6 | 83.3 | 139.4 | 100 |
| G3 | Luciana Benitez Cruz | Killer | 160 | 5 | 6 | 83.3 | 139.4 | 100 |
| G3 | Sofia Navarro Duque | Killer | 142 | 5 | 6 | 83.3 | 139.4 | 100 |
| G3 | Juan Pablo Cifuentes | Killer | 123 | 5 | 6 | 83.3 | 139.4 | 100 |
| G3 | Isabela Munoz Arias | Killer | 110 | 4 | 6 | 66.7 | 139.4 | 100 |
| G5 | Paula Andrea Rios | Killer | 124 | 4 | 5 | 80 | 91.6 | 80 |
| G5 | Sebastian Caicedo Mena | Killer | 117 | 4 | 5 | 80 | 91.6 | 80 |
| G5 | Santiago Quintero Pardo | Killer | 113 | 4 | 5 | 80 | 91.6 | 80 |
| G5 | Gabriela Montoya Lasso | Killer | 104 | 4 | 5 | 80 | 91.6 | 80 |
| G5 | Nicolas Aristizabal Mena | Principiante | 0 | 0 | 5 | 0 | 91.6 | 80 |
| G7 | Emmanuel Henao Posada | Principiante | 54 | 3 | 3 | 100 | 27 | 75 |
| G7 | Tomas Villegas Orozco | Principiante | 34 | 2 | 3 | 66.7 | 27 | 75 |
| G7 | Manuela Escobar Toro | Principiante | 20 | 2 | 3 | 66.7 | 27 | 75 |
| G7 | Juliana Cortes Bedoya | Principiante | 0 | 0 | 3 | 0 | 27 | 75 |

## R6. Participacion por actividad (HU-08, HU-13, HU-16)

> Para cada actividad, incluso las que estan en borrador o no tienen puntajes, muestra su estado, el grupo, cuantos estudiantes estan matriculados, cuantos participaron, la tasa de participacion y los puntos totales otorgados. Incluye semestres anteriores; los mas recientes primero. Tecnicas: LEFT JOIN (actividades sin puntajes), GROUP BY, COUNT DISTINCT y ORDER BY.

```sql
SELECT sem.name AS semestre,
       g.name AS grupo,
       a.name AS actividad,
       ast.name AS estado,
       NVL(ins.total, 0) AS estudiantes_inscritos,
       COUNT(DISTINCT sc.student_id) AS estudiantes_participantes,
       ROUND(100 * COUNT(DISTINCT sc.student_id) / NULLIF(ins.total, 0), 1) AS tasa_participacion,
       NVL(SUM(sc.points), 0) AS puntos_otorgados
FROM activity a
INNER JOIN course_group g       ON g.id = a.group_id
INNER JOIN semester sem         ON sem.id = g.semester_id
INNER JOIN activity_status ast  ON ast.id = a.status_id
LEFT JOIN (SELECT group_id, COUNT(*) AS total
           FROM enrollment
           GROUP BY group_id) ins ON ins.group_id = a.group_id
LEFT JOIN activity_exercise ae  ON ae.activity_id = a.id
LEFT JOIN score sc              ON sc.activity_exercise_id = ae.id
GROUP BY sem.name, sem.start_date, g.name, a.name, a.start_date, ast.name, ins.total
ORDER BY sem.start_date DESC, g.name, a.start_date;
```

**Filas devueltas: 11**

| SEMESTRE | GRUPO | ACTIVIDAD | ESTADO | ESTUDIANTES_INSCRITOS | ESTUDIANTES_PARTICIPANTES | TASA_PARTICIPACION | PUNTOS_OTORGADOS |
|---|---|---|---|---|---|---|---|
| 2026-2 | G1 | Variables y tipos de datos | CERRADA | 6 | 5 | 83.3 | 198 |
| 2026-2 | G1 | Condicionales | CERRADA | 6 | 5 | 83.3 | 470 |
| 2026-2 | G1 | Ciclos | ACTIVA | 6 | 3 | 50 | 224 |
| 2026-2 | G3 | Variables y tipos de datos | CERRADA | 5 | 5 | 100 | 198 |
| 2026-2 | G3 | Condicionales | CERRADA | 5 | 5 | 100 | 499 |
| 2026-2 | G5 | Variables y tipos de datos | CERRADA | 5 | 4 | 80 | 154 |
| 2026-2 | G5 | Listas | CERRADA | 5 | 4 | 80 | 304 |
| 2026-2 | G7 | Variables y tipos de datos | CERRADA | 4 | 3 | 75 | 108 |
| 2026-2 | G7 | Funciones | BORRADOR | 4 | 0 | 0 | 0 |
| 2026-1 | G1 | Introduccion a Python | CERRADA | 3 | 3 | 100 | 61 |
| 2026-1 | G3 | Introduccion a Python | CERRADA | 1 | 1 | 100 | 29 |

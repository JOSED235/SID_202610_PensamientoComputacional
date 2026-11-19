# Caso de estudio: Plataforma de gamificación para Pensamiento Computacional

Equipo: Jose David Rodriguez Pinilla (A00407151), Jose David Valdez (A00408018), Santiago Vinazco Ortegon (A00410366) y Carlos Pasinga (A00412446).

## 1. Contexto

En la Universidad Icesi, en la Facultad Barbieri, todas las carreras inician desde primer semestre con el curso de Pensamiento Computacional, donde se introduce a los estudiantes en la algoritmia mediante programación imperativa en Python.

Los profesores del curso han intentado implementar algunas recompensas siguiendo un modelo de gamificación. Si bien los estudiantes han respondido positivamente, aún hace falta estandarizar esta estrategia en todos los cursos.

El profesor Jorge Quesada, por ejemplo, ha propuesto dividir a los estudiantes en diferentes perfiles, considerando tres niveles: el **pro**, que ya sabe programar desde el colegio; el **killer**, que también tiene experiencia en programación pero a un nivel medio; y el **principiante**, que nunca ha tenido contacto con la programación.

Para apoyar esta clasificación se requiere una plataforma web donde los profesores puedan registrar ejercicios de programación, especificando el nivel y los perfiles a los que está dirigido cada ejercicio. Durante la clase, el profesor podrá activar actividades (compuestas por varios ejercicios); en ese momento los estudiantes serán notificados y podrán acceder a la plataforma para resolver los problemas. La plataforma no califica automáticamente: es el profesor quien, a través de la aplicación, asigna los puntos correspondientes.

## 2. Problema

Hoy la gamificación depende de cada profesor: no hay un registro común de ejercicios, actividades ni puntos, no se puede comparar el desempeño entre grupos y la clasificación de los estudiantes en perfiles se hace a mano. Se necesita un sistema de información transaccional que persista esa información de forma íntegra y permita consultarla.

## 3. Objetivo de la aplicación

Registrar de forma centralizada los usuarios (estudiantes, profesores y administradores), los semestres, grupos y matrículas, el banco de ejercicios, las actividades de clase y los puntos que los profesores asignan, para:

- Calificar sin fricción durante la clase mediante un código de redención, sin permitir la doble asignación de puntos.
- Clasificar automáticamente a cada estudiante en una categoría de desempeño (Principiante, Killer, Pro) según sus puntos.
- Mostrar podium, rankings, historial y métricas de grupo que motiven a los estudiantes y apoyen al profesor.

## 4. Alcance

| Incluye | No incluye |
|---|---|
| Modelo de datos y base de datos Oracle con integridad referencial y reglas de negocio | La aplicación web (interfaz gráfica) |
| Scripts DDL, DML, DQL y PL/SQL | Integración con los sistemas académicos de Icesi |
| Reportes que alimentan las vistas de estudiantes y profesores | Calificación automática de las soluciones |

## 5. Entidades fundamentales

El caso tiene más de cuatro entidades fuertes: **Usuario** (con los subtipos Estudiante, Profesor y Administrador), **Semestre**, **Grupo**, **Ejercicio** y **Actividad**. Alrededor de ellas están las entidades de matrícula (Estudiante–Grupo), ejercicio de actividad (Actividad–Ejercicio), puntaje y los catálogos (tipo y estado de usuario, estado de actividad, escala de dificultad y categoría de desempeño).

## 6. Reportes de interés

| Reporte | Pregunta que responde | Historias de usuario |
|---|---|---|
| R1 Estudiantes por grupo | ¿Quiénes están registrados en cada grupo del semestre activo, con qué categoría y profesor? | HU-02, HU-06, HU-07, HU-14 |
| R2 Podium por grupo | ¿Quiénes son los 5 mejores de cada grupo? | HU-12 |
| R3 TOP 10 del semestre | ¿Quiénes son los 10 estudiantes con más puntos del semestre? | HU-12, HU-13 |
| R4 Historial con acumulado | ¿Cómo evolucionan los puntos de cada estudiante en el tiempo? | HU-11 |
| R5 Desempeño y métricas del grupo | ¿Cuál es el desempeño de cada estudiante y el promedio y la tasa de participación de su grupo? | HU-13, HU-14, HU-15 |
| R6 Participación por actividad | ¿Cuántos estudiantes participaron en cada actividad y cuántos puntos se otorgaron? | HU-08, HU-13, HU-16 |

Las consultas están en [`src/03_dql.sql`](../src/03_dql.sql) y sus resultados reales en [`doc/evidencias/resultados_reportes.md`](evidencias/resultados_reportes.md).

## 7. Requerimientos

Los requerimientos se especifican como 17 historias de usuario con criterios de aceptación en [`historias_usuario.md`](historias_usuario.md) (versión original: [`ProyectoFinalRequerimientosDef.docx`](ProyectoFinalRequerimientosDef.docx)).

## 8. Origen del caso

**Este caso de estudio es original.** Fue redactado por el equipo a partir de la situación real del curso de Pensamiento Computacional de la Universidad Icesi y de la propuesta de gamificación por perfiles (principiante, killer y pro) de sus profesores. No fue adaptado de otro enunciado, libro o fuente externa, por lo que no requiere anexo ni enlace a un problema original.

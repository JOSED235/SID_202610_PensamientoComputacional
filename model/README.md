# Modelos de datos

| Archivo | Contenido |
|---|---|
| [`mer/MER_conceptual.pdf`](mer/MER_conceptual.pdf) ([PNG](mer/MER_conceptual.png), [SVG](mer/MER_conceptual.svg), [fuente Graphviz](mer/MER_conceptual.dot)) | Modelo entidad-relación conceptual actualizado: 16 entidades, herencia de usuario y 20 relaciones con cardinalidad |
| [`mr/MR_3FN.pdf`](mr/MR_3FN.pdf) ([PNG](mr/MR_3FN.png), [SVG](mr/MR_3FN.svg), [fuente Graphviz](mr/MR_3FN.dot)) | Modelo relacional normalizado (3FN) con tipos, PK, FK, UK y NOT NULL de cada columna |
| [`datamodeler/`](datamodeler/) | **Fuentes oficiales en Oracle SQL Developer Data Modeler 24.3**: diseño [`PensamientoComputacional.dmd`](datamodeler/PensamientoComputacional.dmd) con su carpeta, [zip del diseño](datamodeler/PensamientoComputacional_datamodeler.zip), [MER (modelo lógico) en PDF](datamodeler/MER_datamodeler.pdf) y [modelo relacional en PDF](datamodeler/MR_datamodeler.pdf) |
| [`anterior/`](anterior/) | Versiones entregadas antes: MER de la Entrega 1 (PDF, `.dmd`, carpeta y [zip](anterior/MER_PROYECTO_2_datamodeler.zip)) y MR de la Entrega 2 (PDF y `.dmd`). Se conservan como historial; ya no coinciden con la base de datos |

## Origen de los diagramas

El MR se generó leyendo el diccionario de datos de la base Oracle donde se ejecutó `src/01_ddl.sql` (`USER_TAB_COLUMNS`, `USER_CONSTRAINTS`, `USER_CONS_COLUMNS`). Por eso coincide con el DDL: 16 tablas, 16 PK, 20 FK y 13 UNIQUE. El MER es su equivalente conceptual: sin columnas FK, con las relaciones nombradas y la jerarquía Usuario → Administrador, Profesor y Estudiante.

Los dos diagramas usan la misma disposición por módulos (catálogos a la izquierda, usuarios, cursos, actividades y puntajes a la derecha) y notación pata de gallo. En el MER, `#` marca el identificador, `*` un atributo obligatorio y `o` uno opcional; las líneas punteadas son la jerarquía Usuario → subtipos. Para regenerarlos: [`generar_diagramas.py`](generar_diagramas.py) produce los `.dot` y Graphviz (motor `neato`) los dibuja.

Justificación de la normalización: [`doc/normalizacion_3FN.md`](../doc/normalizacion_3FN.md).

## Cómo se construyó el diseño de Data Modeler

1. **Archivo → Importar → Archivo DDL** con `src/01_ddl.sql`, sitio *Oracle Database 21c*: 102 sentencias importadas, 0 fallidas. Resultado: modelo relacional con 16 tablas y 20 claves ajenas.
2. **Realizar Ingeniería a Modelo Lógico** desde el modelo relacional: MER con 16 entidades y 20 relaciones.
3. Las tablas y entidades se ubicaron por módulos, igual que en los diagramas de `mer/` y `mr/`: catálogos de usuario, usuarios, cursos y actividades y puntajes. Las relaciones van en ángulo recto y ninguna atraviesa otra caja.
4. **Archivo → Imprimir Diagrama → En Archivo PDF** para cada diagrama, y el diseño se guardó con su carpeta y se comprimió en el zip.

Para abrirlo: **Archivo → Abrir** y seleccionar `datamodeler/PensamientoComputacional.dmd`, o descomprimir el zip y abrir el `.dmd`.

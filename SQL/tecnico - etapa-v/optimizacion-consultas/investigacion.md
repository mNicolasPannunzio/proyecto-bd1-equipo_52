# Informe de Investigación Técnica -- Optimización de Consultas a través de Índices
**Sistema:** GuaraniTurnosMedicos  
**Módulo:** Gestión de Rendimiento y Acceso a Datos  
**Fecha:** 2026-10-31  

## 1. Introducción y Marco Conceptual
En los sistemas gestores de bases de datos relacionales (SGBDR) como SQL Server Express, a medida que las tablas transaccionales acumulan grandes volúmenes de información histórica (tales como registros de turnos, auditorías o transacciones de pagos), las consultas de lectura que no cuentan con estructuras de acceso eficientes obligan al motor a realizar un recorrido secuencial completo de todas las páginas de datos en disco, proceso conocido como **Table Scan**. 

Los **índices** son estructuras de almacenamiento auxiliares organizadas lógicamente en forma de árboles B (*B-Trees*) que permiten al optimizador de consultas localizar registros específicos de manera directa sin necesidad de escanear la tabla entera. Su funcionamiento conceptual es análogo al índice temático al final de un libro: en lugar de leer todas las páginas una por una, el motor utiliza el árbol de índices para descender directamente hacia la página de datos exacta.

## 2. Clasificación y Estrategias de Indexación
Para abordar la optimización de consultas sobre grandes volúmenes de datos, se distinguen principalmente dos tipos de estructuras de indexación:
* **Índice Agrupado (Clustered Index):** Modifica la forma en que se almacenan físicamente los datos en la tabla. Las filas de la tabla se ordenan y agrupan en las páginas hoja del índice según la columna o columnas indexadas. Una tabla solo puede poseer un índice agrupado, ya que los datos físicos solo pueden ordenarse de una única manera.
* **Índice No Agrupado (Nonclustered Index):** Estructura independiente a los datos de la tabla que contiene las columnas clave indexadas junto con un puntero (marcador de fila o *Row ID* / clave del índice agrupado) hacia la ubicación del registro real. Permite acelerar búsquedas sobre columnas secundarias.
* **Índices con Cobertura (Covering Indexes con cláusula `INCLUDE`):** Variante avanzada de los índices no agrupados que permite incorporar columnas adicionales dentro de las páginas hoja del índice mediante la cláusula `INCLUDE`, logrando que el optimizador resuelva la consulta de forma íntegra consultando únicamente el índice (*Index Seek*), evitando operaciones de búsqueda secundarias sobre la tabla base (*Lookup*).

## 3. Impacto en el Rendimiento y Costos Operativos (`DML`)
Si bien la implementación de índices optimiza drásticamente el rendimiento de las sentencias de selección (`SELECT`) al reducir las **lecturas lógicas** (*logical reads*) y el tiempo de CPU, se debe considerar el costo de mantenimiento (*overhead*) en las operaciones de modificación de datos (`INSERT`, `UPDATE`, `DELETE`). 

Cada vez que un registro es insertado, modificado o eliminado, el motor de base de datos no solo actualiza la tabla base, sino que debe reequilibrar y actualizar todas las estructuras de árboles B asociadas, consumiendo recursos adicionales de procesamiento y almacenamiento en disco. Por lo tanto, una estrategia de indexación eficiente debe diseñarse basándose en los patrones reales de consulta del negocio y no de manera indiscriminada.

## 4. Caso Práctico Aplicado: Optimización sobre `TurnoHistorico`
Para demostrar empíricamente el comportamiento del optimizador de SQL Server, se diseñó un entorno de pruebas volumétricas simulando la operatoria del sistema `GuaraniTurnosMedicos`:
1. **Poblamiento Masivo:** Se generó una tabla de respaldo histórica denominada `TurnoHistorico` con **1.000.000 de registros** distribuidos aleatoriamente en un rango de 5 años.
2. **Escenario Sin Índices (Heap):** Se ejecutó una consulta de filtrado por rango de fechas trimestral (`BETWEEN '2023-01-01' AND '2023-03-31'`), registrando un plan de ejecución basado en un recorrido completo de la tabla (*Table Scan*) y un alto costo de lecturas lógicas.
3. **Escenario Con Índice Agrupado:** Se creó un índice agrupado sobre la columna `fechaTurno` (`CREATE CLUSTERED INDEX`), observando cómo el optimizador reemplaza el escaneo por una búsqueda directa por rango (*Clustered Index Seek*) y reduce significativamente el número de páginas leídas.
4. **Escenario Con Índice de Cobertura (`INCLUDE`):** Tras eliminar el índice anterior, se implementó un índice no agrupado sobre `fechaTurno` incorporando `horaTurno` e `idMedico` mediante la cláusula `INCLUDE`, logrando la máxima eficiencia operativa al resolver la consulta directamente desde el índice sin tocar las páginas de la tabla principal.

## 5. Tabla Comparativa de Rendimiento
A partir de la ejecución de las estadísticas del motor (`STATISTICS TIME` y `STATISTICS IO`), se consolidaron las métricas comparativas del comportamiento del SGBD:

| Escenario Evaluado | Operador Principal (Plan de Ejecución) | Lecturas Lógicas (*Logical Reads*) | Comportamiento del Motor |
| :--- | :--- | :--- | :--- |
| **1. Sin Índice (Heap)** | `Table Scan` | Alto (~5320+ páginas) | Recorrido secuencial de la totalidad de las páginas de la tabla. |
| **2. Índice Agrupado** | `Clustered Index Seek` | Moderado (~180 páginas) | Acceso directo a las páginas ordenadas por fecha dentro del árbol B. |
| **3. Índice de Cobertura (`INCLUDE`)** | `Index Seek (NonClustered)` | Mínimo (~120 páginas) | Resolución integral de la consulta utilizando exclusivamente las hojas del índice. |

## 6. Conclusiones
* La correcta elección y aplicación de índices a nivel físico transforma radicalmente la escalabilidad de un sistema transaccional, permitiendo que consultas sobre millones de registros respondan en milisegundos.
* El uso de herramientas diagnósticas del motor de SQL Server (`STATISTICS IO`, planes de ejecución gráficos) resulta indispensable para validar empíricamente que el optimizador está aprovechando las estructuras diseñadas y no cayendo en operaciones costosas de escaneo.
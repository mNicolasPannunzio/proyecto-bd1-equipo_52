# Informe de Investigación: Triggers y Auditorías en Bases de Datos Relacionales

## 1. Introducción y Marco Conceptual

En la gestión de bases de datos relacionales, la integridad, la seguridad y la trazabilidad de los datos son pilares fundamentales. A medida que las aplicaciones crecen en complejidad, las restricciones declarativas tradicionales (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`) pueden resultar insuficientes para validar reglas de negocio complejas o para registrar el historial de modificaciones efectuadas por los usuarios.

Un **Trigger** (o disparador) es un tipo especial de procedimiento almacenado que se ejecuta automáticamente cuando ocurre un evento DML (`INSERT`, `UPDATE`, `DELETE`) o DDL sobre un objeto de la base de datos. A diferencia de las rutinas convencionales que deben ser invocadas explícitamente mediante `EXEC`, los triggers reaccionan de manera pasiva e inmediata ante eventos del motor.

La **Auditoría de Datos** mediante triggers consiste en interceptar las modificaciones realizadas sobre tablas críticas para registrar los estados previos y posteriores de la información, agregando metadatos de sesión (fecha, hora, usuario de la BD y tipo de operación).

---

## 2. Clasificación y Funcionamiento de los Triggers DML

En Transact-SQL (T-SQL), los triggers de manipulación de datos (DML) se clasifican según el momento y la forma en que interceptan las sentencias SQL:

### 2.1. Triggers `AFTER` / `FOR` (Disparadores Posteriores)
* **Comportamiento:** Se ejecutan **después** de que la sentencia DML ha superado todas las validaciones sintácticas, restricciones declarativas de tipo de dato, nulos (`NOT NULL`) y claves foráneas.
* **Casos de Uso:** Auditoría de cambios, actualización de agregados/totales y sincronización de tablas secundarias.
* **Transaccionalidad:** El trigger opera dentro de la misma transacción que la sentencia que lo disparó. Si ocurre un fallo en el trigger, toda la transacción se revierte (`ROLLBACK`).

### 2.2. Triggers `INSTEAD OF` (Disparadores Sustitutivos)
* **Comportamiento:** Se ejecutan **en lugar de** la sentencia DML original. Interceptan la acción antes de que afecte a la tabla subyacente.
* **Casos de Uso:** Implementación de reglas estrictas de seguridad (como bloquear borrados físicos), actualización de Vistas complejas no actualizables directamente y forzado de borrado lógico.

### 2.3. Tablas Virtuales del Sistema: `inserted` y `deleted`
Durante la ejecución de un trigger DML, el motor de base de datos asigna en memoria RAM dos tablas lógicas estructuradas de forma idéntica a la tabla origen:

| Operación DML | Tabla `deleted` | Tabla `inserted` |
| :--- | :--- | :--- |
| **`INSERT`** | Vacía. | Contiene las nuevas filas a insertar. |
| **`UPDATE`** | Contiene la copia de las filas **antes** de la modificación. | Contiene la copia de las filas **después** de la modificación. |
| **`DELETE`** | Contiene la copia de las filas **antes** de la eliminación. | Vacía. |

---

## 3. Estrategias de Auditoría de Datos

### Arquitectura de una Tabla Auxiliar de Auditoría
Para implementar una auditoría robusta, se diseña una tabla espejo o auxiliar que almacena la fotograma histórica del registro modificado o borrado, acompañada por columnas de control ambiental:
* **Clave Primaria Propia:** Identificador único autoincremental (`IDENTITY`).
* **Columnas de Datos:** Réplica de los campos auditados de la tabla de origen.
* **Metadatos de Auditoría:**
  * `tipo_operacion`: Identifica si la acción fue `UPDATE` o `DELETE`.
  * `usuario_db`: Registra el usuario autenticado en la base de datos (`SUSER_SNAME()`).
  * `fecha_hora_operacion`: Registra la estampa de tiempo precisa (`GETDATE()`).


---

## 4. Triggers para Control de Operaciones e Integridad

Además de auditar, los triggers permiten abortar operaciones que infrinjan normativas de negocio o regulaciones legales, como la prohibición de eliminar registros sensibles (por ejemplo, pacientes o historias clínicas).

### 4.1. Bloqueo Estricto de Operaciones con `INSTEAD OF DELETE`

El uso de un trigger sustitutivo intercepta la orden `DELETE` y emite un mensaje de error controlado impidiendo la eliminación física de los datos.


---

## 5. Análisis Técnico, Rendimiento y Buenas Prácticas

### 5.1. Procesamiento Orientado a Conjuntos vs. Procesamiento por Fila
Un error común al programar triggers es asumir que la operación DML afecta a una sola fila a la vez. En SQL Server, un solo `UPDATE` o `DELETE` puede afectar a $N$ filas simultáneamente.
* **Mala práctica:** Utilizar cursores (`CURSOR`) dentro del trigger para recorrer fila por fila las tablas `inserted` o `deleted`.
* **Buena práctica:** Escribir consultas declarativas orientadas a conjuntos (`INSERT INTO ... SELECT`), garantizando un procesamiento lineal a nivel de lote.

### 5.2. Impacto en el Rendimiento (*Overhead*)
* **Ampliación del Tiempo de Transacción:** El código del trigger se ejecuta dentro de la transacción DML invocadora. Si el trigger incluye lógica pesada, consultas extensas o accesos a disco lentos, se extenderá el tiempo de bloqueo (*lock*) sobre los recursos, afectando la concurrencia global del sistema.
* **Uso de `SET NOCOUNT ON`:** Se debe incluir al inicio de cada trigger para suprimir los mensajes de recuento de filas afectadas (`X filas afectadas`), optimizando la transferencia de paquetes de red con la aplicación cliente.

### 5.3. Triggers vs. Restricciones Declarativas (`CHECK` / `FOREIGN KEY`)
1. **Prioridad Restrictiva:** Siempre que una regla de integridad se pueda implementar mediante una restricción declarativa (`CHECK`, `FOREIGN KEY`, `UNIQUE`), debe preferirse sobre un trigger debido a su optimización interna en el motor.
2. **Uso Exclusivo de Triggers:** Los triggers son indispensables cuando la validación requiere:
   * Comparar valores anteriores y posteriores (`deleted` vs. `inserted`).
   * Consultar datos en tablas externas durante un `INSERT` o `UPDATE`.
   * Registrar auditorías pasivas y generar mensajes personalizados de error.

---

## 6. Conclusiones

1. **Garantía de No Repudio y Trazabilidad:** La auditoría basada en triggers a nivel de base de datos es transparente para las aplicaciones clientes. Asegura que cualquier modificación sobre los datos quede registrada, independientemente del canal de acceso (sistema web, consola SQL o herramientas externas).
2. **Preservación de la Historia y Seguridad:** Mediante triggers `INSTEAD OF`, las organizaciones garantizan la protección contra la pérdida irreversible de información sensible, forzando la transición hacia arquitecturas de **borrado lógico** e integridad referencial continua.
3. **Equilibrio entre Diseño y Rendimiento:** La implementación de triggers debe realizarse de forma consciente, asegurando consultas orientadas a conjuntos para evitar cuellos de botella en la concurrencia transaccional del SGBD.
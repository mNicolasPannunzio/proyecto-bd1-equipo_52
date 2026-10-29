# Investigación: Procedimientos y Funciones Almacenadas

## 1. Diferencias Teóricas
* **Procedimientos Almacenados (`PROCEDURE`)**: Son bloques de código ejecutable diseñados para realizar operaciones complejas, transformaciones o modificaciones en la base de datos (como `INSERT`, `UPDATE` y `DELETE`). Pueden recibir parámetros de entrada/salida y manipular transacciones (`BEGIN TRANSACTION`, `COMMIT`, `ROLLBACK`). Se invocan con `EXEC`.
* **Funciones Almacenadas (`FUNCTION`)**: Son rutinas orientadas a calcular y retornar un único valor escalar o una tabla. No pueden realizar modificaciones permanentes en la base de datos (como inserts o updates directos). Se pueden invocar dentro de sentencias `SELECT`, `WHERE` o cláusulas `JOIN`.

---

## 2. Descripción de Objetos Desarrollados

### Procedimientos Almacenados (Operaciones CRUD)
1. **`USP_InsertarObraSocial`**: Realiza la inserción de un nuevo registro en la tabla `ObraSocial` de forma encapsulada.
2. **`USP_CancelarTurno`**: Ejecuta la modificación (`UPDATE`) de un turno para cambiar su estado a cancelado y liberar la asignación del paciente, manejando la transacción mediante un bloque `TRY...CATCH` con `ROLLBACK` en caso de falla.
3. **`USP_EliminarEspecialidad`**: Implementa el borrado (`DELETE`) de una especialidad médica validando previamente su existencia en el sistema.

### Funciones Almacenadas
1. **`FN_ObtenerTotalTurnosMedico`**: Recibe el ID de un médico y un rango de fechas para calcular la cantidad de turnos en estados reservados, en espera o atendidos.
2. **`FN_CalcularEdad`**: Recibe la fecha de nacimiento de un paciente y devuelve su edad actual calculada dinámicamente en años.
3. **`FN_EsMedicoActivo`**: Retorna un valor booleano (`1` o `0`) que indica si un médico posee registros cargados en su agenda semanal.

---

## 3. Comparativa de Eficiencia

| Criterio | Consultas SQL Directas | Procedimientos y Funciones Almacenadas |
| :--- | :--- | :--- |
| **Planes de Ejecución** | El motor SQL debe analizar, compilar y optimizar la consulta en cada ejecución. | El plan de ejecución se compila y reutiliza en la memoria caché del servidor. |
| **Tráfico de Red** | Requiere transferir todo el texto de las sentencias SQL desde la aplicación a la base de datos. | Reduce el tráfico enviando solo el comando de llamada `EXEC` con sus parámetros. |
| **Seguridad e Integridad** | Expone la estructura de las tablas directamente a la capa de aplicación. | Encapsula la lógica de negocio y permite restringir permisos de acceso directo a tablas. |

# Informe de Investigación: Manejo de Transacciones y Concurrencia en Bases de Datos Relacionales

## 1. Introducción y Marco Conceptual

En los sistemas de gestión de bases de datos relacionales (SGBD) de alto tráfico o entorno crítico —como el **Sistema de Gestión de Turnos Médicos**— la integridad y coherencia de la información resultan fundamentales. La concurrencia de múltiples usuarios (pacientes reservando desde la web y secretarios operando en recepción de forma simultánea) introduce riesgos operacionales como la asignación duplicada de turnos, la pérdida de actualizaciones o lecturas inconsistentes de la agenda.

Para prevenir estos escenarios, los motores de bases de datos implementan el concepto de **Transacción**: una unidad lógica de trabajo (ULI) constituida por una o varias sentencias SQL (`INSERT`, `UPDATE`, `DELETE`) que deben ejecutarse como un bloque indivisible.

## 2. Las Propiedades ACID

Toda transacción gestionada por un SGBD relacional como SQL Server debe garantizar estrictamente las cuatro propiedades del acrónimo **ACID**:

1. **Atomicidad (Atomicity):** Principio de *"todo o nada"*. Si alguna de las instrucciones dentro de la transacción falla por violación de reglas de negocio, errores sintácticos o interrupciones de conectividad, toda la operación se revierte (`ROLLBACK`) dejando la base de datos en su estado previo.

2. **Consistencia (Consistency):** Garantiza que la base de datos pase de un estado válido a otro estado válido. Ninguna transacción puede dejar la base de datos en violación de restricciones de integridad (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`).

3. **Aislamiento (Isolation):** Asegura que las transacciones simultáneas se ejecuten de manera independiente, impidiendo que los estados intermedios e incompletos de una transacción sean visibles para otros usuarios.

4. **Durabilidad (Durability):** Una vez que una transacción se confirma con éxito (`COMMIT`), los cambios persisten de manera permanente en el almacenamiento no volátil, incluso ante fallos de energía o colapsos del servidor.

## 3. Arquitectura Transaccional en Transact-SQL (T-SQL)

En SQL Server Express, el control explicito de transacciones se realiza mediante la combinación de sentencias de control y estructuras de manejo de excepciones:

### 3.1. Sentencias Principales

* **`BEGIN TRANSACTION`:** Marca el punto inicial del bloque de instrucciones atómicas.

* **`COMMIT TRANSACTION`:** Confirma la transacción guardando los cambios de forma definitiva en el motor de base de datos.

* **`ROLLBACK TRANSACTION`:** Cancela la transacción y revierte absolutamente cualquier modificación realizada desde el `BEGIN TRANSACTION`.

### 3.2. Estructura del Manejo de Excepciones (`TRY...CATCH`)

Para garantizar una gestión robusta frente a errores imprevistos o bloqueos, el código transaccional se encapsula dentro de un bloque `BEGIN TRY ... END TRY` acompañado por un `BEGIN CATCH ... END CATCH`.

```
BEGIN TRANSACTION;
BEGIN TRY
    -- Sentencias DML (INSERT, UPDATE, DELETE)
    -- Validaciones con RAISERROR
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    -- Captura y propagación del mensaje de error
END CATCH;

```

## 4. Problemas Clásicos de Concurrencia y Niveles de Aislamiento

Cuando múltiples conexiones interactúan concurrentemente sobre la tabla `Turno`, pueden surgir tres anomalías de lectura principales:

1. **Lectura Sucia:** Ocurre cuando la Transacción A modifica un turno (ej. cambia su estado a *Reservado*) y la Transacción B lee esa modificación antes de que A confirme. Si la Transacción A realiza un `ROLLBACK`, B habrá operado con datos inexistentes.

2. **Lectura No Repetible :** La Transacción A lee un registro de agenda. La Transacción B modifica o elimina dicho registro y confirma. Si la Transacción A vuelve a consultar el mismo registro dentro del mismo bloque, obtendrá un valor diferente.

3. **Lectura Fantasma:** Ocurre cuando la Transacción A consulta un rango de turnos disponibles. La Transacción B inserta un nuevo registro en ese rango y confirma. Al re-ejecutar la consulta la Transacción A, aparecen "filas fantasma" que no existían originalmente.

### Niveles de Aislamiento en SQL Server

SQL Server gestiona estos riesgos a través de niveles de aislamiento configurables mediante `SET TRANSACTION ISOLATION LEVEL`:

* **`READ UNCOMMITTED`:** Permite lecturas sucias (sin bloqueos).

* **`READ COMMITTED`:** Nivel por defecto. Previene lecturas sucias mediante bloqueos compartidos a nivel de fila.

* **`REPEATABLE READ`:** Previene lecturas sucias y no repetibles.

* **`SERIALIZABLE`:** Nivel de aislamiento más estricto. Emplea bloqueos de rango previendo lecturas fantasma, a costa de reducir la concurrencia.

## 5. Implementación Práctica en el Proyecto "Guaraní Turnos Médicos"

### 5.1. Escenario de Negocio: Reserva Concurrente de Turnos

El flujo más crítico del sistema ocurre durante la asignación de citas. Si un paciente realiza la reserva vía Web simultáneamente con una secretaria en recepción, el procedimiento almacenado debe validar la disponibilidad del espacio y garantizar la atomicidad sin riesgo de colisión (*Race Condition*).

### 5.2. Código SQL del Procedimiento Almacenado Transaccional

```
USE GuaraniTurnosMedicos;
GO

IF OBJECT_ID('SP_ReservarTurnoTransaccional', 'P') IS NOT NULL
    DROP PROCEDURE SP_ReservarTurnoTransaccional;
GO

CREATE PROCEDURE SP_ReservarTurnoTransaccional
    @idTurno INT,
    @idPaciente INT,
    @codigoTurno VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Cancela y revierte automáticamente ante fallos graves

    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Verificación de existencia del turno y captura del estado actual
        DECLARE @idEstadoActual INT;
        SELECT @idEstadoActual = idEstado 
        FROM Turno 
        WHERE idTurno = @idTurno;

        -- Validación de existencia
        IF @idEstadoActual IS NULL
        BEGIN
            RAISERROR('Error: El turno especificado no existe en el sistema.', 16, 1);
        END

        -- Validación de disponibilidad (idEstado = 1 representa "Disponible")
        IF @idEstadoActual <> 1 
        BEGIN
            RAISERROR('Error de concurrencia: El turno seleccionado ya no se encuentra disponible.', 16, 1);
        END

        -- 2. Actualización atómica de la reserva
        UPDATE Turno
        SET 
            idPaciente = @idPaciente,
            idEstado = 2, -- idEstado = 2 representa "Reservado"
            codigoTurno = @codigoTurno
        WHERE idTurno = @idTurno;

        -- 3. Confirmación definitiva de la transacción
        COMMIT TRANSACTION;
        PRINT '¡Transacción exitosa! El turno ha sido reservado correctamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurrió algún error o falla de validación, deshacer los cambios
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Capturar y relanzar la excepción original
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

```

## 6. Conclusiones

1. **Garantía de Integriad Operativa:** El uso de procedimientos almacenados transaccionales resguarda al sistema contra la asignación duplicada de turnos, garantizando que las decisiones de reserva se tomen sobre estados validados en el instante exacto de la ejecución.

2. **Resiliencia ante Errores:** La arquitectura `TRY...CATCH` con `ROLLBACK` asegura la estabilidad del motor de datos. Ante cualquier excepción o choque de concurrencia, la base de datos retoma de inmediato su estado previo sin dejar datos inconsistentes ni tablas bloqueadas.

3. **Eficiencia y Mantenibilidad:** Encapsular la lógica transaccional directamente en la base de datos minimiza el tráfico de red con las aplicaciones cliente (React/Spring Boot), centralizando las reglas de negocio críticas bajo los mecanismos nativos de optimización de SQL Server.

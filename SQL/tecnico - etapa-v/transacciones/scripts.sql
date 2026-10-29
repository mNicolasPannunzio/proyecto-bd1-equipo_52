USE GuaraniTurnosMedicos;
GO

-- ============================================================================
-- ETAPA 5 - TEMA 2: MANEJO DE TRANSACCIONES
-- Procedimiento almacenado para la Reserva Segura de Turnos
-- ============================================================================

IF OBJECT_ID('SP_ReservarTurnoTransaccional', 'P') IS NOT NULL
    DROP PROCEDURE SP_ReservarTurnoTransaccional;
GO

CREATE PROCEDURE SP_ReservarTurnoTransaccional
    @idTurno INT,
    @idPaciente INT,
    @codigoTurno VARCHAR(20)
AS
BEGIN
    -- Evitar que se devuelvan conteos innecesarios de filas afectadas
    SET NOCOUNT ON;
    
    -- Configurar para que cualquier error grave interrumpa y salte al CATCH
    SET XACT_ABORT ON;

    -- Iniciar la Transacción
    BEGIN TRANSACTION;

    BEGIN TRY
        -- 1. Validar que el turno exista y verificar su estado actual
        DECLARE @idEstadoActual INT;
        SELECT @idEstadoActual = idEstado 
        FROM Turno 
        WHERE idTurno = @idTurno;

        -- Control 1: Si el turno no existe
        IF @idEstadoActual IS NULL
        BEGIN
            RAISERROR('Error: El turno especificado no existe en el sistema.', 16, 1);
        END

        -- Control 2: Si el turno ya no está disponible (Suponiendo idEstado 1 = Disponible)
        IF @idEstadoActual <> 1 
        BEGIN
            RAISERROR('Error de concurrencia: El turno seleccionado ya no se encuentra disponible.', 16, 1);
        END

        -- 2. Ejecutar la actualización: Cambiar estado a 'Reservado' (idEstado = 2) y asignar paciente
        UPDATE Turno
        SET 
            idPaciente = @idPaciente,
            idEstado = 2,                    -- 2 = Reservado (según tu catálogo de EstadoTurno)
            codigoTurno = @codigoTurno
        WHERE idTurno = @idTurno;

        -- 3. Si todo salió bien, confirmar la transacción permanentemente
        COMMIT TRANSACTION;
        PRINT '¡Transacción exitosa! El turno ha sido reservado correctamente.';

    END TRY
    BEGIN CATCH
        -- Si ocurre cualquier error, deshacer todos los cambios de la transacción
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Capturar y propagar el mensaje de error original del sistema o de la validación
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- ============================================================================
-- TAREA 1: Transacción que realiza dos INSERT y un UPDATE
-- ============================================================================

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Primer INSERT: Registrar bloqueo en la agenda del médico (ej. idMedico = 1)
    INSERT INTO BloqueoAgenda (fechaInicio, fechaFin, motivo, idMedico)
    VALUES ('2026-11-20 08:00:00', '2026-11-20 12:00:00', 'Urgencia Médica Personal', 1);

    -- 2. Segundo INSERT: Registrar al paciente afectado en la Lista de Espera (ej. idPaciente = 1)
    INSERT INTO ListaEspera (fechaCancelacion, idPaciente)
    VALUES (GETDATE(), 1);

    -- 3. UPDATE: Actualizar el estado del turno afectado (idTurno = 4) a Disponible (idEstado = 1) y desvincular paciente
    UPDATE Turno
    SET idEstado = 1,          -- 1 = Disponible
        idPaciente = NULL,     -- Liberar el paciente
        codigoTurno = 'LIBRE'
    WHERE idTurno = 4;

    -- Si las tres operaciones fueron exitosas, se confirman los cambios definitivamente
    COMMIT TRANSACTION;
    PRINT 'TRANSACCIÓN COMPLETADA CON ÉXITO: Se ejecutaron los 2 INSERTs y el UPDATE correctamente.';

END TRY
BEGIN CATCH
    -- Si ocurre cualquier error, deshacer todos los cambios
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    PRINT 'ERROR DETECTADO: Se ha realizado un ROLLBACK. Ningún cambio fue aplicado.';
    SELECT ERROR_MESSAGE() AS MensajeDeError;
END CATCH;
GO

-- ============================================================================
-- TAREA 2: Provocar un error intencional para verificar la Atomicidad
-- ============================================================================

BEGIN TRANSACTION;

BEGIN TRY
    -- 1. Primer INSERT (Válido)
    INSERT INTO BloqueoAgenda (fechaInicio, fechaFin, motivo, idMedico)
    VALUES ('2026-11-25 08:00:00', '2026-11-25 12:00:00', 'Congreso de Salud', 1);

    -- 2. Segundo INSERT (Válido)
    INSERT INTO ListaEspera (fechaCancelacion, idPaciente)
    VALUES (GETDATE(), 2);

    -- ERROR INTENCIONAL: Forzamos una división por cero entre el INSERT y el UPDATE
    -- Esto simula un fallo en medio del proceso
    DECLARE @ErrorForzado INT = 1 / 0;

    -- 3. UPDATE (Nunca llega a ejecutarse por el error anterior)
    UPDATE Turno
    SET idEstado = 1
    WHERE idTurno = 5;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH
    -- El bloque CATCH ataja el error de la división por cero y cancela todo
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END

    PRINT '--> ERROR FORZADO CAPTURADO CORRECTAMENTE: Se ejecutó el ROLLBACK.';
    PRINT '--> VERIFICACIÓN: Ningún insert ni update se guardó en la base de datos.';
    SELECT ERROR_MESSAGE() AS DetalleDelError;
END CATCH;
GO

-- ============================================================================
-- VERIFICACIÓN DE CONSISTENCIA DE DATOS
-- Comprobamos que no se insertó el registro 'Congreso de Salud' ni en ListaEspera
-- ============================================================================
SELECT * FROM BloqueoAgenda WHERE motivo = 'Congreso de Salud';
SELECT * FROM ListaEspera WHERE idPaciente = 2 AND CAST(fechaCancelacion AS DATE) = CAST(GETDATE() AS DATE);


/*
Conclusiones sobre las Pruebas de Transacciones:

Propiedad de Atomicidad ("Todo o Nada"): Durante la prueba de error intencional, se demostró que aunque las sentencias INSERT fueron sintácticamente correctas 
y se ejecutaron en memoria de manera preliminar, la presencia de un error posterior interrumpió la transacción. 
La instrucción ROLLBACK TRANSACTION deshizo por completo las inserciones previas, garantizando que no existan registros "huérfanos" ni parciales.

Consistencia de la Base de Datos: Las transacciones con estructuras TRY...CATCH garantizan que la base de datos pase de un 
estado consistente a otro estado consistente. Evitan que queden datos inconsistentes en el sistema 
(por ejemplo, registrar una fecha en la lista de espera sin haber liberado el turno correspondiente en la tabla de turnos).

Efectividad en el Manejo de Errores: La utilización del bloque BEGIN CATCH en Transact-SQL permite capturar las excepciones del motor, 
abortar la transacción de forma controlada y devolver mensajes claros a la aplicación cliente, mejorando la confiabilidad del software.*/

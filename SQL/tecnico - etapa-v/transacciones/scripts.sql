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

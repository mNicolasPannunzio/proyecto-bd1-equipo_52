--PROCEDIMIENTOS--
--Cancerlar turno...
USE GuaraniTurnosMedicos;

CREATE OR ALTER PROCEDURE dbo.USP_CancelarTurno
    @idTurno INT,
    @motivo VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    --validar si el turno existe
    IF NOT EXISTS (SELECT 1 FROM Turno WHERE idTurno = @idTurno)
    BEGIN
        RAISERROR('El turno especificado no existe.', 16, 1);
        RETURN;
    END

    --validar si el turno ya fue atendido o cancelado
    IF EXISTS (SELECT 1 FROM Turno WHERE idTurno = @idTurno AND idEstado IN (4, 5))
    BEGIN
        RAISERROR('No se puede cancelar un turno que ya fue atendido o previamente cancelado.', 16, 1);
        RETURN;
    END

 
--manejo de transeccion
    BEGIN TRANSACTION;

    BEGIN TRY
        --liberar el turno y marcarlo como cancelado (Estado 5)
        UPDATE Turno
        SET 
            idEstado = 5, --cancelado
            idPaciente = NULL,
            codigoTurno = 'CANCELADO'
        WHERE idTurno = @idTurno;

        --confirma los cambios en la base de datos
        COMMIT TRANSACTION;
        PRINT 'El turno ha sido cancelado y liberado correctamente.';

    END TRY
    BEGIN CATCH
        --si ocurre un error inesperado, deshacer todos los cambios
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @MensajeError NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@MensajeError, 16, 1);
    END CATCH
END;
GO

--con esto se puede realizar el proceso
EXEC dbo.USP_CancelarTurno 
    @idTurno = 2, 
    @motivo = 'El paciente canceló por motivos personales';

---------------------------------------------------------------------------------------------------------------------

--FUNCIONES--
--Mostrar la cantidad de turnos atendidos
USE GuaraniTurnosMedicos;
GO

CREATE OR ALTER FUNCTION dbo.FN_ObtenerTotalTurnosMedico (
    @idMedico INT,
    @fechaInicio DATE,
    @fechaFin DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @cantidad INT;

    SELECT @cantidad = COUNT(*)
    FROM Turno
    WHERE idMedico = @idMedico
      AND fechaTurno BETWEEN @fechaInicio AND @fechaFin
      AND idEstado IN (2, 3, 4); -- Estados: Reservado, En Espera, Atendido

    RETURN ISNULL(@cantidad, 0);
END;
GO
--
SELECT dbo.FN_ObtenerTotalTurnosMedico(1, '2026-01-01', '2026-12-31') AS total_turnos_atendidos;--para comprobar si anda la funcion

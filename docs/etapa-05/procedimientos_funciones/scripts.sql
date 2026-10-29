--PROCEDIMIENTOS--
--1, Cancerlar turno...
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

--2, Insertar una nueva Obra Social
CREATE OR ALTER PROCEDURE dbo.USP_InsertarObraSocial
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO ObraSocial (nombreOS)
    VALUES (@nombre);
    PRINT 'Obra Social insertada correctamente.';
END;
GO

-- 3, Eliminar una especialidad
CREATE OR ALTER PROCEDURE dbo.USP_EliminarEspecialidad
    @idEspecialidad INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Especialidad WHERE idEspecialidad = @idEspecialidad)
    BEGIN
        RAISERROR('La especialidad especificada no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM Especialidad
    WHERE idEspecialidad = @idEspecialidad;

    PRINT 'Especialidad eliminada correctamente.';
END;
GO
---------------------------------------------------------------------------------------------------------------------

--FUNCIONES--
--Funcion 1: Mostrar la cantidad de turnos atendidos
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


-- Función 2: Calcular la edad de un usuario/paciente
CREATE OR ALTER FUNCTION dbo.FN_CalcularEdad (
    @fechaNacimiento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SET @edad = DATEDIFF(YEAR, @fechaNacimiento, GETDATE()) - 
                CASE 
                    WHEN (MONTH(@fechaNacimiento) > MONTH(GETDATE())) OR 
                         (MONTH(@fechaNacimiento) = MONTH(GETDATE()) AND DAY(@fechaNacimiento) > DAY(GETDATE())) 
                    THEN 1 
                    ELSE 0 
                END;
    RETURN @edad;
END;
GO

-- Función 3: Verificar si un médico tiene agenda registrada
CREATE OR ALTER FUNCTION dbo.FN_EsMedicoActivo (
    @idMedico INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @activo BIT = 0;

    IF EXISTS (SELECT 1 FROM AgendaSemanal WHERE idMedico = @idMedico)
        SET @activo = 1;

    RETURN @activo;
END;
GO


    
--============================================================================
--PRUEBAS DE EJECUCIÓN Y LOTES DE DATOS

--1, Inserción de lote de datos directo (INSERT tradicional)
INSERT INTO ObraSocial (nombreOS) VALUES ('OSPRERA'), ('OSPE'), ('IAPOS');

--2, Inserción de lote de datos invocando al procedimiento almacenado
EXEC dbo.USP_InsertarObraSocial @nombre = 'San Cristobal';
EXEC dbo.USP_InsertarObraSocial @nombre = 'Sancor';
EXEC dbo.USP_InsertarObraSocial @nombre = 'Galeno';

--3, Modificación invocando al procedimiento almacenado
EXEC dbo.USP_CancelarTurno 
    @idTurno = 2, 
    @motivo = 'El paciente canceló por motivos personales';

--4, Eliminación invocando al procedimiento almacenado (Especialidad sin médicos vinculados)
INSERT INTO Especialidad (nombreEspecialidad, descripcion) 
VALUES ('Especialidad Temporal', 'Descripción de prueba');

DECLARE @idPrueba INT = SCOPE_IDENTITY();
EXEC dbo.USP_EliminarEspecialidad @idEspecialidad = @idPrueba;


--5, Invocación y prueba de Funciones
SELECT dbo.FN_ObtenerTotalTurnosMedico(1, '2026-01-01', '2026-12-31') AS total_turnos_atendidos;

SELECT 
    p.idPaciente,
    u.nombreUsuario,
    u.apellidoUsuario,
    p.fechaNacimiento,
    dbo.FN_CalcularEdad(p.fechaNacimiento) AS edad_actual 
FROM Paciente p
INNER JOIN Usuario u ON p.idUsuario = u.idUsuario;

SELECT idMedico, dbo.FN_EsMedicoActivo(idMedico) AS posee_agenda 
FROM Medico;

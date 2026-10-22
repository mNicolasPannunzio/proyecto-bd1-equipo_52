USE GuaraniTurnosMedicos;
GO

--===================================================================================================
-- TRIGGERS Y AUDITORIAS
--===================================================================================================
-- Triggers y auditoria para la tabla Turno...
--===================================================================================================

-- Creación de la tabla para registrar la historia de cambios en Turnos
CREATE TABLE Auditoria_Turno (
    idAuditoria INT IDENTITY(1,1) PRIMARY KEY,
    idTurno INT NOT NULL,
    codigoTurno VARCHAR(50) NULL,
    idMedico INT NULL,
    idConsultorio INT NULL,
    idPaciente INT NULL,
    idEstado INT NULL,
    fechaTurno DATE NULL,
    horaTurno TIME NULL,
    tipo_operacion VARCHAR(10) NOT NULL, -- 'UPDATE' o 'DELETE'
    usuario_db VARCHAR(128) NOT NULL,    -- Usuario de la BD que realizó la acción
    fecha_hora_operacion DATETIME NOT NULL DEFAULT GETDATE()
);
GO

SELECT * FROM Auditoria_Turno;
GO

--===================================================================================================
-- Implementacion del Trigger:
CREATE TRIGGER TR_Turno_Auditoria
ON Turno
AFTER UPDATE, DELETE
AS
BEGIN
    -- Evita que se devuelva el mensaje con el recuento de filas afectadas por el trigger
    SET NOCOUNT ON;

    -- 1. Captura de modificaciones (UPDATE) - Registra los valores previos contenidos en 'deleted'
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Turno (
            idTurno, codigoTurno, idMedico, idConsultorio, idPaciente, 
            idEstado, fechaTurno, horaTurno, tipo_operacion, usuario_db, fecha_hora_operacion
        )
        SELECT 
            d.idTurno, d.codigoTurno, d.idMedico, d.idConsultorio, d.idPaciente, 
            d.idEstado, d.fechaTurno, d.horaTurno, 'UPDATE', SUSER_SNAME(), GETDATE()
        FROM deleted d;
    END

    -- 2. Captura de borrados (DELETE) - Registra los valores previos antes de la eliminación
    IF NOT EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO Auditoria_Turno (
            idTurno, codigoTurno, idMedico, idConsultorio, idPaciente, 
            idEstado, fechaTurno, horaTurno, tipo_operacion, usuario_db, fecha_hora_operacion
        )
        SELECT 
            d.idTurno, d.codigoTurno, d.idMedico, d.idConsultorio, d.idPaciente, 
            d.idEstado, d.fechaTurno, d.horaTurno, 'DELETE', SUSER_SNAME(), GETDATE()
        FROM deleted d;
    END
END;
GO

--===================================================================================================
-- Casos de Prueba:

SELECT * FROM Turno;

-- 1. Actualizar (UPDATE) la hora y fecha de un turno existente
UPDATE Turno
SET fechaTurno = '2026-11-15', horaTurno = '10:30:00'
WHERE idTurno = 1;

-- Verificación de la auditoría capturada
SELECT * FROM Auditoria_Turno WHERE idTurno = 1;



-- 2. Eliminar (DELETE) un turno del sistema
DELETE FROM Turno 
WHERE idTurno = 2;

-- Verificación de la auditoría capturada
SELECT * FROM Auditoria_Turno WHERE idTurno = 2;
GO




--===================================================================================================
-- Trigger de Control de Operación (Bloqueo de DELETE)
--===================================================================================================
-- Para la tabla Paciente, de forma que no se pueda eliminar fisicamente un paciente
-- solo permitiendo bajas logicas de los mismo (UPDATES de status)

CREATE TRIGGER TR_Paciente_PreventDelete
ON Paciente
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Si se intenta realizar un borrado de uno o más registros
    IF EXISTS (SELECT 1 FROM deleted)
    BEGIN
        RAISERROR (
            'ACCION RESTRINGIDA: Está prohibido eliminar registros de pacientes del sistema.', 
            16, 
            1
        );
        -- La sentencia DELETE original NO se ejecuta al ser un trigger INSTEAD OF
        RETURN;
    END
END;
GO

--===================================================================================================
-- Casos de Prueba:

-- 1. Intento de DELETE sobre un paciente existente
DELETE FROM Paciente 
WHERE idPaciente = 1;

-- Cheque para ver si el Paciente se elimino o no...
SELECT * FROM Paciente;
USE GuaraniTurnosMedicos;
GO

-- 1. Ver el estado actual para confirmar qué turnos están libres (idEstado = 1)
SELECT idTurno, codigoTurno, fechaTurno, horaTurno, idEstado, idPaciente 
FROM Turno;
GO

-- ============================================================================
-- PRUEBA 1: Transacción Exitosa (Usando el idTurno = 4 que sí está Disponible)
-- ============================================================================
EXEC SP_ReservarTurnoTransaccional 
    @idTurno = 4, 
    @idPaciente = 1, 
    @codigoTurno = 'TRN-2026-TX01';
GO

-- Verificación: Debería haberse actualizado correctamente el idTurno 4 (ahora estado 2)
SELECT * FROM Turno WHERE idTurno = 4;
GO

-- ============================================================================
-- PRUEBA 2: Transacción con Fallo / ROLLBACK (Intentar reservar otra vez el idTurno 4)
-- ============================================================================
-- Como el idTurno = 4 ya fue reservado en la prueba anterior, este segundo 
-- intento fallará por la validación de estado y hará un ROLLBACK automático.
EXEC SP_ReservarTurnoTransaccional 
    @idTurno = 4, 
    @idPaciente = 2, 
    @codigoTurno = 'TRN-2026-TX02';
GO

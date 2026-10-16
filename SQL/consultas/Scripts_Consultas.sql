USE GuaraniTurnosMedicos;

--============================================================================================
-- CONSULTAS SIMPLES DE TODAS LAS TABLAS (LISTADOS COMPLETOS)
--=========================================================================================

-- 1)
SELECT * FROM AgendaSemanal;

-- 2)
SELECT * FROM BloqueoAgenda;

-- 3)
SELECT * FROM Consultorio;

-- 4)
SELECT * FROM Especialidad;

-- 5)
SELECT * FROM Especialidad_Medico;

-- 6)
SELECT * FROM EstadoTurno;

-- 7)
SELECT * FROM ListaEspera;

-- 8)
SELECT * FROM Medico;

-- 9)
SELECT * FROM ObraSocial;

-- 10)
SELECT * FROM Paciente;

-- 11)
SELECT * FROM Rol;

-- 12)
SELECT * FROM Secretario;

-- 13)
SELECT * FROM Turno;

-- 14)
SELECT * FROM Usuario;

-- ================================================================
-- HU#16 / RF#16: Cronograma diario del médico (idMedico = 1)
-- Se usan LEFT JOINs para que el médico pueda ver tanto sus turnos
-- ocupados como los turnos disponibles (libres) del día.
SELECT 
    t.horaTurno,
    COALESCE(u.nombreUsuario, '---') AS nombre_paciente,
    COALESCE(u.apellidoUsuario, '---') AS apellido_paciente,
    COALESCE(CAST(u.dniUsuario AS VARCHAR), '---') AS dni_paciente,
    COALESCE(os.nombreOS, 'Particular') AS obra_social,
    et.nombreEstado AS estado_actual
FROM Turno t
LEFT JOIN Paciente p ON t.idPaciente = p.idPaciente
LEFT JOIN Usuario u ON p.idUsuario = u.idUsuario
LEFT JOIN ObraSocial os ON p.idObraSocial = os.idObraSocial
JOIN EstadoTurno et ON t.idEstado = et.idEstado
JOIN Medico m ON t.idMedico = m.idMedico
WHERE m.idMedico = 1 
  AND t.fechaTurno = '2026-10-05'
ORDER BY t.horaTurno ASC;

-- =============================================================================
-- HU#17 / RF#17: Cronograma de turnos confirmados del paciente (idPaciente = 1)
-- Se agrega DISTINCT para evitar duplicados si el médico posee
-- más de una especialidad en la tabla intermedia.
SELECT DISTINCT
    t.fechaTurno,
    t.horaTurno,
    esp.nombreEspecialidad,
    CONCAT(u_med.nombreUsuario, ' ', u_med.apellidoUsuario) AS medico,
    c.nroConsultorio AS numero_consultorio,
    t.codigoTurno
FROM Turno t
JOIN Medico m ON t.idMedico = m.idMedico
JOIN Usuario u_med ON m.idUsuario = u_med.idUsuario
JOIN Especialidad_Medico em ON m.idMedico = em.idMedico
JOIN Especialidad esp ON em.idEspecialidad = esp.idEspecialidad
JOIN Consultorio c ON t.idConsultorio = c.idConsultorio
JOIN Paciente pac ON t.idPaciente = pac.idPaciente
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE pac.idPaciente = 2 
  AND t.fechaTurno >= '2026-10-01'
ORDER BY t.fechaTurno ASC, t.horaTurno ASC;

-- ============================================================================
-- HU#19 / RF#19: Filtrado y reserva de turnos por especialidad
-- 1. Reserva del turno (Pasa de Disponible 'idEstado = 1' a Reservado 'idEstado = 2')
UPDATE Turno
SET 
    idPaciente = 2,                    -- Asignamos al paciente 2
    idEstado = 2,                      -- Estado 2 = 'Reservado'
    codigoTurno = 'TRN-2026-998'       -- Código único nuevo
WHERE idTurno = 2 
  AND idEstado = 1;                    -- Solo si estaba disponible

  SELECT * FROM TURNO
  SELECT * FROM Paciente
  SELECT * FROM ListaEspera

-- 2. Consulta de turnos disponibles filtrados por especialidad
-- Se usa DISTINCT para prevenir filas duplicadas.
SELECT DISTINCT
    t.idTurno, 
    t.fechaTurno, 
    t.horaTurno, 
    esp.nombreEspecialidad, 
    CONCAT(u.nombreUsuario, ' ', u.apellidoUsuario) AS Medico, 
    c.nroConsultorio
FROM Turno t
JOIN Medico m ON t.idMedico = m.idMedico
JOIN Usuario u ON m.idUsuario = u.idUsuario
JOIN Especialidad_Medico em ON m.idMedico = em.idMedico
JOIN Especialidad esp ON em.idEspecialidad = esp.idEspecialidad
JOIN Consultorio c ON t.idConsultorio = c.idConsultorio
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE et.nombreEstado = 'Disponible' 
  AND esp.idEspecialidad = 1;

-- ============================================================================
-- HU#20 / RF#20: Reserva de turno por paciente
-- Se asigna idEstado = 2 ('Reservado') y un código único válido.
UPDATE Turno
SET 
    idPaciente = 1,
    codigoTurno = 'TRN-2026-101',
    idEstado = 2                       -- Estado 2 = 'Reservado'
WHERE idTurno = 1 
  AND idEstado = 1;                    -- Valida que estuviera disponible

--Aca en el idTurno 1 se tiene que ver idEstado 2. Y el codigoTurno del idTurno 1 = 'TRN-2026-101'
 SELECT * FROM TURNO

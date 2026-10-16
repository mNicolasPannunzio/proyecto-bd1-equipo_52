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


-- ============================================================================
-- HU#21 / RF#21: Cancelación de turnos programados
-- Corregido: Se establece idPaciente = NULL para desvincular al paciente al liberar el turno.
-- ============================================================================

--Aca se actualiza la fecha para poder probar el cambio
UPDATE Turno 
SET fechaTurno = '2026-10-30', horaTurno = '10:00:00' 
WHERE idTurno = 4;
---
UPDATE Turno
SET 
    idPaciente = NULL,
    codigoTurno = 'LIBRE',
    idEstado = (SELECT idEstado FROM EstadoTurno WHERE nombreEstado = 'Disponible')
WHERE idTurno = 4
  -- Validación de regla de negocio: cancelación con más de 2 horas de anticipación
  AND DATEDIFF(HOUR, GETDATE(), CAST(fechaTurno AS DATETIME) + CAST(horaTurno AS DATETIME)) > 2;

  --Al ejecutar select * from turno se tiene que ver un null en idPaciente del idturno 4 y "Libre en codigoturno"
    SELECT * FROM TURNO



-- ============================================================================
-- HU#23 / RF#23: Cambio de estado a "Paciente en Espera" por secretaría
-- ============================================================================
UPDATE Turno
SET idEstado = 3                       -- Estado 3 = 'En Espera' / 'Confirmado'
WHERE idTurno = 1
  AND idEstado = 2;                    -- Solo si estaba previamente 'Reservado'

-- Aca en idTurno 1, se tendria que cambiar el idEstado a 3.
SELECT * FROM TURNO


-- ============================================================================
-- HU#26 / RF#26: Inserción en lista de espera por cancelación
-- Se ajustó el NOT EXISTS para verificar que no se inserte un duplicado
-- para el mismo paciente en el mismo día.
-- ============================================================================
INSERT INTO ListaEspera (fechaCancelacion, idPaciente)
SELECT 
    GETDATE(),
    t.idPaciente
FROM Turno t
WHERE t.idTurno = 5 
  AND t.idPaciente IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 
      FROM ListaEspera le 
      WHERE le.idPaciente = t.idPaciente 
        AND CAST(le.fechaCancelacion AS DATE) = CAST(GETDATE() AS DATE)
  );

  SELECT * FROM ListaEspera --Aca en id lista 4 se tiene que ver la fecha de cancelacion al dia de hoy (getdate())
  SELECT * FROM Turno --Aca vemos que el id_paciente 1 esta asignado al id_turno 5 (que es el que se cambia con esta consulta)



  -- ============================================================================
-- 
-- ============================================================================

-- 1) Comprobante / Constancia de Turno (Equivalente a Factura/Comprobante)
-- Consolida los datos del paciente, médico, especialidad, consultorio y código único (HU#22)
SELECT 
    t.codigoTurno AS codigo_comprobante,
    t.fechaTurno,
    t.horaTurno,
    et.nombreEstado AS estado_turno,
    CONCAT(u_pac.nombreUsuario, ' ', u_pac.apellidoUsuario) AS paciente,
    u_pac.dniUsuario AS dni_paciente,
    COALESCE(os.nombreOS, 'Particular') AS obra_social,
    CONCAT(u_med.nombreUsuario, ' ', u_med.apellidoUsuario) AS profesional_medico,
    m.matriculaMedico AS matricula,
    esp.nombreEspecialidad AS especialidad,
    c.nroConsultorio AS consultorio
FROM Turno t
JOIN Paciente p ON t.idPaciente = p.idPaciente
JOIN Usuario u_pac ON p.idUsuario = u_pac.idUsuario
LEFT JOIN ObraSocial os ON p.idObraSocial = os.idObraSocial
JOIN Medico m ON t.idMedico = m.idMedico
JOIN Usuario u_med ON m.idUsuario = u_med.idUsuario
JOIN Especialidad_Medico em ON m.idMedico = em.idMedico
JOIN Especialidad esp ON em.idEspecialidad = esp.idEspecialidad
JOIN Consultorio c ON t.idConsultorio = c.idConsultorio
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE t.idTurno = 1;


-- 2) Reporte Agregado: Total de atenciones por médico en rango de fechas
-- Aplica GROUP BY, COUNT y filtros temporales (Equivalente a ventas por vendedor)
SELECT 
    m.idMedico,
    CONCAT(u.nombreUsuario, ' ', u.apellidoUsuario) AS profesional,
    m.matriculaMedico,
    COUNT(t.idTurno) AS total_turnos_programados,
    COUNT(CASE WHEN et.nombreEstado = 'Reservado' THEN 1 END) AS turnos_reservados,
    COUNT(CASE WHEN et.nombreEstado = 'Disponible' THEN 1 END) AS turnos_disponibles
FROM Medico m
JOIN Usuario u ON m.idUsuario = u.idUsuario
LEFT JOIN Turno t ON m.idMedico = t.idMedico 
    AND t.fechaTurno BETWEEN '2026-10-01' AND '2026-10-31'
LEFT JOIN EstadoTurno et ON t.idEstado = et.idEstado
GROUP BY m.idMedico, u.nombreUsuario, u.apellidoUsuario, m.matriculaMedico
ORDER BY total_turnos_programados DESC;


-- 3) Consulta de Negocio Avanzada: Médicos con alta demanda de atención
-- Combina más de 3 tablas con JOIN, agregación y filtro condicional mediante HAVING
SELECT 
    m.idMedico,
    CONCAT(u.nombreUsuario, ' ', u.apellidoUsuario) AS medico,
    esp.nombreEspecialidad,
    COUNT(t.idTurno) AS turnos_reservados
FROM Turno t
JOIN Medico m ON t.idMedico = m.idMedico
JOIN Usuario u ON m.idUsuario = u.idUsuario
JOIN Especialidad_Medico em ON m.idMedico = em.idMedico
JOIN Especialidad esp ON em.idEspecialidad = esp.idEspecialidad
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE et.nombreEstado IN ('Reservado', 'En Espera', 'Atendido')
GROUP BY m.idMedico, u.nombreUsuario, u.apellidoUsuario, esp.nombreEspecialidad
HAVING COUNT(t.idTurno) >= 1
ORDER BY turnos_reservados DESC;

-- ============================================================================
-- 1) Comprobante / Ficha de Turno Detallada por Paciente con Obra Social
-- Equivalente a Factura/Comprobante. Consolida los datos del paciente, 
-- cobertura médica, consultorio, médico, especialidad y estado, calculando 
-- el total de turnos acumulados del paciente mediante funciones de ventana.
-- ============================================================================

SELECT 
    p.idPaciente,
    CONCAT(u_pac.nombreUsuario, ' ', u_pac.apellidoUsuario) AS paciente,
    u_pac.dniUsuario AS dni_paciente,
    COALESCE(os.nombreOS, 'Particular') AS cobertura_medica,
    t.codigoTurno AS codigo_comprobante,
    t.fechaTurno,
    t.horaTurno,
    c.nroConsultorio AS consultorio,
    CONCAT(u_med.nombreUsuario, ' ', u_med.apellidoUsuario) AS profesional,
    esp.nombreEspecialidad AS especialidad,
    et.nombreEstado AS estado_turno,
    COUNT(t.idTurno) OVER(PARTITION BY p.idPaciente) AS total_turnos_paciente
FROM Paciente p
JOIN Usuario u_pac ON p.idUsuario = u_pac.idUsuario
LEFT JOIN ObraSocial os ON p.idObraSocial = os.idObraSocial
JOIN Turno t ON p.idPaciente = t.idPaciente
JOIN Consultorio c ON t.idConsultorio = c.idConsultorio
JOIN Medico m ON t.idMedico = m.idMedico
JOIN Usuario u_med ON m.idUsuario = u_med.idUsuario
JOIN Especialidad_Medico em ON m.idMedico = em.idMedico
JOIN Especialidad esp ON em.idEspecialidad = esp.idEspecialidad
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE p.idPaciente = 2
ORDER BY t.fechaTurno DESC, t.horaTurno DESC;

-- ============================================================================
-- 2) Reporte Agregado: Demandas y Volumen de Atenciones por Obra Social
-- Equivalente a Ventas por Categoría. Agrupa los turnos por Obra Social 
-- dentro de un rango de fechas utilizando GROUP BY, COUNT y SUM condicional.
-- ============================================================================

SELECT 
    COALESCE(os.nombreOS, 'Particular') AS obra_social,
    COUNT(t.idTurno) AS total_turnos_solicitados,
    SUM(CASE WHEN et.nombreEstado = 'Reservado' THEN 1 ELSE 0 END) AS turnos_reservados,
    SUM(CASE WHEN et.nombreEstado = 'En Espera' THEN 1 ELSE 0 END) AS pacientes_en_espera,
    COUNT(DISTINCT t.idMedico) AS medicos_distintos_atendiendo
FROM Turno t
JOIN Paciente p ON t.idPaciente = p.idPaciente
LEFT JOIN ObraSocial os ON p.idObraSocial = os.idObraSocial
JOIN EstadoTurno et ON t.idEstado = et.idEstado
WHERE t.fechaTurno BETWEEN '2026-10-01' AND '2026-10-31'
GROUP BY os.nombreOS
ORDER BY total_turnos_solicitados DESC;

-- ============================================================================
-- 3) Consulta de Negocio Avanzada: Análisis de Pacientes en Lista de Espera
-- Cruce relacional de múltiples tablas (Paciente, Usuario, ListaEspera, Turno)
-- aplicando agrupamiento y filtros sobre agregaciones mediante la cláusula HAVING
-- para identificar usuarios con solicitudes activas de reprogramación.
-- ============================================================================

SELECT 
    p.idPaciente,
    CONCAT(u.nombreUsuario, ' ', u.apellidoUsuario) AS paciente,
    u.dniUsuario AS dni,
    COUNT(DISTINCT le.idLista) AS solicitudes_lista_espera,
    COUNT(DISTINCT t.idTurno) AS total_turnos_asociados
FROM Paciente p
JOIN Usuario u ON p.idUsuario = u.idUsuario
LEFT JOIN ListaEspera le ON p.idPaciente = le.idPaciente
LEFT JOIN Turno t ON p.idPaciente = t.idPaciente
GROUP BY p.idPaciente, u.nombreUsuario, u.apellidoUsuario, u.dniUsuario
HAVING COUNT(DISTINCT le.idLista) >= 1
ORDER BY solicitudes_lista_espera DESC;
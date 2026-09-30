USE GuaraniTurnosMedicos;
GO

---------------------------------------------------------------------------------
--1: llenamos Tablas Maestras con datos estaticos
---------------------------------------------------------------------------------

-- 1) Rol
INSERT INTO Rol (nombreRol) 
  VALUES
    ('Administrador'),
    ('Secretario'),
    ('Medico'),
    ('Paciente'),
    ('Auditor');

-- 2) Especialidad
INSERT INTO Especialidad (nombreEspecialidad, descripcion) 
  VALUES
    ('Pediatría', 'Atención médica integral para niños y adolescentes.'),
    ('Cardiología', 'Diagnóstico y tratamiento de enfermedades del corazón y vasos sanguíneos.'),
    ('Dermatología', 'Cuidado de la piel, cabello y uñas.'),
    ('Traumatología', 'Tratamiento de lesiones óseas y musculares.'),
    ('Neurología', 'Diagnóstico de trastornos del sistema nervioso.'),
    ('Oftalmología', 'Atención integral de la salud visual.');

-- 3) ObraSocial
INSERT INTO ObraSocial (nombreOS) 
  VALUES
    ('OSDE'),
    ('Swiss Medical'),
    ('Galeno'),
    ('PAMI'),
    ('IOMA'),
    ('OSECAC');

-- 4) Consultorio
INSERT INTO Consultorio (nroConsultorio) 
  VALUES
    (101),
    (102),
    (103),
    (201),
    (202),
    (203);

-- 5) EstadoTurno
INSERT INTO EstadoTurno (nombreEstado) 
  VALUES
    ('Disponible'),
    ('Reservado'),
    ('Confirmado'),
    ('Atendido'),
    ('Cancelado'),
    ('Ausente');
---------------------------------------------------------------------------------
-- INTEGRANTE 2: USUARIOS Y PERFILES (Nivel 2)
---------------------------------------------------------------------------------

-- 6) Usuario
INSERT INTO Usuario (dniUsuario, nombreUsuario, apellidoUsuario, passwordUsuario, estadoUsuario, idRol) VALUES
(30111222, 'Juan', 'Pérez', 'hash_pass_1', 'Activo', 1),       -- idUsuario 1 (Admin)
(32333444, 'María', 'Gómez', 'hash_pass_2', 'Activo', 2),      -- idUsuario 2 (Secretario)
(33555666, 'Carlos', 'López', 'hash_pass_3', 'Activo', 2),     -- idUsuario 3 (Secretario)
(28777888, 'Roberto', 'Sánchez', 'hash_pass_4', 'Activo', 3),  -- idUsuario 4 (Médico)
(29999000, 'Laura', 'Martínez', 'hash_pass_5', 'Activo', 3),   -- idUsuario 5 (Médico)
(27111333, 'Esteban', 'Quito', 'hash_pass_6', 'Activo', 3),    -- idUsuario 6 (Médico)
(40222444, 'Ana', 'Fernández', 'hash_pass_7', 'Activo', 4),    -- idUsuario 7 (Paciente)
(41555777, 'Diego', 'Torres', 'hash_pass_8', 'Activo', 4);     -- idUsuario 8 (Paciente)

-- 7) Secretario
INSERT INTO Secretario (credencialSecretario, fechaContratacion, idUsuario) VALUES
(1001, '2020-03-15', 2),
(1002, '2021-06-01', 3);

-- 8) Medico
INSERT INTO Medico (matriculaMedico, fechaContratacion, idUsuario) VALUES
(5050, '2015-02-10', 4), -- idMedico 1
(5051, '2018-08-20', 5), -- idMedico 2
(5052, '2019-11-05', 6); -- idMedico 3

-- 9) Paciente
INSERT INTO Paciente (fechaNacimiento, idUsuario, idObraSocial) VALUES
('1995-04-12', 7, 1), -- idPaciente 1 (OSDE)
('1998-11-23', 8, 2); -- idPaciente 2 (Swiss Medical)
---------------------------------------------------------------------------------
-- INTEGRANTE 3: ASOCIACIONES Y TRANSACCIONES (Nivel 3)
---------------------------------------------------------------------------------

-- 10) Especialidad_Medico
INSERT INTO Especialidad_Medico (idMedico, idEspecialidad, activo, fechaObtencion, institucionEmisora) VALUES
(1, 1, 1, '2014-12-15', 'Universidad de Buenos Aires'),
(1, 2, 1, '2018-05-20', 'Universidad Nacional de La Plata'),
(2, 3, 1, '2017-10-10', 'Universidad Nacional de Córdoba'),
(3, 4, 1, '2019-03-30', 'Universidad de Buenos Aires');

-- 11) AgendaSemanal
INSERT INTO AgendaSemanal (diaSemana, horaInicio, horaFin, duracionMinutos, idMedico) VALUES
('Lunes', '08:00:00', '12:00:00', 30, 1),
('Miércoles', '14:00:00', '18:00:00', 20, 1),
('Martes', '09:00:00', '13:00:00', 30, 2),
('Jueves', '08:00:00', '12:00:00', 40, 3),
('Viernes', '15:00:00', '19:00:00', 30, 3);

-- 12) BloqueoAgenda
INSERT INTO BloqueoAgenda (fechaInicio, fechaFin, motivo, idMedico) VALUES
('2026-10-12 00:00:00', '2026-10-12 23:59:59', 'Feriado Nacional', 1),
('2026-11-01 08:00:00', '2026-11-07 18:00:00', 'Congreso de Cardiología', 2),
('2026-12-20 00:00:00', '2026-12-31 23:59:59', 'Vacaciones', 3);

-- 13) ListaEspera
INSERT INTO ListaEspera (fechaCancelacion, idPaciente) VALUES
(NULL, 1),
('2026-09-25 10:30:00', 2),
(NULL, 2);

-- 14) Turno
INSERT INTO Turno (codigoTurno, fechaTurno, horaTurno, idEstado, idMedico, idConsultorio, idPaciente) VALUES
('TRN-2026-001', '2026-10-05', '08:00:00', 2, 1, 1, 1),
('TRN-2026-002', '2026-10-05', '08:30:00', 1, 1, 1, 2),
('TRN-2026-003', '2026-10-06', '09:00:00', 3, 2, 2, 1),
('TRN-2026-004', '2026-10-08', '08:00:00', 4, 3, 3, 2),
('TRN-2026-005', '2026-10-09', '15:00:00', 5, 3, 4, 1);
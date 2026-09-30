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

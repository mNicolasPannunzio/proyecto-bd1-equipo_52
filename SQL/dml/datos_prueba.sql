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


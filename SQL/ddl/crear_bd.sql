CREATE DATABASE GuaraniTurnosMedicos; --Hay que ejecutar esta linea primero, luego las siguientes EN ORDEN de como van apareciendo, por las dependencias que tienen entre ellas
USE GuaraniTurnosMedicos;

---------------------------------------------------------------------------------
-- TABLAS MAESTRAS (No poseen FK, no dependen de ninguna otra tabla)
---------------------------------------------------------------------------------

-- 1) Creamos la tabla de rol, para usuario
CREATE TABLE Rol (
	idRol INT IDENTITY(1,1),
	nombreRol VARCHAR (50) NOT NULL,

	CONSTRAINT PK_Rol PRIMARY KEY (idRol),
	CONSTRAINT UQ_Rol_nombreRol UNIQUE (nombreRol)
	);


-- 2) Se crea tabla para la especialidad del medico
CREATE TABLE Especialidad (
	idEspecialidad INT IDENTITY(1,1),
	nombreEspecialidad VARCHAR (50) NOT NULL,
	descripcion VARCHAR (150) NOT NULL,

	CONSTRAINT PK_Especialidad PRIMARY KEY (idEspecialidad),
	CONSTRAINT UQ_Especialidad_nombreEspecialidad UNIQUE (nombreEspecialidad)
	);


-- 3) Obras sociales
CREATE TABLE ObraSocial (
	idObraSocial INT IDENTITY(1,1),
	nombreOS VARCHAR (100) NOT NULL,

	CONSTRAINT PK_ObraSocial PRIMARY KEY (idObraSocial),
	CONSTRAINT UQ_ObraSocial_nombreOS UNIQUE (nombreOS)
	);


-- 4) Para consultorios
CREATE TABLE Consultorio (
	idConsultorio INT IDENTITY(1,1),
	nroConsultorio INT NOT NULL,

	CONSTRAINT PK_Consultorio PRIMARY KEY (idConsultorio),
	CONSTRAINT UQ_Consultorio_nroConsultorio UNIQUE (nroConsultorio),
	CONSTRAINT CHK_Consultorio_nroPositivo CHECK (nroConsultorio > 0)
	);


-- 5) El estado de turno antes de crear turno
CREATE TABLE EstadoTurno (
	idEstado INT IDENTITY(1,1),
	nombreEstado VARCHAR (30) NOT NULL,

	CONSTRAINT PK_EstadoTurno PRIMARY KEY (idEstado),
	CONSTRAINT UQ_EstadoTurno_nombreEstado UNIQUE (nombreEstado)
	);


----------------------------------------------------------------------------------
-- TABLAS DE SEGUNDO NIVEL (Dependen de Tablas Maestras)
----------------------------------------------------------------------------------

-- 6) Ahora si podemos crear la tabla usuario
CREATE TABLE Usuario (
	idUsuario INT IDENTITY(1,1),
	dniUsuario INT NOT NULL,
	nombreUsuario VARCHAR (50) NOT NULL,
	apellidoUsuario VARCHAR (50) NOT NULL,
	passwordUsuario VARCHAR (100) NOT NULL,
	estadoUsuario VARCHAR (20) NOT NULL,
	idRol INT NOT NULL,

	CONSTRAINT PK_Usuario PRIMARY KEY (idUsuario),
	CONSTRAINT UQ_Usuario_dni UNIQUE (dniUsuario),
	CONSTRAINT FK_Usuario_Rol FOREIGN KEY (idRol) REFERENCES Rol (idRol)
	);


---------------------------------------------------------------------------
-- Tablas Derivadas de Usuario
---------------------------------------------------------------------------

-- 7) Se crea tabla para secretario que es un usuario
CREATE TABLE Secretario (
	idSecretario INT IDENTITY(1,1),
	credencialSecretario INT NOT NULL,
	fechaContratacion DATE NOT NULL,
	idUsuario INT NOT NULL,

	CONSTRAINT PK_Secretario PRIMARY KEY (idSecretario),
	CONSTRAINT UQ_Secretario_idUsuario UNIQUE (idUsuario),
	CONSTRAINT UQ_Secretario_credencial UNIQUE (credencialSecretario),
	CONSTRAINT FK_Secretario_Usuario FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario)
	);



-- 8) Tabla para medicos
CREATE TABLE Medico (
	idMedico INT IDENTITY(1,1),
	matriculaMedico INT NOT NULL,
	fechaContratacion DATE NOT NULL,
	idUsuario INT NOT NULL,

	CONSTRAINT PK_Medico PRIMARY KEY (idMedico),
	CONSTRAINT UQ_Medico_idUsuario UNIQUE (idUsuario),
	CONSTRAINT UQ_Medico_matricula UNIQUE (matriculaMedico),
	CONSTRAINT FK_Medico_idUsuario FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario)
	);


-- 9) Paciente que es un usuario
CREATE TABLE Paciente (
	idPaciente INT IDENTITY(1,1),
	fechaNacimiento DATE NOT NULL,
	idUsuario INT NOT NULL,
	idObraSocial INT NOT NULL,

	CONSTRAINT PK_Paciente PRIMARY KEY (idPaciente),
	CONSTRAINT CHK_Paciente_fechaNacimiento CHECK (fechaNacimiento <= GETDATE()),
	CONSTRAINT UQ_Paciente_idUsuario UNIQUE (idUsuario),
	CONSTRAINT FK_Paciente_idUsuario FOREIGN KEY (idUsuario) REFERENCES Usuario (idUsuario),
	CONSTRAINT FK_Paciente_idObraSocial FOREIGN KEY (idObraSocial) REFERENCES ObraSocial (idObraSocial)
	);


-------------------------------------------------------------------------------
-- TABLAS TRANSACCIONALES Y DE ASOCIACION
-------------------------------------------------------------------------------

-- 10) Se crea una tabla intermedia entre medico y especialidad por la relacion muchos a muchos
CREATE TABLE Especialidad_Medico (
	idEspecialidadMedico INT IDENTITY(1,1),
	idMedico INT NOT NULL,
	idEspecialidad INT NOT NULL,
	activo BIT NOT NULL CONSTRAINT DF_EspecialidadMedico_activo DEFAULT 1,
	fechaObtencion DATE NOT NULL,
	institucionEmisora VARCHAR (100) NOT NULL,

	CONSTRAINT PK_EspecialidadMedico PRIMARY KEY (idEspecialidadMedico),
	CONSTRAINT FK_EspecialidadMedico_Medico FOREIGN KEY (idMedico) REFERENCES Medico (idMedico),
	CONSTRAINT FK_EspecialidadMedico_Especialidad FOREIGN KEY (idEspecialidad) REFERENCES Especialidad (idEspecialidad)
	);

-- 11) Tabla de la agenda semanal
CREATE TABLE AgendaSemanal (
	idAgenda INT IDENTITY(1,1),
	diaSemana VARCHAR(15) NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    duracionMinutos INT NOT NULL,
    idMedico INT NOT NULL,

    CONSTRAINT PK_AgendaSemanal PRIMARY KEY (idAgenda),
    CONSTRAINT FK_AgendaSemanal_Medico FOREIGN KEY (idMedico) REFERENCES Medico (idMedico),
    CONSTRAINT CHK_AgendaSemanal_duracion CHECK (duracionMinutos > 0),
    CONSTRAINT CHK_AgendaSemanal_horas CHECK (horaFin > horaInicio)
);

-- 12) Bloqueo de agenda
CREATE TABLE BloqueoAgenda (
	idBloqueo INT IDENTITY(1,1),
	fechaInicio DATETIME NOT NULL,
	fechaFin DATETIME NOT NULL,
	motivo VARCHAR (100) NOT NULL,
	idMedico INT NOT NULL,

	CONSTRAINT PK_BloqueoAgenda PRIMARY KEY (idBloqueo),
    CONSTRAINT FK_BloqueoAgenda_Medico FOREIGN KEY (idMedico) REFERENCES Medico (idMedico), 
    CONSTRAINT CHK_BloqueoAgenda_fechas CHECK (fechaFin > fechaInicio)
	);


-- 13) Lista de espera para los pacientes
CREATE TABLE ListaEspera (
	idLista INT IDENTITY(1,1),
	fechaCancelacion DATETIME NULL,
	idPaciente INT NOT NULL,

	CONSTRAINT PK_ListaEspera PRIMARY KEY (idLista),
	CONSTRAINT FK_ListaEspera_idPaciente FOREIGN KEY (idPaciente) REFERENCES Paciente (idPaciente)
	);



-- 14) Ahora si creamos turno, ultimo porque depende de muchas entidades
CREATE TABLE Turno (
	idTurno INT IDENTITY(1,1),
	codigoTurno VARCHAR(20) NOT NULL,
	fechaTurno DATE NOT NULL,
	horaTurno TIME NOT NULL,
	idEstado INT NOT NULL,
	idMedico INT NOT NULL,
	idConsultorio INT NOT NULL,
	idPaciente INT NOT NULL,

	CONSTRAINT PK_Turno PRIMARY KEY (idTurno),
	CONSTRAINT UQ_Turno_codigoTurno UNIQUE (codigoTurno),
	CONSTRAINT FK_Turno_Estado FOREIGN KEY (idEstado) REFERENCES EstadoTurno (idEstado),
	CONSTRAINT FK_Turno_Medico FOREIGN KEY (idMedico) REFERENCES Medico (idMedico),
	CONSTRAINT FK_Turno_Consultorio FOREIGN KEY (idConsultorio) REFERENCES Consultorio (idConsultorio),
	CONSTRAINT FK_Turno_Paciente FOREIGN KEY (idPaciente) REFERENCES Paciente (idPaciente)
	);

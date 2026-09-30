CREATE DATABASE GuaraniTurnosMedicos; --Hay que ejecutar esta linea primero, luego las siguientes EN ORDEN de como van apareciendo, por las dependencias que tienen entre ellas
USE GuaraniTurnosMedicos;

--Creamos la tabla de rol, para usuario
CREATE TABLE Rol (
	idRol INT PRIMARY KEY,
	nombreRol VARCHAR (20) NOT NULL
	);

--Ahora si podemos crear la tabla usuario
CREATE TABLE Usuario (
	dniUsuario INT PRIMARY KEY,
	nombreUsuario VARCHAR (20) NOT NULL,
	apellidoUsuario VARCHAR (20) NOT NULL,
	passwordUsuario VARCHAR (50) NOT NULL,
	estadoUsuario VARCHAR (20) NOT NULL,
	idRol INT NOT NULL,
	CONSTRAINT FK_idRol
		FOREIGN KEY (idRol)
		REFERENCES Rol (idRol)
	);

--Se crea tabla para secretario que es un usuario
CREATE TABLE Secretario (
	credencialSecretari INT PRIMARY KEY,
	fechaContratacion VARCHAR (20) NOT NULL, --Ver si se puede modificar
	dniUsuario INT NOT NULL,
	CONSTRAINT FK_dniUsuario
		FOREIGN KEY (dniUsuario)
		REFERENCES Usuario (dniUsuario)
	);

--Se crea tabla para la especialidad del medico
CREATE TABLE Especialidad (
	idEspecialidad INT PRIMARY KEY,
	nombreEspecialidad VARCHAR (20),
	descripcion VARCHAR (20)
	);

--Tabla para medicos
CREATE TABLE Medico (
	matriculaMedico INT PRIMARY KEY,
	fechaContratacion VARCHAR (20),
	dniUsuario INT NOT NULL,
	CONSTRAINT FK_dniUsuario
		FOREIGN KEY (dniUsuario)
		REFERENCES Usuario (dniUsuario)
	);

--Se crea una tabla intermedia entre medico y especialidad por la relacion muchos a muchos
CREATE TABLE Especialidad_Medico (
	matriculaMedico INT NOT NULL,
	idEspecialidad INT NOT NULL,
	activo INT NOT NULL,
	fechaObtencion VARCHAR (20) NOT NULL,
	institucionEmisora VARCHAR (50) NOT NULL
	);

--Tabla de la agenda semanal
CREATE TABLE AgendaSemanal (
	idAgenda INT PRIMARY KEY,
	duracionMinutos INT NOT NULL,
	matriculaMedico INT NOT NULL,
	CONSTRAINT FK_matriculaMedico
		FOREIGN KEY (matriculaMedico)
		REFERENCES Medico (matriculaMedico)
	);

--Bloqueo de agenda
CREATE TABLE BloqueoAgenda (
	idBloqueo INT PRIMARY KEY,
	fechaInicio VARCHAR (20) NOT NULL,
	fechaFin VARCHAR (20) NOT NULL,
	motivo VARCHAR (20) NOT NULL,
	matriculaMedico INT NOT NULL,
	CONSTRAINT FK_matriculaMedico
		FOREIGN KEY (matriculaMedico)
		REFERENCES Medico (matriculaMedico)
	);

--Obras sociales
CREATE TABLE ObraSocial (
	idObraSocial INT PRIMARY KEY,
	nombreOS VARCHAR (20) NOT NULL
	);

--Paciente que es un usuario
CREATE TABLE Paciente (
	idPaciente INT PRIMARY KEY,
	fechaNacimiento VARCHAR (20),
	dniUsuario INT NOT NULL,
	idObraSocial INT NOT NULL,
	CONSTRAINT FK_dniUsuario 
		FOREIGN KEY (dniUsuario)
		REFERENCES Usuario (dniUsuario),
	CONSTRAINT FK_idObraSocial
		FOREIGN KEY (idObraSocial)
		REFERENCES ObraSocial (idObraSocial)
	);

--Lista de espera para los pacientes
CREATE TABLE ListaEspera (
	idLista INT PRIMARY KEY,
	fechaCancelacion VARCHAR (20),
	idPaciente INT NOT NULL,
	CONSTRAINT FK_idPaciente
		FOREIGN KEY (idPaciente)
		REFERENCES Paciente (idPaciente)
	);

--Para consultorios
CREATE TABLE Consultorio (
	idConsultorio INT PRIMARY KEY,
	nroConsultorio INT NOT NULL
	);

--El estado de turno antes de crear turno
CREATE TABLE EstadoTurno (
	idEstado INT PRIMARY KEY,
	nombreEstado VARCHAR (20)
	);

--Ahora si creamos turno, ultimo porque depende de muchas entidades
CREATE TABLE Turno (
	codigoTurno INT PRIMARY KEY,
	fechaTurno VARCHAR (20),
	horaTurno VARCHAR (20),
	idEstado INT NOT NULL,
	matriculaMedico INT NOT NULL,
	idConsultorio INT NOT NULL,
	idPaciente INT NOT NULL,
	CONSTRAINT FK_idEstado FOREIGN KEY (idEstado) REFERENCES EstadoTurno (idEstado),
	CONSTRAINT FK_matriculaMedico FOREIGN KEY (matriculaMedico) REFERENCES Medico (matriculaMedico),
	CONSTRAINT FK_idConsultorio FOREIGN KEY (idConsultorio) REFERENCES Consultorio (idConsultorio),
	CONSTRAINT FK_idPaciente FOREIGN KEY (idPaciente) REFERENCES Paciente (idPaciente)
	);

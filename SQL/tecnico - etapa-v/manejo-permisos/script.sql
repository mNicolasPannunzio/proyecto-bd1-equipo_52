-- =====================================================================
-- PROYECTO: Guaraní Turnos Médicos (Equipo 52)
-- TRABAJO PRÁCTICO: Manejo de permisos a nivel de usuarios y roles del DBMS
-- =====================================================================

USE GuaraniTurnosMedicos;
GO

-------------------------------------------------------------------------
-- PARTE 1: VERIFICAR / CONFIGURAR MODO MIXTO DE AUTENTICACIÓN
-------------------------------------------------------------------------
-- Nota: El modo mixto (Autenticación de Windows y SQL Server) se habilita 
-- a nivel de servidor en las Propiedades de la Instancia en SSMS (Seguridad -> 
-- Modo de autenticación de SQL Server y de Windows). 
-- Una vez habilitado el servidor, procedemos con los scripts requeridos:


-------------------------------------------------------------------------
-- PARTE 2: PERMISOS A NIVEL DE USUARIOS
-------------------------------------------------------------------------

-- 1. Crear dos usuarios de base de datos (con login asociado a SQL Server)
CREATE LOGIN UsrAdmin WITH PASSWORD = 'Password123*';
CREATE LOGIN UsrLectura WITH PASSWORD = 'Password123*';
GO

-- Crear los usuarios en la base de datos de la aplicación
CREATE USER UsuarioAdmin FOR LOGIN UsrAdmin;
CREATE USER UsuarioLectura FOR LOGIN UsrLectura;
GO

-- 2. A un usuario darle el permiso de administrador (db_owner) y al otro solo lectura (db_datareader)
ALTER ROLE db_owner ADD MEMBER UsuarioAdmin;
ALTER ROLE db_datareader ADD MEMBER UsuarioLectura;
GO

-- 3. Utilizar los procedimientos almacenados creados anteriormente
-- (Creamos un procedimiento almacenado de prueba basado en la tabla ObraSocial para cumplir con la tarea)
CREATE PROCEDURE sp_InsertarObraSocialPrueba
    @nombreOS VARCHAR(100)
AS
BEGIN
    INSERT INTO ObraSocial (nombreOS) VALUES (@nombreOS);
END;
GO

-- 4. Al usuario con permiso de solo lectura, darle permiso de ejecución sobre este procedimiento
GRANT EXECUTE ON sp_InsertarObraSocialPrueba TO UsuarioLectura;
GO

-- 5. Realizar INSERT con sentencia SQL sobre la tabla del procedimiento con ambos usuarios
-- NOTA DE PRUEBA: 
-- * El UsuarioAdmin podrá hacerlo porque es db_owner.
-- * El UsuarioLectura fallará si intenta hacer un INSERT directo a la tabla ObraSocial por tener solo lectura.
-- Ejemplo para probar con UsuarioAdmin (ejecutar logueado como Admin):
-- INSERT INTO ObraSocial (nombreOS) VALUES ('OSDE Test');

-- 6. Realizar un INSERT a través del procedimiento almacenado con el usuario con permiso de solo lectura
-- (Esto funcionará correctamente ya que se le otorgó explícitamente el permiso EXECUTE sobre el procedimiento)
EXECUTE AS USER = 'UsuarioLectura';
EXEC sp_InsertarObraSocialPrueba @nombreOS = 'Swiss Medical Test';
REVERT;
GO


-------------------------------------------------------------------------
-- PARTE 3: PERMISOS A NIVEL DE ROLES DEL DBMS
-------------------------------------------------------------------------

-- 1. Crear dos usuarios de base de datos para esta sección
CREATE LOGIN LogUserA WITH PASSWORD = 'Password123*';
CREATE LOGIN LogUserB WITH PASSWORD = 'Password123*';
GO

CREATE USER UserRolA FOR LOGIN LogUserA;
CREATE USER UserRolB FOR LOGIN LogUserB;
GO

-- 2. Crear un rol que solo permita la lectura de alguna de las tablas creadas (ej. Especialidad)
CREATE ROLE RolSoloLecturaEspecialidad;
GRANT SELECT ON Especialidad TO RolSoloLecturaEspecialidad;
GO

-- 3. Darle permiso a uno de los usuarios sobre el rol creado anteriormente (Se asigna UserRolA al rol)
ALTER ROLE RolSoloLecturaEspecialidad ADD MEMBER UserRolA;
GO
-- (UserRolB queda intencionalmente sin este rol para evaluar el comportamiento diferencial).

-- 4. Verificar el comportamiento de ambos usuarios (Consultas de prueba):
-- * UserRolA podrá consultar la tabla Especialidad de forma exitosa.
-- * UserRolB obtendrá un mensaje de denegación de permisos al intentar consultar la tabla Especialidad.

-- Ejemplo de bloque para simular y probar el comportamiento:
/*
-- Probando con UserRolA (Tiene acceso por medio del rol):
EXECUTE AS USER = 'UserRolA';
SELECT * FROM Especialidad;
REVERT;

-- Probando con UserRolB (No tiene acceso):
EXECUTE AS USER = 'UserRolB';
SELECT * FROM Especialidad;
REVERT;
*/
GO


-------------------------------------------------------------------------
-- PARTE 4: CONCLUSIONES / EXPRESIÓN DE RESULTADOS
-------------------------------------------------------------------------
-- Conclusiones del práctico:
-- 1. La autenticación en Modo Mixto permite gestionar tanto accesos del sistema operativo 
--    como credenciales propias de SQL Server.
-- 2. Los roles fijos de base de datos como 'db_datareader' y 'db_owner' facilitan la administración masiva 
--    de permisos, mientras que los roles personalizados otorgan un control granular de seguridad por tablas.
-- 3. Los permisos de ejecución (EXECUTE) en procedimientos almacenados permiten que usuarios con 
--    perfiles restringidos realicen inserciones controladas sin necesidad de otorgarles privilegios de escritura directos (INSERT) sobre las tablas base.
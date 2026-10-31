# Informe de Investigación: Manejo de Permisos, Roles y Seguridad a Nivel de DBMS en Bases de Datos Relacionales

## 1. Introducción y Marco Conceptual

En los sistemas de gestión de bases de datos relacionales (SGBD) multiusuario —como el **Sistema de Gestión de Turnos Médicos**— la seguridad y la protección de los datos resultan fundamentales. La interacción simultánea de diferentes perfiles operativos (administradores generales del sistema, secretarios en recepción operando con privilegios operativos y pacientes realizando consultas web) introduce riesgos de seguridad, como el acceso no autorizado a información sensible, modificaciones indebidas de tablas maestras o la violación de la confidencialidad operativa.

Para prevenir estos escenarios, los motores de bases de datos implementan un modelo de **Seguridad Basada en Roles (RBAC)** y privilegios a nivel de DBMS, permitiendo restringir y auditar de manera estricta qué acciones puede ejecutar cada usuario sobre los distintos objetos de la base de datos (`Tablas`, `Vistas`, `Procedimientos Almacenados`).

---

## 2. Los Principios Fundamentales de Seguridad en SQL Server

Toda gestión de accesos implementada en un SGBD relacional como SQL Server debe regirse bajo principios estrictos de control:

* **Autenticación en Modo Mixto:** Mecanismo que permite al servidor aceptar tanto la autenticación integrada del sistema operativo (Windows) como las credenciales propias definidas en el motor de SQL Server (`Logins`), garantizando flexibilidad en el despliegue del sistema.
* **Principio de Mínimo Privilegio:** Cada usuario o rol debe poseer exclusivamente los permisos indispensables y estrictamente necesarios para cumplir con sus funciones asignadas, mitigando el impacto ante posibles brechas de seguridad.
* **Seguridad Modular mediante Roles:** Agrupación lógica de privilegios que simplifica la administración masiva. En lugar de otorgar permisos de forma individual por usuario, se asignan permisos a roles y estos se heredan a los usuarios miembros.
* **Encapsulamiento de Lógica (`GRANT EXECUTE`):** Estrategia de seguridad que permite otorgar a perfiles restringidos acceso exclusivo a procedimientos almacenados, impidiendo el acceso directo y la manipulación arbitraria de las tablas base subyacentes.

---

## 3. Arquitectura de Seguridad en Transact-SQL (T-SQL)

En SQL Server Express, la seguridad se gestiona a través de una jerarquía que separa los inicios de sesión a nivel de instancia (`Logins`) de los usuarios a nivel de base de datos (`Users`), combinados con roles fijos o personalizados.

### 3.1. Sentencias Principales de Gestión

* **`CREATE LOGIN` / `CREATE USER`:** Permiten dar de alta las credenciales de acceso a la instancia y su posterior mapeo dentro de la base de datos de la aplicación (`GuaraniTurnosMedicos`).
* **`GRANT` / `DENY` / `REVOKE`:** Comandos DCL (*Data Control Language*) para otorgar, denegar o revocar permisos específicos (`SELECT`, `INSERT`, `UPDATE`, `EXECUTE`) sobre los objetos del esquema.
* **`ALTER ROLE ... ADD MEMBER`:** Permite asociar un usuario de base de datos a un rol fijo del sistema (como `db_owner` o `db_datareader`) o a un rol definido por el usuario.

### 3.2. Simulación de Identidad para Auditoría (`EXECUTE AS USER`)

Para validar de forma empírica el comportamiento de los permisos asignados sin necesidad de cerrar sesión constantemente en SSMS, T-SQL provee la instrucción de simulación de contexto:

```sql
-- Ejemplo de estructura de prueba de privilegios
EXECUTE AS USER = 'NombreUsuarioRestringido';
-- Ejecución de consultas o acciones a auditar
REVERT; -- Restaura el contexto del administrador original
```

---

## 4. Problemas de Control de Acceso y Niveles de Privilegio

Cuando se implementan arquitecturas multiusuario sin un esquema de seguridad robusto, se exponen vulnerabilidades críticas:

1. **Acceso Irrestricto a Datos Maestros:** Si cualquier usuario posee permisos de modificación sobre tablas críticas (como `Especialidad` o `ObraSocial`), se corre el riesgo de alteraciones maliciosas o accidentales que corrompan la integridad de la base de datos.
2. **Privilegios de Escritura Excesivos:** Otorgar permisos directos de `INSERT` o `UPDATE` sobre tablas transaccionales vulnera las reglas de validación de negocio, permitiendo saltarse los controles lógicos implementados en los procedimientos almacenados.
3. **Ausencia de Aislamiento de Roles:** No segmentar adecuadamente las funciones entre administradores y personal de lectura expone información sensible de auditoría y gestión interna a perfiles no autorizados.

### Roles y Permisos Estándar en SQL Server

SQL Server gestiona los privilegios predeterminados mediante roles fijos de base de datos:

* **`db_owner`:** Otorga control total y privilegios administrativos absolutos sobre todos los objetos de la base de datos.
* **`db_datareader`:** Concede permisos de lectura (`SELECT`) de forma masiva sobre todas las tablas de la base de datos.
* **Roles Personalizados:** Creados a medida para escenarios específicos, permitiendo restringir la lectura o manipulación a tablas o esquemas particulares.

---

## 5. Implementación Práctica en el Proyecto "Guaraní Turnos Médicos"

### 5.1. Escenario de Negocio: Gestión de Permisos y Roles

El esquema de seguridad del sistema requiere segmentar operativamente a los usuarios: un perfil administrativo con control total (`UsuarioAdmin`), y un perfil operativo con restricciones de lectura directa pero con capacidad de ejecución controlada mediante procedimientos almacenados (`UsuarioLectura`), además de un rol personalizado para auditar el acceso a tablas específicas como `Especialidad`.

### 5.2. Script T-SQL de Configuración de Seguridad y Permisos

```sql
USE GuaraniTurnosMedicos;
GO

-------------------------------------------------------------------------
-- 1. CREACIÓN DE LOGINS Y USUARIOS DE BASE DE DATOS
-------------------------------------------------------------------------
CREATE LOGIN UsrAdmin WITH PASSWORD = 'Password123*';
CREATE LOGIN UsrLectura WITH PASSWORD = 'Password123*';
GO

CREATE USER UsuarioAdmin FOR LOGIN UsrAdmin;
CREATE USER UsuarioLectura FOR LOGIN UsrLectura;
GO

-------------------------------------------------------------------------
-- 2. ASIGNACIÓN DE ROLES FIJOS DEL SISTEMA
-------------------------------------------------------------------------
ALTER ROLE db_owner ADD MEMBER UsuarioAdmin;
ALTER ROLE db_datareader ADD MEMBER UsuarioLectura;
GO

-------------------------------------------------------------------------
-- 3. PROCEDIMIENTO ALMACENADO Y PERMISOS DE EJECUCIÓN
-------------------------------------------------------------------------
IF OBJECT_ID('sp_InsertarObraSocialPrueba', 'P') IS NOT NULL
    DROP PROCEDURE sp_InsertarObraSocialPrueba;
GO

CREATE PROCEDURE sp_InsertarObraSocialPrueba
    @nombreOS VARCHAR(100)
AS
BEGIN
    INSERT INTO ObraSocial (nombreOS) VALUES (@nombreOS);
END;
GO

-- Otorgar permiso específico de ejecución al usuario de lectura
GRANT EXECUTE ON sp_InsertarObraSocialPrueba TO UsuarioLectura;
GO

-------------------------------------------------------------------------
-- 4. CREACIÓN DE ROL PERSONALIZADO Y RESTRICCIONES DE ACCESO
-------------------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'RolSoloLecturaEspecialidad' AND type = 'R')
BEGIN
    CREATE ROLE RolSoloLecturaEspecialidad;
END
GO

-- Conceder permisos selectivos sobre una tabla maestra específica
GRANT SELECT ON Especialidad TO RolSoloLecturaEspecialidad;

-- Vincular el rol personalizado al usuario de lectura
ALTER ROLE RolSoloLecturaEspecialidad ADD MEMBER UsuarioLectura;
GO

-------------------------------------------------------------------------
-- 5. PRUEBAS DE COMPORTAMIENTO (SIMULACIÓN DE IDENTIDAD)
-------------------------------------------------------------------------
-- Prueba de ejecución de procedimiento con usuario restringido (Éxito)
EXECUTE AS USER = 'UsuarioLectura';
EXEC sp_InsertarObraSocialPrueba @nombreOS = 'Swiss Medical Test';
REVERT;
GO
```

---

## 6. Conclusiones

1. **Garantía de Seguridad Granular:** El uso combinado de roles fijos (`db_datareader`, `db_owner`) y roles personalizados permite una administración ordenada y escalable de los privilegios dentro de la base de datos del proyecto.
2. **Protección de Datos mediante Encapsulamiento:** Otorgar permisos de ejecución (`GRANT EXECUTE`) en procedimientos almacenados a usuarios con perfiles restringidos posibilita realizar inserciones controladas sin comprometer la seguridad ni exponer las tablas base a modificaciones directas.
3. **Mitigación de Riesgos Operativos:** La correcta configuración de cuentas y esquemas de autenticación asegura que cada operador y rol cumpla estrictamente con sus funciones asignadas, resguardando la integridad y confidencialidad del **Sistema de Gestión de Turnos Médicos**.
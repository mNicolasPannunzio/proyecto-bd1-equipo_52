USE GuaraniTurnosMedicos;
GO

---------------------------------------------------------------------------------
-- PARTE 1: Creación de la tabla de pruebas adaptada al modelo de Turnos
---------------------------------------------------------------------------------
-- Se crea sin PRIMARY KEY inicial para evaluar primero el comportamiento sin índices (Table Scan)
CREATE TABLE TurnoHistorico (
    idTurno BIGINT IDENTITY(1,1),
    fechaTurno DATE NOT NULL,
    horaTurno TIME(0) NOT NULL,
    idMedico INT NOT NULL,
    idConsultorio INT NOT NULL,
    idEstado INT NOT NULL
);
GO

---------------------------------------------------------------------------------
-- PARTE 2: Carga masiva de datos (1.000.000 de turnos simulados)
---------------------------------------------------------------------------------
SET NOCOUNT ON;
GO

WITH Numeros AS (
    SELECT TOP (1000000)
        ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO TurnoHistorico (fechaTurno, horaTurno, idMedico, idConsultorio, idEstado)
SELECT
    -- Fechas aleatorias distribuidas en 5 años (1825 días desde 2020-01-01)
    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 1825, '2020-01-01') AS fechaTurno,
    -- Horas de atención aleatorias entre las 08:00 y las 18:00
    DATEADD(MINUTE, (ABS(CHECKSUM(NEWID())) % 20) * 30, CAST('08:00:00' AS TIME(0))) AS horaTurno,
    -- Médicos simulados (ID del 1 al 50)
    (ABS(CHECKSUM(NEWID())) % 50) + 1 AS idMedico,
    -- Consultorios simulados (ID del 1 al 15)
    (ABS(CHECKSUM(NEWID())) % 15) + 1 AS idConsultorio,
    -- Estados simulados (1: Pendiente, 2: Atendido, 3: Cancelado, 4: Ausente)
    (ABS(CHECKSUM(NEWID())) % 4) + 1 AS idEstado
FROM Numeros;
GO

SET NOCOUNT OFF;
GO

-- Verificar que se hayan insertado exactamente 1.000.000 de registros
SELECT COUNT(*) AS CantidadRegistros 
FROM TurnoHistorico;
GO

---------------------------------------------------------------------------------
-- PARTE 3: Escenario 1 - Consulta SIN índices
-- (Recordá activar Ctrl + M "Incluir plan de ejecución real" antes de ejecutar)
---------------------------------------------------------------------------------
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

SELECT 
    idTurno,
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO
-- >> ANOTAR DE LA PESTAÑA "MENSAJES": logical reads, CPU time y elapsed time.
-- >> OBSERVAR EN PESTAÑA "PLAN DE EJECUCIÓN": Operador "Table Scan".


---------------------------------------------------------------------------------
-- PARTE 4: Escenario 2 - Crear Índice Agrupado (CLUSTERED INDEX) sobre fechaTurno
---------------------------------------------------------------------------------
CREATE CLUSTERED INDEX IX_TurnoHistorico_Fecha
ON TurnoHistorico (fechaTurno);
GO

-- Repetir la misma consulta para medir la mejora
SELECT 
    idTurno,
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO
-- >> ANOTAR DE LA PESTAÑA "MENSAJES": logical reads, CPU time y elapsed time.
-- >> OBSERVAR EN PESTAÑA "PLAN DE EJECUCIÓN": Cambia de "Table Scan" a "Clustered Index Seek".


---------------------------------------------------------------------------------
-- PARTE 5: Eliminar el índice agrupado para preparar la siguiente prueba
---------------------------------------------------------------------------------
DROP INDEX IX_TurnoHistorico_Fecha 
ON TurnoHistorico;
GO


---------------------------------------------------------------------------------
-- PARTE 6: Escenario 3 - Crear Índice No Agrupado con Cobertura (INCLUDE)
---------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_TurnoHistorico_Fecha_Cobertura
ON TurnoHistorico (fechaTurno)
INCLUDE (horaTurno, idMedico);
GO

-- Ejecutar la consulta cubierta por el índice
SELECT 
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO
-- >> ANOTAR DE LA PESTAÑA "MENSAJES": logical reads (¡vas a ver que baja todavía más!), CPU time y elapsed time.
-- >> OBSERVAR EN PESTAÑA "PLAN DE EJECUCIÓN": Operador "Index Seek (NonClustered)".

-- Desactivar estadísticas al finalizar las pruebas
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
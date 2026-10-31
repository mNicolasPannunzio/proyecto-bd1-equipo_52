-- Activar estadísticas de rendimiento para capturar lecturas y tiempos
SET STATISTICS TIME ON;
SET STATISTICS IO ON;
GO

---------------------------------------------------------------------------------
-- EVIDENCIA 1: Consulta SIN ÍNDICES (Genera Table Scan y alto costo)
---------------------------------------------------------------------------------
SELECT 
    idTurno,
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO

---------------------------------------------------------------------------------
-- EVIDENCIA 2: Creación y prueba con Índice Agrupado (Genera Clustered Index Seek)
---------------------------------------------------------------------------------
CREATE CLUSTERED INDEX IX_TurnoHistorico_Fecha
ON TurnoHistorico (fechaTurno);
GO

SELECT 
    idTurno,
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO

-- Limpiar índice para la siguiente prueba
DROP INDEX IX_TurnoHistorico_Fecha ON TurnoHistorico;
GO

---------------------------------------------------------------------------------
-- EVIDENCIA 3: Creación y prueba con Índice de Cobertura INCLUDE (Genera Index Seek óptimo)
---------------------------------------------------------------------------------
CREATE NONCLUSTERED INDEX IX_TurnoHistorico_Fecha_Cobertura
ON TurnoHistorico (fechaTurno)
INCLUDE (horaTurno, idMedico);
GO

SELECT 
    fechaTurno,
    horaTurno,
    idMedico
FROM TurnoHistorico
WHERE fechaTurno BETWEEN '2023-01-01' AND '2023-03-31';
GO

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;
GO
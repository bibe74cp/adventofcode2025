-- init/setup.sql

-- Create DB AdventOfCode2025 with a SIMPLE recovery model, then a schema named 'input'
IF DB_ID(N'AdventOfCode2025') IS NULL
BEGIN
    CREATE DATABASE AdventOfCode2025;
END
GO

ALTER DATABASE AdventOfCode2025 SET RECOVERY SIMPLE;
GO

USE AdventOfCode2025;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'input')
BEGIN
    CREATE SCHEMA input;
END
GO

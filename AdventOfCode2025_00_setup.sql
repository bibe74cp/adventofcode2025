USE [master]
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AdventOfCode2025')
BEGIN

CREATE DATABASE [AdventOfCode2025] CONTAINMENT = NONE
ON PRIMARY
       (
       NAME = N'AdventOfCode2025',
       FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventOfCode2025.mdf',
       SIZE = 65536KB,
       FILEGROWTH = 65536KB
   )
LOG ON
    (
    NAME = N'AdventOfCode2025_log',
    FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\AdventOfCode2025_log.ldf',
    SIZE = 65536KB,
    FILEGROWTH = 65536KB
)
WITH LEDGER=OFF;

END
GO

USE AdventOfCode2025;
GO

IF SCHEMA_ID('input') IS NULL EXEC('CREATE SCHEMA input AUTHORIZATION dbo;');
GO

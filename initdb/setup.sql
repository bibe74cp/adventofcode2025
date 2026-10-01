-- Setup script for AdventOfCode2025 database

-- Create database if it doesn't exist
IF DB_ID(N'AdventOfCode2025') IS NULL
BEGIN
    CREATE DATABASE AdventOfCode2025;
END
GO

-- Set recovery model to SIMPLE
ALTER DATABASE AdventOfCode2025 SET RECOVERY SIMPLE;
GO

-- Use the database
USE AdventOfCode2025;
GO

-- Create input schema if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'input')
BEGIN
    CREATE SCHEMA [input];
END
GO

-- Verify setup
SELECT 'Database: ' + @@SERVERNAME AS server,
       DB_NAME() AS database_name,
       (SELECT COUNT(*) FROM sys.schemas WHERE name = 'input') AS input_schema_exists;
GO

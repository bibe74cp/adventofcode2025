USE [master]
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'AdventOfCode2025') CREATE DATABASE [AdventOfCode2025];
GO

USE AdventOfCode2025;
GO

IF SCHEMA_ID('input') IS NULL EXEC('CREATE SCHEMA input AUTHORIZATION dbo;');
GO

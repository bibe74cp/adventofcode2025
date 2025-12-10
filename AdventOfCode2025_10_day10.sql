USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* Day 10 (https://adventofcode.com/2025/day/10): BEGIN */

DROP TABLE IF EXISTS input.day10;
GO

IF OBJECT_ID('input.day10', 'U') IS NULL
BEGIN

	CREATE TABLE input.day10 (
		line VARCHAR(MAX) NOT NULL
	);

	--/*
	BULK INSERT input.day10 FROM '/var/aoc/sample_D10P1.txt';
	--*/ BULK INSERT input.day10 FROM '/var/aoc/input_D10P1.txt';

	ALTER TABLE input.day10 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day10_diagrams; DROP TABLE IF EXISTS dbo.day10_wirings;
GO

WITH Splits
AS (
	SELECT
		I.line,
		I.line_id,
		SS.value,
		CONVERT(BIT, CASE WHEN CHARINDEX('[', SS.value) = 1 THEN 1 ELSE 0 END) AS IsDiagram,
		CONVERT(BIT, CASE WHEN CHARINDEX('(', SS.value) = 1 THEN 1 ELSE 0 END) AS IsWiring,
		CONVERT(BIT, CASE WHEN CHARINDEX('{', SS.value) = 1 THEN 1 ELSE 0 END) AS IsRequirement

	FROM input.day10 I
	CROSS APPLY STRING_SPLIT(I.line, ' ') SS
)
SELECT
    DS.line_id,
	DS.line,
    DS.value AS diagram,
	RS.value AS requirement

INTO dbo.day10_diagrams

FROM Splits DS
INNER JOIN Splits RS ON RS.line_id = DS.line_id
	AND RS.IsRequirement = CAST(1 AS BIT)
WHERE DS.IsDiagram = CAST(1 AS BIT);
GO

WITH Splits
AS (
	SELECT
		I.line,
		I.line_id,
		SS.value,
		CONVERT(BIT, CASE WHEN CHARINDEX('[', SS.value) = 1 THEN 1 ELSE 0 END) AS IsDiagram,
		CONVERT(BIT, CASE WHEN CHARINDEX('(', SS.value) = 1 THEN 1 ELSE 0 END) AS IsWiring,
		CONVERT(BIT, CASE WHEN CHARINDEX('{', SS.value) = 1 THEN 1 ELSE 0 END) AS IsRequirement

	FROM input.day10 I
	CROSS APPLY STRING_SPLIT(I.line, ' ') SS
)
SELECT
    WS.line_id,
	ROW_NUMBER() OVER (PARTITION BY WS.line_id ORDER BY (SELECT 1)) AS wiring_id,
    WS.value AS wiring

INTO dbo.day10_wirings

FROM Splits WS
WHERE WS.IsWiring = CAST(1 AS BIT);
GO

SELECT * FROM dbo.day10_diagrams;
SELECT * FROM dbo.day10_wirings;
GO

/* Day 10: END */

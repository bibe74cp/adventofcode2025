USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 4: Printing Department --- (https://adventofcode.com/2025/day/4): BEGIN */ -- 4'01", one extra table

DROP TABLE IF EXISTS input.day04;
GO

IF OBJECT_ID('input.day04', 'U') IS NULL
BEGIN

	CREATE TABLE input.day04 (
		line NVARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day04 FROM '/var/aoc/sample_D04P1.txt';
	--*/ BULK INSERT input.day04 FROM '/var/aoc/input_D04P1.txt';

	ALTER TABLE input.day04 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day04_clone;
GO

SELECT * INTO dbo.day04_clone FROM input.day04;
GO

CREATE OR ALTER FUNCTION dbo.usp_D04_CheckRoll (@line NVARCHAR(200), @position SMALLINT)
RETURNS INT
AS
BEGIN

	RETURN CASE WHEN SUBSTRING(@line, @position, 1) = N'@' THEN 1 ELSE 0 END;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D04_CountRolls (@line NVARCHAR(200), @position SMALLINT)
RETURNS INT
AS
BEGIN

	DECLARE @rollCount INT;

	WITH Slots
	AS (
		SELECT
			@position + GS.value AS position

		FROM GENERATE_SERIES(-1, 1, 1) GS
	)
	SELECT @rollCount = SUM(dbo.usp_D04_CheckRoll(@line, S.position))

	FROM Slots S
	WHERE S.position BETWEEN 1 AND LEN(@line);

	RETURN @rollCount;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D04_CountAdjacentRolls (@line_id INT, @position SMALLINT)
RETURNS INT
AS
BEGIN
	
	DECLARE @rollCount INT;

	WITH Lines
	AS (
		SELECT
			@line_id + GS.value AS line_id

		FROM GENERATE_SERIES(-1, 1, 1) GS
	)
	SELECT
		@rollCount = SUM(
			dbo.usp_D04_CountRolls(I.line, @position)
			- CASE WHEN I.line_id = @line_id AND SUBSTRING(I.line, @position, 1) = N'@' THEN 1 ELSE 0 END
		)

	FROM Lines L
	INNER JOIN dbo.day04_clone I ON I.line_id = L.line_id;

	RETURN @rollCount;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D04_CheckRollAvailability (@line_id INT, @position SMALLINT)
RETURNS INT
AS
BEGIN

	DECLARE @line NVARCHAR(200),
		@adjacentRolls INT;

	SELECT
		@line = line

	FROM dbo.day04_clone I
	WHERE I.line_id = @line_id;

	IF SUBSTRING(@line, @position, 1) <> N'@' RETURN 0;

	SELECT @adjacentRolls = dbo.usp_D04_CountAdjacentRolls(@line_id, @position);

	RETURN CASE WHEN @adjacentRolls < 4 THEN 1 ELSE 0 END;

END;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;

WITH Cols
AS (
	SELECT
		GS.value AS col

	FROM GENERATE_SERIES(1, 136, 1) GS
)
SELECT
	SUM(dbo.usp_D04_CheckRollAvailability(I.line_id, C.col)) AS response1

FROM dbo.day04_clone I,
	Cols C;
GO

CREATE OR ALTER PROCEDURE dbo.usp_D04_RemoveAvailableRolls (
	@rollsRemoved INT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #D04_Rolls;

	WITH Cols
	AS (
		SELECT
			GS.value AS col

		FROM GENERATE_SERIES(1, 136, 1) GS
	)
	SELECT
		I.line_id,
		C.col,
		SUBSTRING(I.line, C.col, 1) AS slotContent

	INTO #D04_Rolls

	FROM dbo.day04_clone I,
		Cols C;

	DROP TABLE IF EXISTS #D04_RollsToRemove;

	SELECT
		R.line_id,
        R.col,
		'.' AS slotContent

	INTO #D04_RollsToRemove

	FROM #D04_Rolls R
	WHERE R.slotContent = '@'
		AND dbo.usp_D04_CheckRollAvailability(R.line_id, R.col) = 1;

	SELECT
		@rollsRemoved = COUNT(1)

	FROM #D04_RollsToRemove RTR;

	TRUNCATE TABLE dbo.day04_clone;

	SET IDENTITY_INSERT dbo.day04_clone ON;

	WITH NewRolls
	AS (
		SELECT
			R.line_id,
			R.col,
			COALESCE(RTR.slotContent, R.slotContent) AS slotContent

		FROM #D04_Rolls R
		LEFT JOIN #D04_RollsToRemove RTR ON RTR.line_id = R.line_id AND RTR.col = R.col
	)
	INSERT INTO dbo.day04_clone (
		line_id,
	    line
	)
	SELECT
		NR.line_id,
		STRING_AGG(CAST(NR.slotContent AS VARCHAR(1)), '')
			WITHIN GROUP (ORDER BY NR.col) AS line

	FROM NewRolls NR
	GROUP BY NR.line_id
	ORDER BY NR.line_id;

	SET IDENTITY_INSERT dbo.day04_clone OFF;

END;
GO

SET STATISTICS IO, TIME OFF;

SET NOCOUNT ON;

DROP TABLE IF EXISTS dbo.day04_clone;
GO

SELECT * INTO dbo.day04_clone FROM input.day04;
GO

DECLARE @iteration INT = 0,
	@rollsRemoved INT = -1,
	@rollsRemovedTotal INT = 0,
	@totalRolls INT;

SELECT @totalRolls = SUM(REGEXP_COUNT(line, '@')) FROM dbo.day04_clone;

WHILE (@rollsRemoved <> 0)
BEGIN

	EXEC dbo.usp_D04_RemoveAvailableRolls @rollsRemoved = @rollsRemoved OUTPUT;

	SELECT @iteration = @iteration + 1,
		@rollsRemovedTotal = @rollsRemovedTotal + @rollsRemoved

	RAISERROR ('Iteration %d: %d rolls out of %d removed. Total rolls removed: %d', 0, 1, @iteration, @rollsRemoved, @totalRolls, @rollsRemovedTotal) WITH NOWAIT;

	SELECT @totalRolls = SUM(REGEXP_COUNT(line, '@')) FROM dbo.day04_clone;

END;

SELECT @rollsRemovedTotal AS response2;
GO

/* Day 4: END */

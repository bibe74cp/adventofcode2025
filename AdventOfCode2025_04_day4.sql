USE AdventOfCode2025;
GO

/* Day 4: BEGIN */

DROP TABLE IF EXISTS input.day04;
GO

IF OBJECT_ID('input.day04', 'U') IS NULL
BEGIN

	CREATE TABLE input.day04 (
		line NVARCHAR(150) NOT NULL
	);

	BULK INSERT input.day04 FROM '/var/aoc/input_D04P1.txt';

	ALTER TABLE input.day04 ADD PK INT NOT NULL IDENTITY (1, 1);

	DROP TABLE IF EXISTS input.day04_backup;

	SELECT * INTO input.day04_backup FROM input.day04;

END;
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

CREATE OR ALTER FUNCTION dbo.usp_D04_CountAdjacentRolls (@linePK INT, @position SMALLINT)
RETURNS INT
AS
BEGIN
	
	DECLARE @rollCount INT;

	WITH Lines
	AS (
		SELECT
			@linePK + GS.value AS linePK

		FROM GENERATE_SERIES(-1, 1, 1) GS
	)
	SELECT
		@rollCount = SUM(
			dbo.usp_D04_CountRolls(I.line, @position)
			- CASE WHEN I.PK = @linePK AND SUBSTRING(I.line, @position, 1) = N'@' THEN 1 ELSE 0 END
		)

	FROM Lines L
	INNER JOIN input.day04 I ON I.PK = L.linePK;

	RETURN @rollCount;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D04_CheckRollAvailability (@linePK INT, @position SMALLINT)
RETURNS INT
AS
BEGIN

	DECLARE @line NVARCHAR(200),
		@adjacentRolls INT;

	SELECT
		@line = line

	FROM input.day04 I
	WHERE I.PK = @linePK;

	IF SUBSTRING(@line, @position, 1) <> N'@' RETURN 0;

	SELECT @adjacentRolls = dbo.usp_D04_CountAdjacentRolls(@linePK, @position);

	RETURN CASE WHEN @adjacentRolls < 4 THEN 1 ELSE 0 END;

END;
GO

SET STATISTICS IO, TIME ON;

WITH Cols
AS (
	SELECT
		GS.value AS col

	FROM GENERATE_SERIES(1, 136, 1) GS
)
SELECT
	SUM(dbo.usp_D04_CheckRollAvailability(I.PK, C.col)) AS response1

FROM input.day04 I,
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
		I.PK AS linePK,
		C.col,
		SUBSTRING(I.line, C.col, 1) AS slotContent

	INTO #D04_Rolls

	FROM input.day04 I,
		Cols C;

	DROP TABLE IF EXISTS #D04_RollsToRemove;

	SELECT
		R.linePK,
        R.col,
		'.' AS slotContent

	INTO #D04_RollsToRemove

	FROM #D04_Rolls R
	WHERE R.slotContent = '@'
		AND dbo.usp_D04_CheckRollAvailability(R.linePK, R.col) = 1;

	SELECT
		@rollsRemoved = COUNT(1)

	FROM #D04_RollsToRemove RTR;

	TRUNCATE TABLE input.day04;

	SET IDENTITY_INSERT input.day04 ON;

	WITH NewRolls
	AS (
		SELECT
			R.linePK,
			R.col,
			COALESCE(RTR.slotContent, R.slotContent) AS slotContent

		FROM #D04_Rolls R
		LEFT JOIN #D04_RollsToRemove RTR ON RTR.linePK = R.linePK AND RTR.col = R.col
	)
	INSERT INTO input.day04 (
		PK,
	    line
	)
	SELECT
		NR.linePK AS PK,
		STRING_AGG(CAST(NR.slotContent AS VARCHAR(1)), '')
			WITHIN GROUP (ORDER BY NR.col) AS line

	FROM NewRolls NR
	GROUP BY NR.linePK
	ORDER BY NR.linePK;

	SET IDENTITY_INSERT input.day04 OFF;

END;
GO

SET STATISTICS IO, TIME OFF;

SET NOCOUNT ON;

DROP TABLE IF EXISTS input.day04;
GO

SELECT * INTO input.day04 FROM input.day04_backup;
GO

DECLARE @iteration INT = 0,
	@rollsRemoved INT = -1,
	@rollsRemovedTotal INT = 0,
	@totalRolls INT;

SELECT @totalRolls = SUM(REGEXP_COUNT(line, '@')) FROM input.day04;

WHILE (@rollsRemoved <> 0)
BEGIN

	EXEC dbo.usp_D04_RemoveAvailableRolls @rollsRemoved = @rollsRemoved OUTPUT;

	SELECT @iteration = @iteration + 1,
		@rollsRemovedTotal = @rollsRemovedTotal + @rollsRemoved

	RAISERROR ('Iteration %d: %d rolls out of %d removed. Total rolls removed: %d', 0, 1, @iteration, @rollsRemoved, @totalRolls, @rollsRemovedTotal) WITH NOWAIT;

	SELECT @totalRolls = SUM(REGEXP_COUNT(line, '@')) FROM input.day04;

END;

SELECT @rollsRemovedTotal AS response2;
GO

DROP TABLE IF EXISTS input.day04;
GO

SELECT * INTO input.day04 FROM input.day04_backup;
GO

/* Day 4: END */

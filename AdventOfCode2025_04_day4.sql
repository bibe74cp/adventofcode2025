USE AdventOfCode2025;
GO

/* Day 4: BEGIN */

/* Import flat file input.txt into table input.D04P1, then:

ALTER TABLE input.D04P1 ADD PK INT NOT NULL IDENTITY (1, 1);
GO

*/
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
			dbo.usp_D04_CountRolls(I.roll_line, @position)
			- CASE WHEN I.PK = @linePK AND SUBSTRING(I.roll_line, @position, 1) = N'@' THEN 1 ELSE 0 END
		)

	FROM Lines L
	INNER JOIN input.D04P1 I ON I.PK = L.linePK;

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
		@line = roll_line

	FROM input.D04P1 I
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

FROM input.D04P1 I,
	Cols C;
GO

-- OK fin qui

DROP TABLE IF EXISTS dbo.D04_Rolls;
GO

WITH Cols
AS (
	SELECT
		GS.value AS col

	FROM GENERATE_SERIES(1, 136, 1) GS
)
SELECT
	I.PK AS linePK,
	C.col,
	SUBSTRING(I.roll_line, C.col, 1) AS slotContent

INTO dbo.D04_Rolls

FROM input.D04P1 I,
	Cols C;
GO

CREATE OR ALTER PROCEDURE dbo.usp_D04_RemoveAvailableRolls (
	@rollsRemoved INT OUTPUT,
	@rollCount INT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #D04_Rolls;

	SELECT * INTO #D04_Rolls FROM dbo.D04_Rolls;

END;
GO

/* Day 4: END */

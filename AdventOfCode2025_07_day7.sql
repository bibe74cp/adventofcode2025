USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* Day 7: BEGIN */

DROP TABLE IF EXISTS input.day07;
GO

IF OBJECT_ID('input.day07', 'U') IS NULL
BEGIN

	CREATE TABLE input.day07 (
		line NVARCHAR(142) NOT NULL
	);

	/*
	BULK INSERT input.day07 FROM '/var/aoc/sample_D07P1.txt';
	--*/ BULK INSERT input.day07 FROM '/var/aoc/input_D07P1.txt';

	ALTER TABLE input.day07 ADD PK INT NOT NULL IDENTITY (1, 1);

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D07_SplitLine (
	@input_line NVARCHAR(142)
)
RETURNS @ret TABLE (
	position INT,
	content NVARCHAR(1)
)
AS
BEGIN

	WITH Positions
	AS (
		SELECT
			GS.value AS position

		FROM GENERATE_SERIES(1, LEN(@input_line), 1) GS
	)
	INSERT INTO @ret (
		position,
	    content
	)
	SELECT
		P.position,
		SUBSTRING(@input_line, P.position, 1) AS content

	FROM Positions P;

	RETURN;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D07_ProcessLine (
	@input_line NVARCHAR(142),
	@line_id BIGINT
)
RETURNS @ret TABLE (
	processed_line NVARCHAR(142),
	splits_count BIGINT
)
AS
BEGIN

	DECLARE @splits BIGINT;

	WITH Input
	AS (
		SELECT
			SL.position,
			SL.content

		FROM dbo.usp_D07_SplitLine(@input_line) SL
	),
	Operator
	AS (
		SELECT
			SL.position,
			SL.content

		FROM input.day07 I
		CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
		WHERE I.PK = @line_id
	)
	SELECT
		@splits = COUNT(1)

	FROM Input I
	INNER JOIN Operator O ON O.position = I.position
	WHERE I.content = N'|'
		AND O.content = N'^';

	WITH InputLine
	AS (
		SELECT
			SL.position,
			SL.content

		FROM dbo.usp_D07_SplitLine(@input_line) SL
	),
	Operator
	AS (
		SELECT
			SL.position,
			SL.content

		FROM input.day07 I
		CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
		WHERE I.PK = @line_id
	),
	Splits
	AS (
		SELECT -1 AS offset
		UNION ALL SELECT 1 AS offset
	),
	OutputBeams
	AS (
		SELECT
			I.position

		FROM InputLine I
		INNER JOIN Operator O ON O.position = I.position
		WHERE I.content = '|'
			AND O.content = '.'

		UNION ALL

		SELECT
			I.position + S.offset

		FROM InputLine I
		INNER JOIN Operator O ON O.position = I.position
		CROSS JOIN Splits S
		WHERE I.content = '|'
			AND O.content = '^'
	),
	OutputLine
	AS (
		SELECT DISTINCT
			IL.position,
			CASE WHEN OB.position IS NULL THEN '.' ELSE '|' END AS content

		FROM InputLine IL
		LEFT JOIN OutputBeams OB ON OB.position = IL.position
	)
	INSERT INTO @ret (
	    processed_line,
		splits_count
	)
	SELECT
		STRING_AGG(OL.content, '') WITHIN GROUP (ORDER BY OL.position),
		@splits
		
	FROM OutputLine OL;

	RETURN;

END;
GO

WITH Tree
AS (
	SELECT
		I.PK AS line_id,
		I.line,
		CONVERT(NVARCHAR(142), REPLACE(I.line, 'S', '|')) AS processed_line,
		CONVERT(BIGINT, 0) AS splits_count
		
	FROM input.day07 I
	WHERE I.PK = 1

	UNION ALL

	SELECT
		I.PK,
		I.line,
		PL.processed_line,
		PL.splits_count

	FROM Tree T
	INNER JOIN input.day07 I ON I.PK = T.line_id + 1
	CROSS APPLY dbo.usp_D07_ProcessLine(T.processed_line, I.PK) PL
)
SELECT
	SUM(T.splits_count) AS response1

FROM Tree T
OPTION (MAXRECURSION 5000);
GO

DROP TABLE IF EXISTS dbo.day07_positions;
GO

SELECT
	SL.position,
    CAST(CASE WHEN SL.content = N'S' THEN 1 ELSE 0 END AS BIGINT) AS paths_count

INTO dbo.day07_positions

FROM input.day07 I
CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
WHERE I.PK = 1;
GO

/* declare variables */
DECLARE @line_id INT

DECLARE curLines CURSOR FAST_FORWARD READ_ONLY FOR SELECT I.PK FROM input.day07 I ORDER BY PK

OPEN curLines

FETCH NEXT FROM curLines INTO @line_id

WHILE @@FETCH_STATUS = 0
BEGIN
    
	WITH Operator
	AS (
		SELECT
			SL.position,
			SL.content

		FROM input.day07 I
		CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
		WHERE I.PK = @line_id
	),
	Splits
	AS (
		SELECT -1 AS offset
		UNION ALL SELECT 1 AS offset
	),
	OutputPathsDetail
	AS (
		SELECT
			P.position,
			CASE WHEN O.content = '^' THEN 0 ELSE P.paths_count END AS paths_count

		FROM dbo.day07_positions P
		INNER JOIN Operator O ON O.position = P.position

		UNION ALL

		SELECT
			P.position + S.offset,
			P.paths_count

		FROM dbo.day07_positions P
		INNER JOIN Operator O ON O.position = P.position
		CROSS JOIN Splits S
		WHERE O.content = N'^'
	),
	OutputPaths
	AS (
		SELECT
			OPD.position,
			SUM(OPD.paths_count) AS paths_count

		FROM OutputPathsDetail OPD
		GROUP BY OPD.position
	)
	UPDATE P
	SET P.paths_count = OP.paths_count

	FROM dbo.day07_positions P
	INNER JOIN OutputPaths OP ON OP.position = P.position;

    FETCH NEXT FROM curLines INTO @line_id
END

CLOSE curLines
DEALLOCATE curLines;
GO

SELECT SUM(P.paths_count) AS response2
FROM dbo.day07_positions P;
GO

/* Day 7: END */

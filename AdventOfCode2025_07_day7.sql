USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 7: Laboratories --- (https://adventofcode.com/2025/day/7): BEGIN */ -- 5", one extra table

DROP TABLE IF EXISTS input.day07;
GO

IF OBJECT_ID('input.day07', 'U') IS NULL
BEGIN

	CREATE TABLE input.day07 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day07 FROM '/var/aoc/sample_D07P1.txt';
	--*/ BULK INSERT input.day07 FROM '/var/aoc/input_D07P1.txt';

	ALTER TABLE input.day07 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D07_SplitLine (
	@input_line VARCHAR(MAX)
)
RETURNS @ret TABLE (
	position INT,
	content VARCHAR(1)
)
AS
BEGIN

	WITH Cols
	AS (
		SELECT
			1 AS position,
			SUBSTRING(@input_line, 1, 1) AS content

		UNION ALL

		SELECT
			C.position + 1,
			SUBSTRING(@input_line, C.position + 1, 1)

		FROM Cols C
		WHERE C.position < LEN(@input_line)
	)
	INSERT INTO @ret (
	    position,
	    content
	)
	SELECT
		C.position,
        C.content

	FROM Cols C
	OPTION (MAXRECURSION 0);

	RETURN;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D07_ProcessLine (
	@input_line VARCHAR(MAX),
	@line_id BIGINT
)
RETURNS @ret TABLE (
	processed_line VARCHAR(MAX),
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
		WHERE I.line_id = @line_id
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
		WHERE I.line_id = @line_id
	),
	Splits
	AS (
		SELECT -1 AS offset
		UNION ALL SELECT 1 AS offset
	),
	OutputBeams
	AS (
		SELECT
			I.position,
			0 AS splits_count

		FROM InputLine I
		INNER JOIN Operator O ON O.position = I.position
		WHERE I.content = '|'
			AND O.content = '.'

		UNION ALL

		SELECT
			I.position + S.offset,
			1

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

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;
GO

WITH Tree
AS (
	SELECT
		I.line_id,
		I.line,
		CONVERT(VARCHAR(MAX), REPLACE(I.line, 'S', '|')) AS processed_line,
		CONVERT(BIGINT, 0) AS splits_count
		
	FROM input.day07 I
	WHERE I.line_id = 1

	UNION ALL

	SELECT
		I.line_id,
		I.line,
		PL.processed_line,
		PL.splits_count

	FROM Tree T
	INNER JOIN input.day07 I ON I.line_id = T.line_id + 1
	CROSS APPLY dbo.usp_D07_ProcessLine(T.processed_line, I.line_id) PL
)
/*
SELECT T.processed_line
FROM Tree T
ORDER BY T.line_id
OPTION (MAXRECURSION 5000);
*/
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
WHERE I.line_id = 1;
GO

DECLARE @line_id INT

DECLARE curLines CURSOR FAST_FORWARD READ_ONLY FOR SELECT I.line_id FROM input.day07 I ORDER BY line_id

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
		WHERE I.line_id = @line_id
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

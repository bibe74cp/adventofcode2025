USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* Day 11 (https://adventofcode.com/2025/day/11): BEGIN */

DROP TABLE IF EXISTS input.day11;
GO

IF OBJECT_ID('input.day11', 'U') IS NULL
BEGIN

	CREATE TABLE input.day11 (
		line VARCHAR(MAX) NOT NULL
	);

	--/*
	BULK INSERT input.day11 FROM '/var/aoc/sample_D11P1.txt';
	--*/ BULK INSERT input.day11 FROM '/var/aoc/input_D11P1.txt';

	ALTER TABLE input.day11 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day11_connections;
GO

WITH InputData
AS (
	SELECT
		I.line_id,
		I.line,
		SS.value,
		ROW_NUMBER() OVER (PARTITION BY I.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day11 I
	CROSS APPLY STRING_SPLIT(I.line, ':') SS
)
SELECT
    ID1.value AS node_from,
	SS.value AS node_to

INTO dbo.day11_connections

FROM InputData ID1
INNER JOIN InputData ID2 ON ID2.line_id = ID1.line_id
	AND ID2.rn = 2
CROSS APPLY STRING_SPLIT(ID2.value, ' ') AS SS
WHERE ID1.rn = 1
	AND SS.value <> '';
GO

DROP TABLE IF EXISTS dbo.day11_full_paths;
GO

SELECT
    CONVERT(VARCHAR(MAX), ',' || C.node_from || ',') AS node_list,
    C.node_from,
    C.node_to

INTO dbo.day11_full_paths

FROM dbo.day11_connections C
WHERE C.node_from = 'you';
GO

WHILE (1 = 1)
BEGIN

	WITH NewConnections
	AS (
		SELECT
			FP.node_list || C.node_to || ',' AS node_list,
			FP.node_from,
			C.node_to

		FROM dbo.day11_full_paths FP
		INNER JOIN dbo.day11_connections C ON C.node_from = FP.node_to
		WHERE CHARINDEX(',' || C.node_to || ',', FP.node_list) = 0
	)
	INSERT INTO dbo.day11_full_paths (
	    node_list,
	    node_from,
	    node_to
	)
	SELECT
		NC.node_list,
        NC.node_from,
        NC.node_to
	
	FROM NewConnections NC
	LEFT JOIN dbo.day11_full_paths FP ON FP.node_list = NC.node_list
	WHERE FP.node_list IS NULL;

	IF (@@ROWCOUNT = 0) BREAK;

END;
GO

SELECT
	COUNT(1) AS response1

FROM dbo.day11_full_paths WHERE node_to = 'out';
GO

DROP TABLE IF EXISTS input.day11;
GO

IF OBJECT_ID('input.day11', 'U') IS NULL
BEGIN

	CREATE TABLE input.day11 (
		line VARCHAR(MAX) NOT NULL
	);

	--/*
	BULK INSERT input.day11 FROM '/var/aoc/sample_D11P1.txt';
	--BULK INSERT input.day11 FROM '/var/aoc/sample_D11P2.txt';
	--*/ BULK INSERT input.day11 FROM '/var/aoc/input_D11P1.txt';

	ALTER TABLE input.day11 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day11_connections;
GO

WITH InputData
AS (
	SELECT
		I.line_id,
		I.line,
		SS.value,
		ROW_NUMBER() OVER (PARTITION BY I.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day11 I
	CROSS APPLY STRING_SPLIT(I.line, ':') SS
)
SELECT
    ID1.value AS node_from,
	SS.value AS node_to

INTO dbo.day11_connections

FROM InputData ID1
INNER JOIN InputData ID2 ON ID2.line_id = ID1.line_id
	AND ID2.rn = 2
CROSS APPLY STRING_SPLIT(ID2.value, ' ') AS SS
WHERE ID1.rn = 1
	AND SS.value <> '';
GO

DROP TABLE IF EXISTS dbo.day11_full_paths;
GO

DECLARE @node_from VARCHAR(3) = 'svr',
	@node_to VARCHAR(3) = 'out';

SELECT
	CONVERT(VARCHAR(MAX), ',' || C.node_from || ',' || C.node_to || ',') AS node_list,
	C.node_from,
	C.node_to,
	2 AS depth,
	CAST(0 AS BIT) AS contains_dac,
	CAST(0 AS BIT) AS contains_fft

INTO dbo.day11_full_paths

FROM dbo.day11_connections C
WHERE C.node_from = @node_from;

DECLARE @nest_level INT = 2;

WHILE (1 = 1)
BEGIN

	INSERT INTO dbo.day11_full_paths (
	    node_list,
	    node_from,
	    node_to,
	    depth,
	    contains_dac,
	    contains_fft
	)
	SELECT
		PT.node_list || C.node_to || ',',
		PT.node_from,
		C.node_to,
		PT.depth + 1,
		CAST(CASE WHEN PT.contains_dac = CAST(1 AS BIT) OR C.node_to = 'dac' THEN 1 ELSE 0 END AS BIT),
		CAST(CASE WHEN PT.contains_fft = CAST(1 AS BIT) OR C.node_to = 'fft' THEN 1 ELSE 0 END AS BIT)

	FROM dbo.day11_full_paths PT
	INNER JOIN dbo.day11_connections C ON C.node_from = PT.node_to
	WHERE CHARINDEX(',' || C.node_to || ',', PT.node_list) = 0
		AND NOT PT.node_from = @node_to
		AND (
			C.node_to <> @node_to
			OR (
				(PT.contains_dac = CAST(1 AS BIT) OR C.node_to = 'dac')
				AND (PT.contains_fft = CAST(1 AS BIT) OR C.node_to = 'fft')
			)
		);

	IF (@@ROWCOUNT = 0) BREAK;

	RAISERROR('Nest level #%d: %d record(s) inserted', 0, 1, @nest_level, @@ROWCOUNT) WITH NOWAIT;

	SELECT @nest_level = @nest_level + 1;

END;
GO

/* Day 11: END */

	WITH NewConnections
	AS (
		SELECT
			FP.node_list || C.node_to || ',' AS node_list,
			FP.node_from,
			C.node_to

		FROM dbo.day11_full_paths FP
		INNER JOIN dbo.day11_connections C ON C.node_from = FP.node_to
		WHERE CHARINDEX(',' || C.node_to || ',', FP.node_list) = 0
			AND FP.depth = @nest_level
			AND FP.node_from NOT IN ('out')
	)
	INSERT INTO dbo.day11_full_paths (
	    node_list,
	    node_from,
	    node_to,
		nest_level
	)
	SELECT
		NC.node_list,
        NC.node_from,
        NC.node_to,
		@nest_level + 1
	
	FROM NewConnections NC
	LEFT JOIN dbo.day11_full_paths FP ON FP.node_list = NC.node_list
	WHERE FP.node_list IS NULL;

	-- Delete unusable paths
	DELETE FROM dbo.day11_full_paths
	WHERE node_to = 'out'
		AND NOT (
			CHARINDEX(',dac,', node_list) > 0
			AND CHARINDEX(',fft,', node_list) > 0
		);

	IF (@@ROWCOUNT = 0) BREAK;

	SELECT @nest_level = @nest_level + 1;

END;
GO





WITH PathsTree
AS (
	SELECT
		CONVERT(VARCHAR(MAX), ',' || C.node_from || ',' || C.node_to || ',') AS node_list,
		C.node_from,
		C.node_to,
		2 AS depth,
		CAST(0 AS BIT) AS contains_dac,
		CAST(0 AS BIT) AS contains_fft

	FROM dbo.day11_connections C
	WHERE C.node_from = @node_from

	UNION ALL

	SELECT
		PT.node_list || C.node_to || ',',
		PT.node_from,
		C.node_to,
		PT.depth + 1,
		CAST(CASE WHEN PT.contains_dac = CAST(1 AS BIT) OR C.node_to = 'dac' THEN 1 ELSE 0 END AS BIT),
		CAST(CASE WHEN PT.contains_fft = CAST(1 AS BIT) OR C.node_to = 'fft' THEN 1 ELSE 0 END AS BIT)

	FROM PathsTree PT
	INNER JOIN dbo.day11_connections C ON C.node_from = PT.node_to
	WHERE CHARINDEX(',' || C.node_to || ',', PT.node_list) = 0
		AND NOT PT.node_from = @node_to
		AND (
			C.node_to <> @node_to
			OR (
				(PT.contains_dac = CAST(1 AS BIT) OR C.node_to = 'dac')
				AND (PT.contains_fft = CAST(1 AS BIT) OR C.node_to = 'fft')
			)
		)
)
SELECT
	PT.node_list,
    PT.node_from,
    PT.node_to,
    PT.depth

INTO dbo.day11_full_paths

FROM PathsTree PT
WHERE PT.node_to = @node_to
OPTION (MAXRECURSION 0);
GO

DECLARE @nest_level INT = 1;

WHILE (1 = 1)
BEGIN

	WITH NewConnections
	AS (
		SELECT
			FP.node_list || C.node_to || ',' AS node_list,
			FP.node_from,
			C.node_to

		FROM dbo.day11_full_paths FP
		INNER JOIN dbo.day11_connections C ON C.node_from = FP.node_to
		WHERE CHARINDEX(',' || C.node_to || ',', FP.node_list) = 0
			AND FP.nest_level = @nest_level
			AND FP.node_from NOT IN ('out')
	)
	INSERT INTO dbo.day11_full_paths (
	    node_list,
	    node_from,
	    node_to,
		nest_level
	)
	SELECT
		NC.node_list,
        NC.node_from,
        NC.node_to,
		@nest_level + 1
	
	FROM NewConnections NC
	LEFT JOIN dbo.day11_full_paths FP ON FP.node_list = NC.node_list
	WHERE FP.node_list IS NULL;

	-- Delete unusable paths
	DELETE FROM dbo.day11_full_paths
	WHERE node_to = 'out'
		AND NOT (
			CHARINDEX(',dac,', node_list) > 0
			AND CHARINDEX(',fft,', node_list) > 0
		);

	IF (@@ROWCOUNT = 0) BREAK;

	SELECT @nest_level = @nest_level + 1;

END;
GO

SELECT
	COUNT(1) AS response2

FROM dbo.day11_full_paths FP
WHERE FP.node_to = 'out'
	AND CHARINDEX(',dac,', FP.node_list) > 0
	AND CHARINDEX(',fft,', FP.node_list) > 0;
GO

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

DROP TABLE IF EXISTS dbo.D11_connections;
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

INTO dbo.D11_connections

FROM InputData ID1
INNER JOIN InputData ID2 ON ID2.line_id = ID1.line_id
	AND ID2.rn = 2
CROSS APPLY STRING_SPLIT(ID2.value, ' ') AS SS
WHERE ID1.rn = 1
	AND SS.value <> '';
GO

DROP TABLE IF EXISTS dbo.D11_full_paths;
GO

SELECT
    CONVERT(VARCHAR(MAX), ',' || C.node_from || ',') AS node_list,
    C.node_from,
    C.node_to

INTO dbo.D11_full_paths

FROM dbo.D11_connections C
WHERE C.node_from = 'you';
GO

SELECT * FROM dbo.D11_full_paths;
GO

WHILE (1 = 1)
BEGIN

	WITH NewConnections
	AS (
		SELECT
			FP.node_list || C.node_to || ',' AS node_list,
			FP.node_from,
			C.node_to

		FROM dbo.D11_full_paths FP
		INNER JOIN dbo.D11_connections C ON C.node_from = FP.node_to
		WHERE CHARINDEX(',' || C.node_to || ',', FP.node_list) = 0
	)
	INSERT INTO dbo.D11_full_paths (
	    node_list,
	    node_from,
	    node_to
	)
	SELECT
		NC.node_list,
        NC.node_from,
        NC.node_to
	
	FROM NewConnections NC
	LEFT JOIN dbo.D11_full_paths FP ON FP.node_list = NC.node_list
	WHERE FP.node_list IS NULL;

	IF (@@ROWCOUNT = 0) BREAK;

END;
GO

SELECT
	COUNT(1) AS response1

FROM dbo.D11_full_paths WHERE node_to = 'out';
GO

DROP TABLE IF EXISTS input.day11;
GO

IF OBJECT_ID('input.day11', 'U') IS NULL
BEGIN

	CREATE TABLE input.day11 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day11 FROM '/var/aoc/sample_D11P2.txt';
	--*/ BULK INSERT input.day11 FROM '/var/aoc/input_D11P1.txt';

	ALTER TABLE input.day11 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.D11_connections;
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

INTO dbo.D11_connections

FROM InputData ID1
INNER JOIN InputData ID2 ON ID2.line_id = ID1.line_id
	AND ID2.rn = 2
CROSS APPLY STRING_SPLIT(ID2.value, ' ') AS SS
WHERE ID1.rn = 1
	AND SS.value <> '';
GO

DROP TABLE IF EXISTS dbo.D11_full_paths;
GO

SELECT
    CONVERT(VARCHAR(MAX), ',' || C.node_from || ',') AS node_list,
    C.node_from,
    C.node_to

INTO dbo.D11_full_paths

FROM dbo.D11_connections C
WHERE C.node_from = 'svr';
GO

SELECT * FROM dbo.D11_full_paths;
GO

WHILE (1 = 1)
BEGIN

	WITH NewConnections
	AS (
		SELECT
			FP.node_list || C.node_to || ',' AS node_list,
			FP.node_from,
			C.node_to

		FROM dbo.D11_full_paths FP
		INNER JOIN dbo.D11_connections C ON C.node_from = FP.node_to
		WHERE CHARINDEX(',' || C.node_to || ',', FP.node_list) = 0
	)
	INSERT INTO dbo.D11_full_paths (
	    node_list,
	    node_from,
	    node_to
	)
	SELECT
		NC.node_list,
        NC.node_from,
        NC.node_to
	
	FROM NewConnections NC
	LEFT JOIN dbo.D11_full_paths FP ON FP.node_list = NC.node_list
	WHERE FP.node_list IS NULL;

	IF (@@ROWCOUNT = 0) BREAK;

END;
GO

SELECT
	COUNT(1) AS response2

FROM dbo.D11_full_paths FP
WHERE FP.node_to = 'out'
	AND CHARINDEX(',dac,', FP.node_list) > 0
	AND CHARINDEX(',fft,', FP.node_list) > 0;
GO

/* Day 11: END */

USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 2: Gift Shop --- (https://adventofcode.com/2025/day/2): BEGIN */

DROP TABLE IF EXISTS input.day02;
GO

IF OBJECT_ID('input.day02', 'U') IS NULL
BEGIN

	CREATE TABLE input.day02 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day02 FROM '/var/aoc/sample_D02P1.txt';
	--*/ BULK INSERT input.day02 FROM '/var/aoc/input_D02P1.txt';

END;
GO

DROP TABLE IF EXISTS dbo.day02_ranges;
GO

SELECT
	CONVERT(VARCHAR(100), SS.value) AS group_range,
	CONVERT(BIGINT, LEFT(SS.value, CHARINDEX('-', SS.value) - 1)) AS range_start,
	CONVERT(BIGINT, SUBSTRING(SS.value, CHARINDEX('-', SS.value) + 1)) AS range_end

INTO dbo.day02_ranges

FROM input.day02 I
CROSS APPLY STRING_SPLIT(I.line, ',') SS;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;

DECLARE @max_number_of_digits BIGINT;

SELECT @max_number_of_digits = CEILING(LOG10(MAX(R.range_end)) / 2) FROM dbo.day02_ranges R;

WITH HalfSizes
AS (
	SELECT GS.value AS half_size
	FROM GENERATE_SERIES(CONVERT(BIGINT, 1), @max_number_of_digits, CONVERT(BIGINT, 1)) GS
),
HalfRanges
AS (
	SELECT
		N.half_size,
		CONVERT(BIGINT, '1' || REPLICATE('0', N.half_size-1)) AS half_range_start,
		CONVERT(BIGINT, REPLICATE('9', N.half_size)) AS half_range_end

	FROM HalfSizes N
),
InvalidCodes
AS (
	SELECT
		CONVERT(BIGINT, GS.value * POWER(10, HR.half_size) + GS.value) AS invalid_code

	FROM HalfRanges HR
	CROSS APPLY GENERATE_SERIES(HR.half_range_start, HR.half_range_end, CONVERT(BIGINT, 1)) GS
)
SELECT
	SUM(IC.invalid_code) AS response1

FROM InvalidCodes IC
INNER JOIN dbo.day02_ranges R ON IC.invalid_code BETWEEN R.range_start AND R.range_end;
GO

SET STATISTICS IO, TIME ON;

DECLARE @max_number_of_digits BIGINT;

SELECT @max_number_of_digits = CEILING(LOG10(MAX(R.range_end))) FROM dbo.day02_ranges R;

WITH Numbers
AS (
	SELECT GS.value AS number
	FROM GENERATE_SERIES(CONVERT(BIGINT, 1), @max_number_of_digits, CONVERT(BIGINT, 1)) GS
),
Combinations
AS (
	SELECT
		N.number AS number_of_digits,
		CONVERT(BIGINT, '1' || REPLICATE('0', N.number - 1)) AS range_start,
		CONVERT(BIGINT, REPLICATE('9', N.number)) AS range_end,
		R.number AS repetitions

	FROM Numbers N,
		Numbers R
	WHERE N.number * R.number <= @max_number_of_digits
		AND R.number > 1
),
InvalidCodes
AS (
	SELECT DISTINCT
		CONVERT(BIGINT, REPLICATE(CONVERT(VARCHAR(10), GS.value), C.repetitions)) AS invalid_code

	FROM Combinations C
	CROSS APPLY GENERATE_SERIES(C.range_start, C.range_end, CONVERT(BIGINT, 1)) GS
)
SELECT
	SUM(IC.invalid_code) AS response2

FROM InvalidCodes IC
INNER JOIN dbo.day02_ranges R ON IC.invalid_code BETWEEN R.range_start AND R.range_end;
GO

/* Day 2: END */

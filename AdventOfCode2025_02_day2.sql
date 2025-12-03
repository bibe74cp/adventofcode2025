USE AdventOfCode2025;
GO

/* Day 2: BEGIN */

/* Import flat file input.txt into table input.D02P1:

DROP TABLE IF EXISTS input.D02P1;
GO

CREATE TABLE input.D02P1 (
	group_id INT IDENTITY (1, 1) CONSTRAINT PK_D02P1 PRIMARY KEY CLUSTERED,
	group_range VARCHAR(100)
);
GO

INSERT INTO input.D02P1 (
    group_range
)
VALUES (...);
GO

*/
GO

DROP TABLE IF EXISTS #Ranges;
GO

SELECT
	group_range,
	CONVERT(BIGINT, LEFT(group_range, CHARINDEX('-', group_range)-1)) AS range_start,
	CONVERT(BIGINT, SUBSTRING(group_range, CHARINDEX('-', group_range)+1)) AS range_end

INTO #Ranges
FROM input.D02P1;
GO

--SELECT * FROM #Ranges ORDER BY range_start;
GO

DECLARE @max_number_of_digits BIGINT;

SELECT @max_number_of_digits = ROUND(LOG10(MAX(R.range_end)) ,0) / 2 FROM #Ranges R;

WITH HalfSizes
AS (
	SELECT gs.value AS half_size
	FROM GENERATE_SERIES(CONVERT(BIGINT, 1), @max_number_of_digits, CONVERT(BIGINT, 1)) AS gs
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
		CONVERT(BIGINT, gs.value * POWER(10, HR.half_size) + gs.value) AS invalid_code

	FROM HalfRanges HR
	CROSS APPLY GENERATE_SERIES(HR.half_range_start, HR.half_range_end, CONVERT(BIGINT, 1)) AS gs
)
SELECT
	--IC.invalid_code
	SUM(IC.invalid_code) AS response1

FROM InvalidCodes IC
INNER JOIN #Ranges R ON IC.invalid_code BETWEEN R.range_start AND R.range_end;
GO

DECLARE @max_number_of_digits BIGINT;

SELECT @max_number_of_digits = ROUND(LOG10(MAX(R.range_end)) ,0) FROM #Ranges R;

WITH Numbers
AS (
	SELECT gs.value AS number
	FROM GENERATE_SERIES(CONVERT(BIGINT, 1), @max_number_of_digits, CONVERT(BIGINT, 1)) AS gs
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
		--C.number_of_digits,
		--C.range_start,
		--C.range_end,
		--C.repetitions,
		CONVERT(BIGINT, REPLICATE(CONVERT(NVARCHAR(10), gs.value), C.repetitions)) AS invalid_code

	FROM Combinations C
	CROSS APPLY GENERATE_SERIES(C.range_start, C.range_end, CONVERT(BIGINT, 1)) AS gs
)
SELECT
	SUM(IC.invalid_code) AS response2

FROM InvalidCodes IC
INNER JOIN #Ranges R ON IC.invalid_code BETWEEN R.range_start AND R.range_end;
GO

/* Day 2: END */

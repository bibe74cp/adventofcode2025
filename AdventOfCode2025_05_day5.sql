USE AdventOfCode2025;
GO

/* Day 5: BEGIN */

/* Import flat file input.txt into table input.D05P1 */
GO

DROP TABLE IF EXISTS dbo.D05_Ranges;
GO

SELECT
	line,
	CONVERT(BIGINT, LEFT(I.line, CHARINDEX('-', I.line) - 1)) AS range_start,
	CONVERT(BIGINT, SUBSTRING(I.line, CHARINDEX('-', I.line) + 1)) AS range_end

INTO dbo.D05_Ranges

FROM input.D05P1 I
WHERE CHARINDEX('-', line) > 0;
GO

DECLARE @extended_range_start INT = 1,
	@extended_range_end INT = 1;

WHILE (@extended_range_start + @extended_range_end > 0)
BEGIN

	UPDATE R1   
	SET R1.range_start = R2.range_start
	FROM dbo.D05_Ranges R1
	INNER JOIN dbo.D05_Ranges R2 ON R1.range_start BETWEEN R2.range_start AND R2.range_end
		AND NOT (R1.range_start = R2.range_start AND R1.range_end = R2.range_end);

	SELECT @extended_range_start = @@ROWCOUNT;

	UPDATE R1   
	SET R1.range_end = R2.range_end
	FROM dbo.D05_Ranges R1
	INNER JOIN dbo.D05_Ranges R2 ON R1.range_end BETWEEN R2.range_start AND R2.range_end
		AND NOT (R1.range_start = R2.range_start AND R1.range_end = R2.range_end);

	SELECT @extended_range_end = @@ROWCOUNT;

END;
GO

SET STATISTICS IO, TIME ON;

WITH Ranges
AS (
	SELECT DISTINCT
		range_start,
		range_end

	FROM dbo.D05_Ranges
),
Ingredients
AS (
	SELECT
		CONVERT(BIGINT, I.line) AS ingredient_id
	FROM input.D05P1 I
	WHERE LEN(I.line) > 0
		AND CHARINDEX('-', I.line) = 0
)
SELECT
	'response1' AS response_id,
	COUNT(DISTINCT I.ingredient_id) AS response_value

FROM Ingredients I
INNER JOIN Ranges R ON I.ingredient_id BETWEEN R.range_start AND R.range_end

UNION ALL

SELECT 
	'response2',
	SUM(R.range_end - R.range_start + 1)

FROM Ranges R;
GO

/* Day 5: END */

USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* Day 6: BEGIN */

DROP TABLE IF EXISTS input.day06;
GO

IF OBJECT_ID('input.day06', 'U') IS NULL
BEGIN

	CREATE TABLE input.day06 (
		line NVARCHAR(4000) NOT NULL
	);

	/*
	BULK INSERT input.day06 FROM '/var/aoc/sample_D06P1.txt';
	--*/ BULK INSERT input.day06 FROM '/var/aoc/input_D06P1.txt';

	ALTER TABLE input.day06 ADD PK INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day06_data;
GO

IF OBJECT_ID('dbo.day06_data', 'U') IS NULL
BEGIN

	WITH OperatorsLine
	AS (
		SELECT
			O.line
	
		FROM input.day06 O
		WHERE CHARINDEX('+', O.line) > 0
	),
	Operators
	AS (
		SELECT
			ROW_NUMBER() OVER (ORDER BY GS.value) AS operation_id,
			GS.value AS operator_col,
			SUBSTRING(O.line, GS.value, 1) AS operator

		FROM OperatorsLine O
		CROSS APPLY GENERATE_SERIES(CAST(1 AS BIGINT), CAST(4000 AS BIGINT), CAST(1 AS BIGINT)) GS
		WHERE SUBSTRING(O.line, GS.value, 1) IN ('*', '+')
	)
	SELECT
		Op.operation_id,
		0 AS row,
		Op.operator AS value,
		Op.operator,
		--CAST(NULL AS BIGINT) AS number
		NULL AS number

	INTO dbo.day06_data

	FROM Operators Op

	UNION ALL

	SELECT
		Op.operation_id,
		I.PK AS row,
		SUBSTRING(I.line, Op.operator_col, COALESCE(NextOp.operator_col, LEN(I.line) + 1) - Op.operator_col) AS value,
		NULL AS operator,
		CONVERT(BIGINT, SUBSTRING(I.line, Op.operator_col, COALESCE(NextOp.operator_col, LEN(I.line) + 1) - Op.operator_col)) AS number
	
	FROM Operators Op
	CROSS JOIN input.day06 I
	LEFT JOIN Operators NextOp ON NextOp.operation_id = Op.operation_id + 1
	WHERE CHARINDEX('+', I.line) = 0;

	ALTER TABLE dbo.day06_data ALTER COLUMN operation_id BIGINT NOT NULL;
	ALTER TABLE dbo.day06_data ALTER COLUMN row BIGINT NOT NULL;

	ALTER TABLE dbo.day06_data ADD CONSTRAINT PK_day06_data PRIMARY KEY CLUSTERED (operation_id, row);

	ALTER TABLE dbo.day06_data ADD col1_digit VARCHAR(1) NULL;
	ALTER TABLE dbo.day06_data ADD col2_digit VARCHAR(1) NULL;
	ALTER TABLE dbo.day06_data ADD col3_digit VARCHAR(1) NULL;
	ALTER TABLE dbo.day06_data ADD col4_digit VARCHAR(1) NULL;

	UPDATE dbo.day06_data
	SET col1_digit = CASE WHEN LEN(value) >= 1 THEN SUBSTRING(value, 1, 1) ELSE NULL END,
		col2_digit = CASE WHEN LEN(value) >= 2 THEN SUBSTRING(value, 2, 1) ELSE NULL END,
		col3_digit = CASE WHEN LEN(value) >= 3 THEN SUBSTRING(value, 3, 1) ELSE NULL END,
		col4_digit = CASE WHEN LEN(value) >= 4 THEN SUBSTRING(value, 4, 1) ELSE NULL END;

END;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;
GO

SELECT
    SUM(CASE O.operator
		WHEN '+' THEN N1.number + N2.number + N3.number + COALESCE(N4.number, 0)
		WHEN '*' THEN N1.number * N2.number * N3.number * COALESCE(N4.number, 1)
		ELSE NULL
	END) AS response1,
	SUM(CASE O.operator
		WHEN '+' THEN
			COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col1_digit, N2.col1_digit, N3.col1_digit, N4.col1_digit)), 0), 0)
			+ COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col2_digit, N2.col2_digit, N3.col2_digit, N4.col2_digit)), 0), 0)
			+ COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col3_digit, N2.col3_digit, N3.col3_digit, N4.col3_digit)), 0), 0)
			+ COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col4_digit, N2.col4_digit, N3.col4_digit, N4.col4_digit)), 0), 0)
		WHEN '*' THEN
			COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col1_digit, N2.col1_digit, N3.col1_digit, N4.col1_digit)), 0), 1)
			* COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col2_digit, N2.col2_digit, N3.col2_digit, N4.col2_digit)), 0), 1)
			* COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col3_digit, N2.col3_digit, N3.col3_digit, N4.col3_digit)), 0), 1)
			* COALESCE(NULLIF(CONVERT(BIGINT, CONCAT(N1.col4_digit, N2.col4_digit, N3.col4_digit, N4.col4_digit)), 0), 1)
		ELSE NULL
	END) AS response2

FROM dbo.day06_data O
LEFT JOIN dbo.day06_data N1 ON N1.operation_id = O.operation_id
	AND N1.row = 1
LEFT JOIN dbo.day06_data N2 ON N2.operation_id = O.operation_id
	AND N2.row = 2
LEFT JOIN dbo.day06_data N3 ON N3.operation_id = O.operation_id
	AND N3.row = 3
LEFT JOIN dbo.day06_data N4 ON N4.operation_id = O.operation_id
	AND N4.row = 4
WHERE O.row = 0; -- 0: operator
GO

/* Day 6: END */

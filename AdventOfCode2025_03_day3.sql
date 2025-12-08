USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 3: Lobby --- (https://adventofcode.com/2025/day/3): BEGIN */ -- <1", no extra tables

DROP TABLE IF EXISTS input.day03;
GO

IF OBJECT_ID('input.day03', 'U') IS NULL
BEGIN

	CREATE TABLE input.day03 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day03 FROM '/var/aoc/sample_D03P1.txt';
	--*/ BULK INSERT input.day03 FROM '/var/aoc/input_D03P1.txt';

END;
GO


CREATE OR ALTER FUNCTION dbo.usp_D03_GetHigherDigit (
	@line VARCHAR(100),
	@remainder_length TINYINT
)
RETURNS @ret TABLE (
	higher_digit VARCHAR(1),
	remainder VARCHAR(100)
)
AS
BEGIN

	DECLARE @position TINYINT = 0,
		@digit TINYINT = 9;

	WHILE (@digit >= 0 AND @position = 0)
	BEGIN
		SET @position = CHARINDEX(CONVERT(CHAR(1), @digit), LEFT(@line, LEN(@line) - @remainder_length + 1));

		SET @digit = @digit - 1;
	END;

	INSERT INTO @ret (
	    higher_digit,
	    remainder
	) VALUES (@digit + 1, SUBSTRING(@line, @position + 1));

	RETURN;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D03_GetJoltage (@line VARCHAR(100), @depth TINYINT = 2)
RETURNS BIGINT
AS
BEGIN

	DECLARE @result BIGINT;

	;WITH Tree
	AS (
		SELECT
			@line AS line,
			@depth AS depth,
			CONVERT(VARCHAR(100), GHD.higher_digit) AS result,
			GHD.remainder

		FROM dbo.usp_D03_GetHigherDigit(@line, @depth) GHD

		UNION ALL

		SELECT
			T.line,
			CONVERT(TINYINT, T.depth - 1),
			CONVERT(VARCHAR(100), T.result || GHD.higher_digit),
			GHD.remainder

		FROM Tree T
		CROSS APPLY dbo.usp_D03_GetHigherDigit(T.remainder, T.depth - 1) GHD
		WHERE T.depth > 1
	)
	SELECT @result = CONVERT(BIGINT, T.result)

	FROM Tree T
	WHERE T.depth = 1;

	RETURN @result;

END;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;

SELECT
	SUM(dbo.usp_D03_GetJoltage(B.line, 2)) AS response1,
	SUM(dbo.usp_D03_GetJoltage(B.line, 12)) AS response2

FROM input.day03 B;
GO

/* Day 3: END */

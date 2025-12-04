USE AdventOfCode2025;
GO

/* Day 3: BEGIN */

/* Import flat file input.txt into table input.D03P1 */
GO

CREATE OR ALTER FUNCTION dbo.usp_D03_GetHigherDigit (
	@bank VARCHAR(100),
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
		SET @position = CHARINDEX(CONVERT(CHAR(1), @digit), LEFT(@bank, LEN(@bank) - @remainder_length + 1));

		SET @digit = @digit - 1;
	END;

	INSERT INTO @ret (
	    higher_digit,
	    remainder
	) VALUES (@digit + 1, SUBSTRING(@bank, @position + 1));

	RETURN;

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D03_GetJoltage (@bank VARCHAR(100), @depth TINYINT = 2)
RETURNS BIGINT
AS
BEGIN

	DECLARE @result BIGINT;

	;WITH Tree
	AS (
		SELECT
			@bank AS bank,
			@depth AS depth,
			CONVERT(VARCHAR(100), GHD.higher_digit) AS result,
			GHD.remainder

		FROM dbo.usp_D03_GetHigherDigit(@bank, @depth) GHD

		UNION ALL

		SELECT
			T.bank,
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

SET STATISTICS IO, TIME ON;

SELECT
	SUM(dbo.usp_D03_GetJoltage(B.bank, 2)) AS response1,
	SUM(dbo.usp_D03_GetJoltage(B.bank, 12)) AS response2

FROM input.D03P1 B;
GO

/* Day 3: END */

USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 1: Secret Entrance --- (https://adventofcode.com/2025/day/1): BEGIN */

DROP TABLE IF EXISTS input.day01;
GO

IF OBJECT_ID('input.day01', 'U') IS NULL
BEGIN

	CREATE TABLE input.day01 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day01 FROM '/var/aoc/sample_D01P1.txt';
	--*/ BULK INSERT input.day01 FROM '/var/aoc/input_D01P1.txt';
	

	ALTER TABLE input.day01 ADD line_id INT NOT NULL IDENTITY (1, 1);
	ALTER TABLE input.day01 ADD direction CHAR(1) NULL;
	ALTER TABLE input.day01 ADD distance SMALLINT NULL;

	UPDATE input.day01
	SET direction = LEFT(line, 1),
		distance = CONVERT(SMALLINT, SUBSTRING(line, 2));

END;
GO

CREATE OR ALTER FUNCTION dbo.usp_D01_ExplainMove (
	@initial_position SMALLINT,
	@move_id INT
)
RETURNS @ret TABLE (
	move_id INT,
	initial_position SMALLINT,
	move_code VARCHAR(10),
	final_position SMALLINT,
	zeroes_passed SMALLINT
)
AS
BEGIN

	DECLARE @direction SMALLINT,
		@distance INT,
		@zeroes_passed SMALLINT;

	SELECT
		@direction = CASE WHEN direction = 'R' THEN 1 ELSE -1 END,
		@distance = distance

	FROM input.day01
	WHERE line_id = @move_id;

	;WITH Numbers
	AS (
		SELECT GS.value AS number
		FROM GENERATE_SERIES(1, @distance, 1) GS
	)
	SELECT
		@zeroes_passed = COUNT(1)

	FROM Numbers N
	WHERE (@initial_position + @direction * N.number) % 100 = 0;

	INSERT INTO @ret (
	    move_id,
		initial_position,
		move_code,
	    final_position,
	    zeroes_passed
	)
	SELECT
		M.line_id AS move_id,
		@initial_position AS initial_position,
		M.direction || M.distance AS move_code,
		(@initial_position + @direction * M.distance) % 100 AS final_position,
		@zeroes_passed AS zeroes_passed

	FROM input.day01 M
	WHERE M.line_id = @move_id;

	UPDATE @ret
	SET final_position = final_position + 100
	WHERE final_position < 0;

	RETURN;

END;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;

WITH Moves
AS (
	SELECT
		move_id,
        initial_position,
        move_code,
        final_position,
        zeroes_passed
	
	FROM dbo.usp_D01_ExplainMove(50, 1)

	UNION ALL

	SELECT
        EM.move_id,
        EM.initial_position,
        EM.move_code,
        EM.final_position,
        EM.zeroes_passed

	FROM Moves M
	CROSS APPLY dbo.usp_D01_ExplainMove(M.final_position, M.move_id + 1) EM
)
SELECT
	SUM(CASE WHEN M.final_position = 0 THEN 1 ELSE 0 END) AS response1,
	SUM(M.zeroes_passed) AS response2

FROM Moves M
OPTION (MAXRECURSION 5000);
GO

/* Day 1: END */

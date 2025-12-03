USE AdventOfCode2025;
GO

/* Day 1: BEGIN */

/* Import flat file input.txt into table input.D01P1, then:

ALTER TABLE input.D01P1 ADD PK INT NOT NULL IDENTITY (1, 1);
GO

*/
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

	FROM input.D01P1
	WHERE PK = @move_id;

	;WITH Numbers
	AS (
		SELECT gs.value AS number
		FROM GENERATE_SERIES(1, @distance, 1) AS gs
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
		M.PK AS move_id,
		@initial_position AS initial_position,
		M.direction || M.distance AS move_code,
		(@initial_position + @direction * M.distance) % 100 AS final_position,
		@zeroes_passed AS zeroes_passed

	FROM input.D01P1 M
	WHERE M.PK = @move_id;

	UPDATE @ret
	SET final_position = final_position + 100
	WHERE final_position < 0;

	RETURN;

END;
GO

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
	/*
	M.move_id,
    M.initial_position,
    M.move_code,
    M.final_position_computed,
    M.final_position,
    M.zeroes_passed
	*/
	SUM(CASE WHEN M.final_position = 0 THEN 1 ELSE 0 END) AS response1,
	SUM(M.zeroes_passed) AS response2

FROM Moves M
OPTION (MAXRECURSION 5000);
GO

/* Day 1: END */

USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 8: Playground --- (https://adventofcode.com/2025/day/8): BEGIN */

DROP TABLE IF EXISTS input.day08;
GO

IF OBJECT_ID('input.day08', 'U') IS NULL
BEGIN

	CREATE TABLE input.day08 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day08 FROM '/var/aoc/sample_D08P1.txt';
	--*/ BULK INSERT input.day08 FROM '/var/aoc/input_D08P1.txt';

	ALTER TABLE input.day08 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day08_boxes;
GO

WITH Coordinates
AS (
	SELECT
		D.line_id,
		D.line,
		SS.value,
		ROW_NUMBER() OVER (PARTITION BY D.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day08 D
	CROSS APPLY STRING_SPLIT(D.line, ',') SS
)
SELECT
	X.line_id AS box_id,
	X.line AS box_coordinates,
    CONVERT(BIGINT, X.value) AS x,
    CONVERT(BIGINT, Y.value) AS y,
    CONVERT(BIGINT, Z.value) AS z,
	X.line_id AS circuit_id

INTO dbo.day08_boxes

FROM Coordinates X
INNER JOIN Coordinates Y ON Y.line_id = X.line_id
	AND Y.rn = 2
INNER JOIN Coordinates Z ON Z.line_id = X.line_id
	AND Z.rn = 3
WHERE X.rn = 1;
GO

DROP TABLE IF EXISTS dbo.day08_distances;
GO

SELECT
	B1.box_id AS box_id_from,
	B1.box_coordinates AS box_coordinates_from,
	B2.box_id AS box_id_to,
	B2.box_coordinates AS box_coordinates_to,
	SQUARE(B1.x - B2.x) + SQUARE(B1.y - B2.y) + SQUARE(B1.z - B2.z) AS distance_squared

INTO dbo.day08_distances

FROM dbo.day08_boxes B1
INNER JOIN dbo.day08_boxes B2 ON B2.box_id < B1.box_id;
GO

DROP TABLE IF EXISTS dbo.day08_circuits;
GO

SET STATISTICS IO, TIME ON; SET NOCOUNT ON;
GO

DECLARE @box_id_from BIGINT,
	@box_id_to BIGINT,
	@iteration_count INT,
	@iteration INT = 0,
	@circuits_count BIGINT;

SELECT @iteration_count = CASE WHEN (SELECT COUNT(1) FROM dbo.day08_boxes) = 20 THEN 10 ELSE 1000 END;

DECLARE curDistances CURSOR FAST_FORWARD READ_ONLY FOR SELECT box_id_from, box_id_to FROM dbo.day08_distances ORDER BY distance_squared

OPEN curDistances

FETCH NEXT FROM curDistances INTO @box_id_from, @box_id_to

WHILE @@FETCH_STATUS = 0
BEGIN

	SET @iteration = @iteration + 1;

	WITH BoxesToConnect
	AS (
		SELECT
			B.box_id,
            B.circuit_id,
			ROW_NUMBER() OVER (ORDER BY B.circuit_id DESC) AS rn

		FROM dbo.day08_boxes B
		WHERE B.box_id IN (@box_id_from, @box_id_to)
	)
	UPDATE B
	SET B.circuit_id = BTCRef.circuit_id

	FROM BoxesToConnect BTC
	INNER JOIN BoxesToConnect BTCRef ON BTCRef.rn = 1
	INNER JOIN dbo.day08_boxes B ON B.circuit_id = BTC.circuit_id
	WHERE BTC.rn > 1;

	IF (@iteration = @iteration_count)
	BEGIN

		WITH Circuits
		AS (
			SELECT TOP (3)
				B.circuit_id,
				COUNT(1) AS boxes_count

			FROM dbo.day08_boxes B
			GROUP BY B.circuit_id
			ORDER BY boxes_count DESC
		)
		SELECT
			PRODUCT(C.boxes_count) AS response1

		FROM Circuits C;

	END;

	SELECT @circuits_count = COUNT(DISTINCT circuit_id) FROM dbo.day08_boxes;

	IF (@circuits_count = 1)
	BEGIN

		SELECT 
			PRODUCT(B.x) AS response2

		FROM dbo.day08_boxes B
		WHERE B.box_id IN (@box_id_from, @box_id_to)

		BREAK;

	END;

    FETCH NEXT FROM curDistances INTO @box_id_from, @box_id_to
END

CLOSE curDistances
DEALLOCATE curDistances
GO

/* Day 8: END */

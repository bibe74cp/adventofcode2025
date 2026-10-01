USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* --- Day 9: Movie Theater --- (https://adventofcode.com/2025/day/9): BEGIN */

DROP TABLE IF EXISTS input.day09;
GO

IF OBJECT_ID('input.day09', 'U') IS NULL
BEGIN

	CREATE TABLE input.day09 (
		line VARCHAR(MAX) NOT NULL
	);

	/*
	BULK INSERT input.day09 FROM '/var/aoc/sample_D09P1.txt';
	--*/ BULK INSERT input.day09 FROM '/var/aoc/input_D09P1.txt';

	ALTER TABLE input.day09 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

DROP TABLE IF EXISTS dbo.day09_tiles;
GO

WITH Coordinates
AS (
	SELECT
		D.line_id,
		D.line,
		CONVERT(INT, SS.value) AS value,
		ROW_NUMBER() OVER (PARTITION BY D.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day09 D
	CROSS APPLY STRING_SPLIT(D.line, ',') SS
)
SELECT
	X.line_id AS tile_id,
	X.line AS tile_coordinates,
	CONVERT(BIGINT, X.value) AS x,
	CONVERT(BIGINT, Y.value) AS y

INTO dbo.day09_tiles

FROM Coordinates X
INNER JOIN Coordinates Y ON Y.line_id = X.line_id
	AND Y.rn = 2
WHERE X.rn = 1;
GO

DROP TABLE IF EXISTS dbo.day09_areas;
GO

WITH Rectangles
AS (
	SELECT
		B1.tile_id AS tile_id_from,
		B1.tile_coordinates AS tile_coordinates_from,
		B2.tile_id AS tile_id_to,
		B2.tile_coordinates AS tile_coordinates_to,
		LEAST(B1.x, B2.x) AS x_from,
		GREATEST(B1.x, B2.x) AS x_to,
		LEAST(B1.y, B2.y) AS y_from,
		GREATEST(B1.y, B2.y) AS y_to,
		CONVERT(BIGINT, ABS(B1.x - B2.x) + 1) * CONVERT(BIGINT, ABS(B1.y - B2.y) + 1) AS area

	FROM dbo.day09_tiles B1
	INNER JOIN dbo.day09_tiles B2 ON B2.tile_id < B1.tile_id
)
SELECT
	R.*,
	geometry::STGeomFromText(
		'POLYGON(('
			|| CONVERT(VARCHAR(10), R.x_from) || ' ' || CONVERT(VARCHAR(10), R.y_from)
			|| ',' || CONVERT(VARCHAR(10), R.x_to) || ' ' || CONVERT(VARCHAR(10), R.y_from)
			|| ',' || CONVERT(VARCHAR(10), R.x_to) || ' ' || CONVERT(VARCHAR(10), R.y_to)
			|| ',' || CONVERT(VARCHAR(10), R.x_from) || ' ' || CONVERT(VARCHAR(10), R.y_to)
			|| ',' || CONVERT(VARCHAR(10), R.x_from) || ' ' || CONVERT(VARCHAR(10), R.y_from)
		|| '))', 0) AS rectangle

INTO dbo.day09_areas

FROM Rectangles R;
GO

SELECT
	MAX(A.area) AS response1

FROM dbo.day09_areas A;
GO

DECLARE @g1 GEOMETRY;

WITH Input
AS (
	SELECT
		REPLACE(line, ',', ' ') AS coordinate

	FROM input.day09

	UNION ALL SELECT TOP (1) REPLACE(line, ',', ' ') FROM input.day09 ORDER BY line_id
)
SELECT @g1 = 'POLYGON((' || STRING_AGG(I.coordinate, ',') || '))' FROM Input I;

SELECT @g1;

SELECT TOP (1)
	A.tile_coordinates_from,
	A.tile_coordinates_to,
	A.rectangle,
	A.area AS response2

FROM dbo.day09_areas A
WHERE @g1.STContains(A.rectangle.MakeValid()) = 1
ORDER BY A.area DESC;
GO

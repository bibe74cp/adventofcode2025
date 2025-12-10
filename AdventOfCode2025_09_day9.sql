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

	--/*
	BULK INSERT input.day09 FROM 'C:\Users\a.turelli\Downloads\input.txt';
	--BULK INSERT input.day09 FROM '/var/aoc/sample_D09P1.txt';
	--*/ BULK INSERT input.day09 FROM '/var/aoc/input_D09P1.txt';

	ALTER TABLE input.day09 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

/* Day 9: END */

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
	CONVERT(INT, X.value) AS x,
	CONVERT(INT, Y.value) AS y

INTO dbo.day09_tiles

FROM Coordinates X
INNER JOIN Coordinates Y ON Y.line_id = X.line_id
	AND Y.rn = 2
WHERE X.rn = 1;
GO

DROP TABLE IF EXISTS dbo.day09_areas;
GO

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

INTO dbo.day09_areas

FROM dbo.day09_tiles B1
INNER JOIN dbo.day09_tiles B2 ON B2.tile_id < B1.tile_id;
GO

SELECT
	MAX(A.area) AS response1

FROM dbo.day09_areas A;
GO

DROP TABLE IF EXISTS dbo.day09_response2;
GO

WITH RangeX
AS (
	SELECT
		MIN(T.x) AS x_min,
		MAX(T.x) AS x_max

	FROM dbo.day09_tiles T
),
RangeY
AS (
	SELECT
		MIN(T.y) AS y_min,
		MAX(T.y) AS y_max

	FROM dbo.day09_tiles T
),
CoordY
AS (
	SELECT
		GS.value AS y,
		ROW_NUMBER() OVER (ORDER BY GS.value) AS rn

	FROM RangeY RY
	CROSS APPLY GENERATE_SERIES(RY.y_min, RY.y_max, 1) AS GS
),
TilesByY AS (
	SELECT
        T.x,
        T.y,
		ROW_NUMBER() OVER (PARTITION BY T.y ORDER BY T.x) AS rn,
		ROW_NUMBER() OVER (PARTITION BY T.y ORDER BY T.x DESC) AS rnDesc

	FROM dbo.day09_tiles T
),
TilesByYFull
AS (
	SELECT
		CY.y,
		COALESCE(TBYMin.x, 0) AS x_min,
		COALESCE(TBYMax.x, 0) AS x_max

	FROM CoordY CY
	LEFT JOIN TilesByY TBYMin ON TBYMin.y = CY.y
		AND TBYMin.rn = 1
	LEFT JOIN TilesByY TBYMax ON TBYMax.y = CY.y
		AND TBYMax.rnDesc = 1
),
ValidTilesTree
AS (
	SELECT
		CY.y,
		TBYF.x_min,
		TBYF.x_max,
		TBYF.x_min AS range_min,
		TBYF.x_max AS range_max

	FROM CoordY CY
	INNER JOIN TilesByYFull TBYF ON TBYF.y = CY.y
	WHERE CY.rn = 1

	UNION ALL

	SELECT
		TBYF.y,
		TBYF.x_min,
		TBYF.x_max,
		CASE WHEN TBYF.x_min = 0 THEN LEAST(VTT.x_min, VTT.range_min) ELSE LEAST(TBYF.x_min, VTT.range_min) END,
		CASE WHEN TBYF.x_max = 0 THEN GREATEST(VTT.x_max, VTT.range_max) ELSE GREATEST(TBYF.x_max, VTT.range_max) END

	FROM ValidTilesTree VTT
	INNER JOIN TilesByYFull TBYF ON TBYF.y = VTT.y + 1
),
ValidTiles
AS (
	SELECT
		GS.value AS x,
		VTT.y

	FROM ValidTilesTree VTT
	CROSS APPLY GENERATE_SERIES(VTT.x_min, VTT.x_max, 1) AS GS
)
SELECT
	A.tile_id_from,
    A.tile_coordinates_from,
    A.tile_id_to,
    A.tile_coordinates_to,
    A.x_from,
    A.x_to,
    A.y_from,
    A.y_to,
    A.area,
	COUNT(1) AS tile_count

INTO dbo.day09_response2

FROM dbo.day09_areas A
INNER JOIN ValidTiles VT ON VT.x BETWEEN A.x_from AND A.x_to AND VT.y BETWEEN A.y_from AND A.y_to
GROUP BY A.tile_id_from,
    A.tile_coordinates_from,
    A.tile_id_to,
    A.tile_coordinates_to,
    A.x_from,
    A.x_to,
    A.y_from,
    A.y_to,
    A.area
--HAVING COUNT(1) = A.area
ORDER BY A.area DESC
OPTION (MAXRECURSION 0);
GO

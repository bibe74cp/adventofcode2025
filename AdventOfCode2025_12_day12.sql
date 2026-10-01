USE AdventOfCode2025;
GO

SET STATISTICS IO, TIME OFF; SET NOCOUNT OFF;
GO

/* Day 12 (https://adventofcode.com/2025/day/12): BEGIN */

DROP TABLE IF EXISTS input.day12;
GO

IF OBJECT_ID('input.day12', 'U') IS NULL
BEGIN

	CREATE TABLE input.day12 (
		line VARCHAR(MAX) NOT NULL
	);

	--/*
	BULK INSERT input.day12 FROM '/var/aoc/sample_D12P1.txt';
	--*/ BULK INSERT input.day12 FROM '/var/aoc/input_D12P1.txt';

	ALTER TABLE input.day12 ADD line_id INT NOT NULL IDENTITY (1, 1);

END;
GO

/* Day 12: END */

DROP TABLE IF EXISTS dbo.day12_shapes;
GO

WITH ShapesData
AS (
	SELECT TOP (30)
		I.line_id / 5 AS shape_id,
		I.line,
		I.line_id % 5 AS row_id,
		CASE I.line_id % 5
			WHEN 1 THEN 'Index'
			WHEN 0 THEN ''
			ELSE 'Shape'
		END AS line_type

	FROM input.day12 I
)
SELECT
	SD.shape_id,
	'S' || SD.shape_id AS shape_name

INTO dbo.day12_shapes

FROM ShapesData SD
WHERE SD.line_type = 'Index';
GO

SELECT * FROM dbo.day12_shapes;
GO

DROP TABLE IF EXISTS dbo.day12_shape_coordinates;
GO

WITH ShapesData
AS (
	SELECT TOP (30)
		I.line_id / 5 AS shape_id,
		I.line,
		I.line_id % 5 AS row_id,
		CASE I.line_id % 5
			WHEN 1 THEN 'Index'
			WHEN 0 THEN ''
			ELSE 'Shape'
		END AS line_type

	FROM input.day12 I
),
Coordinates AS (
	SELECT
		X.value AS x,
		Y.value AS y

	FROM GENERATE_SERIES(-1, 1, 1) X
	CROSS APPLY GENERATE_SERIES(-1, 1, 1) Y
)
SELECT
	SD.shape_id,
	C.x,
	C.y,
	SD.line,
	1 AS content

INTO dbo.day12_shape_coordinates

FROM ShapesData SD
INNER JOIN Coordinates C ON C.y = SD.row_id - 3
WHERE SD.line_type = 'Shape'
	AND SUBSTRING(SD.line, C.x + 2, 1) = '#';
GO

SELECT * FROM dbo.day12_shape_coordinates;
GO

DROP TABLE IF EXISTS dbo.day12_regions;
GO

WITH Input
AS (
	SELECT
		I.line,
		I.line_id,
		SS.value,
		ROW_NUMBER() OVER (PARTITION BY I.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day12 I
	CROSS APPLY STRING_SPLIT(I.line, ':') SS
	WHERE I.line LIKE N'%x%'
),
Regions
AS (
	SELECT
		DENSE_RANK() OVER (ORDER BY I.line_id) AS region_id,
		I.value

	FROM Input I
	WHERE I.rn = 1
),
Dimensions
AS (
	SELECT
		R.region_id,
        SS.value,
		ROW_NUMBER() OVER (PARTITION BY R.region_id ORDER BY (SELECT 1)) AS rn
	
	FROM Regions R
	CROSS APPLY STRING_SPLIT(R.value, 'x') SS
)
SELECT
	R.region_id,
    D1.value AS x,
    D2.value AS y
	
INTO dbo.day12_regions

FROM Regions R
INNER JOIN Dimensions D1 ON D1.region_id = R.region_id
	AND D1.rn = 1
INNER JOIN Dimensions D2 ON D2.region_id = R.region_id
	AND D2.rn = 2;
GO

SELECT * FROM dbo.day12_regions ORDER BY region_id;
GO

DROP TABLE IF EXISTS dbo.day12_region_shapes;
GO

WITH Input
AS (
	SELECT
		I.line,
		I.line_id,
		SS.value,
		ROW_NUMBER() OVER (PARTITION BY I.line_id ORDER BY (SELECT 1)) AS rn

	FROM input.day12 I
	CROSS APPLY STRING_SPLIT(I.line, ':') SS
	WHERE I.line LIKE N'%x%'
),
Regions
AS (
	SELECT
		DENSE_RANK() OVER (ORDER BY I.line_id) AS region_id,
		ROW_NUMBER() OVER (PARTITION BY I.line_id ORDER BY (SELECT 1)) - 2 AS shape_id,
		CONVERT(INT, SS.value) AS shape_count

	FROM Input I
	CROSS APPLY STRING_SPLIT(I.value, ' ') AS SS
	WHERE I.rn = 2
),
RegionShapes
AS (
	SELECT
		R.region_id,
		R.shape_id,
		R.shape_count
	
	FROM Regions R
	INNER JOIN dbo.day12_shapes S ON S.shape_id = R.shape_id
	WHERE R.shape_count > 0
)
SELECT
	RS.region_id,
	CHAR(64 + ROW_NUMBER() OVER (PARTITION BY RS.region_id ORDER BY RS.shape_id, GS.value)) AS shape_name,
    RS.shape_id

INTO dbo.day12_region_shapes

FROM RegionShapes RS
INNER JOIN dbo.day12_shapes S ON S.shape_id = RS.shape_id
CROSS APPLY GENERATE_SERIES(1, RS.shape_count, 1) GS;
GO

SELECT * FROM dbo.day12_region_shapes;
GO

CREATE OR ALTER FUNCTION dbo.ufn_D12_PlaceShape (
	@shape_id INT,
	@x INT,
	@y INT,
	@clockwise_turns INT -- clockwise turns (0 to 3)
)
RETURNS @ret TABLE (
	x INT,
	y INT,
	content INT
)
AS
BEGIN

	WITH Turns
	AS (
		SELECT @clockwise_turns % 4 AS clockwise_turns
	)
	INSERT INTO @ret (
	    x,
	    y,
	    content
	)
	SELECT
		CASE T.clockwise_turns
		  WHEN 0 THEN SC.x
		  WHEN 1 THEN SC.y
		  WHEN 2 THEN -SC.x
		  WHEN 3 THEN -SC.y
		END + @x AS x,
		CASE T.clockwise_turns
		  WHEN 0 THEN SC.y
		  WHEN 1 THEN -SC.x
		  WHEN 2 THEN -SC.y
		  WHEN 3 THEN SC.x
		END + @y AS y,
		SC.content

	FROM dbo.day12_shape_coordinates SC
	CROSS JOIN Turns T
	WHERE SC.shape_id = @shape_id;

	RETURN;

END;
GO

WITH Rotations
AS (
	SELECT
		GS.value AS clockwise_rotations

	FROM GENERATE_SERIES(0, 3, 1) AS GS
),
Placements
AS (
	SELECT
		RS.region_id,
		RS.shape_name,
		RS.shape_id,
		X.value AS x,
		Y.value AS y

	FROM dbo.day12_region_shapes RS
	INNER JOIN dbo.day12_regions R ON R.region_id = RS.region_id
	INNER JOIN dbo.day12_shapes S ON S.shape_id = RS.shape_id
	CROSS APPLY GENERATE_SERIES(2, CONVERT(INT, R.x) - 1) AS X
	CROSS APPLY GENERATE_SERIES(2, CONVERT(INT, R.y) - 1) AS Y
	WHERE RS.region_id = 1
),
AvailablePlacements
AS (
	SELECT
		PA.region_id,
		PA.shape_id AS shape_idA,
		PA.x AS xA,
		PA.y AS yA,
		RA.clockwise_rotations AS rotA,
		PB.shape_id AS shape_idB,
		PB.x AS xB,
		PB.y AS yB,
		RB.clockwise_rotations AS rotB

	FROM Placements PA
	INNER JOIN Placements PB ON PB.region_id = PA.region_id
		AND PB.shape_name = 'B'
	CROSS JOIN Rotations RA
	CROSS JOIN Rotations RB
	WHERE PA.shape_name = 'A'
		AND ABS(PA.x - PB.x) + ABS(PA.y - PB.y) > 1
),
Outcomes
AS (
	SELECT
		AP.region_id,
        AP.xA,
        AP.yA,
        AP.rotA,
        AP.xB,
        AP.yB,
        AP.rotB,
		PSA.x,
		PSA.y,
		PSA.content

	FROM AvailablePlacements AP
	CROSS APPLY dbo.ufn_D12_PlaceShape(AP.shape_idA, AP.xA, AP.yA, AP.rotA) PSA

	UNION ALL

	SELECT
		AP.region_id,
        AP.xA,
        AP.yA,
        AP.rotA,
        AP.xB,
        AP.yB,
        AP.rotB,
		PSB.x,
		PSB.y,
		PSB.content

	FROM AvailablePlacements AP
	CROSS APPLY dbo.ufn_D12_PlaceShape(AP.shape_idB, AP.xB, AP.yB, AP.rotB) PSB
),
Collisions
AS (
	SELECT
		O.region_id,
		O.xA,
		O.yA,
		O.rotA,
		O.xB,
		O.yB,
		O.rotB,
		O.x,
		O.y

	FROM Outcomes O
	GROUP BY O.region_id,
		O.xA,
		O.yA,
		O.rotA,
		O.xB,
		O.yB,
		O.rotB,
		O.x,
		O.y
	HAVING MAX(O.content) > 1
),
InvalidPlacements
AS (
	SELECT DISTINCT
		C.region_id,
        C.xA,
        C.yA,
        C.rotA,
        C.xB,
        C.yB,
        C.rotB

	FROM Collisions C
)
SELECT
	AP.*

FROM AvailablePlacements AP
LEFT JOIN InvalidPlacements IP ON IP.region_id = AP.region_id AND IP.xA = AP.xA AND IP.xB = AP.xB AND IP.yA = AP.yA AND IP.yB = AP.yB AND IP.rotA = AP.rotA AND IP.rotB = AP.rotB
WHERE IP.region_id IS NULL;
GO


,
Combinations
AS (
	SELECT
		O.region_id,
		O.xA,
		O.yA,
		O.rotA,
		O.xB,
		O.yB,
		O.rotB,
		O.xPA AS x,
		O.yPA AS y,
		O.contentA AS content

	FROM Outcomes O

	UNION ALL

	SELECT
		O.region_id,
		O.xA,
		O.yA,
		O.rotA,
		O.xB,
		O.yB,
		O.rotB,
		O.xPB,
		O.yPB,
		O.contentB

	FROM Outcomes O
)
SELECT
	C.region_id,
    C.xA,
    C.yA,
    C.rotA,
    C.xB,
    C.yB,
    C.rotB,
    C.x,
    C.y,
    SUM(C.content) AS content

FROM Combinations C
GROUP BY C.region_id,
    C.xA,
    C.yA,
    C.rotA,
    C.xB,
    C.yB,
    C.rotB,
    C.x,
    C.y;
GO

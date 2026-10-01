CREATE OR ALTER FUNCTION dbo.usp_D07_CountPaths (
	--@input_paths D07_PathsType READONLY
	@line_id INT,
	@position INT,
	@content VARCHAR(1),
	@paths_count BIGINT
)
RETURNS @ret TABLE (
	line_id INT,
	position INT,
	content VARCHAR(1),
	paths_count BIGINT
)
AS
BEGIN

	WITH InputAndOperator
	AS (
		SELECT
			I.line_id AS line_id,
			SL.position,
			SL.content,
			CASE WHEN SL.content = N'S' THEN N'|' ELSE SL.content END AS output_content,
			@paths_count AS paths_count

		FROM input.day07 I
		CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
		WHERE I.line_id IN (@line_id, @line_id + 1)
			AND SL.position = @position
	),
	Splits
	AS (
		SELECT -1 AS offset
		UNION ALL SELECT 1 AS offset
	),
	OutputPathsDetail
	AS (
		SELECT
			O.line_id,
			O.position,
			O.content,
			CASE O.content
				WHEN N'^' THEN N'.'
				WHEN N'.' THEN I.output_content
				ELSE O.output_content
			END AS output_content,
			CASE WHEN O.content = '^' THEN 0 ELSE I.paths_count END AS paths_count

		FROM InputAndOperator I
		INNER JOIN InputAndOperator O ON O.position = I.position
			AND O.line_id = I.line_id + 1
		WHERE I.line_id = @line_id

		UNION ALL

		SELECT
			O.line_id,
			I.position + S.offset,
			O.content,
			N'|',
			I.paths_count

		FROM InputAndOperator I
		INNER JOIN InputAndOperator O ON O.position = I.position
			AND O.line_id = I.line_id + 1
		CROSS JOIN Splits S
		WHERE I.line_id = @line_id
			AND O.content = N'^'
	)
	INSERT INTO @ret (
	    line_id,
	    position,
	    content,
	    paths_count
	)
	SELECT
		OPD.line_id,
		OPD.position,
		OPD.output_content,
		SUM(OPD.paths_count) AS paths_count

	FROM OutputPathsDetail OPD;

	RETURN;

END;
GO

WITH PathsCountTree
AS (
	SELECT
		I.line_id AS line_id,
		SL.position,
		SL.content,
		CAST(CASE WHEN SL.content = N'S' THEN 1 ELSE 0 END AS BIGINT) AS paths_count

	FROM input.day07 I
	CROSS APPLY dbo.usp_D07_SplitLine(I.line) SL
	WHERE I.line_id = 1

	UNION ALL

	SELECT
		CP.line_id,
        CP.position,
        CP.content,
        CP.paths_count

	FROM PathsCountTree PCT
	CROSS APPLY dbo.usp_D07_CountPaths(PCT.line_id + 1, PCT.position, PCT.content, PCT.paths_count) CP
),
PathsCount
AS (
	SELECT
		PCT.line_id,
        PCT.position,
        PCT.content,
        PCT.paths_count,
		DENSE_RANK() OVER (ORDER BY PCT.line_id DESC) AS rn
	
	FROM PathsCountTree PCT
)
SELECT
	SUM(PC.paths_count) AS response2

FROM PathsCount PC
WHERE PC.rn = 1
OPTION (MAXRECURSION 5000);
GO

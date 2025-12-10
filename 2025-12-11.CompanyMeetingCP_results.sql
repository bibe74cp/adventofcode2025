DROP TABLE IF EXISTS dbo.day08_results;
GO

CREATE TABLE dbo.day08_results (
	adventor VARCHAR(20) NOT NULL CONSTRAINT PK_day08_results PRIMARY KEY CLUSTERED,
	response1 BIGINT NOT NULL,
	response2 BIGINT NOT NULL
);
GO

INSERT INTO dbo.day08_results (
    adventor,
    response1,
    response2
)
VALUES ('bibe74cp', 98696, 2245203960),
	('Davide Brognoli', 96672, 22517595),
	('Moreno Gentili', 68112, 44543856),
	('emadb', 140008, 9253260633),
	('lowqualityrkomi', 121770, 7893123992),
	('Luca Torriani', 50568, 36045012);
GO

SELECT * FROM dbo.day08_results;
GO

CREATE   PROCEDURE [vc].[mockup_horizontal_bar_chart] AS

BEGIN
CREATE TABLE #temp_values(
function_name VARCHAR(100),
median numeric(20,4),
top_quartile numeric(20,4)
);

INSERT INTO #temp_values (function_name, median, top_quartile)
VALUES
('Sales',        3700000,   28200000),
('Supply Chain', 12700000,  24100000),
('Finance',      4900000,   12000000),
('Marketing',    1300000,   9240000),
('IT',           1500000,   3200000),
('Legal',        800000,    2400000);

SELECT(
	SELECT
	*
	FROM #temp_values
	for json auto
) as json;

DROP TABLE #temp_values;

END

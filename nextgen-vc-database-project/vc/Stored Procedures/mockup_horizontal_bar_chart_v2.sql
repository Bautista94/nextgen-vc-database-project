
CREATE     PROCEDURE [vc].[mockup_horizontal_bar_chart_v2](
@metric_id int
) AS

CREATE TABLE #temp_values(
[function] VARCHAR(100),
median_savings numeric(20,4),
top_Savings numeric(20,4)
);

IF @metric_id = 1
BEGIN
	INSERT INTO #temp_values ([function], median_savings, top_Savings)
	VALUES
	('Sales',        3700000,   28200000),
	('Supply Chain', 12700000,  24100000),
	('Finance',      4900000,   12000000),
	('Marketing',    1300000,   9240000),
	('IT',           1500000,   3200000),
	('Legal',        800000,    2400000);


		SELECT
		*
		FROM #temp_values;

		DROP TABLE #temp_values;
END

ELSE IF @metric_id = 2
BEGIN
	INSERT INTO #temp_values ([function], median_savings, top_Savings)
	VALUES
	('Sales',        4500000,   12800000),
	('Supply Chain', 1010000,   24100000),
	('Finance',      3500000,   9900000),
	('Marketing',    700000,    9240000),
	('IT',           600000,    8900000),
	('Legal',        800000,    9500000);


		SELECT
		*
		FROM #temp_values;

		DROP TABLE #temp_values;
END



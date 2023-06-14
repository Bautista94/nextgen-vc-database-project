/* ================================================================================================================================================
   Procedure Name : [vc].[proc_getSavingsOpportunitiesByFunction]
   Purpose : This SP is a wraper for 4 stored procedures (4 function benchmarks). 
			Just to call them and show a table that feeds the gap to benchmark views in the VC tool.
   Last Modified: 23/02/2023
   Date Modified:   
   Inputs :
		@input_year: ID for year
		@designation_id: ID for designation
		@benchmark_metric: ID for any function benchmark
   Outputs:
	   A result set containing the columns for the gap to benchmark views.

	Parameters :
	This can be replace by procedure  parameters for testing with the following declare statement:

	DECLARE	@input_year INT = 857,
			@designation_id INT = NULL,
			@benchmark_metric INT = 573

select * from vc.designation
select * from vc.benchmark_metric
select * from vc.function_benchmark
select * from vc.year
================================================================================================================================================*/

CREATE   PROCEDURE [vc].[proc_getSavingsOpportunitiesByFunction]
(
    @input_year INT,
    @designation_id INT,
	@benchmark_metric INT
) 
AS
BEGIN

--DECLARE	@input_year INT = 1313,
--		@designation_id INT = NULL,
--		@benchmark_metric INT = 846

	DECLARE @metric_name NVARCHAR(300)

	SET @metric_name = (SELECT UPPER(bm.[name]) FROM vc.benchmark_metric bm WHERE bm.benchmark_metric_id = @benchmark_metric)

	CREATE TABLE #temptable
	(
		[year_id] INT DEFAULT NULL
		,[year] VARCHAR(300) DEFAULT NULL
		,[function_type_id] INT DEFAULT NULL
		,[function_type] VARCHAR(300) DEFAULT NULL
		,[function_id] INT DEFAULT NULL
		,[function] VARCHAR(300) DEFAULT NULL
		,[designation_revenue] NUMERIC(24,6) DEFAULT NULL
		,[labor_amount] NUMERIC(24,6) DEFAULT NULL
		,[employee_count] NUMERIC(24,6) DEFAULT NULL
		,[non_labor_amount] NUMERIC(24,6) DEFAULT NULL
		,[total_amount] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile] NUMERIC(24,6) DEFAULT NULL
		,[median] NUMERIC(24,6) DEFAULT NULL
		,[median_potential_amount] NUMERIC(24,6) DEFAULT NULL
		,[median_potential_percent_baseline] NUMERIC(24,6) DEFAULT NULL
		,[median_potential_fte] NUMERIC(24,6) DEFAULT NULL
		,[median_opportunity_amount] NUMERIC(24,6) DEFAULT NULL
		,[median_opportunity_percent_baseline] NUMERIC(24,6) DEFAULT NULL
		,[median_opportunity_fte] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_potential_amount] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_potential_percent_baseline] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_potential_fte] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_opportunity_amount] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_opportunity_percent_baseline] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_opportunity_fte] NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_total_amount NUMERIC(24,6) DEFAULT NULL
		,total_total_amount NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_labor_amount NUMERIC(24,6) DEFAULT NULL
		,total_labor_amount NUMERIC(24,6) DEFAULT NULL
		--,total_benchmark_total_fte NUMERIC(24,6) DEFAULT NULL
		--,total_total_fte NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_median_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_median_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		--,total_median_opportunity_fte NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_median_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,total_median_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		--,total_benchmark_median_opportunity_percent_baseline_fte NUMERIC(24,6) DEFAULT NULL
		--,total_median_opportunity_percent_baseline_fte NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_top_quartile_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_top_quartile_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		--,total_top_quartile_opportunity_fte NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_top_quartile_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,total_top_quartile_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		--,total_benchmark_top_quartile_opportunity_percent_baseline_fte NUMERIC(24,6) DEFAULT NULL
		--,total_top_quartile_opportunity_percent_baseline_fte NUMERIC(24,6) DEFAULT NULL
	)

	IF @metric_name = UPPER('FTEs as % of total FTEs')
		BEGIN
			INSERT INTO #temptable EXEC [vc].[proc_func_FTEs_as_%_of_total_FTEs]
				@input_year = @input_year,
				@designation_id =  @designation_id,
				@benchmark_metric = @benchmark_metric

		END

	ELSE IF @metric_name = UPPER('Personnel cost as % of revenue')
		BEGIN
			INSERT INTO #temptable EXEC [vc].[proc_func_Personnel_cost_as_%_of_revenue]
				@input_year = @input_year,
				@designation_id =  @designation_id,
				@benchmark_metric = @benchmark_metric

		END

	ELSE IF @metric_name = UPPER('Function FTEs per $1B revenue')
		BEGIN
			INSERT INTO #temptable EXEC [vc].[proc_func_FTEs_per_$1B_revenue]
				@input_year = @input_year,
				@designation_id =  @designation_id,
				@benchmark_metric = @benchmark_metric

		END

	ELSE IF @metric_name = UPPER('Total cost as % of revenue')
		BEGIN
			INSERT INTO #temptable EXEC [vc].[proc_func_Total_cost_as_%_of_revenue]
				@input_year = @input_year,
				@designation_id =  @designation_id,
				@benchmark_metric = @benchmark_metric

		END

	ELSE 
		BEGIN
			INSERT INTO #temptable([year_id])
			VALUES (NULL)
		END

	SELECT
		[year_id]   
		,[year]   
		,[function_type_id]   
		,[function_type]   
		,[function_id]   
		,[function]   
		,[designation_revenue]   
		,[labor_amount]   
		,[employee_count]   
		,[non_labor_amount]   
		,[total_amount]   
		,[top_quartile]   
		,[median]   
		,[median_potential_amount]   
		,[median_potential_percent_baseline]   
		,[median_potential_fte]   
		,[median_opportunity_amount]
		,[median_opportunity_percent_baseline]   
		,[median_opportunity_fte]   
		,[top_quartile_potential_amount]   
		,[top_quartile_potential_percent_baseline]   
		,[top_quartile_potential_fte]   
		,[top_quartile_opportunity_amount]
		,[top_quartile_opportunity_percent_baseline]   
		,[top_quartile_opportunity_fte]   
		,total_benchmark_total_amount   
		,total_total_amount   
		,total_benchmark_labor_amount   
		,total_labor_amount   
		--,total_benchmark_total_fte   
		--,total_total_fte   
		,total_benchmark_median_opportunity_amount   
		,total_median_opportunity_amount   
		--,total_median_opportunity_fte   
		,total_benchmark_median_opportunity_percent_baseline   
		,total_median_opportunity_percent_baseline   
		--,total_benchmark_median_opportunity_percent_baseline_fte   
		--,total_median_opportunity_percent_baseline_fte   
		,total_benchmark_top_quartile_opportunity_amount   
		,total_top_quartile_opportunity_amount   
		--,total_top_quartile_opportunity_fte   
		,total_benchmark_top_quartile_opportunity_percent_baseline   
		,total_top_quartile_opportunity_percent_baseline   
		--,total_benchmark_top_quartile_opportunity_percent_baseline_fte   
		--,total_top_quartile_opportunity_percent_baseline_fte
	FROM #temptable

DROP TABLE #temptable
	

END

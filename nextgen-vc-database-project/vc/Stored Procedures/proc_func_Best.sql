/* ================================================================================================================================================
   Procedure Name : [vc].[proc_func_Best]
   Purpose : Show the best benchmark for every function, if applicable, in the gap to benchmark views.
   Last Modified: 23/02/2023
   Date Modified: 23/03/2023  
   Inputs :
		@input_year: ID for year
		@designation_id: ID for designation

		This SP calls the SP for the 4 fuction benchmarks in order to obtain all benchmarks for every function.
   
   Outputs:
	   A result set containing the columns for the best benchmark drop down option it the gap to benchmark views.

	Parameters :
	This can be replace by procedure parameters for testing with the following declare statement:

		DECLARE
			@input_year INT = 1427,
			@designation_id INT = NULL,
			@benchmark_metric INT;


SELECT * from vc.designation
SELECT * from vc.benchmark_metric
SELECT * from vc.function_benchmark
SELECT * from vc.year

================================================================================================================================================*/

CREATE   PROCEDURE [vc].[proc_func_Best](
    @input_year INT,
    @designation_id INT,
	@benchmark_metric INT
--@benchmark_peer_group INT --uncomment this once user INTerface is developed
) AS
BEGIN

		--DECLARE
		--	@input_year INT = 438,
		--	@designation_id INT = NULL,
		--	@benchmark_metric INT;

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
		,total_benchmark_median_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_median_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_median_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,total_median_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_top_quartile_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_top_quartile_opportunity_amount NUMERIC(24,6) DEFAULT NULL
		,total_benchmark_top_quartile_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,total_top_quartile_opportunity_percent_baseline NUMERIC(24,6) DEFAULT NULL
		,[benchmark_metric_name] NVARCHAR(100) DEFAULT ''
	)

	SET @benchmark_metric = (SELECT [benchmark_metric_id] FROM vc.benchmark_metric bm WHERE bm.[name] = 'FTEs as % of total FTEs')

	INSERT INTO #temptable
	(
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
		,total_benchmark_median_opportunity_amount   
		,total_median_opportunity_amount   
		,total_benchmark_median_opportunity_percent_baseline   
		,total_median_opportunity_percent_baseline   
		,total_benchmark_top_quartile_opportunity_amount   
		,total_top_quartile_opportunity_amount   
		,total_benchmark_top_quartile_opportunity_percent_baseline   
		,total_top_quartile_opportunity_percent_baseline   
	)

	EXEC [vc].[proc_func_FTEs_as_%_of_total_FTEs]
		@input_year = @input_year,
		@designation_id =  @designation_id,
		@benchmark_metric = @benchmark_metric

	--ALTER TABLE #temptable ADD [benchmark_metric_name] [nvarchar](100);

	UPDATE #temptable 
		SET [benchmark_metric_name] = 'FTEs as % of total FTEs'
		WHERE [benchmark_metric_name] = ''


	------------------------------------------------------------------------------

	SET @benchmark_metric = (SELECT [benchmark_metric_id] FROM vc.benchmark_metric bm WHERE bm.[name] = 'Personnel cost as % of revenue')

	INSERT INTO #temptable
	(
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
		,total_benchmark_median_opportunity_amount   
		,total_median_opportunity_amount   
		,total_benchmark_median_opportunity_percent_baseline   
		,total_median_opportunity_percent_baseline   
		,total_benchmark_top_quartile_opportunity_amount   
		,total_top_quartile_opportunity_amount   
		,total_benchmark_top_quartile_opportunity_percent_baseline   
		,total_top_quartile_opportunity_percent_baseline   

	)

	EXEC [vc].[proc_func_Personnel_cost_as_%_of_revenue]
		@input_year = @input_year,
		@designation_id =  @designation_id,
		@benchmark_metric = @benchmark_metric

	--ALTER TABLE #temptable2 ADD [benchmark_metric_name] [nvarchar](100);

	UPDATE #temptable 
		SET [#temptable].[benchmark_metric_name] = 'Personnel cost as % of revenue'
		WHERE [benchmark_metric_name] = '';
	------------------------------------------------------------------------------

	SET @benchmark_metric = (SELECT [benchmark_metric_id] FROM vc.benchmark_metric bm WHERE bm.[name] = 'Function FTEs per $1B revenue')

	INSERT INTO #temptable
	(
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
		,total_benchmark_median_opportunity_amount   
		,total_median_opportunity_amount     
		,total_benchmark_median_opportunity_percent_baseline   
		,total_median_opportunity_percent_baseline   
		,total_benchmark_top_quartile_opportunity_amount   
		,total_top_quartile_opportunity_amount    
		,total_benchmark_top_quartile_opportunity_percent_baseline   
		,total_top_quartile_opportunity_percent_baseline
	)

	EXEC [vc].[proc_func_FTEs_per_$1B_revenue]
		@input_year = @input_year,
		@designation_id =  @designation_id,
		@benchmark_metric = @benchmark_metric

	--ALTER TABLE #temptable ADD [benchmark_metric_name] [nvarchar](100);

	UPDATE #temptable 
		SET [#temptable].[benchmark_metric_name] = 'Function FTEs per $1B revenue'
		WHERE [benchmark_metric_name] = '';
	------------------------------------------------------------------------------
	SET @benchmark_metric = (SELECT [benchmark_metric_id] FROM vc.benchmark_metric bm WHERE bm.[name] = 'Total cost as % of revenue')

	INSERT INTO #temptable
	(
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
		,total_benchmark_median_opportunity_amount   
		,total_median_opportunity_amount    
		,total_benchmark_median_opportunity_percent_baseline   
		,total_median_opportunity_percent_baseline   
		,total_benchmark_top_quartile_opportunity_amount   
		,total_top_quartile_opportunity_amount   
		,total_benchmark_top_quartile_opportunity_percent_baseline   
		,total_top_quartile_opportunity_percent_baseline   
	)

	EXEC [vc].[proc_func_Total_cost_as_%_of_revenue]
		@input_year = @input_year,
		@designation_id =  @designation_id,
		@benchmark_metric = @benchmark_metric

	UPDATE #temptable 
		SET [#temptable].[benchmark_metric_name] = 'Total cost as % of revenue'
		WHERE [benchmark_metric_name] = '';
	------------------------------------------------------------------------------

	SELECT 
		[year_id]   
		,[year]   
		,[function_type_id]   
		,[function_type]   
		,#temptable.[function_id]   
		,[function]
		,benchmark_metric_name
		,[designation_revenue]   
		,[labor_amount]   
		,[employee_count]   
		,[non_labor_amount]   
		,[total_amount]   
		,#temptable.[top_quartile]   
		,#temptable.[median]   
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
		,SUM(CASE WHEN #temptable.top_quartile IS NOT NULL THEN labor_amount + non_labor_amount ELSE NULL END) OVER() AS 'total_benchmark_total_amount' --ok
		,SUM(total_amount) OVER() AS 'total_total_amount' --ok
		--TOTALS LABOR 
		,SUM(CASE WHEN #temptable.top_quartile IS NOT NULL THEN labor_amount ELSE NULL END) OVER() AS 'total_benchmark_labor_amount' --ok
		,SUM(labor_amount) OVER() AS 'total_labor_amount' --ok
		--TOTALS median_opportunity_amount
		,SUM(median_opportunity_amount) OVER () AS 'total_benchmark_median_opportunity_amount'
		,SUM(median_opportunity_amount) OVER () AS 'total_median_opportunity_amount'
		--TOTALS median_opportunity_percent_baseline
		,SUM(median_opportunity_amount) OVER () / SUM(CASE WHEN #temptable.top_quartile IS NOT NULL THEN labor_amount ELSE NULL END) OVER() AS 'total_benchmark_median_opportunity_percent_baseline'
		,SUM(median_opportunity_amount) OVER () / SUM(labor_amount) OVER() AS 'total_median_opportunity_percent_baseline'
		--TOTALS top_quartile_opportunity_amount
		,SUM(top_quartile_opportunity_amount) OVER () AS 'total_benchmark_top_quartile_opportunity_amount'
		,SUM(top_quartile_opportunity_amount) OVER () AS 'total_top_quartile_opportunity_amount'
		--TOTALS top_quartile_opportunity_percent_baseline
		,SUM(top_quartile_opportunity_amount) OVER () / SUM(CASE WHEN #temptable.top_quartile IS NOT NULL THEN labor_amount ELSE NULL END) OVER() AS 'total_benchmark_top_quartile_opportunity_percent_baseline'
		,SUM(top_quartile_opportunity_amount) OVER () / SUM(labor_amount) OVER() AS 'total_top_quartile_opportunity_percent_baseline'
	FROM #temptable
	LEFT JOIN [vc].[benchmark_metric] ON [benchmark_metric].[name] = #temptable.[benchmark_metric_name]
	LEFT JOIN [vc].[function_benchmark]	ON [vc].[function_benchmark].function_id = #temptable.function_id
		AND [vc].[function_benchmark].benchmark_metric_id = [vc].[benchmark_metric].benchmark_metric_id
	WHERE [function_benchmark].[is_best]=1

	DROP TABLE IF EXISTS [vc].[sp_function_best];

	CREATE TABLE [vc].[sp_function_best]
	(	[year_id] INT DEFAULT NULL
		,[year]   VARCHAR(300) DEFAULT NULL
		,[function_type_id]   INT DEFAULT NULL
		,[function_type]   VARCHAR(300) DEFAULT NULL
		,[function_id]   INT DEFAULT NULL
		,[function] VARCHAR(300) DEFAULT NULL
		,[benchmark_metric_name] NVARCHAR(100) DEFAULT NULL
		,[is_best] BIT DEFAULT NULL
		,[median_opportunity_amount] NUMERIC(24,6) DEFAULT NULL
		,[top_quartile_opportunity_amount] NUMERIC(24,6) DEFAULT NULL
	);

	WITH temp2 AS 
	(
		SELECT 
			[year_id]
			,[year]   
			,[function_type_id]  
			,[function_type]   
			,#temptable.[function_id] 
			,[function]
			,[benchmark_metric_name]
			,[is_best]
			,[median_opportunity_amount]     
			,[top_quartile_opportunity_amount] 

		FROM #temptable
		LEFT JOIN [vc].[benchmark_metric] ON [benchmark_metric].[name] = #temptable.[benchmark_metric_name]
		LEFT JOIN [vc].[function_benchmark]	ON [vc].[function_benchmark].function_id = #temptable.function_id
			AND [vc].[function_benchmark].benchmark_metric_id = [vc].[benchmark_metric].benchmark_metric_id
		WHERE [function_benchmark].[is_best]=1
	)
	INSERT INTO [vc].[sp_function_best]	
	SELECT * FROM temp2 WHERE [is_best]=1;

	DROP TABLE #temptable;
------------------------------------------------------------------------------

END
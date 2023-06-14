
/* ================================================================================================================================================
   Procedure Name : [vc].[proc_func_slider_function_benchmarks]
   Purpose : SP for the pop-up slider for benchmarks metric for each function, in the function gap to benchmark views.
   Last Modified: 09/03/2023
   Date Modified:  29/03/2023 
   Inputs :
		@input_year: ID for year
		@designation_id: ID for designation

		This SP calls the SP for the 4 fuction benchmarks in order to obtain all benchmarks for every function.
   
   Outputs:
	   A result set containing the columns for the pop-up info in the slider benchmark for each function in the functions 
		gap to benchmark views.

	Parameters :
	This can be replace by procedure parameters for testing with the following declare statement:

		DECLARE
			@input_year INT = 1427,
			@designation_id INT = NULL,
			@benchmark_metric INT;

SELECT * from vc.designation
SELECT * from vc.year
================================================================================================================================================*/

CREATE   PROCEDURE [vc].[proc_func_slider_function_benchmarks](
    @input_year INT,
    @designation_id INT,
	@benchmark_metric INT
--@benchmark_peer_group INT --uncomment this once user INTerface is developed
) AS
BEGIN

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
	)

	EXEC [vc].[proc_func_Total_cost_as_%_of_revenue]
		@input_year = @input_year,
		@designation_id =  @designation_id,
		@benchmark_metric = @benchmark_metric

	UPDATE #temptable 
		SET [#temptable].[benchmark_metric_name] = 'Total cost as % of revenue'
		WHERE [benchmark_metric_name] = '';
	------------------------------------------------------------------------------

	WITH slider_table AS
	(
		SELECT
			--[year_id]   
			[year]
			--,[function_type_id]   
			--,[function_type]
			,[function_benchmark].[benchmark_peer_group_id]
			,[benchmark_peer_group].[name] AS benchmark_peer_group
			,#temptable.[function_id]   
			,[function]
			,[function_benchmark].[benchmark_metric_id]
			,[benchmark_metric_name]
			,#temptable.[top_quartile]
			,#temptable.[median]

			,CASE WHEN [benchmark_metric_name]='Total cost as % of revenue' THEN (COALESCE([labor_amount],0)+COALESCE([non_labor_amount],0))
				WHEN [benchmark_metric_name]='Function FTEs per $1B revenue' THEN [employee_count]
				WHEN [benchmark_metric_name]='Personnel cost as % of revenue' THEN [labor_amount]
				ELSE ([employee_count])
				END AS baseline_value 
 
			,CASE WHEN [benchmark_metric_name]='Total cost as % of revenue' THEN (COALESCE([labor_amount],0)+COALESCE([non_labor_amount],0)) / designation_revenue
				WHEN [benchmark_metric_name]='Function FTEs per $1B revenue' THEN [employee_count]/(designation_revenue/POWER(10, 9))
				WHEN [benchmark_metric_name]='Personnel cost as % of revenue' THEN [labor_amount]/ designation_revenue
				ELSE ([employee_count] / (SUM([employee_count]) OVER(PARTITION BY benchmark_metric_name)))
				END AS client_metric

			,CASE WHEN [benchmark_metric_name] in ('Total cost as % of revenue', 'Personnel cost as % of revenue')  THEN [median_potential_amount]
				WHEN [benchmark_metric_name] in ('Function FTEs per $1B revenue', 'FTEs as % of total FTEs') THEN [median_potential_fte]
				ELSE 0
				END AS median_potential
			,CASE WHEN [benchmark_metric_name] in ('Total cost as % of revenue', 'Personnel cost as % of revenue')  THEN [top_quartile_potential_amount]
				WHEN [benchmark_metric_name] in ('Function FTEs per $1B revenue', 'FTEs as % of total FTEs') THEN [top_quartile_potential_fte]
				ELSE 0
				END AS top_quartile_potential

			,CASE WHEN [benchmark_metric_name] in ('Total cost as % of revenue', 'Personnel cost as % of revenue')  THEN [median_opportunity_amount]
				WHEN [benchmark_metric_name] in ('Function FTEs per $1B revenue', 'FTEs as % of total FTEs') THEN [median_opportunity_fte]
				ELSE 0
				END AS median_opportunity
			,CASE WHEN [benchmark_metric_name] in ('Total cost as % of revenue', 'Personnel cost as % of revenue')  THEN [top_quartile_opportunity_amount]
				WHEN [benchmark_metric_name] in ('Function FTEs per $1B revenue', 'FTEs as % of total FTEs') THEN [top_quartile_opportunity_fte]
				ELSE 0
				END AS top_quartile_opportunity

			,[median_opportunity_percent_baseline]   
			,[top_quartile_opportunity_percent_baseline]
			,[median_opportunity_amount]
			,[top_quartile_opportunity_amount]

		FROM #temptable
		LEFT JOIN [vc].[benchmark_metric]
			ON [benchmark_metric].[name] = #temptable.[benchmark_metric_name]
			-- If two benchmark peer group for one function share the same keys, need to get 'benchmark_peer_group_id'
			-- from the individual SP.
		LEFT JOIN [vc].[function_benchmark]
			ON [function_benchmark].[function_id] = #temptable.[function_id] 
			AND [function_benchmark].[benchmark_metric_id] = [benchmark_metric].[benchmark_metric_id]
			AND [function_benchmark].[median] = #temptable.[median]
			AND [function_benchmark].[top_quartile] =#temptable.[top_quartile]

		LEFT JOIN [vc].[benchmark_peer_group]
			ON [benchmark_peer_group].[benchmark_peer_group_id] = [function_benchmark].[benchmark_peer_group_id]
	)
	SELECT *
	FROM slider_table
	WHERE slider_table.top_quartile IS NOT NULL;

	DROP TABLE #temptable
------------------------------------------------------------------------------

END
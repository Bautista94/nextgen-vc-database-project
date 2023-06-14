CREATE    PROCEDURE [vc].[proc_getSavingsOpportunitiesByProcurementDetailed]
(
	@input_year INT,
	@designation_id INT
) 
AS
BEGIN

	--DECLARE	@input_year INT = 300,
	--		@designation_id INT = NULL;
	
---------------------------------------------------------------------------------------------------------------
--Grouped by Category and Function / Detailed view
---------------------------------------------------------------------------------------------------------------

WITH func_data AS (
	SELECT
		[year_id]
		,[year]
		,[v_proc_data].[procurement_category_id]
		,[category]
		--,[v_proc_data].[procurement_sub_category_id]
		--,[v_proc_data].[sub_category]
		,[v_proc_data].[function_id]
		,[function]
		--,COALESCE(SUM([designation_revenue]),0) AS designation_revenue
		,COALESCE(SUM([non_labor_amount]),0) AS non_labor_amount
		,[procurement_benchmark].low_factor AS median
		,[procurement_benchmark].high_factor AS top_quartile

		--MEDIAN
		,CASE WHEN [low_factor] IS NULL THEN NULL ELSE low_factor * SUM([non_labor_amount]) END AS median_opportunity_amount
		,CASE WHEN [low_factor] IS NULL THEN NULL ELSE low_factor END AS median_opportunity_percent_baseline

		--TOP QUARTILE
		,CASE WHEN [high_factor] IS NULL THEN NULL ELSE  high_factor * SUM([non_labor_amount]) END AS top_quartile_opportunity_amount
		,CASE WHEN [high_factor] IS NULL THEN NULL ELSE  high_factor END AS top_quartile_opportunity_percent_baseline

	FROM 
	[vc].[v_proc_data]

	LEFT JOIN [vc].[procurement_benchmark]
	ON [procurement_benchmark].[procurement_category_id] = [v_proc_data].[procurement_category_id]
	AND [procurement_benchmark].[designation_id] = [v_proc_data].[designation_id]
	--AND [function_benchmark].benchmark_peer_group_id = (SELECT MIN(benchmark_peer_group_id ) FROM [vc].[benchmark_peer_group]) --replace this for the one below once user interface is developed
	--AND function_benchmark.benchmark_peer_group_id = @benchmark_peer_group --no user interface for this right now, just use the first one

	WHERE 
	[year_id] = @input_year
	AND (@designation_id IS NULL OR [v_proc_data].[designation_id] = @designation_id)

	GROUP BY
		[year_id]
		,[year]
		,[v_proc_data].[procurement_category_id]
		,[category]
		--,[v_proc_data].[procurement_sub_category_id]
		--,[v_proc_data].[sub_category]
		,[v_proc_data].[function_id]
		,[function]

		,[procurement_benchmark].low_factor
		,[procurement_benchmark].high_factor
),
best_table AS
(
	SELECT [function]
	FROM [vc].[sp_function_best]
	WHERE [benchmark_metric_name] = 'Total cost as % of revenue'
)
SELECT
	func_data.[year_id]
	,func_data.[year]
	,[procurement_category_id]
	,[category]
	,func_data.[function_id]
	,func_data.[function]
	,SUM([non_labor_amount]) AS [non_labor_amount]
	--,[top_quartile]
	--,[median] 
	,SUM([median_opportunity_amount]) AS [median_opportunity_amount]
	,SUM([median_opportunity_amount])/NULLIF(SUM([non_labor_amount]),0) AS [median_opportunity_percent_baseline]
	,SUM([top_quartile_opportunity_amount]) AS [top_quartile_opportunity_amount]
	,SUM([top_quartile_opportunity_amount])/NULLIF(SUM([non_labor_amount]),0) AS [top_quartile_opportunity_percent_baseline]
	,CASE WHEN func_data.[function] = best_table.[function] THEN 1 ELSE 0 END AS IsIndirect
	--,CASE WHEN ROW_NUMBER() OVER (PARTITION BY [category] ORDER BY RAND()) = 1 THEN 1 ELSE 0 END AS IsIndirect

FROM func_data
LEFT JOIN best_table
	ON func_data.[function] = best_table.[function]

GROUP BY
    func_data.[year_id]
    ,func_data.[year]
	,[procurement_category_id]
    ,[category]
    ,func_data.[function_id]
    ,func_data.[function]
	,best_table.[function]
;

END

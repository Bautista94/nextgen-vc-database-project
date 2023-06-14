CREATE    PROCEDURE [vc].[proc_getSavingsOpportunitiesByProcurement]
(
	@input_year INT,
	@designation_id INT
) 
AS
BEGIN

	--DECLARE	@input_year INT =300,
	--		@designation_id INT = NULL;
		
---------------------------------------------------------------------------------------------------------------
--Grouped by Category
---------------------------------------------------------------------------------------------------------------

WITH func_data AS
(
	SELECT
		[year_id]
		,[year]
		,[v_proc_data].[procurement_category_id]
		,[v_proc_data].[category]

		,COALESCE(SUM([non_labor_amount]),0) AS non_labor_amount
		,[procurement_benchmark].low_factor AS median
		,[procurement_benchmark].high_factor AS top_quartile

		--MEDIAN
		,CASE WHEN [low_factor] IS NULL THEN NULL ELSE low_factor * SUM([non_labor_amount]) END AS median_opportunity_amount
		,CASE WHEN [low_factor] IS NULL THEN NULL ELSE low_factor END AS median_opportunity_percent_bASeline

		--TOP QUARTILE
		,CASE WHEN [high_factor] IS NULL THEN NULL ELSE  high_factor * SUM([non_labor_amount]) END AS top_quartile_opportunity_amount
		,CASE WHEN [high_factor] IS NULL THEN NULL ELSE  high_factor END AS top_quartile_opportunity_percent_bASeline
	
	FROM [vc].[v_proc_data]
	LEFT JOIN [vc].[procurement_benchmark]
		ON [procurement_benchmark].[procurement_category_id] = [v_proc_data].[procurement_category_id]
		AND [procurement_benchmark].[designation_id] = [v_proc_data].[designation_id]
	WHERE
		[year_id] = @input_year
		AND (@designation_id IS NULL OR [v_proc_data].[designation_id] = @designation_id)

	GROUP BY
		[year_id]
		,[year]
		,[v_proc_data].[procurement_category_id]
		,[v_proc_data].[category]
		,[procurement_benchmark].low_factor
		,[procurement_benchmark].high_factor
)
	SELECT 
		[year_id]
		,[year]
		,[procurement_category_id]
		,[category]
		,SUM([non_labor_amount]) AS non_labor_amount
		,AVG([top_quartile]) AS top_quartile
		,AVG([median]) AS median
		,SUM([median_opportunity_amount]) AS median_opportunity_amount
		,SUM([median_opportunity_amount])/SUM([non_labor_amount]) AS median_opportunity_percent_baseline
		,SUM([top_quartile_opportunity_amount]) AS top_quartile_opportunity_amount
		,SUM([top_quartile_opportunity_amount])/SUM([non_labor_amount]) AS top_quartile_opportunity_percent_baseline

	FROM func_data
	GROUP BY
		[year_id]
		,[year]
		,[procurement_category_id]
		,[category] 

END

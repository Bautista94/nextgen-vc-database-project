/* ================================================================================================================================================
   Procedure Name : [vc].[proc_func_FTEs_as_%_of_total_FTEs]
   Purpose : Show the 'FTE as percentage of total FTEs' benchmark for every function in the gap to benchmark views.
			Also, contains the columns for the FTE option view.
   Last Modified: 21/02/2023
   Date Modified:   
   Inputs :
		@input_year: ID for year
		@designation_id: ID for designation
		@benchmark_metric: ID for the 'FTE as percentage of total FTEs' benchmark
   
   Outputs:
	   A result set containing the columns for the 'FTE as percentage of total FTEs' benchmark drop down option it the gap to benchmark views.

	Parameters :
	This can be replace by procedure parameters for testing with the following declare statement:

		DECLARE
			@input_year INT = 1295,
			@designation_id INT = NULL,
			@benchmark_metric INT = 823;


/*
select * from vc.designation
select * from vc.benchmark_metric
select * from vc.function_benchmark
select * from vc.year
*/
================================================================================================================================================*/

CREATE   PROCEDURE [vc].[proc_func_FTEs_as_%_of_total_FTEs](
    @input_year int,
    @designation_id int,
	@benchmark_metric int
--@benchmark_peer_group int --uncomment this once user interface is developed
) AS
BEGIN

WITH func_data as (
SELECT
    [year_id]
    ,[year]
    ,[function_type_id]
    ,[function_type]
    ,[v_func_data].[function_id]
    ,[function]
    ,COALESCE(SUM([designation_revenue]),0) as designation_revenue 
    ,COALESCE(SUM([labor_amount]),0) as labor_amount
    ,COALESCE(SUM([employee_count]),0) as employee_count
    ,COALESCE(SUM([non_labor_amount]),0) as non_labor_amount
	,SUM(COALESCE([labor_amount],0)+COALESCE([non_labor_amount],0)) as total_amount
	,function_benchmark.top_quartile
	,function_benchmark.median

	--,(SUM([employee_count]) / SUM(SUM([employee_count])) OVER()) --client 
	--MEDIAN
		--COST
	,SUM([labor_amount]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()) as median_potential_amount
	,(SUM([employee_count]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())) / SUM([employee_count]) as median_potential_percent_baseline
	,SUM([employee_count]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()) as median_potential_fte
		--GAP
	,CASE WHEN [median] is null then null else GREATEST(SUM([labor_amount]) - (SUM([labor_amount]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())),0) END as median_opportunity_amount
	,CASE WHEN [median] is null then null else GREATEST((SUM([employee_count]) - (SUM([employee_count]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()))) / SUM([employee_count]),0) END as median_opportunity_percent_baseline
	,CASE WHEN [median] is null then null else GREATEST(SUM([employee_count]) - (SUM([employee_count]) * median / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())),0) END as median_opportunity_fte

	--TOP QUARTILE
		--COST
	,SUM([labor_amount]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()) as top_quartile_potential_amount
	,(SUM([employee_count]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())) / SUM([employee_count]) as top_quartile_potential_percent_baseline
	,SUM([employee_count]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()) as top_quartile_potential_fte
		--GAP
	,CASE WHEN [top_quartile] is null then null else GREATEST(SUM([labor_amount]) - (SUM([labor_amount]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())),0) END as top_quartile_opportunity_amount
	,CASE WHEN [top_quartile] is null then null else GREATEST((SUM([employee_count]) - (SUM([employee_count]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER()))) / SUM([employee_count]),0) END as top_quartile_opportunity_percent_baseline
	,CASE WHEN [top_quartile] is null then null else GREATEST(SUM([employee_count]) - (SUM([employee_count]) * top_quartile / (SUM([employee_count]) / SUM(SUM([employee_count])) OVER())),0) END as top_quartile_opportunity_fte

FROM 
[vc].[v_func_data]

LEFT JOIN vc.function_benchmark
ON function_benchmark.function_id = [v_func_data].function_id
AND function_benchmark.benchmark_metric_id = @benchmark_metric
AND function_benchmark.benchmark_peer_group_id = (SELECT MIN(benchmark_peer_group_id ) FROM [vc].[benchmark_peer_group]) --replace this for the one below once user interface is developed
--AND function_benchmark.benchmark_peer_group_id = @benchmark_peer_group --no user interface for this right now, just use the first one

WHERE 
[year_id] = @input_year
AND (@designation_id is null OR [designation_id] = @designation_id)


GROUP BY
    [year_id]
    ,[year]
    ,[function_type_id]
    ,[function_type]
    ,[v_func_data].[function_id]
    ,[function]

	,function_benchmark.top_quartile
	,function_benchmark.median
)

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
--,median_customer_metric
--,median_savings_multiplier
--,median_implied_savings
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

--TOTALS TOTAL LABOR 
,SUM(CASE WHEN top_quartile is not null then labor_amount + non_labor_amount else null END) OVER() as 'total_benchmark_total_amount' --ok
,SUM(total_amount) OVER() as 'total_total_amount' --ok

--TOTALS LABOR 
,SUM(CASE WHEN top_quartile is not null then labor_amount else null END) OVER() as 'total_benchmark_labor_amount' --ok
,SUM(labor_amount) OVER() as 'total_labor_amount' --ok
	--FTE
	--,SUM(CASE WHEN top_quartile is not null then employee_count else null END) OVER() as 'total_benchmark_total_fte' --ok
	--,SUM(employee_count) OVER() as 'total_total_fte' --ok

--TOTALS median_opportunity_amount
,SUM(median_opportunity_amount) OVER () as 'total_benchmark_median_opportunity_amount'
,SUM(median_opportunity_amount) OVER () as 'total_median_opportunity_amount'
	--FTE
	--,SUM(median_opportunity_fte) OVER () as 'total_median_opportunity_fte'

--TOTALS median_opportunity_percent_baseline
,SUM(median_opportunity_amount) OVER () / SUM(CASE WHEN top_quartile is not null then labor_amount else null END) OVER() as 'total_benchmark_median_opportunity_percent_baseline'
,SUM(median_opportunity_amount) OVER () / SUM(labor_amount) OVER() as 'total_median_opportunity_percent_baseline'
	--FTE
	--,SUM(median_opportunity_fte) OVER () / SUM(CASE WHEN top_quartile is not null then employee_count else null END) OVER() as 'total_benchmark_median_opportunity_percent_baseline_fte'
	--,SUM(median_opportunity_fte) OVER () / SUM(employee_count) OVER() as 'total_median_opportunity_percent_baseline_fte'

--TOTALS top_quartile_opportunity_amount
,SUM(top_quartile_opportunity_amount) OVER () as 'total_benchmark_top_quartile_opportunity_amount'
,SUM(top_quartile_opportunity_amount) OVER () as 'total_top_quartile_opportunity_amount'
	--FTE
	--,SUM(top_quartile_opportunity_fte) OVER () as 'total_top_quartile_opportunity_fte'

--TOTALS top_quartile_opportunity_percent_baseline
,SUM(top_quartile_opportunity_amount) OVER () / SUM(CASE WHEN top_quartile is not null then labor_amount else null END) OVER() as 'total_benchmark_top_quartile_opportunity_percent_baseline'
,SUM(top_quartile_opportunity_amount) OVER () / SUM(labor_amount) OVER() as 'total_top_quartile_opportunity_percent_baseline'
	--FTE
	--,SUM(top_quartile_opportunity_fte) OVER () / SUM(CASE WHEN top_quartile is not null then employee_count else null END) OVER() as 'total_benchmark_top_quartile_opportunity_percent_baseline_fte'
	--,SUM(top_quartile_opportunity_fte) OVER () / SUM(employee_count) OVER() as 'total_top_quartile_opportunity_percent_baseline_fte'

FROM func_data

END

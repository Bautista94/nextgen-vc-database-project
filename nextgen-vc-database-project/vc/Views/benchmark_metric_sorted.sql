

CREATE   VIEW [vc].[benchmark_metric_sorted] AS

	SELECT TOP 1000
		[benchmark_metric_id]
		,[name]
		,[is_total_cost]

	FROM 
		[vc].[benchmark_metric]
	
	ORDER BY 
		CASE 
		WHEN [name]='Total cost as % of revenue' THEN 1
		WHEN [name]='Personnel cost as % of revenue' THEN 2
		WHEN [name]='FTEs as % of total FTEs' THEN 3
		WHEN [name]='Function FTEs per $1B revenue' THEN 4
		ELSE 5 END 


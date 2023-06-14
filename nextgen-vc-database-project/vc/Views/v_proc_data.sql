CREATE      VIEW [vc].[v_proc_data] AS
WITH group_proc AS (--groups procurement data at the year/designation/function level
	SELECT
		--[procurement_sub_category_id]
		[procurement_category_id]
		,[function_id]
		,[designation_id]
		,[year]
		,[year_id]
		,SUM([amount]) AS non_labor_amount

	FROM
		[vc].[procurement_data]

	--LEFT JOIN
	--	[vc].[spend_type]
	--	ON [spend_type].[spend_type_id] = [procurement_data].[spend_type_id]

	GROUP BY
		--[procurement_sub_category_id]
		[procurement_category_id]
		,[function_id]
		,[designation_id]
		,[year]
		,[year_id]
)
--------------------------------------------------------------------
SELECT
	[group_proc].[year_id]
	,[group_proc].[year]

	--,[group_proc].[procurement_sub_category_id]
	--,[procurement_sub_category].[name] AS sub_category

	,[group_proc].[designation_id]
	,[designation].[name] AS designation

	,[group_proc].[procurement_category_id]
	,[procurement_category].[name] AS category

	,[function].[function_type_id]
	,[function_type].[name] AS function_type

	,[group_proc].[function_id]
	,[function].[name] AS [function]

	,[designation].[revenue] AS designation_revenue
	,[group_proc].[non_labor_amount]


FROM 
	[group_proc]

--LEFT JOIN
	--[vc].[procurement_sub_category]
	--ON [procurement_sub_category].[procurement_sub_category_id] = [group_proc].[procurement_sub_category_id]

LEFT JOIN
	[vc].[procurement_category]
	ON [procurement_category].[procurement_category_id] = [group_proc].[procurement_category_id]

LEFT JOIN
	[vc].[function]
	ON [function].[function_id] = [group_proc].[function_id]

LEFT JOIN
	[vc].[function_type]
	ON [function_type].[function_type_id] = [function].[function_type_id]

LEFT JOIN
	[vc].[designation]
	ON [designation].[designation_id] = [group_proc].[designation_id]


CREATE   VIEW [vc].[v_func_data] AS
WITH group_func as (--groups function data at the year/designation/function level
	SELECT 
		[function_data].[function_id]
		,[function_data].[designation_id]
		,[function_data].[year]
		,[function_data].[year_id]
		,SUM([function_data].[amount]) as labor_amount
		,SUM([function_data].[employee_count]) as employee_count

	FROM 
		[vc].[function_data]

	GROUP BY
		[function_data].[function_id]
		,[function_data].[designation_id]
		,[function_data].[year]
		,[function_data].[year_id]
),
--------------------------------------------------
group_proc as (--groups procurement data at the year/designation/function level
	SELECT
		[function_id]
		,[designation_id]
		,[year]
		,[year_id]
		,SUM([amount]) as non_labor_amount

	FROM
		[vc].[procurement_data]

	LEFT JOIN
		[vc].[spend_type]
		ON [spend_type].[spend_type_id] = [procurement_data].[spend_type_id]

	GROUP BY
		[function_id]
		,[designation_id]
		,[year]
		,[year_id]
)
--------------------------------------------------------------------
SELECT
	[group_func].[year_id]
	,[group_func].[year]

	,[group_func].[designation_id]
	,[designation].[name] as designation

	,[function].[function_type_id]
	,[function_type].[name] as function_type

	,[group_func].[function_id]
	,[function].[name] as [function]

	,[designation].[revenue] as designation_revenue

	,[group_func].[labor_amount]
	,[group_func].[employee_count]
	,[group_proc].[non_labor_amount]


FROM 
	group_func

LEFT JOIN
	group_proc
	ON [group_proc].[function_id] = [group_func].[function_id]
	AND [group_proc].[designation_id] = [group_func].[designation_id]
	AND [group_proc].[year_id] = [group_func].[year_id]

LEFT JOIN
	[vc].[function]
	ON [function].[function_id] = [group_func].[function_id]

LEFT JOIN
	[vc].[function_type]
	ON [function_type].[function_type_id] = [function].[function_type_id]

LEFT JOIN
	[vc].[designation]
	ON [designation].[designation_id] = [group_func].[designation_id]

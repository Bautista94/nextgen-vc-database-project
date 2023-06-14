
CREATE PROCEDURE [vc_staging].[validate_function_data_ingested]

AS
BEGIN
	WITH function_data_agg_raw AS (
	SELECT
		year
		,Designation
		,[Function Type]
		,[function]
		,[Spend Type]
		,[business unit]
		,[Account Number]
		,[cost center]	
		,sum([Amount]) as amount
		,sum([Employee Count]) as employee_count
	FROM
		vc_staging.function_data_raw
	GROUP BY
		year
		,Designation
		,[Function Type]
		,[function]
		,[Spend Type]
		,[business unit]
		,[Account Number]
		,[cost center])
	, function_function_type_counts_raw AS (
	SELECT
		function_data_agg_raw.[Function Type]
		,function_data_agg_raw.[function]
		,count(*) as [records]
	FROM
		function_data_agg_raw
	GROUP BY
		function_data_agg_raw.[Function Type]
		,function_data_agg_raw.[function]
	), function_function_type_counts_ring AS (
	SELECT
		ft.name	as function_type
		,f.name as [function]
		,count(fd.function_data_id) as [records]
	FROM
		vc.function_data fd
		INNER JOIN vc.[function] f
			ON f.function_id = fd.function_id
		INNER JOIN vc.[function_type] ft
			ON ft.function_type_id = f.function_type_id
	GROUP BY
		ft.name
		,f.name)
	SELECT
		CASE
			WHEN ic.function_type IS NULL OR ic.[function] IS NULL OR  ic.records IS NULL THEN	
				'Missing ' + CAST(RC.records AS nvarchar(100)) + ' record(s) in function type/function:[' + rc.[Function Type] + '/' +  RC.[Function] + ']'
			ELSE
				'Validation OK'
			END AS Result
	FROM
		function_function_type_counts_raw rc
		LEFT JOIN function_function_type_counts_ring ic
			ON rc.[Function Type] = ic.function_type
			AND	RC.[Function] = ic.[function]
			AND	RC.records = ic.records
	WHERE
		ic.function_type IS NULL OR ic.[function] IS NULL OR  ic.records IS NULL
END

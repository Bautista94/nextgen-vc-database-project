
CREATE PROCEDURE [vc_staging].[validate_designation_function_data]
AS
BEGIN
	

WITH function_preagg_raw as (
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
, procurement_preagg_raw as (
	SELECT
		year
		,Designation
		,[Category]
		,[SubCategory]
		,[function]
		,[Is Direct]
		,[Spend Type]
		,[business unit]
		,[Account Number]
		,sum([Amount]) as amount
	FROM
		vc_staging.procurement_data_raw
	GROUP BY
		year
		,Designation
		,[Category]
		,[SubCategory]
		,[function]
		,[Is Direct]
		,[Spend Type]
		,[business unit]
		,[Account Number])
,total_function_designation_raw as (
	SELECT
		[function],
		[designation]
	FROM
		function_preagg_raw 
	UNION ALL
	SELECT
		[function],
		[designation]
	FROM
		procurement_preagg_raw 
), total_function_designation_agg_raw AS (
	SELECT
		COUNT(*) AS [Records]
		,[function]
		,[Designation]
	FROM
		total_function_designation_raw
	GROUP BY
		[function]
		,[Designation])
, total_function_designation_ing AS (
	SELECT
		function_data_id AS [internal_id]
		,function_id
		,designation_id
	FROM
		vc.function_data 
	UNION ALL
	SELECT
		procurement_data_id as [internal_id]
		,function_id
		,designation_id
	FROM
		vc.procurement_data)
, total_function_designation_agg_ing AS (
	SELECT
		f.name as [function]
		,d.name as [designation]
		,count(fd.[internal_id]) AS [records]
	FROM
		total_function_designation_ing fd
		INNER JOIN vc.[function] f
			ON f.function_id = fd.function_id
		INNER JOIN vc.[designation] d
			ON d.designation_id = fd.designation_id
	GROUP BY
		f.name 
		,d.name )
SELECT DISTINCT
	CASE
		WHEN ia.[function] IS NULL OR ia.[designation] IS NULL OR  ia.records IS NULL THEN 	
			'Missing ' + CAST(ra.records AS nvarchar(100)) + ' record(s) in Function/Designation:[' +  ra.[Function] + '/' + ra.Designation  +  ']'
		ELSE
			'Validation OK'
	END AS Result
FROM
	total_function_designation_agg_raw ra
	LEFT JOIN total_function_designation_agg_ing ia
		ON ra.[Function] = ia.[function]
		AND ra.Designation = ia.[designation]
		AND ra.Records = ia.records
WHERE
	ia.[function] IS NULL OR ia.[designation] IS NULL OR ia.records IS NULL
	
END

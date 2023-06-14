
CREATE PROCEDURE [vc_staging].[validate_procurement_data_ingested]
AS
BEGIN
	WITH procurement_data_agg_raw AS (
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
	, category_sub_category_counts_raw AS (
	SELECT
		procurement_data_agg_raw.[Category]
		,procurement_data_agg_raw.[SubCategory]
		,procurement_data_agg_raw.[function]
		,count(*) as [records]
	FROM
		procurement_data_agg_raw
	GROUP BY
		procurement_data_agg_raw.[Category]
		,procurement_data_agg_raw.[SubCategory]
		,procurement_data_agg_raw.[function]
	), category_sub_category_counts_ing AS (
	SELECT
		pc.name	as procurement_category
		,psc.name as procurement_sub_category
		,f.name as [function]
		,count(pd.procurement_data_id) as [records]
	FROM
		vc.procurement_data pd
		INNER JOIN vc.[procurement_sub_category] psc
			ON psc.procurement_sub_category_id= pd.procurement_sub_category_id
		INNER JOIN vc.[procurement_category] pc
			ON pc.procurement_category_id= psc.procurement_category_id
		INNER JOIN vc.[function] f
			ON f.function_id = pd.function_id
	GROUP BY
		pc.name
		,psc.name
		,f.name)
	SELECT DISTINCT
		CASE
			WHEN ic.procurement_category IS NULL OR ic.procurement_sub_category IS NULL OR  ic.[function] IS NULL OR IC.records IS NULL THEN 	
				'Missing ' + CAST(RC.records AS nvarchar(100)) + ' record(s) in Category/SubCategory/Function:[' + rc.[Category] + '/' +  RC.SubCategory + '/' + RC.[Function] +  ']'
			ELSE
				'Validation OK'
			END AS Result
	FROM
		category_sub_category_counts_raw rc
		LEFT JOIN category_sub_category_counts_ing ic
			ON rc.[Category] = ic.procurement_category
			AND	RC.SubCategory = ic.procurement_sub_category
			AND rc.[Function] = ic.[function]
			AND	RC.records = ic.records
	WHERE
		ic.procurement_category IS NULL OR ic.procurement_sub_category IS NULL OR  ic.records IS NULL OR ic.[function] IS NULL
END

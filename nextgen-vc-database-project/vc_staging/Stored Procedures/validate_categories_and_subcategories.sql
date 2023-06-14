
CREATE PROCEDURE [vc_staging].[validate_categories_and_subcategories]

AS
BEGIN
	WITH procurement_categories_sub_categories_ing AS (
		SELECT
			pc.name as category
			,psc.name as subcategory
		FROM
			vc.procurement_category pc
			INNER JOIN vc.procurement_sub_category psc
				ON pc.procurement_category_id = psc.procurement_category_id)
	SELECT DISTINCT
		CASE
			WHEN procurement_categories_sub_categories_ing.subcategory IS NULL OR procurement_categories_sub_categories_ing.category IS NULL THEN
				'Missing category/subcategory --> [' + CAST( vc_staging.procurement_data_raw.Category+'/'+ vc_staging.procurement_data_raw.SubCategory as nvarchar(100)) + ']'
			ELSE
				'Validation OK'
		END AS Result
	FROM
		vc_staging.procurement_data_raw 
		LEFT JOIN procurement_categories_sub_categories_ing
			ON procurement_categories_sub_categories_ing.category = vc_staging.procurement_data_raw.Category
			AND procurement_categories_sub_categories_ing.subcategory = vc_staging.procurement_data_raw.SubCategory
	WHERE
		procurement_categories_sub_categories_ing.category IS NULL
		OR procurement_categories_sub_categories_ing.subcategory IS NULL
END


CREATE PROCEDURE [vc_staging].[validate_categories]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN categories_raw.category IS NULL THEN
				'Validation OK'
			WHEN categories_ing.category IS NULL THEN
				'Missing category --> [ ' + CAST(categories_raw.category as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			category
		FROM
			vc_staging.procurement_data_raw) categories_raw
	LEFT JOIN
		(SELECT
			name as category
		FROM
			vc.procurement_category pd) categories_ing 
		ON categories_raw.category = categories_ing.category
	WHERE
		categories_ing.category IS NULL
END

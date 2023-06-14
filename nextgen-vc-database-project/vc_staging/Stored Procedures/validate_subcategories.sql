CREATE PROCEDURE [vc_staging].[validate_subcategories]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN subcategories_raw.[subcategory] IS NULL THEN
				'Validation OK'
			WHEN subcategories_ing.[subcategory] IS NULL THEN
				'Missing subcategory --> [ ' + CAST(subcategories_raw.[subcategory] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[subcategory]
		FROM
			vc_staging.procurement_data_raw) subcategories_raw
	LEFT JOIN
		(SELECT
			name as [subcategory]
		FROM
			vc.[procurement_sub_category] pd) subcategories_ing 
		ON subcategories_raw.[subcategory] = subcategories_ing.[subcategory]
	WHERE
		subcategories_ing.[subcategory] IS NULL
END

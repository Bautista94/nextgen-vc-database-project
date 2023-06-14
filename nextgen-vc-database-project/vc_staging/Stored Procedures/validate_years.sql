

CREATE PROCEDURE [vc_staging].[validate_years]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN years_raw.year IS NULL THEN
				'Validation OK'
			WHEN years_ing.year IS NULL THEN
				'Missing year ' + CAST(years_raw.year as nvarchar(100))
		END AS Result
	FROM
		(SELECT
			year 
		FROM
			vc_staging.function_data_raw
		UNION
		SELECT
			year
		FROM
			vc_staging.procurement_data_raw) years_raw
	LEFT JOIN
		(SELECT
			year
		FROM
			vc.procurement_data pd
		UNION
		SELECT
			year
		FROM
			vc.function_data fd) years_ing 
		ON years_raw.year = years_ing.year
	WHERE
		years_ing.year IS NULL
END




CREATE PROCEDURE [vc_staging].[validate_business_units]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN business_unit_raw.[business unit] IS NULL THEN
				'Validation OK'
			WHEN business_unit_ing.[business unit] IS NULL THEN
				'Missing business unit --> [' + CAST(business_unit_raw.[business unit] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT DISTINCT
			CAST([business unit] AS nvarchar(100)) AS [business unit]
		FROM
			vc_staging.function_data_raw
		UNION
		SELECT DISTINCT
			CAST([business unit] AS nvarchar(100)) AS [business unit]
		FROM
			vc_staging.procurement_data_raw) business_unit_raw
	LEFT JOIN
		(SELECT
			name as [business unit]
		FROM
			vc.business_unit pd) business_unit_ing 
		ON business_unit_raw.[business unit] = business_unit_ing.[business unit]
	WHERE
		business_unit_ing.[business unit] IS NULL
END

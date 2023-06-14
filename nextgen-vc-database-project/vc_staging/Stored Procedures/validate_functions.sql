CREATE PROCEDURE [vc_staging].[validate_functions]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN functions_raw.[function] IS NULL THEN
				'Validation OK'
			WHEN functions_ing.[function] IS NULL THEN
				'Missing function --> [ ' + CAST(functions_raw.[function] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[function]
		FROM
			vc_staging.function_data_raw) functions_raw
	LEFT JOIN
		(SELECT
			name as [function]
		FROM
			vc.[function] pd) functions_ing 
		ON functions_raw.[function] = functions_ing.[function]
	WHERE
		functions_ing.[function] IS NULL
END

CREATE PROCEDURE [vc_staging].[validate_function_types]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN functiontypes_raw.[function type] IS NULL THEN
				'Validation OK'
			WHEN functiontypes_ing.[function type] IS NULL THEN
				'Missing category --> [ ' + CAST(functiontypes_raw.[function type] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[function type]
		FROM
			vc_staging.function_data_raw) functiontypes_raw
	LEFT JOIN
		(SELECT
			name as [function type]
		FROM
			vc.function_type pd) functiontypes_ing 
		ON functiontypes_raw.[function type] = functiontypes_ing.[function type]
	WHERE
		functiontypes_ing.[function type] IS NULL
END

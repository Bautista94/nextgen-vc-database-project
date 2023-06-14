
CREATE PROCEDURE [vc_staging].[validate_functions_and_function_types]

AS
BEGIN
	WITH functions_raw AS (
	SELECT
			[function]
		FROM
			vc_staging.function_data_raw
		UNION
		SELECT
			[function]
		FROM
			vc_staging.procurement_data_raw)
		, function_function_types_raw AS (
			SELECT DISTINCT
				functions_raw.[function]
				,[Function Type] 
			FROM
				functions_raw 	
				INNER JOIN vc_staging.function_data_raw
					ON functions_raw.[Function] = vc_staging.function_data_raw.[Function])
	, function_function_types_ing AS (
	SELECT
		ft.name as	function_type
		,f.name as [function]
	FROM
		vc.[function] f
		INNER JOIN vc.function_type ft
			ON f.function_type_id  = ft.function_type_id)
	SELECT
		CASE
			WHEN function_function_types_ing.function_type IS NULL OR function_function_types_ing.[function] IS NULL THEN
				'Missing function/function_type --> [' + CAST(function_function_types_raw.[Function Type]+'/'+function_function_types_raw.[Function] as nvarchar(100)) + ']'
			ELSE
				'Validation OK'
		END AS Result
	FROM
		function_function_types_raw 
		LEFT JOIN function_function_types_ing
			ON function_function_types_ing.function_type = function_function_types_raw.[Function Type]
			AND function_function_types_ing.[function] =   function_function_types_raw.[Function]
	WHERE
		 function_function_types_ing.[function] IS NULL
END

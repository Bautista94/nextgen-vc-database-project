CREATE PROCEDURE [vc_staging].[validate_cost_centers]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN cost_centers_raw.[cost center] IS NULL THEN
				'Validation OK'
			WHEN cost_centers_ing.[cost center] IS NULL THEN
				'Missing cost center --> [ ' + CAST(cost_centers_raw.[cost center] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[cost center]
		FROM
			vc_staging.function_data_raw) cost_centers_raw
	LEFT JOIN
		(SELECT
			name as [cost center]
		FROM
			vc.[cost_center] pd) cost_centers_ing 
		ON cost_centers_raw.[cost center] = cost_centers_ing.[cost center]
	WHERE
		cost_centers_ing.[cost center] IS NULL
END

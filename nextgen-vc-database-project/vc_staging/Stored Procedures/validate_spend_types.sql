

CREATE PROCEDURE [vc_staging].[validate_spend_types]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN spend_type_raw.[spend type] IS NULL THEN
				'Validation OK'
			WHEN spend_type_ing.[spend type] IS NULL THEN
				'Missing spend type --> [' + CAST(spend_type_raw.[spend type] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[spend type] 
		FROM
			vc_staging.function_data_raw
		UNION
		SELECT
			[spend type]
		FROM
			vc_staging.procurement_data_raw) spend_type_raw
	LEFT JOIN
		(SELECT
			name as [spend type]
		FROM
			vc.spend_type pd) spend_type_ing 
		ON spend_type_raw.[spend type] = spend_type_ing.[spend type]
	WHERE
		spend_type_ing.[spend type] IS NULL
END

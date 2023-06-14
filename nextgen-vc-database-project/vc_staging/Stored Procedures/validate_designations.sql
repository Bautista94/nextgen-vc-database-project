
CREATE PROCEDURE [vc_staging].[validate_designations]

AS
BEGIN
	SELECT DISTINCT
		CASE
			WHEN designations_raw.[designation] IS NULL THEN
				'Validation OK'
			WHEN designations_ing.[designation] IS NULL THEN
				'Missing designation --> [' + CAST(designations_raw.[designation] as nvarchar(100)) + ']'
		END AS Result
	FROM
		(SELECT
			[designation] 
		FROM
			vc_staging.function_data_raw
		UNION
		SELECT
			[designation]
		FROM
			vc_staging.procurement_data_raw) designations_raw
	LEFT JOIN
		(SELECT
			name as [designation]
		FROM
			vc.designation pd) designations_ing 
		ON designations_raw.[designation] = designations_ing.[designation]
	WHERE
		designations_ing.[designation] IS NULL
END

CREATE PROCEDURE [vc_staging].[validate_function_amounts_by_designation]

AS

BEGIN
		WITH function_amounts_by_designation_raw AS (
		SELECT
			SUM(amount) as	partial_amount
			,[Designation]
		FROM
			vc_staging.function_data_raw
		GROUP BY
			[Designation])
		, function_amounts_by_function_ing AS (
		SELECT
			SUM(amount) as	partial_amount
			,d.name as [Designation]
		FROM
			vc.function_data fd
			INNER JOIN vc.[Designation] d
				ON d.designation_id = fd.designation_id
		GROUP BY
			d.name)
		 SELECT
			CASE
				WHEN  fr.partial_amount = fi.partial_amount THEN
					'function amounts by designation: validated OK, equal amounts: [' + CAST(format( fr.partial_amount,'C') AS nvarchar)  + ']'
				WHEN  fr.partial_amount > fi.partial_amount THEN
					'function amounts by designation: ingested amount for [' + fr.[Designation] + '] designation is less than imported dataset by [' + CAST(format( fr.partial_amount-fi.partial_amount,'C') AS nvarchar) + ']'
				WHEN  fi.partial_amount > fr.partial_amount THEN
					'function amounts by designation: dataset amount  for [' + fr.[Designation] + '] designation is less than ingested data by [' + CAST(format(fi.partial_amount- fr.partial_amount,'C') AS nvarchar) + ']'
			END AS Result
		FROM
			function_amounts_by_designation_raw fr
			INNER JOIN function_amounts_by_function_ing fi
				ON fr.[Designation] = fi.[Designation]
				AND fr.partial_amount <> fi.partial_amount
		WHERE
			fi.[Designation] IS NOT NULL AND  fi.partial_amount IS NOT NULL
	
	RETURN
END

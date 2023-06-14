CREATE PROCEDURE [vc_staging].[validate_amounts_by_function]

AS

BEGIN
	WITH amounts_by_function_raw AS (
		SELECT
			SUM(amount) as	partial_amount
			,[function]
		FROM
			vc_staging.function_data_raw
		GROUP BY
			[function])
	, amounts_by_function_ing AS (
		SELECT
			SUM(amount) as	partial_amount
			,f.name as [function]
		FROM
			vc.function_data fd
			INNER JOIN vc.[function] f
				ON F.function_id = fd.function_id
		GROUP BY
			f.name)
		 SELECT
			CASE
				WHEN  fr.partial_amount = fi.partial_amount THEN
					'function amounts: validated OK, equal amounts: [' + CAST(format( fr.partial_amount,'C') AS nvarchar)  + ']'
				WHEN  fr.partial_amount > fi.partial_amount THEN
					'function amounts: ingested amount for [' + fr.[function] + '] function is less than imported dataset by [' + CAST(format( fr.partial_amount-fi.partial_amount,'C') AS nvarchar) + ']'
				WHEN  fi.partial_amount > fr.partial_amount THEN
					'function amounts: dataset amount  for [' + fr.[function] + '] function is less than ingested data by [' + CAST(format(fi.partial_amount- fr.partial_amount,'C') AS nvarchar) + ']'
			END AS Result
		FROM
			amounts_by_function_raw fr
			INNER JOIN amounts_by_function_ing fi
				ON fr.[Function] = fi.[function]
				AND fr.partial_amount <> fi.partial_amount
		WHERE
			fi.[function] IS NOT NULL AND  fi.partial_amount IS NOT NULL
	
	RETURN
END

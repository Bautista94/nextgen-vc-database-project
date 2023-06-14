CREATE PROCEDURE [vc_staging].[validate_function_amounts]

AS

BEGIN
	DECLARE @function_total_raw numeric(18,2);
	DECLARE @function_total_ing numeric(18,2);

	SET @function_total_raw =( 
		SELECT
			sum(amount) as total_amount
		FROM
			vc_staging.function_data_raw);

	SET @function_total_ing = (
		SELECT
			sum(amount) as total_amount
		FROM
			vc.function_data);

	 SELECT
		CASE
			WHEN @function_total_raw = @function_total_ing THEN
				'function amounts: validated OK, equal amounts: [' + CAST(format(@function_total_raw,'C') AS nvarchar)  + ']'
			WHEN @function_total_raw > @function_total_ing THEN
				'function amounts: ingested amount is less than imported dataset by [' + CAST(format(@function_total_raw-@function_total_ing,'C') AS nvarchar) + ']'
			WHEN  @function_total_ing > @function_total_raw THEN
				'function amounts: dataset amount is less than ingested data by [' + CAST(format(@function_total_ing-@function_total_raw,'C') AS nvarchar) + ']'
		END AS Result
	
	RETURN
END

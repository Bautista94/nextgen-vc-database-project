CREATE PROCEDURE [vc_staging].[validate_procurement_amounts]

AS

BEGIN
	DECLARE @procurement_total_raw numeric(18,2);
	DECLARE @procurement_total_ing numeric(18,2);

	SET @procurement_total_raw =( 
		SELECT
			sum(amount) as total_amount
		FROM
			vc_staging.procurement_data_raw);

	SET @procurement_total_ing = (
		SELECT
			sum(amount) as total_amount
		FROM
			vc.procurement_data);

	RETURN SELECT
		CASE
			WHEN @procurement_total_raw = @procurement_total_ing THEN
				'Procurement amounts: validated OK, equal amounts: [' + CAST(format(@procurement_total_raw,'C') AS nvarchar)  + ']'
			WHEN @procurement_total_raw > @procurement_total_ing THEN
				'Procurement amnounts: ingested amount is less than imported dataset by [' + CAST(format(@procurement_total_raw-@procurement_total_ing,'C') AS nvarchar) + ']'
			WHEN  @procurement_total_ing > @procurement_total_raw THEN
				'Procurement amnounts: dataset amount is less than ingested data by [' + CAST(format(@procurement_total_ing-@procurement_total_raw,'C') AS nvarchar) + ']'
		END AS Result
	

END

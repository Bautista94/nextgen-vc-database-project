CREATE PROCEDURE [dbo].[proc_func_test]
AS
BEGIN
	select cost_center_id,
	[name],
	display_name
	 from [vc].[cost_center]

END

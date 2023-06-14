
CREATE PROCEDURE [vc_staging].[validate_ingested_data]

AS

BEGIN
	CREATE TABLE #RESULTS (Result nvarchar(MAX))

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_amounts_by_function;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_business_units ;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_categories;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_categories_and_subcategories;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_cost_centers;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_designation_function_data;

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_designations

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_function_amounts

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_function_amounts_by_designation

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_function_data_ingested

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_function_types

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_functions

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_functions_and_function_types

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_procurement_amounts

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_procurement_amounts_by_designation

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_procurement_data_ingested

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_spend_types

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_subcategories

	INSERT INTO #RESULTS
	EXEC [vc_staging].validate_years

	SELECT * FROM #RESULTS;

	DROP TABLE #RESULTS;

	RETURN
END

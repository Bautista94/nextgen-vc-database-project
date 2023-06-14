CREATE PROCEDURE [vc].[proc_getBenchmarkDropdown](
    @dropdown_input_year int,
    @dropdown_designation_id int,
    @dropdown_query_all bit,
	@dropdown_function_id int
) AS
BEGIN
/*
This stored procedure is used to populate the "Benchmark Metric" dropdown menu in the "support function" area of Mendix.
It was necessary to create this stored procedure cause we only want the drowndown menu to be populated with options that actually have data.

The main logic in this stored procedure is as it follows
1 - We declare the @temp_store_proc_table table variable that is going to hold the results of the actual store procedure that returns the data we want to check if exists 
2 - We declare the @temp_benchmark_metric table variable that we're going to use later to know what benchmark_metrics have data or not
3 - We populate @temp_benchmark_metric table variable with data from the actual [vc].[benchmark_metric] table
4 - We declare @current_id and @max_id variables with the min and max IDs from the [vc].[benchmark_metric] that we're going to use in a loop
5 - We loop each ID in the [vc].[benchmark_metric] table, from every ID we run the [vc].[proc_getFunctionBenchmarkByDesignation] store procedure
6 - In the loop if [vc].[proc_getFunctionBenchmarkByDesignation] has data for that benchmark_metric_id we set the [is_empty] field in our @temp_benchmark_metric table variable to 0, otherwise we set it to 1
7 - We return @temp_benchmark_metric table variable filtered to only show the IDs that have [is_empty] = 0
*/

	DECLARE 
		@temp_store_proc_table table (
		peer_group_id int,       
		median_potential_amount numeric(20,4),
		median_opportunity_amount numeric(20,4),
		median_potential_percent_baseline numeric(20,4),
		median_opportunity_percent_baseline numeric(20,4),
		median_potential_fte numeric(20,4),
		median_opportunity_fte numeric(20,4),
		top_quartile_potential_amount numeric(20,4),
		top_quartile_opportunity_amount numeric(20,4),
		top_quartile_potential_percent_baseline numeric(20,4),
		top_quartile_opportunity_percent_baseline numeric(20,4),
		top_quartile_potential_fte numeric(20,4),
		top_quartile_opportunity_fte numeric(20,4)
		)

	DECLARE 
		@temp_benchmark_metric table(
		benchmark_metric_id int
		,name nvarchar(100)
		,is_total_cost bit
		,is_empty bit
		)

	INSERT INTO @temp_benchmark_metric 
		SELECT 
		[benchmark_metric_id]
		,[name]
		,[is_total_cost]
		,null as [is_empty]
		FROM [vc].[benchmark_metric];

	DECLARE
		@current_id int = (SELECT MIN([benchmark_metric_id]) FROM [vc].[benchmark_metric]),
		@max_id int = (SELECT MAX([benchmark_metric_id]) FROM [vc].[benchmark_metric])

	WHILE @current_id <= @max_id
		BEGIN
			INSERT @temp_store_proc_table
			EXEC  [vc].[proc_getFunctionBenchmarkByDesignation]
			@input_year = @dropdown_input_year, --comes from store proc parameter
			@designation_id = @dropdown_designation_id, --comes from store proc parameter
			@query_all = @dropdown_query_all, --comes from store proc parameter
			@function_id = @dropdown_function_id,--comes from store proc parameter
			@metric_id = @current_id --comes from the loop

			UPDATE @temp_benchmark_metric
			SET is_empty = (SELECT CASE WHEN EXISTS	(SELECT 1 FROM @temp_store_proc_table) THEN 0 ELSE 1 END)
			WHERE benchmark_metric_id = @current_id 

			SET @current_id = @current_id+1
			DELETE FROM @temp_store_proc_table
		END

	SELECT 
		[benchmark_metric_id]
		,[name]
		,[is_total_cost]
	FROM 
		@temp_benchmark_metric
	WHERE
		is_empty = 0
		
END

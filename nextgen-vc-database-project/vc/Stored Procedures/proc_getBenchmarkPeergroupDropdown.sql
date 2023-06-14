CREATE PROCEDURE [vc].[proc_getBenchmarkPeergroupDropdown](
    @dropdown_input_year int,
    @dropdown_designation_id int,
    @dropdown_query_all bit,
	@dropdown_function_id int,
	@dropdown_metric_id int
) AS
BEGIN
/*
This stored procedure is used to populate the "Benchmark PeerGroup" dropdown menu in the "support function" area of Mendix.
It was necessary to create this stored procedure cause we only want the drowndown menu to be populated with options that actually have data.

The main logic in this stored procedure is as it follows
1 - We declare the @temp_store_proc_table table variable that is going to hold the results of the actual store procedure that returns the data we want to check if exists 
2 - We then run the store procedure @temp_store_proc_table to populate the table
3 - Finally we join @temp_store_proc_table with the data from vc.benchmark_peer_group to create the final result
*/

	DECLARE
	@temp_store_proc_table table (
	benchmark_peer_group_id int,
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


	INSERT @temp_store_proc_table
	EXEC  [vc].[proc_getFunctionBenchmarkByDesignation]
	@input_year = @dropdown_input_year, --comes from store proc parameter
	@designation_id = @dropdown_designation_id, --comes from store proc parameter
	@query_all = @dropdown_query_all, --comes from store proc parameter
	@function_id = @dropdown_function_id,--comes from store proc parameter
	@metric_id = @dropdown_metric_id --comes from store proc parameter

	SELECT
	[sp].[benchmark_peer_group_id]
	,[benchmark_peer_group].[name]
	,[benchmark_peer_group].[is_total_cost]
	FROM
	@temp_store_proc_table as sp
	LEFT JOIN [vc].[benchmark_peer_group]
	ON [benchmark_peer_group].[benchmark_peer_group_id] = [sp].[benchmark_peer_group_id]

END

CREATE PROCEDURE [vc].[proc_getFunctionBenchmarkByDesignation](
    @input_year int,
    @designation_id int,
    @query_all bit,
	@function_id int,
	@metric_id int
) AS
BEGIN
	DECLARE 
		@labor_cost numeric(24,6),
		@non_labor_cost numeric(24,6),
		@total_cost numeric(24,6),
		@designation_revenue numeric(24,6),
		@function_fte numeric(24,6),
		@total_fte numeric(24,6),
		@metric_name nvarchar(300),
		@median numeric(24,6),
		@top_quartile numeric(24,6),
		@peer_group_id int,
		@peer_group_id_n int,
		@peer_group_max int,
		@client numeric(24,6),

		@median_potential_amount numeric(24,6),
		@median_opportunity_amount numeric(24,6),
		@median_potential_fte numeric(24,6),
		@median_opportunity_fte numeric(24,6),
		@median_potential_percent_baseline numeric(24,6),
		@median_opportunity_percent_baseline numeric(24,6),

		@top_quartile_potential_amount numeric(24,6),
		@top_quartile_opportunity_amount numeric(24,6),
		@top_quartile_potential_fte numeric(24,6),
		@top_quartile_opportunity_fte numeric(24,6),
		@top_quartile_potential_percent_baseline numeric(24,6),
		@top_quartile_opportunity_percent_baseline numeric(24,6)

		CREATE TABLE #funcbenchdesignation(
		peer_group_id_n int,
		function_fte numeric (24,6),
		total_fte numeric (24,6),
		client numeric(24,6),           
		median_potential_amount numeric(24,6),
		median_opportunity_amount numeric(24,6),
		median_potential_percent_baseline numeric(24,6),
		median_opportunity_percent_baseline numeric(24,6),
		median_potential_fte numeric(24,6),
		median_opportunity_fte numeric(24,6),
		top_quartile_potential_amount numeric(24,6),
		top_quartile_opportunity_amount numeric(24,6),
		top_quartile_potential_percent_baseline numeric(24,6),
		top_quartile_opportunity_percent_baseline numeric(24,6),
		top_quartile_potential_fte numeric(24,6),
		top_quartile_opportunity_fte numeric(24,6)
		);

	/*DECLARE

		@input_year = 2020,
		@designation_id = 463,
		@query_all = NULL,
		@function_id = 4967,
		@metric_id = 807*/ -- validated
	
	------------------Integer number for the loop
	SET @peer_group_id_n = (SELECT MIN(fb.benchmark_peer_group_id) FROM [vc].[function_benchmark] fb WHERE fb.benchmark_metric_id = @metric_id)
	------------------SELECT @peergroups where -- @metric = seleccionada... línea de arriba
	SET @peer_group_max = (SELECT MAX(fb.benchmark_peer_group_id) FROM [vc].[function_benchmark] fb WHERE fb.benchmark_metric_id = @metric_id) + 1

	WHILE @peer_group_id_n < @peer_group_max
	BEGIN 

		SELECT @labor_cost = SUM(fd.amount),@function_fte = SUM(fd.employee_count) FROM [vc].[function_data] fd WHERE fd.year = @input_year AND fd.designation_id =ISNULL(@designation_id, fd.designation_id) AND fd.function_id = @function_id;
		SET @non_labor_cost = (SELECT CASE WHEN sum(amount)  IS NULL THEN 0 ELSE sum(amount) END AS sum_amount FROM [vc].[procurement_data] pd WHERE pd.year = @input_year AND pd.designation_id = ISNULL(@designation_id, pd.designation_id) AND pd.function_id = @function_id);
		SET @total_cost = @labor_cost + @non_labor_cost
		SET @designation_revenue = (SELECT SUM(d.revenue) FROM vc.designation d WHERE d.designation_id = ISNULL(@designation_id, d.designation_id));
		SET @total_fte = (SELECT SUM(fd.employee_count) FROM [vc].[function_data] fd WHERE fd.year = @input_year AND fd.designation_id = ISNULL(@designation_id, fd.designation_id));
		SET @metric_name = (SELECT UPPER(bm.name) FROM vc.benchmark_metric bm WHERE bm.benchmark_metric_id = @metric_id)  
		SELECT @median = fb.median, @top_quartile = fb.top_quartile, @peer_group_id = fb.benchmark_peer_group_id 
		FROM vc.function_benchmark fb 
		WHERE fb.benchmark_metric_id = @metric_id AND fb.function_id = @function_id and fb.benchmark_peer_group_id = @peer_group_id_n
	
		/*Test values for Support function benchmark calculations Excel file
		SET @labor_cost = 1699
		SET @non_labor_cost = 2585
		SET @total_cost = @labor_cost + @non_labor_cost
		SET @designation_revenue = 5038
		SET @function_fte = 230
		SET @total_fte = 17691
		SET @metric_name = 'FTEs as % of total FTEs' 
		SET @median = 0.009
		SET @top_quartile = 0.008
		SELECT @labor_cost AS labor_cost, @non_labor_cost AS non_labor_cost, @total_cost AS total_cost, @designation_revenue AS designation_revenue, @function_fte AS function_fte, @total_fte AS total_fte, @metric_name AS metric_name, @median AS median, @top_quartile AS top_quartile 
		*/

		IF @metric_name = UPPER('Total cost as % of revenue')
			BEGIN
				SET @client = 0      
				SET @median_potential_amount = @designation_revenue * @median
				SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_percent_baseline = @median_potential_amount / @total_cost
				SET @median_opportunity_percent_baseline = @median_opportunity_amount / @total_cost 
				SET @median_potential_fte = @function_fte * @median_potential_percent_baseline
				SET @median_opportunity_fte = @function_fte * @median_opportunity_percent_baseline
		
				SET @top_quartile_potential_amount = @designation_revenue * @top_quartile
				SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @total_cost
				SET @top_quartile_opportunity_percent_baseline =  @top_quartile_opportunity_amount / @total_cost
				SET @top_quartile_potential_fte = @function_fte * @top_quartile_potential_percent_baseline
				SET @top_quartile_opportunity_fte = @function_fte * @top_quartile_opportunity_percent_baseline	
				
			END
		ELSE IF @metric_name = UPPER('Personnel cost per $1K revenue')
			BEGIN
				SET @client = @labor_cost / ( @designation_revenue / 1000)
				SET @median_potential_amount = @labor_cost * @median / @client
				SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_percent_baseline = @median_potential_amount / @labor_cost
				SET @median_opportunity_percent_baseline =   @median_opportunity_amount / @labor_cost
				SET @median_potential_fte = @function_fte * @median_potential_percent_baseline
				SET @median_opportunity_fte = @function_fte * @median_opportunity_percent_baseline

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
				SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_amount / @labor_cost
				SET @top_quartile_potential_fte = @function_fte * @top_quartile_potential_percent_baseline
				SET @top_quartile_opportunity_fte = @function_fte * @top_quartile_opportunity_percent_baseline

			END
		ELSE IF	@metric_name = UPPER('Function FTEs per $1B revenue')
			BEGIN
				SET @client = @function_fte / ( @designation_revenue / 1000000000)
				SET @median_potential_amount = @labor_cost * @median / @client
				SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_fte = @function_fte * @median / @client
				SET @median_opportunity_fte = @function_fte - @median_potential_fte
				SET @median_potential_percent_baseline = @median_potential_amount / @labor_cost
				SET @median_opportunity_percent_baseline =   @median_opportunity_fte / @function_fte

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
				SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_fte = @function_fte * @top_quartile / @client
				SET @top_quartile_opportunity_fte = @function_fte - @top_quartile_potential_fte
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_fte / @function_fte
				
			END
		ELSE IF @metric_name = UPPER('FTEs as % of total FTEs')
			BEGIN
				SET @client = @function_fte / @total_fte
				SET @median_potential_amount = @labor_cost * @median / @client
				SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_fte = @function_fte * @median / @client
				SET @median_opportunity_fte = @function_fte - @median_potential_fte
				SET @median_potential_percent_baseline = @median_potential_fte / @function_fte
				SET @median_opportunity_percent_baseline =   @median_opportunity_fte / @function_fte

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
				SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_fte = @function_fte * @top_quartile / @client
				SET @top_quartile_opportunity_fte = @function_fte - @top_quartile_potential_fte
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_fte / @function_fte
				
			END

		ELSE IF @metric_name = UPPER('Personnel cost as % of revenue')
			BEGIN
				SET @client = 0      
				SET @median_potential_amount = @designation_revenue * @median
				SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_percent_baseline = @median_potential_amount / @labor_cost
				SET @median_opportunity_percent_baseline = @median_opportunity_amount / @labor_cost 
				SET @median_potential_fte = @function_fte * @median_potential_percent_baseline
				SET @median_opportunity_fte = @function_fte * @median_opportunity_percent_baseline
		
				SET @top_quartile_potential_amount = @designation_revenue * @top_quartile
				SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =  @top_quartile_opportunity_amount / @labor_cost
				SET @top_quartile_potential_fte = @function_fte * @top_quartile_potential_percent_baseline
				SET @top_quartile_opportunity_fte = @function_fte * @top_quartile_opportunity_percent_baseline	
				
			END
		--- Restoring the variable for the loop
		------
		INSERT INTO #funcbenchdesignation
				select 
					@peer_group_id as peer_group_id_n,
				  	@function_fte,         
					@total_fte,  
					@client,														
					@median_potential_amount,
					@median_opportunity_amount,
					@median_potential_percent_baseline,
					@median_opportunity_percent_baseline,
					@median_potential_fte,
					@median_opportunity_fte,
					@top_quartile_potential_amount,
					@top_quartile_opportunity_amount,
					@top_quartile_potential_percent_baseline,
					@top_quartile_opportunity_percent_baseline,
					@top_quartile_potential_fte,
					@top_quartile_opportunity_fte
		SET @peer_group_id_n = @peer_group_id_n + 1
	END

	SELECT DISTINCT
		peer_group_id_n									AS peer_group_id
	--	,function_fte																				   ------------added
	--	,total_fte																					   ------------added
	--	,client											AS client								       ------------added
		,median_potential_amount						AS median_potential_amount
		,median_opportunity_amount						AS median_opportunity_amount
		,median_potential_percent_baseline				AS median_potential_percent_baseline
		,median_opportunity_percent_baseline			AS median_opportunity_percent_baseline	
		,median_potential_fte				 			AS median_potential_fte
		,median_opportunity_fte							AS median_opportunity_fte		
		,top_quartile_potential_amount					AS top_quartile_potential_amount
		,top_quartile_opportunity_amount				AS top_quartile_opportunity_amount
		,top_quartile_potential_percent_baseline		AS top_quartile_potential_percent_baseline
		,top_quartile_opportunity_percent_baseline		AS top_quartile_opportunity_percent_baseline
		,top_quartile_potential_fte						AS top_quartile_potential_fte	
		,top_quartile_opportunity_fte					AS top_quartile_opportunity_fte
	FROM
		#funcbenchdesignation
	WHERE peer_group_id_n IS NOT NULL;

DROP TABLE 	#funcbenchdesignation;
END

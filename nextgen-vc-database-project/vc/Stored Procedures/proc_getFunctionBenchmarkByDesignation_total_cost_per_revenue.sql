

CREATE PROCEDURE [vc].[proc_getFunctionBenchmarkByDesignation_total_cost_per_revenue]( ----total cost as % of revenue is a metric name located in vc.benchmark_metric
    @input_year int,
    @designation_id int,
    @query_all bit, 
	@function_id int,
	@metric_id int
) AS
BEGIN
	DECLARE 
		@labor_cost numeric(20,4),
		@non_labor_cost numeric(20,4),
		@total_cost numeric(20,4),
		@designation_revenue numeric(20,4),
		@function_fte numeric(20,4),
		@total_fte numeric(20,4),
		@metric_name nvarchar(300),
		@median numeric(20,4),
		@top_quartile numeric(20,4),
		@bottom_quartile numeric(20,4), ---- added
		@peer_group_id int,
		@peer_group_id_n int,
		@peer_group_max int,
		@client numeric(20,4),
		@metric_related nvarchar (50), --- added
		@current_percentage numeric (20,4), ---- added

		@median_potential_amount numeric(20,4), 
		@median_reduction_percentage numeric(20,4),  --------
		@median_potential_fte numeric(20,4),
		@median_opportunity_fte numeric(20,4),
		@median_potential_percent_baseline numeric(20,4),
		@median_opportunity_percent_baseline numeric(20,4),

		@top_quartile_potential_amount numeric(20,4),
		@top_quartile_reduction_percentage numeric(20,4), ------
		@top_quartile_potential_fte numeric(20,4),
		@top_quartile_opportunity_fte numeric(20,4),
		@top_quartile_potential_percent_baseline numeric(20,4),
		@top_quartile_opportunity_percent_baseline numeric(20,4),
		
		------------added
		@bottom_quartile_potential_amount numeric(20,4),
		@bottom_quartile_reduction_percentage numeric(20,4), ---------
		@bottom_quartile_potential_fte numeric(20,4),
		@bottom_quartile_opportunity_fte numeric(20,4),
		@bottom_quartile_potential_percent_baseline numeric(20,4),
		@bottom_quartile_opportunity_percent_baseline numeric(20,4)

		CREATE TABLE #funcbenchdesignation(
		peer_group_id_n int,
		function_fte numeric (24,4),
		total_fte numeric (24,4),
		client numeric(20,4),   
		metric_related nvarchar (50),
		current_percentage numeric (20,4),
		designation_revenue numeric(24,2),
		total_cost numeric (24,2),
		median_potential_amount numeric(20,4),
		median_reduction_percentage numeric(20,4),
		median_potential_percent_baseline numeric(20,4),
		--median_opportunity_percent_baseline numeric(20,4),
		--median_potential_fte numeric(20,4),
		--median_opportunity_fte numeric(20,4),
		top_quartile_potential_amount numeric(20,4),
		top_quartile_reduction_percentage numeric(20,4),
		top_quartile_potential_percent_baseline numeric(20,4),
		--top_quartile_opportunity_percent_baseline numeric(20,4),
		--top_quartile_potential_fte numeric(20,4),
		--top_quartile_opportunity_fte numeric(20,4),
		-------------------added-------
		bottom_quartile_potential_amount numeric(20,4),
		bottom_quartile_reduction_percentage numeric(20,4),
		bottom_quartile_potential_percent_baseline numeric(20,4)
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
		SET @metric_name = (SELECT bm.name FROM vc.benchmark_metric bm WHERE bm.benchmark_metric_id = @metric_id)  
		SELECT @median = fb.median, @top_quartile = fb.top_quartile,@bottom_quartile = fb.bottom_quartile, @peer_group_id = fb.benchmark_peer_group_id 
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

		IF @metric_name = 'Total cost as % of revenue' 
			BEGIN
				SET @client = 0      
				SET @metric_related = 'Currency related'
				SET @current_percentage = @designation_revenue / @total_cost   --- new calculation
				SET @median_potential_amount = @designation_revenue * @median
				SET @median_reduction_percentage = ((@labor_cost - @median_potential_amount)/@labor_cost)*100
				SET @median_potential_percent_baseline = (@median_potential_amount / @total_cost) * 100
			--	SET @median_opportunity_percent_baseline = @median_opportunity_amount / @total_cost 
			--	SET @median_potential_fte = @function_fte * @median_potential_percent_baseline
			--	SET @median_opportunity_fte = @function_fte * @median_opportunity_percent_baseline
		
				SET @top_quartile_potential_amount = @designation_revenue * @top_quartile
				SET @top_quartile_reduction_percentage = ((@labor_cost - @top_quartile_potential_amount)/@labor_cost)*100
				SET @top_quartile_potential_percent_baseline = (@top_quartile_potential_amount / @total_cost) * 100
			--	SET @top_quartile_opportunity_percent_baseline =  @top_quartile_opportunity_amount / @total_cost
			--	SET @top_quartile_potential_fte = @function_fte * @top_quartile_potential_percent_baseline
			--	SET @top_quartile_opportunity_fte = @function_fte * @top_quartile_opportunity_percent_baseline	
			---------------------- added-------
				SET @bottom_quartile_potential_amount = @designation_revenue * @bottom_quartile
				SET @bottom_quartile_reduction_percentage = ((@labor_cost - @bottom_quartile_potential_amount)/@labor_cost)*100
				SET @bottom_quartile_potential_percent_baseline = (@bottom_quartile_potential_amount / @total_cost)*100
			--	SET @bottom_quartile_opportunity_percent_baseline =  @bottom_quartile_opportunity_amount / @total_cost

				
			END
		ELSE IF @metric_name = 'Personnel cost per $1K revenue' 
			BEGIN
				SET @client = @labor_cost / ( @designation_revenue / 1000)
				SET @metric_related = 'Currency related'
				SET @median_potential_amount = @labor_cost * @median / @client
			--	SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_percent_baseline = @median_potential_amount / @labor_cost
			--	SET @median_opportunity_percent_baseline =   @median_opportunity_amount / @labor_cost
				SET @median_potential_fte = @function_fte * @median_potential_percent_baseline
				SET @median_opportunity_fte = @function_fte * @median_opportunity_percent_baseline

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
		--		SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
			--	SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_amount / @labor_cost
				SET @top_quartile_potential_fte = @function_fte * @top_quartile_potential_percent_baseline
				SET @top_quartile_opportunity_fte = @function_fte * @top_quartile_opportunity_percent_baseline

			END
		ELSE IF	@metric_name = 'Function FTEs per $1B revenue'
			BEGIN
				SET @client = @function_fte / ( @designation_revenue / 1000000000)
				SET @metric_related = 'FTE related'
				SET @median_potential_amount = @labor_cost * @median / @client
				--SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_amount = @function_fte * @median / @client
			--	SET @median_opportunity_amount = @function_fte - @median_potential_fte
				SET @median_potential_percent_baseline = @median_potential_amount / @labor_cost
				SET @median_opportunity_percent_baseline =   @median_opportunity_fte / @function_fte

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
			--	SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_fte = @function_fte * @top_quartile / @client
				SET @top_quartile_opportunity_fte = @function_fte - @top_quartile_potential_fte
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_fte / @function_fte
				
			END
		ELSE IF @metric_name = 'FTEs as % of total FTEs' 
			BEGIN
				SET @client = @function_fte / @total_fte
				SET @metric_related = 'FTE related'
				SET @median_potential_amount = @labor_cost * @median / @client
			--	SET @median_opportunity_amount = @labor_cost - @median_potential_amount
				SET @median_potential_fte = @function_fte * @median / @client
			--	SET @median_opportunity_amount = @function_fte - @median_potential_fte
				SET @median_potential_percent_baseline = @median_potential_fte / @function_fte
				SET @median_opportunity_percent_baseline =   @median_opportunity_fte / @function_fte

				SET @top_quartile_potential_amount = @labor_cost * @top_quartile / @client
			--	SET @top_quartile_opportunity_amount = @labor_cost - @top_quartile_potential_amount
				SET @top_quartile_potential_fte = @function_fte * @top_quartile / @client
				SET @top_quartile_opportunity_fte = @function_fte - @top_quartile_potential_fte
				SET @top_quartile_potential_percent_baseline = @top_quartile_potential_amount / @labor_cost
				SET @top_quartile_opportunity_percent_baseline =   @top_quartile_opportunity_fte / @function_fte
				
			END 
		--- Restoring the variable for the loop
		------
		INSERT INTO #funcbenchdesignation
				select 
					@peer_group_id as peer_group_id_n,
				  	@function_fte,         
					@total_fte,  
					@client,
					@metric_related,
					@designation_revenue,
					@total_cost,
					@current_percentage,
					@median_potential_amount,
					@median_reduction_percentage,
					@median_potential_percent_baseline,
					--@median_opportunity_percent_baseline,
					--@median_potential_fte,
					--@median_opportunity_fte,
					@top_quartile_potential_amount,
					@top_quartile_reduction_percentage,
					@top_quartile_potential_percent_baseline,
					--@top_quartile_opportunity_percent_baseline,
					--@top_quartile_potential_fte,
					--@top_quartile_opportunity_fte
					@bottom_quartile_potential_amount,
					@bottom_quartile_reduction_percentage,
					@bottom_quartile_potential_percent_baseline
		SET @peer_group_id_n = @peer_group_id_n + 1
	END

	SELECT DISTINCT
		peer_group_id_n									AS peer_group_id
	--	,function_fte																				   ------------added
	--	,total_fte																					   ------------added
	--	,client											AS client								       ------------added
		,metric_related
		,current_percentage
		,designation_revenue,total_cost
		,median_potential_amount						AS median_potential_amount
		,median_reduction_percentage					AS median_reduction_percentage
		,median_potential_percent_baseline				AS median_potential_percent_baseline
		--,median_opportunity_percent_baseline			AS median_opportunity_percent_baseline	
		--,median_potential_fte				 			AS median_potential_fte
		--,median_opportunity_fte							AS median_opportunity_fte		
		,top_quartile_potential_amount					AS top_quartile_potential_amount
		,top_quartile_reduction_percentage				AS top_quartile_reduction_percentage
		,top_quartile_potential_percent_baseline		AS top_quartile_potential_percent_baseline
		--,top_quartile_opportunity_percent_baseline		AS top_quartile_opportunity_percent_baseline
		--,top_quartile_potential_fte						AS top_quartile_potential_fte	
		--,top_quartile_opportunity_fte					AS top_quartile_opportunity_fte
		,bottom_quartile_potential_amount				AS bottom_quartile_potential_amount
		,bottom_quartile_reduction_percentage			AS bottom_quartile_reduction_percentage
		,bottom_quartile_potential_percent_baseline		AS bottom_quartile_potential_percent_baseline

	FROM
		#funcbenchdesignation
	WHERE peer_group_id_n IS NOT NULL;

DROP TABLE 	#funcbenchdesignation;
END

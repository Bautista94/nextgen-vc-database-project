

CREATE PROCEDURE [vc].[proc_getFunctionBaselineByDesignation](
    @input_year int,
    @designation_id int,
    @query_all bit,
	@function_id int
) AS
BEGIN
	/*--Test Variables ---------------------------------------------
	declare 
	@input_year int = 2020,
	@designation_id int = NULL,
	@query_all bit = 1,
	@function_id int = 1
	-------------------------------------------------------------*/

	IF (@query_all = 0 AND @designation_id IS NULL) OR @input_year IS NULL OR @function_id = 0
	RETURN;

	CREATE TABLE #proc_func (
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,4),
		employee_count numeric(20,4),
		third_party_amount numeric(20,4),
		deducted_by_total_cost numeric(20,4)
	)

	INSERT INTO #proc_func
	EXEC [vc].[proc_getFunctionBaseData] @input_year, @designation_id, @query_all

	

	IF @query_all = 1
		BEGIN
		--Query all designations--------------------------------------------------
			--------------------------------------------------------------------------
			DECLARE @total_by_function_and_designation table (
				function_id int,
				designation_id int,
				partial_labor_amount numeric(20,4),
				partial_third_party_amount numeric(20,4)
			);

			INSERT INTO @total_by_function_and_designation
			SELECT
				function_id,
				designation_id,
				sUM(labor_amount),
				sUM(third_party_amount)
			FROM 
				#proc_func
			GROUP BY 
				function_id
				,designation_id
			--------------------------------------------------------------------------
			DECLARE @total_by_function table (
				function_id int,
				total_labor_amount numeric(20,4),
				total_third_party_amount numeric(20,4)
			);

			INSERT INTO @total_by_function
			SELECT
				function_id,
				sUM(partial_labor_amount),
				sUM(partial_third_party_amount)
			FROM
				@total_by_function_and_designation
			GROUP BY
				function_id
			--------------------------------------------------------------------------
			DECLARE @weighted_factors table (
				function_id int,
				designation_id int,
				labor_target_low_factor numeric(20,6),
				labor_target_high_factor numeric(20,6),
				third_party_target_low_factor numeric(20,6),
				third_party_target_high_factor numeric(20,6),
				is_total_cost bit
			);

			INSERT INTO @weighted_factors
			SELECT
				t.function_id,
				p.designation_id,
				sUM(IIF(t.total_labor_amount = 0.0 or fsf.labor_target_low_factor = 0.0, 0.0, 
					p.partial_labor_amount / t.total_labor_amount * fsf.labor_target_low_factor)) AS labor_target_low_factor, 
				sUM(IIF(t.total_labor_amount = 0.0 or fsf.labor_target_high_factor = 0.0, 0.0, 
					p.partial_labor_amount / t.total_labor_amount * fsf.labor_target_high_factor)) AS labor_target_high_factor,
				sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.third_party_target_low_factor = 0.0, 0.0, 
					p.partial_third_party_amount / t.total_third_party_amount * fsf.third_party_target_low_factor)) AS third_party_target_low_factor,
				sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.third_party_target_high_factor = 0.0, 0.0, 
					p.partial_third_party_amount / t.total_third_party_amount * fsf.third_party_target_high_factor)) AS third_party_target_high_factor,
				fsf.is_total_cost
			FROM 
				@total_by_function_and_designation p
				LEFT JOIN @total_by_function T 
					ON t.function_id = p.function_id
				LEFT JOIN vc.function_saving_factor fsf 
					ON P.function_id = fsf.function_id 
					AND	P.designation_id = fsf.designation_id
			GROUP BY 
				t.function_id, p.designation_id,fsf.is_total_cost;
			--Return Query----------------------------------------------------
			SELECT
				pfd.year
				,f.function_type_id
				,ft.name								AS function_type_name
				,pfd.function_id
				,f.name									AS function_name
				,NULL									AS designation_id
				,NULL									AS designation_name
				,(SELECT SUM(d.revenue)	FROM vc.designation d)
														AS designation_revenue
				,SUM(pfd.labor_amount)					AS labor_amount
				,SUM(pfd.employee_count)				AS employee_count
				,SUM(pfd.third_party_amount)			AS third_party_amount
				,SUM(wf.labor_target_low_factor)		AS labor_target_low_factor
				,SUM(wf.labor_target_high_factor)		AS labor_target_high_factor
				,SUM(wf.third_party_target_low_factor)	AS third_party_target_low_factor
				,SUM(wf.third_party_target_high_factor)	AS third_party_target_high_factor
				,wf.is_total_cost
			FROM
				#proc_func pfd
				INNER JOIN vc.[function] f
					ON pfd.function_id = f.function_id
				INNER JOIN vc.function_type ft
					ON ft.function_type_id = f.function_type_id
				INNER JOIN vc.designation d
					ON d.designation_id = pfd.designation_id
				LEFT JOIN @weighted_factors wf 
					ON pfd.function_id = wf.function_id 
					AND pfd.designation_id = wf.designation_id
			WHERE
				 pfd.function_id = ISNULL(@function_id, pfd.function_id)
			GROUP BY
				pfd.year
				,f.function_type_id
				,ft.name
				,pfd.function_id
				,f.name
				,wf.is_total_cost
		END
	ELSE
		BEGIN
		--Query by designation----------------------------------------------------
			SELECT
				pfd.year
				,f.function_type_id
				,ft.name						AS function_type_name
				,pfd.function_id
				,f.name							AS function_name
				,pfd.designation_id
				,d.name							AS designation_name
				,d.revenue						AS designation_revenue
				,SUM(pfd.labor_amount)			AS labor_amount
				,SUM(pfd.employee_count)		AS employee_count
				,SUM(pfd.third_party_amount)	AS third_party_amount
				,fsf.labor_target_low_factor	
				,fsf.labor_target_high_factor
				,fsf.third_party_target_low_factor
				,fsf.third_party_target_high_factor
				,fsf.is_total_cost
			FROM
				#proc_func pfd
				INNER JOIN vc.[function] f
					ON pfd.function_id = f.function_id
				INNER JOIN vc.function_type ft
					ON ft.function_type_id = f.function_type_id
				INNER JOIN vc.designation d
					ON d.designation_id = pfd.designation_id
				INNER JOIN vc.function_saving_factor fsf
					ON fsf.function_id = pfd.function_id
					AND fsf.designation_id = pfd.designation_id
			WHERE
				pfd.function_id = ISNULL(@function_id, pfd.function_id)
			GROUP BY
				pfd.year
				,f.function_type_id
				,ft.name
				,pfd.function_id
				,f.name
				,pfd.designation_id
				,d.name
				,d.revenue
				,fsf.labor_target_low_factor	
				,fsf.labor_target_high_factor
				,fsf.third_party_target_low_factor
				,fsf.third_party_target_high_factor
				,fsf.is_total_cost
		END
	END

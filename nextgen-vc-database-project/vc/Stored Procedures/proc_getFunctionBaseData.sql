

CREATE PROCEDURE [vc].[proc_getFunctionBaseData](
    @input_year int,
    @designation_id int,
    @query_all bit
) AS
BEGIN
	--Test Variables ---------------------------------------------
	/*declare 
	@input_year int = 2020,
	@designation_id int = NULL,
	@query_all bit = 1*/
	--drop table #proc_data
	--drop table #func_data
	-------------------------------------------------------------
	--Get procurement data----------------------------------------------------

	cREATE TABLE #proc_data (
		procurement_sub_category_id int,
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,4),
		employee_count numeric(20,4),
		third_party_amount numeric(20,4),
		deducted_by_total_cost numeric(20,4)
	 );

	INSERT INTO #proc_data
	SELECT
		pd.procurement_sub_category_id,
		pd.designation_id,
		pd.function_id,
		pd.year,
		pd.is_direct,
		SUM(IIF(st.name = 'Headcount', pd.amount, 0.0)), --labor_amount
		0.0, --employee_count
		SUM(IIF(st.name = 'Spend', pd.amount, 0.0)), --third_party_amount
		SUM(IIF(st.name = 'Spend',
		   IIF(fsf.is_total_cost = 1, pd.amount, 0.0),
		   0.0)) --deducted_by_total_cost
	FROM vc.procurement_data pd
	INNER JOIN vc.spend_type st ON st.spend_type_id = pd.spend_type_id
	INNER JOIN vc.function_saving_factor fsf ON fsf.function_id = pd.function_id AND fsf.designation_id = pd.designation_id
	WHERE pd.year = @input_year
		AND pd.designation_id = ISNULL(@designation_id, pd.designation_id)
	GROUP BY pd.procurement_sub_category_id, pd.designation_id, pd.function_id, pd.year, pd.is_direct;

	--Get function data-------------------------------------------------------

	CREATE TABLE #func_data (
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,4),
		employee_count numeric(20,4),
		third_party_amount numeric(20,4),
		deducted_by_total_cost numeric(20,4)
	 );

	INSERT INTO #func_data
	SELECT
		fd.designation_id,
		fd.function_id,
		fd.year,
		0, --is_direct
		SUM(fd.amount), --labor_amount
		SUM(fd.employee_count),
		0.0, --third_party_amount
		0.0 --deducted_by_total_cost
	FROM vc.function_data fd
	WHERE fd.year = @input_year
		AND fd.designation_id = ISNULL(@designation_id, fd.designation_id)
	GROUP BY
		fd.designation_id,
		fd.function_id,
		fd.year;

	--Merge procurement and function data-------------------------------------
	WITH proc_func_data AS
	(SELECT
		pd.designation_id,
		pd.function_id,
		pd.year,
		pd.is_direct,
		pd.labor_amount,
		pd.employee_count,
		pd.third_party_amount,
		pd.deducted_by_total_cost
	FROM #proc_data pd
	UNION ALL
	SELECT
		fd.designation_id,
		fd.function_id,
		fd.year,
		fd.is_direct,
		fd.labor_amount,
		fd.employee_count,
		fd.third_party_amount,
		fd.deducted_by_total_cost
	FROM #func_data fd)
	SELECT
		designation_id
		,function_id
		,year
		,is_direct
		,SUM(labor_amount)				AS labor_amount
		,SUM(employee_count)			AS employee_count
		,SUM(third_party_amount)		AS third_party_amount
		,SUM(deducted_by_total_cost)	AS deducted_by_total_cost
	FROM
		proc_func_data
	GROUP BY
		designation_id
		,function_id
		,year
		,is_direct

END

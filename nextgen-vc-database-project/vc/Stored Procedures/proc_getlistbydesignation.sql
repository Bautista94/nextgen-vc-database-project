
CREATE PROCEDURE [vc].[proc_getlistbydesignation] (
    @input_year int,
    @designation_id int,
    @query_all bit
) AS

BEGIN
	--declare 
	--    @input_year int = 2020,
	--    @designation_id int = 119,
	--    @query_all bit = null
	--Sanity check------------------------------------------------------------

	IF @query_all = 0 AND @designation_id IS NULL
		RETURN;

	--Get procurement data----------------------------------------------------

	cREATE TABLE #proc_data (
		procurement_sub_category_id int,
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,8),
		employee_count numeric(20,8),
		third_party_amount numeric(20,8),
		deducted_by_total_cost numeric(20,8)
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
		labor_amount numeric(20,8),
		employee_count numeric(20,8),
		third_party_amount numeric(20,8),
		deducted_by_total_cost numeric(20,8)
	 );

	INSERT INTO #func_data
	SELECT
		fd.designation_id,
		fd.function_id,
		fd.year,
		NULL, --is_direct
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
	--Do we really need to merge this into a separate temp table?

	CREATE TABLE #proc_func (
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,8),
		employee_count numeric(20,8),
		third_party_amount numeric(20,8),
		deducted_by_total_cost numeric(20,8)
	)

	INSERT INTO #proc_func
	SELECT
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
	FROM #func_data fd;

	--Combine all data sources------------------------------------------------

	CREATE TABLE #combined_data (
		data_type nvarchar(20),
		year int,
		function_id int,
		designation_id int,
		procurement_sub_category_id int,
		is_direct bit,
		labor_amount numeric(20,8),
		employee_count numeric(20,8),
		third_party_amount numeric(20,8),
		labor_target_low_factor numeric(20,8),
		labor_target_high_factor numeric(20,8),
		third_party_target_low_factor numeric(20,8),
		third_party_target_high_factor numeric(20,8),
		is_total_cost bit
	);

	INSERT INTO #combined_data
	SELECT
		'Function' as data_type,
		pfd.year,
		pfd.function_id,
		pfd.designation_id,
		NULL as procurement_sub_category_id,
		NULL as is_direct,
		SUM(pfd.labor_amount) as labor_amount,
		SUM(pfd.employee_count) as employee_count,
		SUM(pfd.third_party_amount) as third_party_amount,
		fsf.labor_target_low_factor,
		fsf.labor_target_high_factor,
		fsf.third_party_target_low_factor,
		fsf.third_party_target_high_factor,
		fsf.is_total_cost
	FROM #proc_func pfd
	LEFT JOIN vc.function_saving_factor fsf
		ON pfd.function_id = fsf.function_id
		AND pfd.designation_id = fsf.designation_id
	GROUP BY
		pfd.year,
		pfd.function_id,
		pfd.designation_id,
		fsf.labor_target_low_factor,
		fsf.labor_target_high_factor,
		fsf.third_party_target_low_factor,
		fsf.third_party_target_high_factor,
		fsf.is_total_cost
	 UNION ALL
	 SELECT
		'Procurement' as data_type,
		pd.year,
		NULL as function_id,
		pd.designation_id,
		pd.procurement_sub_category_id,
		pd.is_direct,
		SUM(pd.labor_amount) as labor_amount,
		SUM(pd.employee_count) as employee_count,
		SUM(pd.third_party_amount) - SUM(pd.deducted_by_total_cost) as third_party_amount,
		IsNull(psf.low_factor,0) as labor_target_low_factor,
		IsNull(psf.high_factor,0) as labor_target_high_factor,
		psf.low_factor as third_party_target_low_factor,
		psf.high_factor as third_party_target_high_factor,
		NULL --is_total_cost
	FROM #proc_data pd
	LEFT JOIN vc.procurement_saving_factor psf ON pd.procurement_sub_category_id = psf.procurement_sub_category_id AND pd.designation_id = psf.designation_id
	GROUP BY pd.year, pd.designation_id, pd.is_direct, pd.procurement_sub_category_id, psf.low_factor, psf.high_factor

	--Query all designations--------------------------------------------------

	IF @query_all = 1
	BEGIN

		DECLARE @total_by_function_and_designation table (
			function_id int,
			designation_id int,
			procurement_sub_category_id int,
			data_type varchar(100),
			partial_labor_amount numeric(20,8),
			partial_third_party_amount numeric(20,8)
		);

		INSERT INTO @total_by_function_and_designation
		SELECT
			function_id,
			designation_id,
			procurement_sub_category_id,
			data_type,
			sUM(labor_amount),
			sUM(third_party_amount)
		FROM #combined_data
		GROUP BY function_id, designation_id, data_type, procurement_sub_category_id;

		--------------------------------------------------------------------------

		DECLARE @total_by_function table (
			function_id int,
			total_labor_amount numeric(20,8),
			total_third_party_amount numeric(20,8)
		);

		INSERT INTO @total_by_function
		SELECT
			function_id,
			sUM(partial_labor_amount),
			sUM(partial_third_party_amount)
		FROM
			@total_by_function_and_designation
		GROUP BY
			function_id;

		--------------------------------------------------------------------------

		DECLARE @weighted_factors table (
			function_id int,
			designation_id int,
			labor_target_low_factor numeric(20,8),
			labor_target_high_factor numeric(20,8),
			third_party_target_low_factor numeric(20,8),
			third_party_target_high_factor numeric(20,8)
		);

		INSERT INTO @weighted_factors
		SELECT
			t.function_id,
			p.designation_id,
			sUM(IIF(t.total_labor_amount = 0.0 or fsf.labor_target_low_factor = 0.0, 0.0, p.partial_labor_amount / t.total_labor_amount * fsf.labor_target_low_factor)), --labor_target_low_factor,

			sUM(IIF(t.total_labor_amount = 0.0 or fsf.labor_target_high_factor = 0.0, 0.0, p.partial_labor_amount / t.total_labor_amount * fsf.labor_target_high_factor)), --labor_target_high_factor,

			sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.third_party_target_low_factor = 0.0, 0.0, p.partial_third_party_amount / t.total_third_party_amount * fsf.third_party_target_low_factor)), --third_party_target_low_factor,

			sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.third_party_target_high_factor = 0.0, 0.0, p.partial_third_party_amount / t.total_third_party_amount * fsf.third_party_target_high_factor)) --third_party_target_high_factor

		FROM @total_by_function_and_designation p
		LEFT JOIN @total_by_function T ON t.function_id = p.function_id
		LEFT JOIN vc.function_saving_factor fsf ON P.function_id = fsf.function_id AND	P.designation_id = fsf.designation_id
		where p.data_type = 'Function'
		GROUP BY t.function_id, p.designation_id;

		INSERT INTO @weighted_factors
		SELECT
			t.function_id,
			p.designation_id,
			sUM(IIF(t.total_labor_amount = 0.0 or fsf.low_factor = 0.0, 0.0, p.partial_labor_amount / t.total_labor_amount * fsf.low_factor)), --labor_target_low_factor,

			sUM(IIF(t.total_labor_amount = 0.0 or fsf.high_factor = 0.0, 0.0, p.partial_labor_amount / t.total_labor_amount * fsf.high_factor)), --labor_target_high_factor,

			sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.high_factor = 0.0, 0.0, p.partial_third_party_amount / t.total_third_party_amount * fsf.low_factor)), --third_party_target_low_factor,

			sUM(IIF(p.partial_third_party_amount = 0.0 or fsf.high_factor = 0.0, 0.0, p.partial_third_party_amount / t.total_third_party_amount * fsf.high_factor)) --third_party_target_high_factor

		FROM @total_by_function_and_designation p
		LEFT JOIN @total_by_function T ON t.function_id = p.function_id OR (t.function_id is null AND p.function_id is null)
		LEFT JOIN vc.procurement_saving_factor fsf ON P.procurement_sub_category_id = fsf.procurement_sub_category_id AND	P.designation_id = fsf.designation_id
		where p.data_type = 'Procurement'
		GROUP BY t.function_id, p.designation_id;

		--Returned result set query-----------------------------------------------

		WITH weight_factor_divisor AS (--This CTE was developed to deal with the duplicated labor and third party saving factors by dividing the final value by the number of times it was duplicated
		SELECT 
		cd.data_type
		,cd.designation_id
		,cd.function_id
		,cd.procurement_sub_category_id
		,COUNT(*) OVER (PARTITION BY cd.data_type, cd.designation_id, cd.function_id ) AS "divisor"
		FROM #combined_data cd
		)

		SELECT
			cd.data_type,
			cd.year,
			ft.function_type_id,
			ft.name as function_type_name,
			f.name as function_name,
			f.function_id,
			cd.is_direct,
			NULL AS designation_id,
			NULL AS designation_name,
			--NULL AS designation_revenue,
			sum(d.revenue) as designation_revenue,
			sUM(cd.labor_amount) AS labor_amount,
			sUM(cd.employee_count) AS employee_count,
			SUM(cd.third_party_amount) AS third_party_amount,
			SUM(wf.labor_target_low_factor/wfd.divisor) AS labor_target_low_factor,
			SUM(wf.labor_target_high_factor/wfd.divisor) AS labor_target_high_factor,
			--CASE
			--    WHEN cd.is_direct IS NOT NULL THEN 0.5 --procurement saving factors
			--    WHEN cd.is_direct IS NULL THEN SUM(wf.third_party_target_low_factor)
			--END AS third_party_target_low_factor,
			--CASE
			--    WHEN cd.is_direct IS NOT NULL THEN 0.7
			--    WHEN cd.is_direct IS NULL THEN  SUM(wf.third_party_target_high_factor)
			--END AS third_party_target_high_factor,
			SUM(wf.third_party_target_low_factor/wfd.divisor) AS third_party_target_low_factor,
			SUM(wf.third_party_target_high_factor/wfd.divisor) AS third_party_target_high_factor,
			fcp.function_custom_percentage_1,
			fcp.function_custom_percentage_2,
			ftcp.function_type_custom_percentage_1,
			ftcp.function_type_custom_percentage_2,
			cd.is_total_cost
		FROM
			#combined_data cd
		LEFT JOIN vc.[function] f ON f.function_id = cd.function_id
		LEFT JOIN vc.function_type ft ON ft.function_type_id = f.function_type_id
		INNER JOIN vc.designation d ON cd.designation_id = d.designation_id
		LEFT JOIN vc.function_custom_percentage fcp ON fcp.function_id=cd.function_id and fcp.designation_id IS NULL
		LEFT JOIN vc.function_type_custom_percentage ftcp ON ftcp.function_type_id = ft.function_type_id and ftcp.designation_id IS NULL
		LEFT JOIN @weighted_factors wf ON cd.designation_id = wf.designation_id AND (cd.function_id = wf.function_id OR (cd.function_id IS NULL AND  wf.function_id IS NULL ))
		LEFT JOIN weight_factor_divisor wfd ON wfd.data_type = cd.data_type AND wfd.designation_id = cd.designation_id AND (wfd.procurement_sub_category_id = cd.procurement_sub_category_id OR (wfd.procurement_sub_category_id is null AND cd.procurement_sub_category_id is null ))  AND (wfd.function_id = cd.function_id OR (cd.function_id IS NULL AND wfd.function_id IS NULL ))
		WHERE
			cd.third_party_amount IS NOT NULL
		GROUP BY
			ft.function_type_id,
			ft.name,
			f.name,
			f.function_id,
			cd.data_type,
			cd.year,
			cd.is_direct,
			fcp.function_custom_percentage_1,
			fcp.function_custom_percentage_2,
			ftcp.function_type_custom_percentage_1,
			ftcp.function_type_custom_percentage_2,
			cd.is_total_cost
		ORDER BY
			f.function_id;

	END

	ELSE

	--Query by designation----------------------------------------------------

	BEGIN

	WITH amount_totals as (--This CTE was developed to correctly calculate labor and third party saving factors
		SELECT 
		cd.data_type
		,cd.function_id
		,SUM(labor_amount) as "total_labor_amount"
		,SUM(third_party_amount) as "total_third_party_amount"
		FROM #combined_data cd
		GROUP BY
		cd.data_type
		,cd.function_id
		)

		SELECT
			cd.data_type,
			cd.year,
			ft.function_type_id,
			ft.name AS function_type_name,
			f.name AS function_name,
			f.function_id,
			cd.is_direct,
			d.designation_id,
			d.name AS designation_name,
			d.revenue as designation_revenue,
			sum(cd.labor_amount) AS labor_amount,
			sum(cd.employee_count) AS employee_count,
			SUM(cd.third_party_amount) AS third_party_amount,
				sum(CAST(cd.labor_target_low_factor  * CAST((COALESCE(labor_amount / NULLIF(total_labor_amount,0),0)) AS NUMERIC(20,8)) AS NUMERIC(20,8))) as labor_target_low_factor,
			sum(CAST(cd.labor_target_high_factor * CAST((COALESCE(labor_amount / NULLIF(total_labor_amount,0),0)) AS NUMERIC(20,8)) AS NUMERIC(20,8))) as labor_target_high_factor,
			--CASE
			--    WHEN cd.is_direct IS NOT NULL THEN 0.5
			--    WHEN cd.is_direct IS NULL THEN cd.third_party_target_low_factor
			--END AS third_party_target_low_factor,
			--CASE
			--    WHEN cd.is_direct IS NOT NULL THEN 0.7
			--    WHEN cd.is_direct IS NULL THEN cd.third_party_target_high_factor
			--END AS third_party_target_high_factor,
			sum(CAST(cd.third_party_target_low_factor  * CAST((COALESCE(third_party_amount / NULLIF(total_third_party_amount,0),0)) AS NUMERIC(20,8)) AS NUMERIC(20,8))) as third_party_target_low_factor,
			sum(CAST(cd.third_party_target_high_factor * CAST((COALESCE(third_party_amount / NULLIF(total_third_party_amount,0),0)) AS NUMERIC(20,8)) AS NUMERIC(20,8))) AS third_party_target_high_factor,
			fcp.function_custom_percentage_1,
			fcp.function_custom_percentage_2,
			ftcp.function_type_custom_percentage_1,
			ftcp.function_type_custom_percentage_2,
			cd.is_total_cost
		FROM
			#combined_data cd
		LEFT JOIN vc.[function] f
			ON f.function_id = cd.function_id
		LEFT JOIN vc.function_type ft
			ON ft.function_type_id = f.function_type_id
		INNER JOIN vc.designation d
			ON cd.designation_id = d.designation_id
		LEFT JOIN vc.function_custom_percentage fcp
			ON cd.[function_id] = fcp.[function_id]
			AND cd.designation_id = fcp.designation_id
		LEFT JOIN vc.function_type_custom_percentage ftcp
			ON f.function_type_id = ftcp.function_type_id
			AND cd.designation_id = ftcp.designation_id
		LEFT JOIN amount_totals ats
			ON ats.data_type = cd.data_type AND (ats.function_id = cd.function_id OR (cd.function_id IS NULL AND ats.function_id IS NULL ))
		WHERE
			cd.third_party_amount IS NOT NULL
			AND cd.designation_id = @designation_id
		GROUP BY
			ft.function_type_id,
			ft.name,
			f.name,
			f.function_id,
			d.designation_id,
			d.name,
			d.revenue,
			cd.data_type,
			cd.year,
			cd.is_direct,
			--cd.labor_target_low_factor,
			--cd.labor_target_high_factor,
			--cd.third_party_target_low_factor,
			--cd.third_party_target_high_factor,
			fcp.function_custom_percentage_1,
			fcp.function_custom_percentage_2,
			ftcp.function_type_custom_percentage_1,
			ftcp.function_type_custom_percentage_2,
			cd.is_total_cost
		ORDER BY
			f.function_id;

	END

	--------------------------------------------------------------------------

	DROP TABLE #proc_data;
	DROP TABLE #func_data;
	DROP TABLE #proc_func;
	DROP TABLE #combined_data;
END

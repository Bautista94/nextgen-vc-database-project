
CREATE PROCEDURE [vc].[proc_getProcurementBaselinebydesignation] (
    @input_year int,
    @designation_id int,
    @query_all bit
) AS
BEGIN
	--declare
	--    @input_year int = 2020,
	--    @designation_id int = null,
	--    @query_all bit = 1

	--Sanity check------------------------------------------------------------

	IF @query_all = 0 AND @designation_id IS NULL
		RETURN;

	--Get procurement data----------------------------------------------------

	CREATE TABLE #proc_data (
		procurement_sub_category_id int,
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,4),
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
		SUM(IIF(st.name = 'Headcount', pd.amount, 0.0)) as labor_amount,
		SUM(IIF(st.name = 'Spend', cast(pd.amount as numeric(20,4)), 0.0)) as third_party_amount,
		SUM(IIF(st.name = 'Spend', IIF(fsf.is_total_cost = 1, pd.amount, 0.0), 0.0)) as deducted_by_total_cost
	FROM vc.procurement_data pd
	INNER JOIN vc.spend_type st ON st.spend_type_id = pd.spend_type_id
	INNER JOIN vc.function_saving_factor fsf ON fsf.function_id = pd.function_id AND fsf.designation_id = pd.designation_id
	WHERE pd.year = @input_year
	  AND pd.designation_id = ISNULL(@designation_id, pd.designation_id)
	GROUP BY
		pd.procurement_sub_category_id,
		pd.designation_id,
		pd.function_id,
		pd.year,
		pd.is_direct;

	--Get function data-------------------------------------------------------

	CREATE TABLE #func_data (
		designation_id int,
		function_id int,
		year int,
		is_direct bit,
		labor_amount numeric(20,4),
		third_party_amount numeric(20,4),
		deducted_by_total_cost numeric(20,4)
	 );

	INSERT INTO #func_data
	SELECT
		fd.designation_id,
		fd.function_id,
		fd.year,
		NULL as is_direct,
		SUM(fd.amount) as labor_amount,
		0.0 as third_party_amount,
		0.0 as deducted_by_total_cost
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
		labor_amount numeric(20,4),
		third_party_amount numeric(20,4),
		deducted_by_total_cost numeric(20,4)
	)

	INSERT INTO #proc_func
	SELECT
		pd.designation_id,
		pd.function_id,
		pd.year,
		pd.is_direct,
		pd.labor_amount,
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
		labor_amount numeric(20,4),
		third_party_amount numeric(20,4),
		labor_target_low_factor numeric(20,6),
		labor_target_high_factor numeric(20,6),
		third_party_target_low_factor numeric(20,6),
		third_party_target_high_factor numeric(20,6),
	);

	INSERT INTO #combined_data
	SELECT
		'Function', --data_type
		pfd.year,
		pfd.function_id,
		pfd.designation_id,
		NULL as procurement_sub_category_id,
		NULL as is_direct,
		SUM(pfd.labor_amount),
		SUM(pfd.third_party_amount),
		IsNull(fsf.labor_target_low_factor,0) as labor_target_low_factor,
		IsNull(fsf.labor_target_high_factor,0) as labor_target_high_factor,
		IsNull(fsf.third_party_target_low_factor,0) as third_party_target_low_factor,
		IsNull(fsf.third_party_target_high_factor,0) as third_party_target_high_factor
	FROM #proc_func pfd
	LEFT JOIN vc.function_saving_factor fsf ON pfd.function_id = fsf.function_id AND pfd.designation_id = fsf.designation_id
	GROUP BY
		pfd.year,
		pfd.function_id,
		pfd.designation_id,
		fsf.labor_target_low_factor,
		fsf.labor_target_high_factor,
		fsf.third_party_target_low_factor,
		fsf.third_party_target_high_factor
	 UNION ALL
	 SELECT
		'Procurement', --data_type,
		pd.year,
		NULL as function_id,
		pd.designation_id,
		pd.procurement_sub_category_id,
		pd.is_direct,
		SUM(pd.labor_amount),
		SUM(pd.third_party_amount) - SUM(pd.deducted_by_total_cost) as third_party_amount,
		IsNull(psf.low_factor,0) as labor_target_low_factor,
		IsNull(psf.high_factor,0) as labor_target_high_factor,
		psf.low_factor as third_party_target_low_factor,
		psf.high_factor as third_party_target_high_factor
	FROM #proc_data pd
	LEFT JOIN vc.procurement_saving_factor psf ON pd.procurement_sub_category_id = psf.procurement_sub_category_id AND pd.designation_id = psf.designation_id
	GROUP BY
		pd.year,
		pd.designation_id,
		pd.is_direct,
		psf.low_factor,
		psf.high_factor,
		pd.procurement_sub_category_id,
		psf.low_factor,
		psf.high_factor;

	IF @query_all = 1 BEGIN
		--Query all designations--------------------------------------------------
		DECLARE @total_by_SubCategory_and_designation table (
			designation_id int,
			procurement_sub_category_id int,
			partial_labor_amount numeric(20,4),
			partial_third_party_amount numeric(20,4)
		);

		INSERT INTO @total_by_SubCategory_and_designation
		SELECT
			designation_id,
			procurement_sub_category_id,
			sUM(IsNull(labor_amount,0)),
			sUM(IsNull(third_party_amount,0))
		FROM
			#combined_data
		GROUP BY
			procurement_sub_category_id,
			designation_id;

		--------------------------------------------------------------------------
		DECLARE @total_by_SubCategory table (
			procurement_sub_category_id int,
			total_labor_amount numeric(20,4),
			total_third_party_amount numeric(20,4)
		);

		INSERT INTO @total_by_SubCategory
		SELECT
			procurement_sub_category_id,
			sUM(IsNull(partial_labor_amount,0)),
			sUM(IsNull(partial_third_party_amount,0))
		FROM
			@total_by_SubCategory_and_designation
		GROUP BY
			procurement_sub_category_id;

		--------------------------------------------------------------------------
		DECLARE @weighted_factors table (
			procurement_sub_category_id int,
			third_party_target_low_factor numeric(20,6),
			third_party_target_high_factor numeric(20,6)
		);

		INSERT INTO @weighted_factors
		SELECT
			t.procurement_sub_category_id,
			sUM(IIF(partial_third_party_amount = 0.0 or fsf.low_factor = 0.0, 0.0, partial_third_party_amount / total_third_party_amount * fsf.low_factor)), --third_party_target_low_factor,
			sUM(IIF(partial_third_party_amount = 0.0 or fsf.high_factor = 0.0, 0.0, partial_third_party_amount / total_third_party_amount * fsf.high_factor)) --third_party_target_high_factor
		FROM @total_by_SubCategory_and_designation p
		LEFT JOIN @total_by_SubCategory T ON t.procurement_sub_category_id = p.procurement_sub_category_id
		LEFT JOIN vc.Procurement_saving_factor fsf ON P.procurement_sub_category_id = fsf.procurement_sub_category_id AND	P.designation_id = fsf.designation_id
		GROUP BY
			t.procurement_sub_category_id;

		--Returned result set query-----------------------------------------------
		SELECT
			cd.data_type,
			cd.year,
			cd.is_direct,
			NULL AS designation_id,
			NULL AS designation_name,
			SUM(cd.third_party_amount) AS third_party_amount,
			SUM(wf.third_party_target_low_factor) AS third_party_target_low_factor,
			SUM(wf.third_party_target_high_factor) AS third_party_target_high_factor
		FROM #combined_data cd
		INNER JOIN vc.designation d ON cd.designation_id = d.designation_id
		LEFT JOIN @weighted_factors wf ON cd.procurement_sub_category_id = wf.procurement_sub_category_id
		WHERE cd.third_party_amount IS NOT NULL
		and cd.data_type = 'Procurement'
		GROUP BY cd.data_type, cd.year, cd.is_direct
		order by cd.is_direct desc;

	END

	ELSE BEGIN
		--Query by designation----------------------------------------------------
		SELECT
			cd.data_type,
			cd.year,
			cd.is_direct,
			d.designation_id,
			d.name AS designation_name,
			SUM(cd.third_party_amount) AS third_party_amount,
			cd.third_party_target_low_factor,
			cd.third_party_target_high_factor
		FROM #combined_data cd
		INNER JOIN vc.designation d ON cd.designation_id = d.designation_id
		INNER JOIN VC.procurement_sub_category psc on cd.procurement_sub_category_id = psc.procurement_sub_category_id
		WHERE cd.third_party_amount IS NOT NULL
		  AND cd.designation_id = @designation_id
		  and cd.data_type = 'Procurement'
		GROUP BY cd.data_type, cd.year, cd.is_direct, d.designation_id, d.name, 
		         cd.third_party_target_low_factor, cd.third_party_target_high_factor
		order by d.name, cd.is_direct desc, cd.third_party_target_low_factor desc;

	END

	--------------------------------------------------------------------------

	DROP TABLE #proc_data;
	DROP TABLE #func_data;
	DROP TABLE #proc_func;
	DROP TABLE #combined_data;

END










CREATE PROCEDURE [vc].[proc_getProcurementSubCategoryDirectIndirectBenchmarkByDesignation](
    @input_year int,
    @designation_id int,
    @query_all bit
) AS
BEGIN
	/*declare
	    @input_year int = 2020,
	    @designation_id int = NULL,
	    @query_all bit = 1*/

	--Sanity check------------------------------------------------------------

	IF @query_all = 0 AND @designation_id IS NULL
		RETURN;

	DECLARE @PROC_BENCH_CATEGORY TABLE (
			designation_id int,
			designation_name nvarchar(100),
			procurement_category_id int,
			procurement_category_name nvarchar(100),
			procurement_sub_category_id int,
			procurement_sub_category_name nvarchar(100),
			procurement_spend numeric(20,2),
			original_spend numeric(20,2),
			opportunity_range_low_factor numeric(20,2),
			opportunity_range_high_factor numeric(20,2),
			original_low_factor numeric(20,2),
			original_high_factor numeric(20,2),
			low_calibrated_factor numeric(20,2),
			high_calibrated_factor numeric(20,2),
			low_target_opportunity_range numeric(20,2),
			high_target_opportunity_range numeric(20,2),
			is_direct bit
			--,impacting_functions nvarchar(MAX)
		);

	insert into @PROC_BENCH_CATEGORY
	EXEC [vc].[proc_getProcurementBaseData] @input_year, @designation_id, @query_all;

	--select * from @PROC_BENCH_CATEGORY

	DECLARE @SUBCATEGORY_SAVING_FACTORS TABLE (
			subcategory_low_factor numeric(20,2),
			subcategory_high_factor numeric(20,2),
			procurement_sub_category_id int,
			procurement_sub_category_name nvarchar(100),
			designation_id int,
			is_direct bit
		);

	WITH SUBCATEGORY_AMOUNT_TOTAL AS (
		SELECT
			sum(pd.procurement_spend) as designation_amount
			,pd.procurement_sub_category_id
			,pd.is_direct
		FROM
			@PROC_BENCH_CATEGORY pd
		GROUP BY
			pd.procurement_sub_category_id
			,pd.is_direct)
	--SELECT * FROM DESIGNATION_AMOUNT_TOTAL

	INSERT INTO @SUBCATEGORY_SAVING_FACTORS
	SELECT
		SUM(IIF(dat.designation_amount = 0.0 , 0.0, pd.procurement_spend / dat.designation_amount * pd.opportunity_range_low_factor)) as weighted_opportunity_range_low_factor
		,SUM(IIF(dat.designation_amount = 0.0 , 0.0, pd.procurement_spend / dat.designation_amount * pd.opportunity_range_high_factor)) as weighted_opportunity_range_high_factor
		,pd.procurement_sub_category_id
		,pd.procurement_sub_category_name
		,pd.designation_id
		,pd.is_direct
	FROM
		SUBCATEGORY_AMOUNT_TOTAL dat
		INNER JOIN @PROC_BENCH_CATEGORY pd
			ON dat.procurement_sub_category_id = pd.procurement_sub_category_id
			AND dat.is_direct = pd.is_direct
	GROUP BY
		pd.procurement_sub_category_id
		,pd.procurement_sub_category_name
		,pd.designation_id
		,pd.is_direct;
	
	--SELECT * FROM @SUBCATEGORY_SAVING_FACTORS order by procurement_sub_category_id;

	IF @query_all = 1 BEGIN
		select 
			null											as designation_id
			,null											as designation_name
			,procurement_category_id
			,procurement_category_name
			,pbc.procurement_sub_category_id
			,pbc.procurement_sub_category_name
			,sum(procurement_spend)							as spend
			,sum(procurement_spend)							as procurement_spend
			,sum(original_spend)							as original_spend
			,sum(ssf.subcategory_low_factor)				as opportunity_range_low_factor
			,sum(ssf.subcategory_high_factor)				as opportunity_range_high_factor
			--,avg(opportunity_range_low_factor)				
			--,avg(opportunity_range_high_factor)				
			,avg(original_low_factor)						as original_low_factor
			,avg(original_high_factor)						as original_high_factor
			,avg(low_calibrated_factor)						as low_calibrated_factor
			,avg(high_calibrated_factor)					as high_calibrated_factor
			,pbc.is_direct
			--,max(impacting_functions)						as impacting_functions
		from 
			@PROC_BENCH_CATEGORY pbc
			INNER JOIN @SUBCATEGORY_SAVING_FACTORS ssf
				ON pbc.procurement_sub_category_id = ssf.procurement_sub_category_id
				AND pbc.designation_id  = ssf.designation_id
				AND pbc.is_direct = ssf.is_direct
		group by 
			procurement_category_id
			,procurement_category_name
			,pbc.procurement_sub_category_id
			,pbc.procurement_sub_category_name
			,pbc.is_direct
		order by designation_name, procurement_category_name
	END
	ELSE 
		BEGIN
		SELECT
			designation_id
			,designation_name
			,procurement_category_id
			,procurement_category_name
			,procurement_sub_category_id
			,procurement_sub_category_name
			,sum(procurement_spend)							as spend
			,sum(procurement_spend)						as procurement_spend
			,sum(original_spend)							as original_spend
			,avg(opportunity_range_low_factor)				as opportunity_range_low_factor
			,avg(opportunity_range_high_factor)				as opportunity_range_high_factor
			,avg(original_low_factor)						as original_low_factor
			,avg(original_high_factor)						as original_high_factor
			,avg(low_calibrated_factor)						as low_calibrated_factor
			,avg(high_calibrated_factor)					as high_calibrated_factor
			,is_direct
			--,max(impacting_functions)						as impacting_functions
		from 
			@PROC_BENCH_CATEGORY
		where 
			designation_id = IsNull(@designation_id, designation_id)
		group by 
			designation_id
			,designation_name
			,procurement_category_id
			,procurement_category_name
			,procurement_sub_category_id
			,procurement_sub_category_name
			,is_direct
		order by designation_name, procurement_category_name, procurement_sub_category_name
	END



END


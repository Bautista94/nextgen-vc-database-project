














CREATE PROCEDURE [vc].[proc_getProcurementCategoryDirectIndirectBenchmarkByDesignation](
    @input_year int,
    @designation_id int,
    @query_all bit
) AS
BEGIN
  /*declare
  @input_year int = 2020,
  @designation_id int = null,
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
	EXEC [vc].[proc_getProcurementBaseData] @input_year, @designation_id, @query_all


	IF @query_all = 1 
		--Global Level
		BEGIN
			SELECT 
				NULL as designation_id, 
				NULL as designation_name, 
				a.procurement_category_id, 
				a.procurement_category_name,
				sum(a.procurement_spend) as spend,
				sum(a.procurement_spend) as procurement_spend,
				sum(a.original_spend)	as original_spend,
				--*** CHECK THE COLUMNS BELOW ***
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.original_low_factor)/sum(a.procurement_spend),2)) as original_low_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.original_high_factor)/sum(a.procurement_spend),2)) as original_high_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.low_calibrated_factor)/sum(a.procurement_spend),2)) as low_calibrated_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.high_calibrated_factor)/sum(a.procurement_spend),2)) as high_calibrated_factor,
				avg(b.managed_touched_factor) as managed_touched_factor,
				avg(b.managed_not_touched_factor) as managed_not_touched_factor,
				avg(b.unmanaged_factor) as unmanaged_factor,
				avg(b.bb_factor) as buybetter_factor,
				avg(b.sb_factor) as spendbetter_factor,
				--***
				a.is_direct
				--,MAX(a.impacting_functions) AS impacting_functions
			from 
				@PROC_BENCH_CATEGORY a
				left join [vc].[procurement_category_survey] b 
					ON a.procurement_category_id = b.procurement_category_id 
					AND a.designation_id = b.designation_id 
					AND A.is_direct = B.is_direct
			group by 
				a.procurement_category_id
				,a.procurement_category_name
				,a.is_direct
				--,a.impacting_functions
			order by 
				a.procurement_category_name
		END
	ELSE 
		--By Designation
		BEGIN
			SELECT
				a.designation_id
				,a.designation_name
				,a.procurement_category_id
				,a.procurement_category_name
				,sum(a.procurement_spend) as spend
				,sum(a.procurement_spend) as procurement_spend
				,sum(a.original_spend)	as original_spend
				--*** CHECK THE COLUMNS BELOW ***
				,IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.original_low_factor)/sum(a.procurement_spend),2)) as original_low_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.original_high_factor)/sum(a.procurement_spend),2)) as original_high_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.low_calibrated_factor)/sum(a.procurement_spend),2)) as low_calibrated_factor,
				IIF(sum(a.procurement_spend) = 0,0.00, round(sum(a.high_calibrated_factor)/sum(a.procurement_spend),2)) as high_calibrated_factor,
				avg(b.managed_touched_factor) as managed_touched_factor,
				avg(b.managed_not_touched_factor) as managed_not_touched_factor,
				avg(b.unmanaged_factor) as unmanaged_factor,
				avg(b.bb_factor) as buybetter_factor,
				avg(b.sb_factor) as spendbetter_factor,
				--***
				a.is_direct
				--,MAX(a.impacting_functions) AS impacting_functions
			from 
				@PROC_BENCH_CATEGORY a
				left join [vc].[procurement_category_survey] b 
					ON a.procurement_category_id = b.procurement_category_id 
					AND a.designation_id = b.designation_id
			where 
				a.designation_id = IsNull(@designation_id, a.designation_id)
			group by 
				a.designation_id
				,a.designation_name
				,a.procurement_category_id
				,a.procurement_category_name
				,a.is_direct
			order by 
				a.designation_name
				,a.procurement_category_name
		END
	END

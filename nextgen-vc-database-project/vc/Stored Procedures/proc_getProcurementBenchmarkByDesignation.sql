CREATE PROCEDURE [vc].[proc_getProcurementBenchmarkByDesignation](
    @input_year int,
    @designation_id int,
    @query_all bit
) AS
BEGIN
	--declare
	--    @input_year int = 2020,
	--    @designation_id int = 106,
	--    @query_all bit = null

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
			spend numeric(20,2),
			original_low_factor numeric(20,2),
			original_high_factor numeric(20,2),
			low_calibrated_factor numeric(20,2),
			high_calibrated_factor numeric(20,2)
		);

	insert into @PROC_BENCH_CATEGORY
	select d.designation_id, d.name as designation_name, 
			   pc.procurement_category_id, pc.name as procurement_category_name,
			   pd.procurement_sub_category_id, psc.name as procurement_sub_category_name,
			   sum(pd.amount) as spend_by_sub_category,
			   pb.low_factor as original_low_factor,
			   pb.high_factor as original_high_factor,
			   pb.low_calibrated_factor,
			   pb.high_calibrated_factor
		from vc.procurement_data pd
		join vc.designation d on pd.designation_id = d.designation_id
		left join vc.procurement_sub_category psc on pd.procurement_sub_category_id = psc.procurement_sub_category_id
		left join vc.procurement_category pc on psc.procurement_category_id = pc.procurement_category_id
		left join vc.procurement_benchmark pb on psc.procurement_sub_category_id = pb.procurement_sub_category_id
		where pd.year = @input_year
		and pd.designation_id = IsNull(@designation_id, pd.designation_id)
		group by d.designation_id, d.name, 
				 pc.procurement_category_id, pc.name, 
				 pd.procurement_sub_category_id, psc.name,
			     pb.low_factor, pb.high_factor, pb.low_calibrated_factor, pb.high_calibrated_factor
		order by d.name, pc.name, psc.name

	IF @query_all = 1 BEGIN
		select NULL as designation_id, NULL as designation_name, 
			   procurement_category_id, procurement_category_name,
			   NULL as procurement_sub_category_id, NULL as procurement_sub_category_name,
			   sum(spend) as spend,
			   original_low_factor,
			   original_high_factor,
			   low_calibrated_factor,
			   high_calibrated_factor
		from @PROC_BENCH_CATEGORY
		group by procurement_category_id, procurement_category_name,
			     original_low_factor, original_high_factor, low_calibrated_factor, high_calibrated_factor
		order by procurement_category_name
	END
	ELSE BEGIN
		select designation_id, designation_name, 
				procurement_category_id, procurement_category_name,
				procurement_sub_category_id, procurement_sub_category_name,
				sum(spend) as spend,
				original_low_factor,
				original_high_factor,
				low_calibrated_factor,
				high_calibrated_factor
		from @PROC_BENCH_CATEGORY
		group by designation_id, designation_name, procurement_category_id, procurement_category_name,
				procurement_sub_category_id, procurement_sub_category_name, original_low_factor,
				original_high_factor, low_calibrated_factor, high_calibrated_factor
		order by designation_name, procurement_category_name, procurement_sub_category_name
	END



END

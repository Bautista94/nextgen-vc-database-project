





CREATE PROCEDURE [vc].[proc_getProcurementBaseData](
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

	WITH FUNCTIONS_MATC AS (
		SELECT
			fsf.function_id
			,f.name as function_name
		FROM
			vc.function_saving_factor fsf
			INNER JOIN vc.[function] f 
				ON fsf.function_id = f.function_id
		WHERE
			fsf.is_total_cost = 1)
	,SUBCATEGORIES_MATC AS (
		SELECT 
			pd.procurement_sub_category_id
			,fmatc.function_id
			,fmatc.function_name
		FROM
			vc.procurement_data pd
			INNER JOIN FUNCTIONS_MATC fmatc
				ON pd.function_id = fmatc.function_id
		WHERE
			pd.year = @input_year
			and pd.designation_id = IsNull(@designation_id, pd.designation_id)
		GROUP BY
			pd.procurement_sub_category_id
			,fmatc.function_id
			,fmatc.function_name)
	,IMPACTING_FUNCTIONS AS (
	SELECT
		smatc.procurement_sub_category_id
		,STRING_AGG(smatc.function_name,', ') as impacted_functions
	FROM
		SUBCATEGORIES_MATC smatc
	GROUP BY
		smatc.procurement_sub_category_id)

	SELECT
		pd.designation_id
		,d.name															as designation_name
		,pc.procurement_category_id
		,pc.name														as procurement_category_name
		,psc.procurement_sub_category_id
		,psc.name														as procurement_sub_category_name
		,SUM(IIF(fsf.is_total_cost = 0, pd.amount, 0.0))				as procurement_spend
		,SUM(pd.amount)													as original_spend
		,psf.low_factor													as opportunity_range_low_factor
		,psf.high_factor												as opportunity_range_high_factor
		,pb.low_factor													as original_low_factor
		,pb.high_factor													as original_high_factor
		,pb.low_calibrated_factor
		,pb.high_calibrated_factor
		,(SUM(IIF(fsf.is_total_cost = 0, pd.amount, 0.0)) * psf.low_factor)								as low_target_opportinity_range
		,(SUM(IIF(fsf.is_total_cost = 0, pd.amount, 0.0)) * psf.high_factor)								as high_target_opportinity_range
		,pd.is_direct
		--,imf.impacted_functions
	FROM
		vc.procurement_data pd
		INNER JOIN vc.designation d
			ON pd.designation_id = d.designation_id 
		INNER JOIN vc.procurement_sub_category psc
			ON pd.procurement_sub_category_id = psc.procurement_sub_category_id
		INNER JOIN vc.procurement_category pc
			ON psc.procurement_category_id = pc.procurement_category_id
		LEFT JOIN vc.procurement_saving_factor psf
			ON psf.procurement_sub_category_id = pd.procurement_sub_category_id
			AND psf.designation_id = pd.designation_id
		LEFT JOIN vc.procurement_benchmark pb
			ON pb.procurement_sub_category_id = pd.procurement_sub_category_id
			AND pb.designation_id = pd.designation_id
			AND pb.function_id = pd.function_id
			AND pb.is_direct = pd.is_direct
		LEFT JOIN vc.function_saving_factor fsf
			ON fsf.function_id = pd.function_id	
			AND fsf.designation_id = pd.designation_id
		LEFT JOIN IMPACTING_FUNCTIONS imf
			ON imf.procurement_sub_category_id = pd.procurement_sub_category_id
	WHERE
		pd.year = @input_year
		and pd.designation_id = IsNull(@designation_id, pd.designation_id)
	GROUP BY
		pd.designation_id
		,d.name
		,pc.procurement_category_id
		,pc.name
		,psc.procurement_sub_category_id
		,psc.name
		,psf.low_factor
		,psf.high_factor
		,pb.low_factor
		,pb.high_factor
		,pb.low_calibrated_factor
		,pb.high_calibrated_factor
		,pd.is_direct
		--,imf.impacted_functions
		--,fsf.is_total_cost;
	ORDER BY
		psc.procurement_sub_category_id
END

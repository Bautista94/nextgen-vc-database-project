










CREATE PROCEDURE [vc].[proc_initialize_factors_and_percentages]
AS
BEGIN
	DECLARE @var_table_count int;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[function_saving_factor]);

	IF (@var_table_count = 0)
			INSERT INTO  [vc].[function_saving_factor]
           ([function_id]
           ,[designation_id]
           ,[labor_target_low_factor]
           ,[labor_target_high_factor]
           ,[third_party_target_low_factor]
           ,[third_party_target_high_factor]
           ,[is_total_cost]) 
		SELECT
			f.[function_id]
			,d.designation_id
           ,0.0 as [labor_target_low_factor]
           ,0.0 as [labor_target_high_factor]
           ,0.0 as [third_party_target_low_factor]
           ,0.0 as [third_party_target_high_factor]
           ,0 as [is_total_cost]
		FROM
			vc.[function] as f,
			vc.designation as d;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[function_custom_percentage]);

	IF (@var_table_count = 0)
		INSERT INTO [vc].[function_custom_percentage]
           ([function_id]
           ,[designation_id]
           ,[function_custom_percentage_1]
           ,[function_custom_percentage_2])
		SELECT
			f.[function_id]
			,d.designation_id
           ,'Not Set' as [function_custom_percentage_1]
           ,'Not Set' as [function_custom_percentage_2]
		FROM
			vc.[function] as f,
			vc.designation as d;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[function_type_custom_percentage]);

	IF (@var_table_count = 0)
		INSERT INTO [vc].[function_type_custom_percentage]
				   ([function_type_id]
				   ,[designation_id]
				   ,[function_type_custom_percentage_1]
				   ,[function_type_custom_percentage_2])
				SELECT
					f.[function_type_id]
					,d.designation_id
				   ,'Not Set' as [function_type_custom_percentage_1]
				   ,'Not Set' as [function_type_custom_percentage_2]
				FROM
					vc.[function_type] as f,
					vc.designation as d;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[procurement_saving_factor]);

	IF (@var_table_count = 0)
		INSERT INTO [vc].[procurement_saving_factor]
			   ([procurement_sub_category_id]
			   ,[designation_id]
			   ,[low_factor]
			   ,[high_factor])
				SELECT
				psc.[procurement_sub_category_id]
			   ,d.[designation_id]
			   ,0.0 as [benchmark_low_factor]
			   ,0.0 as [benchmark_high_factor]
				FROM
					vc.[procurement_sub_category] as psc,
					vc.designation as d;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].procurement_benchmark);

	IF (@var_table_count = 0)
		INSERT INTO [vc].procurement_benchmark
			   ([procurement_sub_category_id]
			   ,[designation_id]
			   ,function_id
			   ,[low_factor]
			   ,[high_factor]
			   ,[low_calibrated_factor]
			   ,[high_calibrated_factor]
			   ,[is_direct])
				SELECT
				psc.[procurement_sub_category_id]
			   ,d.[designation_id]
			   ,f.[function_id]
			   ,0.0 as [low_factor]
			   ,0.0 as [high_factor]
			   ,0.0 as [low_calibrated_factor]
			   ,0.0 as [high_calibrated_factor]
			   ,(select max(cast(pd.is_direct as int)) from vc.procurement_data pd where pd.procurement_sub_category_id = psc.procurement_sub_category_id) as is_direct
				FROM
					vc.[procurement_sub_category] as psc,
					vc.designation as d
					,vc.[function] as f;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].procurement_category_survey);

	IF (@var_table_count = 0)
		INSERT INTO [vc].procurement_category_survey
			   ([procurement_category_id]
			   ,[designation_id]
			   ,[managed_touched_factor]
			   ,[managed_not_touched_factor]
			   ,[unmanaged_factor]
			   ,[bb_factor]
			   ,[sb_factor]
			   ,[low_benchmark_saving_factor]
			   ,[high_benchmark_saving_factor]
			   ,[is_direct])
				SELECT
				pc.[procurement_category_id]
			   ,d.[designation_id]
			   ,0.20 as [managed_touched_factor]
			   ,0.40 as [managed_not_touched_factor]
			   ,0.60 as [unmanaged_factor]
			   ,0.30 as [bb_factor]
			   ,0.50 as [sb_factor]
			   ,0.10 as [low_benchmark_saving_factor]
			   ,0.70 as [high_benchmark_saving_factor]
			   ,(select max(cast(pd.is_direct as int)) from vc.procurement_data pd where pd.procurement_sub_category_id in (select psc.procurement_sub_category_id from vc.procurement_sub_category psc where psc.procurement_category_id = pc.procurement_category_id )) as is_direct
				FROM
					vc.procurement_category as pc,
					vc.designation as d;

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[function_survey_lever]);

	IF (@var_table_count = 0)
		INSERT INTO [vc].[function_survey_lever]
				   ([survey_lever_id]
				   ,[designation_id]
				   ,[function_id]
				   ,[score]
				   ,[benchmark])
		SELECT
			sl.survey_lever_id
			,d.designation_id
			,f.function_id
			,ABS(CHECKSUM(NEWID()) % 3)+1 AS score
			,ABS(CHECKSUM(NEWID()) % 3)+1 AS benchmark
		FROM
			vc.designation d
			,vc.[function] f
			,vc.survey_lever sl
		WHERE
			sl.type NOT IN ('Buy Better','Spend Better')

	SET @var_table_count = (SELECT COUNT(*) FROM [vc].[function_benchmark]);

	IF (@var_table_count = 0)
	WITH quartiles AS (
			SELECT
				f.function_id		
				,bm.benchmark_metric_id	
				,CASE	
					WHEN bm.name IN('FTEs as % of total FTEs','Total cost as % of revenue') THEN	
						CAST(RAND() AS numeric(4,3))
					WHEN bm.name ='Personnel cost per $1K revenue' THEN 
						ABS(CHECKSUM(NEWID()))%999
					ELSE	
						ABS(CHECKSUM(NEWID()))%99
				END			AS quartile_A
				,CASE	
					WHEN bm.name IN('FTEs as % of total FTEs','Total cost as % of revenue') THEN	
						CAST(RAND() AS numeric(4,3))
					WHEN bm.name ='Personnel cost per $1K revenue' THEN 
						ABS(CHECKSUM(NEWID()))%999
					ELSE	
						ABS(CHECKSUM(NEWID()))%99
				END			AS quartile_B
			FROM
				vc.[function] f
				,vc.benchmark_metric bm
		)
		INSERT INTO [vc].[function_benchmark]
				   ([function_id]
				   ,[benchmark_metric_id]
				   ,[benchmark_peer_group_id]
				   ,[top_quartile]
				   ,[median])
		SELECT
			f.function_id		
			,bm.benchmark_metric_id
			,bpg.benchmark_peer_group_id
			,CASE 
				WHEN quartile_A > quartile_B THEN
					quartile_A
				ELSE
					quartile_B
			END			AS median
			,CASE 
				WHEN quartile_A > quartile_B THEN
					quartile_B
				ELSE
					quartile_A
			END			AS top_quartile
		FROM
			quartiles q
			INNER JOIN vc.[function] f
				ON f.function_id = q.function_id
			INNER JOIN vc.benchmark_metric bm
				ON bm.benchmark_metric_id = q.benchmark_metric_id
			,vc.benchmark_peer_group bpg
END

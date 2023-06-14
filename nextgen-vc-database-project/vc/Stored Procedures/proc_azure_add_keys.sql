/* ================================================================================================================================================
   Procedure Name : [vc].[proc_azure_add_keys]
   Purpose : 
   Last Modified: 
   Date Modified:  
   Inputs :
		
   
   Outputs:


	Parameters :
	This can be replace by procedure parameters for testing with the following declare statement:
================================================================================================================================================*/

CREATE    PROCEDURE [vc].[proc_azure_add_keys](
    @input_number INT
--@benchmark_peer_group INT --uncomment this once user INTerface is developed
) AS
BEGIN
	
	ALTER TABLE [vc].[function]  WITH CHECK ADD  CONSTRAINT [fk_function_01] FOREIGN KEY([function_type_id])
	REFERENCES [vc].[function_type] ([function_type_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function] CHECK CONSTRAINT [fk_function_01];
	--ALTER TABLE [vc].[function_type_custom_percentage]  WITH CHECK ADD  CONSTRAINT [fk_function_type_custom_percentage_01] FOREIGN KEY([function_type_id])
	--REFERENCES [vc].[function_type] ([function_type_id])
	--ON DELETE CASCADE;

--
	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_04] FOREIGN KEY([cost_center_id])
	REFERENCES [vc].[cost_center] ([cost_center_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_04];

	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_12] FOREIGN KEY([cost_center_id])
	REFERENCES [vc].[cost_center] ([cost_center_id]);
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_12];
	 
--
	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_02] FOREIGN KEY([business_unit_id])
	REFERENCES [vc].[business_unit] ([business_unit_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_02];

	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_03] FOREIGN KEY([business_unit_id])
	REFERENCES [vc].[business_unit] ([business_unit_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_03];
	
--
	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_03] FOREIGN KEY([spend_type_id])
	REFERENCES [vc].[spend_type] ([spend_type_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_03];

	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_04] FOREIGN KEY([spend_type_id])
	REFERENCES [vc].[spend_type] ([spend_type_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_04];

--
	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_11] FOREIGN KEY([year_id])
	REFERENCES [vc].[year] ([year_id]);
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_11];

	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_09] FOREIGN KEY([year_id])
	REFERENCES [vc].[year] ([year_id]);
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_09];

--
	--ALTER TABLE [vc].[function_custom_percentage]  WITH CHECK ADD  CONSTRAINT [fk_function_custom_percentage_02] FOREIGN KEY([designation_id])
	--REFERENCES [vc].[designation] ([designation_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_05] FOREIGN KEY([designation_id])
	REFERENCES [vc].[designation] ([designation_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_05];
	--ALTER TABLE [vc].[function_saving_factor]  WITH CHECK ADD  CONSTRAINT [fk_function_saving_02] FOREIGN KEY([designation_id])
	--REFERENCES [vc].[designation] ([designation_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[function_survey_lever]  WITH NOCHECK ADD  CONSTRAINT [FK_function_survey_lever_02] FOREIGN KEY([designation_id])
	REFERENCES [vc].[designation] ([designation_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_survey_lever] CHECK CONSTRAINT [FK_function_survey_lever_02];

	ALTER TABLE [vc].[function_top_lever]  WITH CHECK ADD  CONSTRAINT [FK_function_top_lever_01] FOREIGN KEY([designation_id])
	REFERENCES [vc].[designation] ([designation_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_top_lever] CHECK CONSTRAINT [FK_function_top_lever_01];
	--ALTER TABLE [vc].[function_type_custom_percentage]  WITH CHECK ADD  CONSTRAINT [fk_function_type_custom_percentage_02] FOREIGN KEY([designation_id])
	--REFERENCES [vc].[designation] ([designation_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_05] FOREIGN KEY([designation_id])
	REFERENCES [vc].[designation] ([designation_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_05];
	--ALTER TABLE [vc].[procurement_survey_lever]  WITH CHECK ADD  CONSTRAINT [FK_procurement_top_lever_02] FOREIGN KEY([designation_id])
	--REFERENCES [vc].[designation] ([designation_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[procurement_top_lever]  WITH CHECK ADD  CONSTRAINT [FK_procurement_top_lever_01] FOREIGN KEY([designation_id])
	REFERENCES [vc].[designation] ([designation_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_top_lever] CHECK CONSTRAINT [FK_procurement_top_lever_01];

--
	--ALTER TABLE [vc].[function_benchmark]  WITH CHECK ADD  CONSTRAINT [fk_function_benchmark_01] FOREIGN KEY([function_id])
	--REFERENCES [vc].[function] ([function_id])
	--ON DELETE CASCADE
	--ALTER TABLE [vc].[function_custom_percentage]  WITH CHECK ADD  CONSTRAINT [fk_function_custom_percentage_01] FOREIGN KEY([function_id])
	--REFERENCES [vc].[function] ([function_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[function_data]  WITH CHECK ADD  CONSTRAINT [fk_function_data_01] FOREIGN KEY([function_id])
	REFERENCES [vc].[function] ([function_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_data] CHECK CONSTRAINT [fk_function_data_01];
	--ALTER TABLE [vc].[function_saving_factor]  WITH CHECK ADD  CONSTRAINT [fk_function_saving_01] FOREIGN KEY([function_id])
	--REFERENCES [vc].[function] ([function_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[function_summary]  WITH NOCHECK ADD  CONSTRAINT [FK_function_summary_01] FOREIGN KEY([function_id])
	REFERENCES [vc].[function] ([function_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_summary] CHECK CONSTRAINT [FK_function_summary_01];

	ALTER TABLE [vc].[function_top_lever]  WITH CHECK ADD  CONSTRAINT [FK_function_top_lever_02] FOREIGN KEY([function_id])
	REFERENCES [vc].[function] ([function_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[function_top_lever] CHECK CONSTRAINT [FK_function_top_lever_02];

	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_02] FOREIGN KEY([function_id])
	REFERENCES [vc].[function] ([function_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_02];
--
	--ALTER TABLE [vc].[procurement_category_survey]  WITH CHECK ADD  CONSTRAINT [FK_procurement_category_survey_01] FOREIGN KEY([procurement_category_id])
	--REFERENCES [vc].[procurement_category] ([procurement_category_id])
	--ON DELETE CASCADE
	ALTER TABLE [vc].[procurement_data]  WITH CHECK ADD  CONSTRAINT [fk_procurement_data_01] FOREIGN KEY([procurement_category_id])
	REFERENCES [vc].[procurement_category] ([procurement_category_id])
	ON DELETE CASCADE;
	ALTER TABLE [vc].[procurement_data] CHECK CONSTRAINT [fk_procurement_data_01];

END

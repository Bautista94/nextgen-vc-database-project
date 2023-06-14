/* ================================================================================================================================================
   Procedure Name : [vc].[proc_azure_delete_keys]
   Purpose : 
   Last Modified: 
   Date Modified:  
   Inputs :
		
   
   Outputs:


	Parameters :
	This can be replace by procedure parameters for testing with the following declare statement:
================================================================================================================================================*/

CREATE     PROCEDURE [vc].[proc_azure_delete_keys](
    @input_number INT
--@benchmark_peer_group INT --uncomment this once user INTerface is developed
) AS
BEGIN

	TRUNCATE TABLE [vc].[function_data];

	TRUNCATE TABLE [vc].[procurement_data];

	ALTER TABLE [vc].[function] DROP CONSTRAINT [fk_function_01];
	--ALTER TABLE [vc].[function_type_custom_percentage] DROP CONSTRAINT [fk_function_type_custom_percentage_01];
	
	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_04];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_12];

	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_02];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_03];

	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_03];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_04];
	
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_11];
	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_09];

	--ALTER TABLE [vc].[function_custom_percentage] DROP CONSTRAINT [fk_function_custom_percentage_02];
	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_05];
	--ALTER TABLE [vc].[function_saving_factor] DROP CONSTRAINT [fk_function_saving_02];
	ALTER TABLE [vc].[function_survey_lever] DROP CONSTRAINT [FK_function_survey_lever_02];
	ALTER TABLE [vc].[function_top_lever] DROP CONSTRAINT [FK_function_top_lever_01];
	--ALTER TABLE [vc].[function_type_custom_percentage] DROP CONSTRAINT [fk_function_type_custom_percentage_02];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_05];
	--ALTER TABLE [vc].[procurement_survey_lever] DROP CONSTRAINT [FK_procurement_top_lever_02];
	ALTER TABLE [vc].[procurement_top_lever] DROP CONSTRAINT [FK_procurement_top_lever_01];

	--ALTER TABLE [vc].[function_benchmark] DROP CONSTRAINT [fk_function_benchmark_01];
	--ALTER TABLE [vc].[function_custom_percentage] DROP CONSTRAINT [fk_function_custom_percentage_01];
	ALTER TABLE [vc].[function_data] DROP CONSTRAINT [fk_function_data_01];
	--ALTER TABLE [vc].[function_saving_factor] DROP CONSTRAINT [fk_function_saving_01];
	ALTER TABLE [vc].[function_summary] DROP CONSTRAINT [FK_function_summary_01];
	ALTER TABLE [vc].[function_top_lever] DROP CONSTRAINT [FK_function_top_lever_02];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_02];

	--ALTER TABLE [vc].[procurement_category_survey] DROP CONSTRAINT [FK_procurement_category_survey_01];
	ALTER TABLE [vc].[procurement_data] DROP CONSTRAINT [fk_procurement_data_01];

	TRUNCATE TABLE [vc].[procurement_category];
	TRUNCATE TABLE [vc].[function_type];
	TRUNCATE TABLE [vc].[cost_center];
	TRUNCATE TABLE [vc].[business_unit];
	TRUNCATE TABLE [vc].[spend_type];
	TRUNCATE TABLE [vc].[year];
	TRUNCATE TABLE [vc].[function];
	TRUNCATE TABLE [vc].[designation];

END

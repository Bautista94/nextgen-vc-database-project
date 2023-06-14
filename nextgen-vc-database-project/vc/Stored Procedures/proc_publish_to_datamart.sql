


CREATE PROCEDURE [vc].[proc_publish_to_datamart]  AS

--EXEC [vc].[proc_publish_fact_baseline]

--EXEC [vc].[proc_publish_baseline_function]

--EXEC [vc].[proc_publish_baseline_procurement]

--EXEC [vc].[proc_publish_benchmark]

drop table vc_datamart.application_fact_baseline

select * 
into vc_datamart.application_fact_baseline
from (
		select 'function' as datasource_type, NULL as category, NULL as subcategory, cast([business unit] as nvarchar(400)) as [business unit],
				/*case when isnull([Labor/NonLabor],'0') = 1 then 'Labor' else 'NonLabor' end as*/ [Labor/NonLabor], 
				[Function Type], [Function], [Spend Type], Year, Designation, [cost center], [Cost Center Name],
				[Cost Center Description], [Account Description], [Savings source type], [Savings source], [Sub Function], [Account Number],
				cast(Amount as numeric(20,2)) as Amount, [Designation Revenue]
		from vc_staging.function_data_raw
		union
		select 'procurement' as datasource_type, Category, Subcategory, cast([business unit] as nvarchar(400)) as [business unit],
				/*case when isnull([Labor/NonLabor],'0') = 1 then 'Labor' else 'NonLabor' end as*/ [Labor/NonLabor],
				ft.[name] as [Function Type], [Function], [Spend Type], Year, Designation, [cost center], [Cost Center Name],
				[Cost Center Description], [Account Description], [Savings source type], [Savings source], [Sub Function], [Account Number],
				cast(Amount as numeric(20,2)) as Amount, [Designation Revenue]
		from vc_staging.procurement_data_raw pdr
		left join vc.[function] f on pdr.[Function] = f.[name]
		left join vc.function_type ft on f.function_type_id = ft.function_type_id
) t



--update vc_datamart.application_fact_baseline set
--year = '2021'
--where year in ('2021 F','2021 LTM')

--delete vc_datamart.application_fact_baseline where year = '2021'

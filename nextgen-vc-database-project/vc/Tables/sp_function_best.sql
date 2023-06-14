CREATE TABLE [vc].[sp_function_best] (
    [year_id]                         INT             DEFAULT (NULL) NULL,
    [year]                            VARCHAR (300)   DEFAULT (NULL) NULL,
    [function_type_id]                INT             DEFAULT (NULL) NULL,
    [function_type]                   VARCHAR (300)   DEFAULT (NULL) NULL,
    [function_id]                     INT             DEFAULT (NULL) NULL,
    [function]                        VARCHAR (300)   DEFAULT (NULL) NULL,
    [benchmark_metric_name]           NVARCHAR (100)  DEFAULT (NULL) NULL,
    [is_best]                         BIT             DEFAULT (NULL) NULL,
    [median_opportunity_amount]       NUMERIC (24, 6) DEFAULT (NULL) NULL,
    [top_quartile_opportunity_amount] NUMERIC (24, 6) DEFAULT (NULL) NULL
);


CREATE TABLE [vc].[benchmark_metric] (
    [benchmark_metric_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]                NVARCHAR (100) NOT NULL,
    [is_total_cost]       BIT            NULL,
    CONSTRAINT [PK_benchmark_metric] PRIMARY KEY CLUSTERED ([benchmark_metric_id] ASC),
    CONSTRAINT [uk_benchmark_metric_01] UNIQUE NONCLUSTERED ([name] ASC)
);


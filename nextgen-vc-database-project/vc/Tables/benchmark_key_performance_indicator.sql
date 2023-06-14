CREATE TABLE [vc].[benchmark_key_performance_indicator] (
    [benchmark_key_performance_indicator_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]                                   NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_benchmark_key_performance_indicator] PRIMARY KEY CLUSTERED ([benchmark_key_performance_indicator_id] ASC)
);


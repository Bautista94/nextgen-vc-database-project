CREATE TABLE [vc].[function_benchmark] (
    [function_benchmark_id]   INT        IDENTITY (1, 1) NOT NULL,
    [function_id]             INT        NOT NULL,
    [benchmark_metric_id]     INT        NOT NULL,
    [benchmark_peer_group_id] INT        NOT NULL,
    [top_quartile]            FLOAT (53) NULL,
    [median]                  FLOAT (53) NULL,
    [bottom_quartile]         FLOAT (53) NULL,
    [is_best]                 INT        DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_function_benchmark] PRIMARY KEY CLUSTERED ([function_benchmark_id] ASC),
    CONSTRAINT [fk_function_benchmark_02] FOREIGN KEY ([benchmark_metric_id]) REFERENCES [vc].[benchmark_metric] ([benchmark_metric_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_benchmark_03] FOREIGN KEY ([benchmark_peer_group_id]) REFERENCES [vc].[benchmark_peer_group] ([benchmark_peer_group_id]) ON DELETE CASCADE
);


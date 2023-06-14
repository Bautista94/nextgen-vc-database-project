CREATE TABLE [vc].[benchmark_peer_group] (
    [benchmark_peer_group_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]                    NVARCHAR (100) NOT NULL,
    [is_total_cost]           BIT            NULL,
    CONSTRAINT [PK_benchmark_peer_group] PRIMARY KEY CLUSTERED ([benchmark_peer_group_id] ASC),
    CONSTRAINT [uk_benchmark_peer_group_01] UNIQUE NONCLUSTERED ([name] ASC)
);


CREATE TABLE [vc].[level_filter] (
    [level_filter_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]            NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_level_filter] PRIMARY KEY CLUSTERED ([level_filter_id] ASC)
);


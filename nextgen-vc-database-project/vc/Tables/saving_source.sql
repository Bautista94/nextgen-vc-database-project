CREATE TABLE [vc].[saving_source] (
    [saving_source_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (100) NOT NULL,
    [type]             NVARCHAR (100) NULL,
    CONSTRAINT [PK_saving_source] PRIMARY KEY CLUSTERED ([saving_source_id] ASC)
);


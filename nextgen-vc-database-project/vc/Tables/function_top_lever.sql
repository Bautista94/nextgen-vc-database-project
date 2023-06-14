CREATE TABLE [vc].[function_top_lever] (
    [function_top_lever_id] INT             IDENTITY (1, 1) NOT NULL,
    [designation_id]        INT             NULL,
    [function_id]           INT             NULL,
    [description]           NVARCHAR (4000) NULL,
    CONSTRAINT [PK_function_top_lever] PRIMARY KEY CLUSTERED ([function_top_lever_id] ASC),
    CONSTRAINT [FK_function_top_lever_01] FOREIGN KEY ([designation_id]) REFERENCES [vc].[designation] ([designation_id]) ON DELETE CASCADE,
    CONSTRAINT [FK_function_top_lever_02] FOREIGN KEY ([function_id]) REFERENCES [vc].[function] ([function_id]) ON DELETE CASCADE
);


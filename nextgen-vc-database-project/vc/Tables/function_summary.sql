CREATE TABLE [vc].[function_summary] (
    [function_summary_id]   INT            IDENTITY (1, 1) NOT NULL,
    [function_id]           INT            NOT NULL,
    [formatted_description] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_function_summary] PRIMARY KEY CLUSTERED ([function_summary_id] ASC),
    CONSTRAINT [FK_function_summary_01] FOREIGN KEY ([function_id]) REFERENCES [vc].[function] ([function_id]) ON DELETE CASCADE
);


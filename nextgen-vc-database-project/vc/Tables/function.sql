CREATE TABLE [vc].[function] (
    [function_id]      INT            IDENTITY (1, 1) NOT NULL,
    [function_type_id] INT            NOT NULL,
    [name]             NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_function] PRIMARY KEY CLUSTERED ([function_id] ASC),
    CONSTRAINT [fk_function_01] FOREIGN KEY ([function_type_id]) REFERENCES [vc].[function_type] ([function_type_id]) ON DELETE CASCADE,
    CONSTRAINT [uk_function_01] UNIQUE NONCLUSTERED ([name] ASC, [function_type_id] ASC)
);


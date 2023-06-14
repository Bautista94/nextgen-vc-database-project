CREATE TABLE [vc].[function_type] (
    [function_type_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_function_type] PRIMARY KEY CLUSTERED ([function_type_id] ASC),
    CONSTRAINT [uk_function_type_01] UNIQUE NONCLUSTERED ([name] ASC)
);


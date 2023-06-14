CREATE TABLE [vc].[function_custom_percentage] (
    [function_custom_percentage_id] INT           IDENTITY (1, 1) NOT NULL,
    [function_id]                   INT           NULL,
    [designation_id]                INT           NULL,
    [function_custom_percentage_1]  NVARCHAR (50) NULL,
    [function_custom_percentage_2]  NVARCHAR (50) NULL,
    CONSTRAINT [PK_function_custom_percentage] PRIMARY KEY CLUSTERED ([function_custom_percentage_id] ASC)
);


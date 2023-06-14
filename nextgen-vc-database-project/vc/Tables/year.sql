CREATE TABLE [vc].[year] (
    [year_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]    NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_year] PRIMARY KEY CLUSTERED ([year_id] ASC)
);


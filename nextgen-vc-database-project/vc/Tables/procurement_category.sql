CREATE TABLE [vc].[procurement_category] (
    [procurement_category_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]                    NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_procurement_category] PRIMARY KEY CLUSTERED ([procurement_category_id] ASC),
    CONSTRAINT [uk_procurement_category_01] UNIQUE NONCLUSTERED ([name] ASC)
);


CREATE TABLE [vc].[business_unit] (
    [business_unit_id] INT             IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (100)  NOT NULL,
    [revenue]          NUMERIC (12, 2) NULL,
    CONSTRAINT [PK_business_unit] PRIMARY KEY CLUSTERED ([business_unit_id] ASC),
    CONSTRAINT [uk_business_unit_01] UNIQUE NONCLUSTERED ([name] ASC)
);


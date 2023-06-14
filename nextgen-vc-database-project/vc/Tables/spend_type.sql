CREATE TABLE [vc].[spend_type] (
    [spend_type_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]          NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_spend_type] PRIMARY KEY CLUSTERED ([spend_type_id] ASC),
    CONSTRAINT [uk_spend_type_01] UNIQUE NONCLUSTERED ([name] ASC)
);


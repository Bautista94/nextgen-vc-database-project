CREATE TABLE [vc].[procurement_summary] (
    [procurement_summary_id] INT            IDENTITY (1, 1) NOT NULL,
    [formatted_description]  NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_procurement_summary] PRIMARY KEY CLUSTERED ([procurement_summary_id] ASC)
);


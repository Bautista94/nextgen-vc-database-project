CREATE TABLE [vc].[procurement_description] (
    [procurement_description_id]   INT            IDENTITY (1, 1) NOT NULL,
    [formatted_description]        NVARCHAR (MAX) NULL,
    [survey_formatted_description] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_procurement_description] PRIMARY KEY CLUSTERED ([procurement_description_id] ASC)
);


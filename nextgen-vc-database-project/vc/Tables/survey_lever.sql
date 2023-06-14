CREATE TABLE [vc].[survey_lever] (
    [survey_lever_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]            NVARCHAR (100) NULL,
    [type]            NVARCHAR (100) NULL,
    CONSTRAINT [PK_survey_lever] PRIMARY KEY CLUSTERED ([survey_lever_id] ASC)
);


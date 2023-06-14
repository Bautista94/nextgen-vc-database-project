CREATE TABLE [vc].[procurement_survey_pillar] (
    [procurement_survey_pillar_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]                         NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_procurement_survey_pillar] PRIMARY KEY CLUSTERED ([procurement_survey_pillar_id] ASC)
);


﻿CREATE TABLE [vc].[procurement_survey_lever] (
    [procurement_survey_lever_id] INT            IDENTITY (1, 1) NOT NULL,
    [survey_lever_id]             INT            NULL,
    [designation_id]              INT            NULL,
    [score]                       NUMERIC (3, 2) NULL,
    [benchmark]                   NUMERIC (3, 2) NULL,
    [standard_text]               VARCHAR (1000) NULL,
    CONSTRAINT [PK_procurement_survey_lever] PRIMARY KEY CLUSTERED ([procurement_survey_lever_id] ASC),
    CONSTRAINT [FK_procurement_survey_lever_01] FOREIGN KEY ([survey_lever_id]) REFERENCES [vc].[survey_lever] ([survey_lever_id]) ON DELETE CASCADE
);


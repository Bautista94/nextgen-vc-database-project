CREATE TABLE [vc].[procurement_top_lever] (
    [procurement_top_lever_id] INT             IDENTITY (1, 1) NOT NULL,
    [designation_id]           INT             NULL,
    [description]              NVARCHAR (4000) NULL,
    CONSTRAINT [PK_procurement_top_lever] PRIMARY KEY CLUSTERED ([procurement_top_lever_id] ASC),
    CONSTRAINT [FK_procurement_top_lever_01] FOREIGN KEY ([designation_id]) REFERENCES [vc].[designation] ([designation_id]) ON DELETE CASCADE
);


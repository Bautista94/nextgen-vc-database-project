CREATE TABLE [vc].[cost_center] (
    [cost_center_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]           NVARCHAR (100) NOT NULL,
    [display_name]   NVARCHAR (200) NULL,
    [description]    NVARCHAR (200) NULL,
    CONSTRAINT [PK_cost_center] PRIMARY KEY CLUSTERED ([cost_center_id] ASC),
    CONSTRAINT [uk_cost_center_01] UNIQUE NONCLUSTERED ([cost_center_id] ASC, [name] ASC, [display_name] ASC, [description] ASC)
);


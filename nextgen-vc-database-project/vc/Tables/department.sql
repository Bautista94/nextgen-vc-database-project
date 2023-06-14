CREATE TABLE [vc].[department] (
    [department_id] INT            IDENTITY (1, 1) NOT NULL,
    [name]          NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_department] PRIMARY KEY CLUSTERED ([department_id] ASC)
);


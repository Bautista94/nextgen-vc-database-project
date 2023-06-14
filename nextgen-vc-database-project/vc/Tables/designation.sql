CREATE TABLE [vc].[designation] (
    [designation_id] INT             IDENTITY (1, 1) NOT NULL,
    [name]           NVARCHAR (100)  NOT NULL,
    [revenue]        NUMERIC (20, 2) NULL,
    CONSTRAINT [PK_designation] PRIMARY KEY CLUSTERED ([designation_id] ASC)
);


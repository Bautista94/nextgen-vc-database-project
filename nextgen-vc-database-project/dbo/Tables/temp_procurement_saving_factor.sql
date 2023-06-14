CREATE TABLE [dbo].[temp_procurement_saving_factor] (
    [procurement_category]    NVARCHAR (100) NOT NULL,
    [procurement_category_id] INT            NULL,
    [designation]             NVARCHAR (100) NOT NULL,
    [low_factor]              FLOAT (53)     NULL,
    [high_factor]             FLOAT (53)     NULL
);


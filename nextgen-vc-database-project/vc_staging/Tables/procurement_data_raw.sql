CREATE TABLE [vc_staging].[procurement_data_raw] (
    [procurement_data_raw_id] BIGINT        NULL,
    [Labor/NonLabor]          CHAR (8)      NULL,
    [Category]                VARCHAR (40)  NULL,
    [Subcategory]             CHAR (1)      NULL,
    [Function]                VARCHAR (26)  NULL,
    [Business Unit]           FLOAT (53)    NULL,
    [Spend Type]              CHAR (5)      NULL,
    [Year]                    SMALLINT      NULL,
    [Amount]                  FLOAT (53)    NULL,
    [Cost Center]             CHAR (5)      NULL,
    [Designation]             CHAR (6)      NULL,
    [Account Number]          CHAR (6)      NULL,
    [Cost Center Description] NVARCHAR (46) NULL,
    [Cost Center Name]        NVARCHAR (42) NULL,
    [Account Description]     NVARCHAR (49) NULL,
    [Savings source type]     CHAR (10)     NULL,
    [Savings source]          VARCHAR (40)  NULL,
    [Sub Function]            VARCHAR (26)  NULL,
    [Is Direct]               FLOAT (53)    NULL,
    [Designation Revenue]     FLOAT (53)    NULL,
    [IsDirecto]               FLOAT (53)    NULL
);


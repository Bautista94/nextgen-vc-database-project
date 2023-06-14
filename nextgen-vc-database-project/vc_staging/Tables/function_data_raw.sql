CREATE TABLE [vc_staging].[function_data_raw] (
    [function_data_raw_id]    BIGINT        NULL,
    [Labor/NonLabor]          CHAR (5)      NULL,
    [Function Type]           VARCHAR (17)  NULL,
    [Function]                VARCHAR (26)  NULL,
    [Business Unit]           CHAR (3)      NULL,
    [Spend Type]              CHAR (5)      NULL,
    [Year]                    SMALLINT      NULL,
    [Cost Center]             CHAR (5)      NULL,
    [Amount]                  FLOAT (53)    NULL,
    [Designation]             CHAR (6)      NULL,
    [Account Number]          INT           NULL,
    [Cost Center Description] NVARCHAR (46) NULL,
    [Cost Center Name]        NVARCHAR (40) NULL,
    [Account Description]     VARCHAR (49)  NULL,
    [Savings source type]     CHAR (10)     NULL,
    [Savings source]          VARCHAR (26)  NULL,
    [Sub Function]            VARCHAR (26)  NULL,
    [Employee count]          FLOAT (53)    NULL,
    [Is Direct]               FLOAT (53)    NULL,
    [Designation Revenue]     FLOAT (53)    NULL
);


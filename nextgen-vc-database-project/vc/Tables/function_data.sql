﻿CREATE TABLE [vc].[function_data] (
    [function_data_id]    INT             IDENTITY (1, 1) NOT NULL,
    [function_id]         INT             NOT NULL,
    [business_unit_id]    INT             NOT NULL,
    [designation_id]      INT             NOT NULL,
    [spend_type_id]       INT             NOT NULL,
    [year]                INT             NULL,
    [year_id]             INT             NOT NULL,
    [account_number]      NVARCHAR (500)  NOT NULL,
    [amount]              NUMERIC (12, 2) NOT NULL,
    [employee_count]      NUMERIC (7, 2)  NOT NULL,
    [cost_center_id]      INT             NOT NULL,
    [amount_local]        NUMERIC (12)    NULL,
    [department_id]       INT             NULL,
    [level_1_filter_id]   INT             NULL,
    [level_2_filter_id]   INT             NULL,
    [level_3_filter_id]   INT             NULL,
    [is_labor]            BIT             NULL,
    [account_description] NVARCHAR (500)  NULL,
    [saving_source_id]    INT             NULL,
    CONSTRAINT [PK_function_data] PRIMARY KEY CLUSTERED ([function_data_id] ASC),
    CONSTRAINT [fk_function_data_01] FOREIGN KEY ([function_id]) REFERENCES [vc].[function] ([function_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_02] FOREIGN KEY ([business_unit_id]) REFERENCES [vc].[business_unit] ([business_unit_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_03] FOREIGN KEY ([spend_type_id]) REFERENCES [vc].[spend_type] ([spend_type_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_04] FOREIGN KEY ([cost_center_id]) REFERENCES [vc].[cost_center] ([cost_center_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_05] FOREIGN KEY ([designation_id]) REFERENCES [vc].[designation] ([designation_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_06] FOREIGN KEY ([department_id]) REFERENCES [vc].[department] ([department_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_07] FOREIGN KEY ([level_1_filter_id]) REFERENCES [vc].[level_filter] ([level_filter_id]) ON DELETE CASCADE,
    CONSTRAINT [fk_function_data_08] FOREIGN KEY ([level_2_filter_id]) REFERENCES [vc].[level_filter] ([level_filter_id]),
    CONSTRAINT [fk_function_data_09] FOREIGN KEY ([year_id]) REFERENCES [vc].[year] ([year_id]),
    CONSTRAINT [fk_function_data_11] FOREIGN KEY ([saving_source_id]) REFERENCES [vc].[saving_source] ([saving_source_id])
);


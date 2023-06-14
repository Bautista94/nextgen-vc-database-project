CREATE TABLE [vc].[function_saving_factor] (
    [function_saving_factor_id]      INT            IDENTITY (1, 1) NOT NULL,
    [function_id]                    INT            NOT NULL,
    [designation_id]                 INT            NOT NULL,
    [labor_target_low_factor]        NUMERIC (9, 8) NULL,
    [labor_target_high_factor]       NUMERIC (9, 8) NULL,
    [third_party_target_low_factor]  NUMERIC (9, 8) NULL,
    [third_party_target_high_factor] NUMERIC (9, 8) NULL,
    [is_total_cost]                  BIT            NOT NULL,
    CONSTRAINT [PK_function_saving_factor] PRIMARY KEY CLUSTERED ([function_saving_factor_id] ASC)
);


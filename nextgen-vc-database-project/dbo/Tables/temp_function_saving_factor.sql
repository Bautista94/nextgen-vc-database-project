CREATE TABLE [dbo].[temp_function_saving_factor] (
    [function]                       NVARCHAR (100) NOT NULL,
    [designation]                    NVARCHAR (100) NOT NULL,
    [function_type]                  NVARCHAR (100) NOT NULL,
    [labor_target_low_factor]        NUMERIC (9, 8) NULL,
    [labor_target_high_factor]       NUMERIC (9, 8) NULL,
    [third_party_target_low_factor]  NUMERIC (9, 8) NULL,
    [third_party_target_high_factor] NUMERIC (9, 8) NULL,
    [is_total_cost]                  BIT            NOT NULL
);


CREATE TABLE [vc].[procurement_benchmark] (
    [designation_id]                   INT        NULL,
    [low_factor]                       FLOAT (53) NULL,
    [high_factor]                      FLOAT (53) NULL,
    [is_direct]                        BIGINT     NULL,
    [keep_procurement_savings_factors] BIT        NULL,
    [procurement_category_id]          INT        NULL,
    [low_calibrated_factor]            FLOAT (53) NULL,
    [high_calibrated_factor]           FLOAT (53) NULL
);


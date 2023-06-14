CREATE TABLE [vc].[procurement_category_survey] (
    [procurement_category_survey_id] INT            IDENTITY (1, 1) NOT NULL,
    [procurement_category_id]        INT            NULL,
    [designation_id]                 INT            NULL,
    [managed_touched_factor]         NUMERIC (3, 2) NULL,
    [managed_not_touched_factor]     NUMERIC (3, 2) NULL,
    [unmanaged_factor]               NUMERIC (3, 2) NULL,
    [bb_factor]                      NUMERIC (3, 2) NULL,
    [sb_factor]                      NUMERIC (3, 2) NULL,
    [low_benchmark_saving_factor]    NUMERIC (3, 2) NULL,
    [high_benchmark_saving_factor]   NUMERIC (3, 2) NULL,
    [is_direct]                      BIT            NULL,
    CONSTRAINT [PK_procurement_category_survey] PRIMARY KEY CLUSTERED ([procurement_category_survey_id] ASC)
);


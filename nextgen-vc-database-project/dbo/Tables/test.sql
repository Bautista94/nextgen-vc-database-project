CREATE TABLE [dbo].[test] (
    [RetainSummaryTexts]           TINYINT    NULL,
    [KeepHarveyball]               TINYINT    NULL,
    [KeepSavingFactors]            TINYINT    NULL,
    [FileName]                     CHAR (15)  NULL,
    [BaseURL]                      CHAR (42)  NULL,
    [Container]                    CHAR (29)  NULL,
    [Folder]                       CHAR (19)  NULL,
    [File]                         CHAR (25)  NULL,
    [SAS]                          CHAR (133) NULL,
    [   URL*   ]                   CHAR (244) NULL,
    [Drive]                        CHAR (1)   NULL,
    [KeepProcurementSavingFactors] TINYINT    NULL,
    [NewFileName]                  NTEXT      NULL,
    [NewURL]                       NTEXT      NULL,
    [Query]                        NTEXT      NULL,
    [Import Template URL]          NTEXT      NULL,
    [Import Template File]         NTEXT      NULL,
    [DownloadHeaders]              TEXT       NULL
);


CREATE EXTERNAL DATA SOURCE [RawDataBS]
    WITH (
    TYPE = BLOB_STORAGE,
    LOCATION = N'https://nextgenvcdevstorage2.blob.core.windows.net/nextgenvcdevstoragecontainer2/DataImport_Standard',
    CREDENTIAL = [blobcred]
    );


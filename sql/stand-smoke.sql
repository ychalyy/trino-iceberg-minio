CREATE SCHEMA IF NOT EXISTS iceberg.stand_check;

CREATE TABLE IF NOT EXISTS iceberg.stand_check.probe (
    id BIGINT,
    label VARCHAR
) WITH (
    format = 'PARQUET',
    format_version = 2
);

MERGE INTO iceberg.stand_check.probe AS target
USING (VALUES (BIGINT '1', 'trino'), (BIGINT '2', 'minio')) AS sample (id, label)
ON target.id = sample.id
WHEN NOT MATCHED THEN
    INSERT (id, label) VALUES (sample.id, sample.label);

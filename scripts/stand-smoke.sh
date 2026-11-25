#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
mode=${1:-}
if [[ "$mode" != prepare && "$mode" != verify ]]; then
    printf 'Usage: bash scripts/stand-smoke.sh {prepare|verify}\n' >&2
    exit 2
fi

trino() {
    docker compose exec -T trino trino --server http://localhost:8080 "$@"
}

if [[ "$mode" == prepare ]]; then
    trino --file /dev/stdin < sql/stand-smoke.sql
fi

rows=$(trino --output-format TSV --execute 'SELECT id, label FROM iceberg.stand_check.probe ORDER BY id')
expected=$(printf '1\ttrino\n2\tminio')
printf '%s\n' "$rows"
if [[ "$rows" != "$expected" ]]; then
    printf 'Unexpected Iceberg rows\n' >&2
    exit 1
fi

policy=$(docker compose exec -T mc sh -ec '/usr/bin/mc anonymous get "minio/$WAREHOUSE_BUCKET"')
printf '%s\n' "$policy"
if [[ "$policy" != *private* ]]; then
    printf 'Expected a private warehouse bucket\n' >&2
    exit 1
fi

objects=$(docker compose exec -T mc sh -ec '/usr/bin/mc ls --recursive "minio/$WAREHOUSE_BUCKET"')
printf '%s\n' "$objects"
if [[ "$objects" != *stand_check*probe*/data/*.parquet* ||
      "$objects" != *stand_check*probe*/metadata/*.metadata.json* ]]; then
    printf 'Expected both Parquet data and Iceberg metadata for the probe table\n' >&2
    exit 1
fi

printf 'OK: Iceberg rows, private MinIO bucket, Parquet and Iceberg metadata.\n'

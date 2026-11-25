CREATE SCHEMA IF NOT EXISTS iceberg.raw;

CREATE SCHEMA IF NOT EXISTS iceberg.stage;

CREATE SCHEMA IF NOT EXISTS iceberg.vault;

CREATE SCHEMA IF NOT EXISTS iceberg.mart;

CREATE SCHEMA IF NOT EXISTS iceberg.ops;

CREATE TABLE IF NOT EXISTS iceberg.ops.batches (
    batch_seq integer,
    batch_id varchar,
    loaded_at timestamp(6) with time zone,
    status varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.ops.dq_results (
    run_id varchar,
    batch_id varchar,
    checked_at timestamp(6) with time zone,
    phase varchar,
    rule_id varchar,
    object_name varchar,
    expected_value bigint,
    actual_value bigint,
    violations bigint,
    status varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.region (
    regionkey bigint,
    name varchar(25),
    comment varchar(152),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.nation (
    nationkey bigint,
    name varchar(25),
    regionkey bigint,
    comment varchar(152),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.supplier (
    suppkey bigint,
    name varchar(25),
    address varchar(40),
    nationkey bigint,
    phone varchar(15),
    acctbal decimal(15,2),
    comment varchar(101),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.customer (
    custkey bigint,
    name varchar(25),
    address varchar(40),
    nationkey bigint,
    phone varchar(15),
    acctbal decimal(15,2),
    mktsegment varchar(10),
    comment varchar(117),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.part (
    partkey bigint,
    name varchar(55),
    mfgr varchar(25),
    brand varchar(10),
    type varchar(25),
    size integer,
    container varchar(10),
    retailprice decimal(15,2),
    comment varchar(23),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.partsupp (
    partkey bigint,
    suppkey bigint,
    availqty integer,
    supplycost decimal(15,2),
    comment varchar(199),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.orders (
    orderkey bigint,
    custkey bigint,
    orderstatus varchar(1),
    totalprice decimal(15,2),
    orderdate date,
    orderpriority varchar(15),
    clerk varchar(15),
    shippriority integer,
    comment varchar(79),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.raw.lineitem (
    orderkey bigint,
    partkey bigint,
    suppkey bigint,
    linenumber integer,
    quantity decimal(15,2),
    extendedprice decimal(15,2),
    discount decimal(4,2),
    tax decimal(4,2),
    returnflag varchar(1),
    linestatus varchar(1),
    shipdate date,
    commitdate date,
    receiptdate date,
    shipinstruct varchar(25),
    shipmode varchar(10),
    comment varchar(44),
    batch_seq integer
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_region (
    hk varchar,
    regionkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_nation (
    hk varchar,
    nationkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_supplier (
    hk varchar,
    suppkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_customer (
    hk varchar,
    custkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_part (
    hk varchar,
    partkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.h_order (
    hk varchar,
    orderkey bigint,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_nation_region (
    hk varchar,
    hk_nation varchar,
    hk_region varchar,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_supplier_nation (
    hk varchar,
    hk_supplier varchar,
    hk_nation varchar,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_customer_nation (
    hk varchar,
    hk_customer varchar,
    hk_nation varchar,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_order_customer (
    hk varchar,
    hk_order varchar,
    hk_customer varchar,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_partsupp (
    hk varchar,
    hk_part varchar,
    hk_supplier varchar,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.l_lineitem (
    hk varchar,
    hk_order varchar,
    hk_part varchar,
    hk_supplier varchar,
    linenumber integer,
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_region (
    hk varchar,
    hashdiff varchar,
    name varchar(25),
    comment varchar(152),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_nation (
    hk varchar,
    hashdiff varchar,
    name varchar(25),
    comment varchar(152),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_supplier (
    hk varchar,
    hashdiff varchar,
    name varchar(25),
    address varchar(40),
    phone varchar(15),
    acctbal decimal(15,2),
    comment varchar(101),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_customer (
    hk varchar,
    hashdiff varchar,
    name varchar(25),
    address varchar(40),
    phone varchar(15),
    acctbal decimal(15,2),
    mktsegment varchar(10),
    comment varchar(117),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_part (
    hk varchar,
    hashdiff varchar,
    name varchar(55),
    mfgr varchar(25),
    brand varchar(10),
    type varchar(25),
    size integer,
    container varchar(10),
    retailprice decimal(15,2),
    comment varchar(23),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_partsupp (
    hk varchar,
    hashdiff varchar,
    availqty integer,
    supplycost decimal(15,2),
    comment varchar(199),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_order (
    hk varchar,
    hashdiff varchar,
    orderstatus varchar(1),
    totalprice decimal(15,2),
    orderdate date,
    orderpriority varchar(15),
    clerk varchar(15),
    shippriority integer,
    comment varchar(79),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.vault.s_lineitem (
    hk varchar,
    hashdiff varchar,
    quantity decimal(15,2),
    extendedprice decimal(15,2),
    discount decimal(4,2),
    tax decimal(4,2),
    returnflag varchar(1),
    linestatus varchar(1),
    shipdate date,
    commitdate date,
    receiptdate date,
    shipinstruct varchar(25),
    shipmode varchar(10),
    comment varchar(44),
    batch_seq integer,
    loaded_at timestamp(6) with time zone,
    record_source varchar
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.mart.sales_snapshot (
    batch_seq integer,
    order_month date,
    customer_region varchar,
    orders bigint,
    line_count bigint,
    gross_sales decimal(38,2),
    net_sales decimal(38,4)
) WITH (format = 'PARQUET', format_version = 2);

CREATE TABLE IF NOT EXISTS iceberg.mart.shipping_snapshot (
    batch_seq integer,
    ship_month date,
    ship_mode varchar,
    shipped_lines bigint,
    late_lines bigint,
    late_share double
) WITH (format = 'PARQUET', format_version = 2);

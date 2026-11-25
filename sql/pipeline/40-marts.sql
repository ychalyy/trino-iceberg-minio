CREATE OR REPLACE VIEW iceberg.stage.raw_positions AS
SELECT *
FROM (
    SELECT b.batch_seq AS as_of_batch, p.*,
           row_number() OVER (PARTITION BY b.batch_seq, orderkey, linenumber ORDER BY p.batch_seq DESC) AS version_rank
    FROM iceberg.ops.batches b
    JOIN iceberg.raw.lineitem p ON p.batch_seq <= b.batch_seq
) versions
WHERE version_rank = 1;

CREATE OR REPLACE VIEW iceberg.stage.vault_positions AS
SELECT *
FROM (
    SELECT b.batch_seq AS as_of_batch, p.*,
           row_number() OVER (PARTITION BY b.batch_seq, hk ORDER BY p.batch_seq DESC) AS version_rank
    FROM iceberg.ops.batches b
    JOIN iceberg.vault.s_lineitem p ON p.batch_seq <= b.batch_seq
) versions
WHERE version_rank = 1;

CREATE OR REPLACE VIEW iceberg.stage.vault_sales AS
SELECT batch_seq, order_month, customer_region, count(DISTINCT order_id) AS orders,
       count(*) AS line_count, sum(extendedprice) AS gross_sales,
       sum(CAST(extendedprice * (DECIMAL '1.00' - discount) AS decimal(22,4))) AS net_sales
FROM (
    SELECT li.as_of_batch AS batch_seq, date_trunc('month', o.orderdate) AS order_month,
           region.name AS customer_region, p.hk_order AS order_id, li.extendedprice, li.discount
    FROM iceberg.stage.vault_positions li
    JOIN iceberg.vault.l_lineitem p ON p.hk = li.hk AND p.batch_seq <= li.as_of_batch
    JOIN iceberg.vault.s_order o ON o.hk = p.hk_order AND o.batch_seq <= li.as_of_batch
    JOIN iceberg.vault.l_order_customer oc ON oc.hk_order = p.hk_order AND oc.batch_seq <= li.as_of_batch
    JOIN iceberg.vault.l_customer_nation cn ON cn.hk_customer = oc.hk_customer AND cn.batch_seq <= li.as_of_batch
    JOIN iceberg.vault.l_nation_region nr ON nr.hk_nation = cn.hk_nation AND nr.batch_seq <= li.as_of_batch
    JOIN iceberg.vault.s_region region ON region.hk = nr.hk_region AND region.batch_seq <= li.as_of_batch
) items
GROUP BY batch_seq, order_month, customer_region;

CREATE OR REPLACE VIEW iceberg.stage.vault_shipping AS
SELECT batch_seq, ship_month, ship_mode, count(*) AS shipped_lines,
       count_if(shipdate > commitdate) AS late_lines,
       CAST(count_if(shipdate > commitdate) AS double) / count(*) AS late_share
FROM (
    SELECT as_of_batch AS batch_seq, date_trunc('month', shipdate) AS ship_month,
           shipmode AS ship_mode, shipdate, commitdate
    FROM iceberg.stage.vault_positions
) items
WHERE shipdate IS NOT NULL
GROUP BY batch_seq, ship_month, ship_mode;

CREATE OR REPLACE VIEW iceberg.stage.raw_sales AS
SELECT batch_seq, order_month, customer_region, count(DISTINCT order_id) AS orders,
       count(*) AS line_count, sum(extendedprice) AS gross_sales,
       sum(CAST(extendedprice * (DECIMAL '1.00' - discount) AS decimal(22,4))) AS net_sales
FROM (
    SELECT li.as_of_batch AS batch_seq, date_trunc('month', o.orderdate) AS order_month,
           region.name AS customer_region, o.orderkey AS order_id, li.extendedprice, li.discount
    FROM iceberg.stage.raw_positions li
    JOIN iceberg.raw.orders o ON o.orderkey = li.orderkey AND o.batch_seq = 1
    JOIN iceberg.raw.customer c ON c.custkey = o.custkey AND c.batch_seq = 1
    JOIN iceberg.raw.nation n ON n.nationkey = c.nationkey AND n.batch_seq = 1
    JOIN iceberg.raw.region region ON region.regionkey = n.regionkey AND region.batch_seq = 1
) items
GROUP BY batch_seq, order_month, customer_region;

CREATE OR REPLACE VIEW iceberg.stage.raw_shipping AS
SELECT batch_seq, ship_month, ship_mode, count(*) AS shipped_lines,
       count_if(shipdate > commitdate) AS late_lines,
       CAST(count_if(shipdate > commitdate) AS double) / count(*) AS late_share
FROM (
    SELECT as_of_batch AS batch_seq, date_trunc('month', shipdate) AS ship_month,
           shipmode AS ship_mode, shipdate, commitdate
    FROM iceberg.stage.raw_positions
) items
WHERE shipdate IS NOT NULL
GROUP BY batch_seq, ship_month, ship_mode;

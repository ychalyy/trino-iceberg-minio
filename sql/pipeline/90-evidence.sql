SELECT batch_id, status FROM iceberg.ops.batches ORDER BY batch_seq;

SELECT 'region' AS source, count(*) AS raw_rows FROM iceberg.raw.region WHERE batch_seq=1
UNION ALL SELECT 'nation', count(*) FROM iceberg.raw.nation WHERE batch_seq=1
UNION ALL SELECT 'supplier', count(*) FROM iceberg.raw.supplier WHERE batch_seq=1
UNION ALL SELECT 'customer', count(*) FROM iceberg.raw.customer WHERE batch_seq=1
UNION ALL SELECT 'part', count(*) FROM iceberg.raw.part WHERE batch_seq=1
UNION ALL SELECT 'partsupp', count(*) FROM iceberg.raw.partsupp WHERE batch_seq=1
UNION ALL SELECT 'orders', count(*) FROM iceberg.raw.orders WHERE batch_seq=1
UNION ALL SELECT 'lineitem', count(*) FROM iceberg.raw.lineitem WHERE batch_seq=1
ORDER BY source;

SELECT r.orderkey, r.linenumber, v.batch_seq, v.extendedprice, v.discount
FROM iceberg.vault.s_lineitem v
JOIN iceberg.vault.l_lineitem l ON l.hk=v.hk
JOIN iceberg.vault.h_order o ON o.hk=l.hk_order
JOIN iceberg.raw.lineitem r ON r.batch_seq=2 AND r.orderkey=o.orderkey AND r.linenumber=l.linenumber
ORDER BY v.batch_seq;

WITH changed_group AS (
    SELECT date_trunc('month', o.orderdate) AS order_month,
           g.name AS customer_region, li.extendedprice
    FROM iceberg.raw.lineitem li
    JOIN iceberg.raw.orders o ON li.orderkey=o.orderkey
    JOIN iceberg.raw.customer c ON o.custkey=c.custkey
    JOIN iceberg.raw.nation n ON c.nationkey=n.nationkey
    JOIN iceberg.raw.region g ON n.regionkey=g.regionkey
    WHERE li.batch_seq=2
)
SELECT b.order_month, b.customer_region, a.net_sales AS before_net, b.net_sales AS after_net,
       b.net_sales-a.net_sales AS actual_delta, -g.extendedprice*DECIMAL '0.01' AS expected_delta
FROM iceberg.mart.sales_snapshot a
JOIN iceberg.mart.sales_snapshot b ON a.order_month=b.order_month AND a.customer_region=b.customer_region
JOIN changed_group g ON g.order_month=b.order_month AND g.customer_region=b.customer_region
WHERE a.batch_seq=1 AND b.batch_seq=2;

SELECT batch_id, phase, status, count(*) AS checks
FROM iceberg.ops.dq_results GROUP BY 1,2,3 ORDER BY 1,2,3;

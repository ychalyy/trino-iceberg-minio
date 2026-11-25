CREATE OR REPLACE VIEW iceberg.mart.sales_by_region AS
SELECT batch_seq, order_month, customer_region, orders, line_count, gross_sales, net_sales
FROM iceberg.mart.sales_snapshot
WHERE batch_seq = (SELECT max(batch_seq) FROM iceberg.ops.batches WHERE status = 'COMPLETE');

CREATE OR REPLACE VIEW iceberg.mart.shipping_by_mode AS
SELECT batch_seq, ship_month, ship_mode, shipped_lines, late_lines, late_share
FROM iceberg.mart.shipping_snapshot
WHERE batch_seq = (SELECT max(batch_seq) FROM iceberg.ops.batches WHERE status = 'COMPLETE');

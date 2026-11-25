MERGE INTO iceberg.mart.sales_snapshot AS t
USING (SELECT batch_seq, order_month, customer_region, orders, line_count, gross_sales, net_sales FROM iceberg.stage.vault_sales WHERE batch_seq=@batch_seq@) AS s
ON t.batch_seq=s.batch_seq AND t.order_month=s.order_month AND t.customer_region=s.customer_region
WHEN NOT MATCHED THEN INSERT (batch_seq, order_month, customer_region, orders, line_count, gross_sales, net_sales)
VALUES (s.batch_seq, s.order_month, s.customer_region, s.orders, s.line_count, s.gross_sales, s.net_sales);

MERGE INTO iceberg.mart.shipping_snapshot AS t
USING (SELECT batch_seq, ship_month, ship_mode, shipped_lines, late_lines, late_share FROM iceberg.stage.vault_shipping WHERE batch_seq=@batch_seq@) AS s
ON t.batch_seq=s.batch_seq AND t.ship_month=s.ship_month AND t.ship_mode=s.ship_mode
WHEN NOT MATCHED THEN INSERT (batch_seq, ship_month, ship_mode, shipped_lines, late_lines, late_share)
VALUES (s.batch_seq, s.ship_month, s.ship_mode, s.shipped_lines, s.late_lines, s.late_share);

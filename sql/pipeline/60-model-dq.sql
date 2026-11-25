MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'RAW_COUNT' AS rule_id, 'region' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.region WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.region WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'nation' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.nation WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.nation WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'supplier' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.supplier WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.supplier WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'customer' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.customer WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.customer WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'part' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.part WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.part WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'partsupp' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.partsupp WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.partsupp WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'orders' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.orders WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.orders WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'RAW_COUNT' AS rule_id, 'lineitem' AS object_name, q.* FROM (SELECT (SELECT count(*) FROM iceberg.stage.lineitem WHERE batch_seq=@batch_seq@) expected_value, count(*) actual_value FROM iceberg.raw.lineitem WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_region WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_nation WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_supplier WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_customer WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_part WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'h_order' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.h_order WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_nation_region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_nation_region WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_nation_region->h_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_nation_region c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_nation p WHERE p.hk=c.hk_nation AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_nation_region->h_region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_nation_region c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_region p WHERE p.hk=c.hk_region AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_supplier_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_supplier_nation WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_supplier_nation->h_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_supplier_nation c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_supplier p WHERE p.hk=c.hk_supplier AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_supplier_nation->h_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_supplier_nation c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_nation p WHERE p.hk=c.hk_nation AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_customer_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_customer_nation WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_customer_nation->h_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_customer_nation c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_customer p WHERE p.hk=c.hk_customer AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_customer_nation->h_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_customer_nation c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_nation p WHERE p.hk=c.hk_nation AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_order_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_order_customer WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'VAULT_FK' AS rule_id, 'l_order_customer->h_order' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_order_customer c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_order p WHERE p.hk=c.hk_order AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_order_customer->h_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_order_customer c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_customer p WHERE p.hk=c.hk_customer AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_partsupp WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_partsupp->h_part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_partsupp c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_part p WHERE p.hk=c.hk_part AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_partsupp->h_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_partsupp c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_supplier p WHERE p.hk=c.hk_supplier AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 'l_lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk FROM iceberg.vault.l_lineitem WHERE batch_seq<=@batch_seq@ GROUP BY hk HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_lineitem->h_order' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_lineitem c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_order p WHERE p.hk=c.hk_order AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_lineitem->h_part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_lineitem c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_part p WHERE p.hk=c.hk_part AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 'l_lineitem->h_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.l_lineitem c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_supplier p WHERE p.hk=c.hk_supplier AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_region WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_region->h_region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_region c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_region p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_region' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_region WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_region WHERE batch_seq=@batch_seq@) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_nation WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_nation->h_nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_nation c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_nation p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_nation' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_nation WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_nation WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_supplier WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_supplier->h_supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_supplier c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_supplier p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_supplier' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_supplier WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_supplier WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_customer WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_customer->h_customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_customer c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_customer p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_customer' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_customer WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_customer WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_part WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_part->h_part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_part c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_part p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_part' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_part WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_part WHERE batch_seq=@batch_seq@) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_partsupp WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_partsupp->l_partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_partsupp c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.l_partsupp p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_partsupp' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.l_partsupp WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_partsupp WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_order' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_order WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_order->h_order' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_order c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.h_order p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_order' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.h_order WHERE batch_seq=1), 0) expected_value, count(*) actual_value FROM iceberg.vault.s_order WHERE batch_seq=@batch_seq@) q
UNION ALL
SELECT 'VAULT_KEY_DUPLICATE' AS rule_id, 's_lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT hk, batch_seq FROM iceberg.vault.s_lineitem WHERE batch_seq<=@batch_seq@ GROUP BY hk, batch_seq HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'VAULT_FK' AS rule_id, 's_lineitem->l_lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.vault.s_lineitem c WHERE c.batch_seq<=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.vault.l_lineitem p WHERE p.hk=c.hk AND p.batch_seq<=c.batch_seq)) failures) q
UNION ALL
SELECT 'SAT_VERSION_COUNT' AS rule_id, 's_lineitem' AS object_name, q.* FROM (SELECT IF(@batch_seq@=1, (SELECT count(*) FROM iceberg.vault.l_lineitem WHERE batch_seq=1), 1) expected_value, count(*) actual_value FROM iceberg.vault.s_lineitem WHERE batch_seq=@batch_seq@) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'MART_RECONCILE' AS rule_id, 'sales' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM ((SELECT * FROM iceberg.stage.raw_sales WHERE batch_seq=@batch_seq@ EXCEPT SELECT * FROM iceberg.mart.sales_snapshot WHERE batch_seq=@batch_seq@) UNION ALL (SELECT * FROM iceberg.mart.sales_snapshot WHERE batch_seq=@batch_seq@ EXCEPT SELECT * FROM iceberg.stage.raw_sales WHERE batch_seq=@batch_seq@)) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'model' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'MART_RECONCILE' AS rule_id, 'shipping' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM ((SELECT * FROM iceberg.stage.raw_shipping WHERE batch_seq=@batch_seq@ EXCEPT SELECT * FROM iceberg.mart.shipping_snapshot WHERE batch_seq=@batch_seq@) UNION ALL (SELECT * FROM iceberg.mart.shipping_snapshot WHERE batch_seq=@batch_seq@ EXCEPT SELECT * FROM iceberg.stage.raw_shipping WHERE batch_seq=@batch_seq@)) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

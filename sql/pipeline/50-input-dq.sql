MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'input' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'KEY_NULL' AS rule_id, 'region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.region WHERE batch_seq = @batch_seq@ AND (regionkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT regionkey FROM iceberg.stage.region WHERE batch_seq = @batch_seq@ GROUP BY regionkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'region' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.region), 0) expected_value, count(*) actual_value FROM iceberg.stage.region WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.nation WHERE batch_seq = @batch_seq@ AND (nationkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT nationkey FROM iceberg.stage.nation WHERE batch_seq = @batch_seq@ GROUP BY nationkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'nation' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.nation), 0) expected_value, count(*) actual_value FROM iceberg.stage.nation WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'nation->region' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.nation c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.region p WHERE p.batch_seq=1 AND c.regionkey=p.regionkey)) failures) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.supplier WHERE batch_seq = @batch_seq@ AND (suppkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT suppkey FROM iceberg.stage.supplier WHERE batch_seq = @batch_seq@ GROUP BY suppkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'supplier' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.supplier), 0) expected_value, count(*) actual_value FROM iceberg.stage.supplier WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'supplier->nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.supplier c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.nation p WHERE p.batch_seq=1 AND c.nationkey=p.nationkey)) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'input' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'KEY_NULL' AS rule_id, 'customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.customer WHERE batch_seq = @batch_seq@ AND (custkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT custkey FROM iceberg.stage.customer WHERE batch_seq = @batch_seq@ GROUP BY custkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'customer' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.customer), 0) expected_value, count(*) actual_value FROM iceberg.stage.customer WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'customer->nation' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.customer c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.nation p WHERE p.batch_seq=1 AND c.nationkey=p.nationkey)) failures) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.part WHERE batch_seq = @batch_seq@ AND (partkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT partkey FROM iceberg.stage.part WHERE batch_seq = @batch_seq@ GROUP BY partkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'part' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.part), 0) expected_value, count(*) actual_value FROM iceberg.stage.part WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.partsupp WHERE batch_seq = @batch_seq@ AND (partkey IS NULL OR suppkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT partkey, suppkey FROM iceberg.stage.partsupp WHERE batch_seq = @batch_seq@ GROUP BY partkey, suppkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'partsupp' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.partsupp), 0) expected_value, count(*) actual_value FROM iceberg.stage.partsupp WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'partsupp->part' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.partsupp c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.part p WHERE p.batch_seq=1 AND c.partkey=p.partkey)) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

MERGE INTO iceberg.ops.dq_results AS t
USING (
    SELECT '@run_id@' AS run_id, '@batch_id@' AS batch_id, current_timestamp(6) AS checked_at,
       'input' AS phase, rule_id, object_name, expected_value, actual_value,
       abs(actual_value - expected_value) AS violations,
       IF(expected_value = actual_value, 'PASS', 'FAIL') AS status
FROM (
SELECT 'INPUT_FK' AS rule_id, 'partsupp->supplier' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.partsupp c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.supplier p WHERE p.batch_seq=1 AND c.suppkey=p.suppkey)) failures) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'orders' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.orders WHERE batch_seq = @batch_seq@ AND (orderkey IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'orders' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT orderkey FROM iceberg.stage.orders WHERE batch_seq = @batch_seq@ GROUP BY orderkey HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'orders' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.orders), 0) expected_value, count(*) actual_value FROM iceberg.stage.orders WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'orders->customer' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.orders c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.customer p WHERE p.batch_seq=1 AND c.custkey=p.custkey)) failures) q
UNION ALL
SELECT 'KEY_NULL' AS rule_id, 'lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.lineitem WHERE batch_seq = @batch_seq@ AND (orderkey IS NULL OR linenumber IS NULL)) failures) q
UNION ALL
SELECT 'KEY_DUPLICATE' AS rule_id, 'lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT orderkey, linenumber FROM iceberg.stage.lineitem WHERE batch_seq = @batch_seq@ GROUP BY orderkey, linenumber HAVING count(*) > 1) failures) q
UNION ALL
SELECT 'INPUT_COUNT' AS rule_id, 'lineitem' AS object_name, q.* FROM (SELECT IF(@batch_seq@ = 1, (SELECT count(*) FROM tpch.tiny.lineitem), 1) expected_value, count(*) actual_value FROM iceberg.stage.lineitem WHERE batch_seq = @batch_seq@) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'lineitem->orders' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.lineitem c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.orders p WHERE p.batch_seq=1 AND c.orderkey=p.orderkey)) failures) q
UNION ALL
SELECT 'INPUT_FK' AS rule_id, 'lineitem->partsupp' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.lineitem c WHERE c.batch_seq=@batch_seq@ AND NOT EXISTS (SELECT 1 FROM iceberg.stage.partsupp p WHERE p.batch_seq=1 AND c.partkey=p.partkey AND c.suppkey=p.suppkey)) failures) q
UNION ALL
SELECT 'DISCOUNT_RANGE' AS rule_id, 'lineitem' AS object_name, q.* FROM (SELECT CAST(0 AS bigint) expected_value, count(*) actual_value FROM (SELECT 1 FROM iceberg.stage.lineitem WHERE batch_seq=@batch_seq@ AND (discount IS NULL OR discount < 0 OR discount > 1)) failures) q
) results
) AS s
ON t.run_id = s.run_id AND t.phase = s.phase AND t.rule_id = s.rule_id AND t.object_name = s.object_name
WHEN NOT MATCHED THEN INSERT (run_id, batch_id, checked_at, phase, rule_id, object_name, expected_value, actual_value, violations, status)
VALUES (s.run_id, s.batch_id, s.checked_at, s.phase, s.rule_id, s.object_name, s.expected_value, s.actual_value, s.violations, s.status);

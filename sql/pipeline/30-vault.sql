MERGE INTO iceberg.vault.h_region AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['region', CAST(regionkey AS varchar)] AS JSON))))) AS hk, regionkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.region r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, regionkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.regionkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.h_nation AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation', CAST(nationkey AS varchar)] AS JSON))))) AS hk, nationkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.nation r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, nationkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.nationkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.h_supplier AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier', CAST(suppkey AS varchar)] AS JSON))))) AS hk, suppkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.supplier r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, suppkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.suppkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.h_customer AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['customer', CAST(custkey AS varchar)] AS JSON))))) AS hk, custkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.customer r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, custkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.custkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.h_part AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['part', CAST(partkey AS varchar)] AS JSON))))) AS hk, partkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.part r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, partkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.partkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.h_order AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['order', CAST(orderkey AS varchar)] AS JSON))))) AS hk, orderkey, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.orders r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, orderkey, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.orderkey, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_nation_region AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation_region', CAST(nationkey AS varchar), CAST(regionkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation', CAST(nationkey AS varchar)] AS JSON))))) AS hk_nation, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['region', CAST(regionkey AS varchar)] AS JSON))))) AS hk_region, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.nation r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_nation, hk_region, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_nation, s.hk_region, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_supplier_nation AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier_nation', CAST(suppkey AS varchar), CAST(nationkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier', CAST(suppkey AS varchar)] AS JSON))))) AS hk_supplier, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation', CAST(nationkey AS varchar)] AS JSON))))) AS hk_nation, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.supplier r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_supplier, hk_nation, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_supplier, s.hk_nation, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_customer_nation AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['customer_nation', CAST(custkey AS varchar), CAST(nationkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['customer', CAST(custkey AS varchar)] AS JSON))))) AS hk_customer, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation', CAST(nationkey AS varchar)] AS JSON))))) AS hk_nation, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.customer r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_customer, hk_nation, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_customer, s.hk_nation, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_order_customer AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['order_customer', CAST(orderkey AS varchar), CAST(custkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['order', CAST(orderkey AS varchar)] AS JSON))))) AS hk_order, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['customer', CAST(custkey AS varchar)] AS JSON))))) AS hk_customer, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.orders r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_order, hk_customer, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_order, s.hk_customer, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_partsupp AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['partsupp', CAST(partkey AS varchar), CAST(suppkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['part', CAST(partkey AS varchar)] AS JSON))))) AS hk_part, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier', CAST(suppkey AS varchar)] AS JSON))))) AS hk_supplier, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.partsupp r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_part, hk_supplier, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_part, s.hk_supplier, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.l_lineitem AS t
USING (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['lineitem', CAST(orderkey AS varchar), CAST(linenumber AS varchar), CAST(partkey AS varchar), CAST(suppkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['order', CAST(orderkey AS varchar)] AS JSON))))) AS hk_order, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['part', CAST(partkey AS varchar)] AS JSON))))) AS hk_part, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier', CAST(suppkey AS varchar)] AS JSON))))) AS hk_supplier, linenumber, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.lineitem r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
) AS s
ON t.hk = s.hk
WHEN NOT MATCHED THEN INSERT (hk, hk_order, hk_part, hk_supplier, linenumber, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hk_order, s.hk_part, s.hk_supplier, s.linenumber, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_region AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['region', CAST(regionkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_region', CAST(name AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, name, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.region r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_region
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, name, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.name, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_nation AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['nation', CAST(nationkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_nation', CAST(name AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, name, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.nation r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_nation
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, name, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.name, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_supplier AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['supplier', CAST(suppkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_supplier', CAST(name AS varchar), CAST(address AS varchar), CAST(phone AS varchar), CAST(acctbal AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, name, address, phone, acctbal, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.supplier r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_supplier
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, name, address, phone, acctbal, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.name, s.address, s.phone, s.acctbal, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_customer AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['customer', CAST(custkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_customer', CAST(name AS varchar), CAST(address AS varchar), CAST(phone AS varchar), CAST(acctbal AS varchar), CAST(mktsegment AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, name, address, phone, acctbal, mktsegment, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.customer r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_customer
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, name, address, phone, acctbal, mktsegment, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.name, s.address, s.phone, s.acctbal, s.mktsegment, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_part AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['part', CAST(partkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_part', CAST(name AS varchar), CAST(mfgr AS varchar), CAST(brand AS varchar), CAST(type AS varchar), CAST(size AS varchar), CAST(container AS varchar), CAST(retailprice AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, name, mfgr, brand, type, size, container, retailprice, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.part r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_part
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, name, mfgr, brand, type, size, container, retailprice, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.name, s.mfgr, s.brand, s.type, s.size, s.container, s.retailprice, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_partsupp AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['partsupp', CAST(partkey AS varchar), CAST(suppkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_partsupp', CAST(availqty AS varchar), CAST(supplycost AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, availqty, supplycost, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.partsupp r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_partsupp
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, availqty, supplycost, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.availqty, s.supplycost, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_order AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['order', CAST(orderkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_order', CAST(orderstatus AS varchar), CAST(totalprice AS varchar), CAST(orderdate AS varchar), CAST(orderpriority AS varchar), CAST(clerk AS varchar), CAST(shippriority AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.orders r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_order
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.orderstatus, s.totalprice, s.orderdate, s.orderpriority, s.clerk, s.shippriority, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.vault.s_lineitem AS t
USING (
    SELECT c.* FROM (
    SELECT DISTINCT to_hex(sha256(to_utf8(json_format(CAST(ARRAY['lineitem', CAST(orderkey AS varchar), CAST(linenumber AS varchar), CAST(partkey AS varchar), CAST(suppkey AS varchar)] AS JSON))))) AS hk, to_hex(sha256(to_utf8(json_format(CAST(ARRAY['s_lineitem', CAST(quantity AS varchar), CAST(extendedprice AS varchar), CAST(discount AS varchar), CAST(tax AS varchar), CAST(returnflag AS varchar), CAST(linestatus AS varchar), CAST(shipdate AS varchar), CAST(commitdate AS varchar), CAST(receiptdate AS varchar), CAST(shipinstruct AS varchar), CAST(shipmode AS varchar), CAST(comment AS varchar)] AS JSON))))) AS hashdiff, quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, r.batch_seq, b.loaded_at, 'TPC-H' AS record_source
    FROM iceberg.raw.lineitem r
    JOIN iceberg.ops.batches b ON b.batch_seq = r.batch_seq
    WHERE r.batch_seq = @batch_seq@
    ) c
    LEFT JOIN (
        SELECT hk, max_by(hashdiff,batch_seq) AS hashdiff FROM iceberg.vault.s_lineitem
        WHERE batch_seq < @batch_seq@ GROUP BY hk
    ) prev ON prev.hk = c.hk
    WHERE c.hashdiff IS DISTINCT FROM prev.hashdiff
) AS s
ON t.hk = s.hk AND t.batch_seq = s.batch_seq
WHEN NOT MATCHED THEN INSERT (hk, hashdiff, quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, batch_seq, loaded_at, record_source)
VALUES (s.hk, s.hashdiff, s.quantity, s.extendedprice, s.discount, s.tax, s.returnflag, s.linestatus, s.shipdate, s.commitdate, s.receiptdate, s.shipinstruct, s.shipmode, s.comment, s.batch_seq, s.loaded_at, s.record_source);

MERGE INTO iceberg.raw.region AS t
USING (
    SELECT regionkey, name, comment, batch_seq FROM iceberg.stage.region WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.regionkey = s.regionkey
WHEN NOT MATCHED THEN INSERT (regionkey, name, comment, batch_seq)
VALUES (s.regionkey, s.name, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.nation AS t
USING (
    SELECT nationkey, name, regionkey, comment, batch_seq FROM iceberg.stage.nation WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.nationkey = s.nationkey
WHEN NOT MATCHED THEN INSERT (nationkey, name, regionkey, comment, batch_seq)
VALUES (s.nationkey, s.name, s.regionkey, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.supplier AS t
USING (
    SELECT suppkey, name, address, nationkey, phone, acctbal, comment, batch_seq FROM iceberg.stage.supplier WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.suppkey = s.suppkey
WHEN NOT MATCHED THEN INSERT (suppkey, name, address, nationkey, phone, acctbal, comment, batch_seq)
VALUES (s.suppkey, s.name, s.address, s.nationkey, s.phone, s.acctbal, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.customer AS t
USING (
    SELECT custkey, name, address, nationkey, phone, acctbal, mktsegment, comment, batch_seq FROM iceberg.stage.customer WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.custkey = s.custkey
WHEN NOT MATCHED THEN INSERT (custkey, name, address, nationkey, phone, acctbal, mktsegment, comment, batch_seq)
VALUES (s.custkey, s.name, s.address, s.nationkey, s.phone, s.acctbal, s.mktsegment, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.part AS t
USING (
    SELECT partkey, name, mfgr, brand, type, size, container, retailprice, comment, batch_seq FROM iceberg.stage.part WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.partkey = s.partkey
WHEN NOT MATCHED THEN INSERT (partkey, name, mfgr, brand, type, size, container, retailprice, comment, batch_seq)
VALUES (s.partkey, s.name, s.mfgr, s.brand, s.type, s.size, s.container, s.retailprice, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.partsupp AS t
USING (
    SELECT partkey, suppkey, availqty, supplycost, comment, batch_seq FROM iceberg.stage.partsupp WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.partkey = s.partkey AND t.suppkey = s.suppkey
WHEN NOT MATCHED THEN INSERT (partkey, suppkey, availqty, supplycost, comment, batch_seq)
VALUES (s.partkey, s.suppkey, s.availqty, s.supplycost, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.orders AS t
USING (
    SELECT orderkey, custkey, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment, batch_seq FROM iceberg.stage.orders WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.orderkey = s.orderkey
WHEN NOT MATCHED THEN INSERT (orderkey, custkey, orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment, batch_seq)
VALUES (s.orderkey, s.custkey, s.orderstatus, s.totalprice, s.orderdate, s.orderpriority, s.clerk, s.shippriority, s.comment, s.batch_seq);

MERGE INTO iceberg.raw.lineitem AS t
USING (
    SELECT orderkey, partkey, suppkey, linenumber, quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, batch_seq FROM iceberg.stage.lineitem WHERE batch_seq = @batch_seq@
) AS s
ON t.batch_seq = s.batch_seq AND t.orderkey = s.orderkey AND t.linenumber = s.linenumber
WHEN NOT MATCHED THEN INSERT (orderkey, partkey, suppkey, linenumber, quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, batch_seq)
VALUES (s.orderkey, s.partkey, s.suppkey, s.linenumber, s.quantity, s.extendedprice, s.discount, s.tax, s.returnflag, s.linestatus, s.shipdate, s.commitdate, s.receiptdate, s.shipinstruct, s.shipmode, s.comment, s.batch_seq);

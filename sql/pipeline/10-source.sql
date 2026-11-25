CREATE OR REPLACE VIEW iceberg.stage.region AS
SELECT CAST(regionkey AS bigint) AS regionkey, CAST(name AS varchar(25)) AS name, CAST(comment AS varchar(152)) AS comment, 1 AS batch_seq FROM tpch.tiny.region;

CREATE OR REPLACE VIEW iceberg.stage.nation AS
SELECT CAST(nationkey AS bigint) AS nationkey, CAST(name AS varchar(25)) AS name, CAST(regionkey AS bigint) AS regionkey, CAST(comment AS varchar(152)) AS comment, 1 AS batch_seq FROM tpch.tiny.nation;

CREATE OR REPLACE VIEW iceberg.stage.supplier AS
SELECT CAST(suppkey AS bigint) AS suppkey, CAST(name AS varchar(25)) AS name, CAST(address AS varchar(40)) AS address, CAST(nationkey AS bigint) AS nationkey, CAST(phone AS varchar(15)) AS phone, CAST(acctbal AS decimal(15,2)) AS acctbal, CAST(comment AS varchar(101)) AS comment, 1 AS batch_seq FROM tpch.tiny.supplier;

CREATE OR REPLACE VIEW iceberg.stage.customer AS
SELECT CAST(custkey AS bigint) AS custkey, CAST(name AS varchar(25)) AS name, CAST(address AS varchar(40)) AS address, CAST(nationkey AS bigint) AS nationkey, CAST(phone AS varchar(15)) AS phone, CAST(acctbal AS decimal(15,2)) AS acctbal, CAST(mktsegment AS varchar(10)) AS mktsegment, CAST(comment AS varchar(117)) AS comment, 1 AS batch_seq FROM tpch.tiny.customer;

CREATE OR REPLACE VIEW iceberg.stage.part AS
SELECT CAST(partkey AS bigint) AS partkey, CAST(name AS varchar(55)) AS name, CAST(mfgr AS varchar(25)) AS mfgr, CAST(brand AS varchar(10)) AS brand, CAST(type AS varchar(25)) AS type, CAST(size AS integer) AS size, CAST(container AS varchar(10)) AS container, CAST(retailprice AS decimal(15,2)) AS retailprice, CAST(comment AS varchar(23)) AS comment, 1 AS batch_seq FROM tpch.tiny.part;

CREATE OR REPLACE VIEW iceberg.stage.partsupp AS
SELECT CAST(partkey AS bigint) AS partkey, CAST(suppkey AS bigint) AS suppkey, CAST(availqty AS integer) AS availqty, CAST(supplycost AS decimal(15,2)) AS supplycost, CAST(comment AS varchar(199)) AS comment, 1 AS batch_seq FROM tpch.tiny.partsupp;

CREATE OR REPLACE VIEW iceberg.stage.orders AS
SELECT CAST(orderkey AS bigint) AS orderkey, CAST(custkey AS bigint) AS custkey, CAST(orderstatus AS varchar(1)) AS orderstatus, CAST(totalprice AS decimal(15,2)) AS totalprice, CAST(orderdate AS date) AS orderdate, CAST(orderpriority AS varchar(15)) AS orderpriority, CAST(clerk AS varchar(15)) AS clerk, CAST(shippriority AS integer) AS shippriority, CAST(comment AS varchar(79)) AS comment, 1 AS batch_seq FROM tpch.tiny.orders;

CREATE OR REPLACE VIEW iceberg.stage.lineitem AS
WITH baseline AS (
    SELECT CAST(orderkey AS bigint) AS orderkey, CAST(partkey AS bigint) AS partkey, CAST(suppkey AS bigint) AS suppkey, CAST(linenumber AS integer) AS linenumber, CAST(quantity AS decimal(15,2)) AS quantity, CAST(extendedprice AS decimal(15,2)) AS extendedprice, CAST(discount AS decimal(4,2)) AS discount, CAST(tax AS decimal(4,2)) AS tax, CAST(returnflag AS varchar(1)) AS returnflag, CAST(linestatus AS varchar(1)) AS linestatus, CAST(shipdate AS date) AS shipdate, CAST(commitdate AS date) AS commitdate, CAST(receiptdate AS date) AS receiptdate, CAST(shipinstruct AS varchar(25)) AS shipinstruct, CAST(shipmode AS varchar(10)) AS shipmode, CAST(comment AS varchar(44)) AS comment, 1 AS batch_seq FROM tpch.tiny.lineitem
), changed AS (
    SELECT * FROM baseline WHERE shipdate IS NOT NULL AND extendedprice > 0 AND discount <= DECIMAL '0.99'
    ORDER BY orderkey, linenumber LIMIT 1
)
SELECT * FROM baseline
UNION ALL
SELECT orderkey, partkey, suppkey, linenumber, quantity, extendedprice, CAST(discount + DECIMAL '0.01' AS decimal(4,2)) AS discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, 2 FROM changed
UNION ALL
SELECT orderkey, partkey, suppkey, linenumber, quantity, extendedprice, CAST(1.25 AS decimal(4,2)) AS discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment, 3 FROM changed;

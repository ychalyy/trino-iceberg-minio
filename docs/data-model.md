# Словарь данных и маппинг

Приложение к ТРП. Все целевые схемы находятся в каталоге `iceberg`. Сверять определения следует с SQL в `sql/pipeline/`.

PK и FK задают логический контракт. Физический DDL допускает NULL, а DQ проверяет входные ключи, обязательность ссылок и скидки. Колонка «NULL» относится к логическому контракту. Типы ограниченного VARCHAR описаны в терминах Trino DDL. Iceberg хранит их как string и может возвращать VARCHAR без длины.

## TPC-H и Raw

Исходный `tpch.tiny` генерирует набор `SF 0.01` при SELECT. В Raw хранится версия строки источника по логическому ключу и номеру пакета.

### raw.region

Один регион в пакете. Ключ источника — `regionkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `regionkey` | `bigint` | Идентификатор региона | Нет | PK | `tpch.tiny.region.regionkey`. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `tpch.tiny.region.name`. |
| `comment` | `varchar(152)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.region.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.nation

Одна страна в пакете. Ключ источника — `nationkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `nationkey` | `bigint` | Идентификатор страны | Нет | PK | `tpch.tiny.nation.nationkey`. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `tpch.tiny.nation.name`. |
| `regionkey` | `bigint` | Идентификатор региона | Нет | FK → `region` (regionkey) | `tpch.tiny.nation.regionkey`. |
| `comment` | `varchar(152)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.nation.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.supplier

Один поставщик в пакете. Ключ источника — `suppkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `suppkey` | `bigint` | Идентификатор поставщика | Нет | PK | `tpch.tiny.supplier.suppkey`. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `tpch.tiny.supplier.name`. |
| `address` | `varchar(40)` | Адрес контрагента | Да | — | `tpch.tiny.supplier.address`. |
| `nationkey` | `bigint` | Идентификатор страны | Нет | FK → `nation` (nationkey) | `tpch.tiny.supplier.nationkey`. |
| `phone` | `varchar(15)` | Номер телефона | Да | — | `tpch.tiny.supplier.phone`. |
| `acctbal` | `decimal(15,2)` | Баланс счёта контрагента | Да | — | `tpch.tiny.supplier.acctbal` → `CAST AS decimal(15,2)`. |
| `comment` | `varchar(101)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.supplier.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.customer

Один клиент в пакете. Ключ источника — `custkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `custkey` | `bigint` | Идентификатор клиента | Нет | PK | `tpch.tiny.customer.custkey`. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `tpch.tiny.customer.name`. |
| `address` | `varchar(40)` | Адрес контрагента | Да | — | `tpch.tiny.customer.address`. |
| `nationkey` | `bigint` | Идентификатор страны | Нет | FK → `nation` (nationkey) | `tpch.tiny.customer.nationkey`. |
| `phone` | `varchar(15)` | Номер телефона | Да | — | `tpch.tiny.customer.phone`. |
| `acctbal` | `decimal(15,2)` | Баланс счёта контрагента | Да | — | `tpch.tiny.customer.acctbal` → `CAST AS decimal(15,2)`. |
| `mktsegment` | `varchar(10)` | Сегмент клиента | Да | — | `tpch.tiny.customer.mktsegment`. |
| `comment` | `varchar(117)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.customer.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.part

Один товар в пакете. Ключ источника — `partkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `partkey` | `bigint` | Идентификатор товара | Нет | PK | `tpch.tiny.part.partkey`. |
| `name` | `varchar(55)` | Наименование объекта | Да | — | `tpch.tiny.part.name`. |
| `mfgr` | `varchar(25)` | Производитель | Да | — | `tpch.tiny.part.mfgr`. |
| `brand` | `varchar(10)` | Марка товара | Да | — | `tpch.tiny.part.brand`. |
| `type` | `varchar(25)` | Классификация товара | Да | — | `tpch.tiny.part.type`. |
| `size` | `integer` | Размер товара | Да | — | `tpch.tiny.part.size`. |
| `container` | `varchar(10)` | Вид упаковки | Да | — | `tpch.tiny.part.container`. |
| `retailprice` | `decimal(15,2)` | Розничная цена товара | Да | — | `tpch.tiny.part.retailprice` → `CAST AS decimal(15,2)`. |
| `comment` | `varchar(23)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.part.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.partsupp

Одна пара товар–поставщик в пакете. Ключ источника — `partkey, suppkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `partkey` | `bigint` | Идентификатор товара | Нет | PK / FK → `part` (partkey) | `tpch.tiny.partsupp.partkey`. |
| `suppkey` | `bigint` | Идентификатор поставщика | Нет | PK / FK → `supplier` (suppkey) | `tpch.tiny.partsupp.suppkey`. |
| `availqty` | `integer` | Доступное количество у поставщика | Да | — | `tpch.tiny.partsupp.availqty`. |
| `supplycost` | `decimal(15,2)` | Цена поставки единицы | Да | — | `tpch.tiny.partsupp.supplycost` → `CAST AS decimal(15,2)`. |
| `comment` | `varchar(199)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.partsupp.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.orders

Один заказ в пакете. Ключ источника — `orderkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `orderkey` | `bigint` | Идентификатор заказа | Нет | PK | `tpch.tiny.orders.orderkey`. |
| `custkey` | `bigint` | Идентификатор клиента | Нет | FK → `customer` (custkey) | `tpch.tiny.orders.custkey`. |
| `orderstatus` | `varchar(1)` | Код статуса заказа | Да | — | `tpch.tiny.orders.orderstatus`. |
| `totalprice` | `decimal(15,2)` | Полная цена заказа из TPC-H | Да | — | `tpch.tiny.orders.totalprice` → `CAST AS decimal(15,2)`. |
| `orderdate` | `date` | Дата заказа | Да | — | `tpch.tiny.orders.orderdate`. |
| `orderpriority` | `varchar(15)` | Приоритет заказа | Да | — | `tpch.tiny.orders.orderpriority`. |
| `clerk` | `varchar(15)` | Код сотрудника | Да | — | `tpch.tiny.orders.clerk`. |
| `shippriority` | `integer` | Приоритет отгрузки | Да | — | `tpch.tiny.orders.shippriority`. |
| `comment` | `varchar(79)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.orders.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

### raw.lineitem

Одна позиция заказа в пакете. Ключ источника — `orderkey, linenumber`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `orderkey` | `bigint` | Идентификатор заказа | Нет | PK / FK → `orders` (orderkey) | `tpch.tiny.lineitem.orderkey`. |
| `partkey` | `bigint` | Идентификатор товара | Нет | FK → `partsupp` (partkey, suppkey) | `tpch.tiny.lineitem.partkey`. |
| `suppkey` | `bigint` | Идентификатор поставщика | Нет | FK → `partsupp` (partkey, suppkey) | `tpch.tiny.lineitem.suppkey`. |
| `linenumber` | `integer` | Номер позиции внутри заказа | Нет | PK | `tpch.tiny.lineitem.linenumber`. |
| `quantity` | `decimal(15,2)` | Количество единиц в позиции | Да | — | `tpch.tiny.lineitem.quantity` → `CAST AS decimal(15,2)`. |
| `extendedprice` | `decimal(15,2)` | Стоимость позиции до скидки и налога | Да | — | `tpch.tiny.lineitem.extendedprice` → `CAST AS decimal(15,2)`. |
| `discount` | `decimal(4,2)` | Ставка скидки как доля единицы | Нет | — | `tpch.tiny.lineitem.discount` → `CAST AS decimal(4,2)`. В delta увеличить на `0.01` для выбранной строки. |
| `tax` | `decimal(4,2)` | Ставка налога как доля единицы | Да | — | `tpch.tiny.lineitem.tax` → `CAST AS decimal(4,2)`. |
| `returnflag` | `varchar(1)` | Признак возврата позиции | Да | — | `tpch.tiny.lineitem.returnflag`. |
| `linestatus` | `varchar(1)` | Код состояния позиции | Да | — | `tpch.tiny.lineitem.linestatus`. |
| `shipdate` | `date` | Дата фактической отгрузки | Да | — | `tpch.tiny.lineitem.shipdate`. |
| `commitdate` | `date` | Дата обязательства по отгрузке | Да | — | `tpch.tiny.lineitem.commitdate`. |
| `receiptdate` | `date` | Дата получения | Да | — | `tpch.tiny.lineitem.receiptdate`. |
| `shipinstruct` | `varchar(25)` | Инструкция для отгрузки | Да | — | `tpch.tiny.lineitem.shipinstruct`. |
| `shipmode` | `varchar(10)` | Способ доставки | Да | — | `tpch.tiny.lineitem.shipmode`. |
| `comment` | `varchar(44)` | Текстовое примечание TPC-H | Да | — | `tpch.tiny.lineitem.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |

## Data Vault 2.0

### vault.h_region

Один бизнес-ключ из `raw.region`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `region` и `raw.region.regionkey`. |
| `regionkey` | `bigint` | Идентификатор региона | Нет | BK | `raw.region.regionkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.h_nation

Один бизнес-ключ из `raw.nation`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `nation` и `raw.nation.nationkey`. |
| `nationkey` | `bigint` | Идентификатор страны | Нет | BK | `raw.nation.nationkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.h_supplier

Один бизнес-ключ из `raw.supplier`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `supplier` и `raw.supplier.suppkey`. |
| `suppkey` | `bigint` | Идентификатор поставщика | Нет | BK | `raw.supplier.suppkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.h_customer

Один бизнес-ключ из `raw.customer`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `customer` и `raw.customer.custkey`. |
| `custkey` | `bigint` | Идентификатор клиента | Нет | BK | `raw.customer.custkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.h_part

Один бизнес-ключ из `raw.part`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `part` и `raw.part.partkey`. |
| `partkey` | `bigint` | Идентификатор товара | Нет | BK | `raw.part.partkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.h_order

Один бизнес-ключ из `raw.orders`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `order` и `raw.orders.orderkey`. |
| `orderkey` | `bigint` | Идентификатор заказа | Нет | BK | `raw.orders.orderkey`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_nation_region

Одна комбинация ключей `nationkey, regionkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `nation_region` и полей Raw `nationkey, regionkey`. |
| `hk_nation` | `varchar` | Хеш-ключ связанного хаба nation | Нет | FK → `vault.h_nation` | Хеш бизнес-ключа роли `nation` из `raw.nation`. |
| `hk_region` | `varchar` | Хеш-ключ связанного хаба region | Нет | FK → `vault.h_region` | Хеш бизнес-ключа роли `region` из `raw.nation`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_supplier_nation

Одна комбинация ключей `suppkey, nationkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `supplier_nation` и полей Raw `suppkey, nationkey`. |
| `hk_supplier` | `varchar` | Хеш-ключ связанного хаба supplier | Нет | FK → `vault.h_supplier` | Хеш бизнес-ключа роли `supplier` из `raw.supplier`. |
| `hk_nation` | `varchar` | Хеш-ключ связанного хаба nation | Нет | FK → `vault.h_nation` | Хеш бизнес-ключа роли `nation` из `raw.supplier`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_customer_nation

Одна комбинация ключей `custkey, nationkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `customer_nation` и полей Raw `custkey, nationkey`. |
| `hk_customer` | `varchar` | Хеш-ключ связанного хаба customer | Нет | FK → `vault.h_customer` | Хеш бизнес-ключа роли `customer` из `raw.customer`. |
| `hk_nation` | `varchar` | Хеш-ключ связанного хаба nation | Нет | FK → `vault.h_nation` | Хеш бизнес-ключа роли `nation` из `raw.customer`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_order_customer

Одна комбинация ключей `orderkey, custkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `order_customer` и полей Raw `orderkey, custkey`. |
| `hk_order` | `varchar` | Хеш-ключ связанного хаба order | Нет | FK → `vault.h_order` | Хеш бизнес-ключа роли `order` из `raw.orders`. |
| `hk_customer` | `varchar` | Хеш-ключ связанного хаба customer | Нет | FK → `vault.h_customer` | Хеш бизнес-ключа роли `customer` из `raw.orders`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_partsupp

Одна комбинация ключей `partkey, suppkey`.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `partsupp` и полей Raw `partkey, suppkey`. |
| `hk_part` | `varchar` | Хеш-ключ связанного хаба part | Нет | FK → `vault.h_part` | Хеш бизнес-ключа роли `part` из `raw.partsupp`. |
| `hk_supplier` | `varchar` | Хеш-ключ связанного хаба supplier | Нет | FK → `vault.h_supplier` | Хеш бизнес-ключа роли `supplier` из `raw.partsupp`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.l_lineitem

Одна позиция заказа с выбранной парой товар–поставщик.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK | SHA-256 пространства `lineitem` и полей Raw `orderkey, linenumber, partkey, suppkey`. |
| `hk_order` | `varchar` | Хеш-ключ связанного хаба order | Нет | FK → `vault.h_order` | Хеш бизнес-ключа роли `order` из `raw.lineitem`. |
| `hk_part` | `varchar` | Хеш-ключ связанного хаба part | Нет | FK → `vault.h_part` | Хеш бизнес-ключа роли `part` из `raw.lineitem`. |
| `hk_supplier` | `varchar` | Хеш-ключ связанного хаба supplier | Нет | FK → `vault.h_supplier` | Хеш бизнес-ключа роли `supplier` из `raw.lineitem`. |
| `linenumber` | `integer` | Номер позиции внутри заказа | Нет | DK | `raw.lineitem.linenumber`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_region

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_region` | Хеш родительского `vault.h_region.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: name, comment. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `raw.region.name`. |
| `comment` | `varchar(152)` | Текстовое примечание TPC-H | Да | — | `raw.region.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_nation

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_nation` | Хеш родительского `vault.h_nation.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: name, comment. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `raw.nation.name`. |
| `comment` | `varchar(152)` | Текстовое примечание TPC-H | Да | — | `raw.nation.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_supplier

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_supplier` | Хеш родительского `vault.h_supplier.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: name, address, phone, acctbal, comment. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `raw.supplier.name`. |
| `address` | `varchar(40)` | Адрес контрагента | Да | — | `raw.supplier.address`. |
| `phone` | `varchar(15)` | Номер телефона | Да | — | `raw.supplier.phone`. |
| `acctbal` | `decimal(15,2)` | Баланс счёта контрагента | Да | — | `raw.supplier.acctbal`. |
| `comment` | `varchar(101)` | Текстовое примечание TPC-H | Да | — | `raw.supplier.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_customer

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_customer` | Хеш родительского `vault.h_customer.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: name, address, phone, acctbal, mktsegment, comment. |
| `name` | `varchar(25)` | Наименование объекта | Да | — | `raw.customer.name`. |
| `address` | `varchar(40)` | Адрес контрагента | Да | — | `raw.customer.address`. |
| `phone` | `varchar(15)` | Номер телефона | Да | — | `raw.customer.phone`. |
| `acctbal` | `decimal(15,2)` | Баланс счёта контрагента | Да | — | `raw.customer.acctbal`. |
| `mktsegment` | `varchar(10)` | Сегмент клиента | Да | — | `raw.customer.mktsegment`. |
| `comment` | `varchar(117)` | Текстовое примечание TPC-H | Да | — | `raw.customer.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_part

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_part` | Хеш родительского `vault.h_part.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: name, mfgr, brand, type, size, container, retailprice, comment. |
| `name` | `varchar(55)` | Наименование объекта | Да | — | `raw.part.name`. |
| `mfgr` | `varchar(25)` | Производитель | Да | — | `raw.part.mfgr`. |
| `brand` | `varchar(10)` | Марка товара | Да | — | `raw.part.brand`. |
| `type` | `varchar(25)` | Классификация товара | Да | — | `raw.part.type`. |
| `size` | `integer` | Размер товара | Да | — | `raw.part.size`. |
| `container` | `varchar(10)` | Вид упаковки | Да | — | `raw.part.container`. |
| `retailprice` | `decimal(15,2)` | Розничная цена товара | Да | — | `raw.part.retailprice`. |
| `comment` | `varchar(23)` | Текстовое примечание TPC-H | Да | — | `raw.part.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_partsupp

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.l_partsupp` | Хеш родительского `vault.l_partsupp.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: availqty, supplycost, comment. |
| `availqty` | `integer` | Доступное количество у поставщика | Да | — | `raw.partsupp.availqty`. |
| `supplycost` | `decimal(15,2)` | Цена поставки единицы | Да | — | `raw.partsupp.supplycost`. |
| `comment` | `varchar(199)` | Текстовое примечание TPC-H | Да | — | `raw.partsupp.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_order

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.h_order` | Хеш родительского `vault.h_order.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: orderstatus, totalprice, orderdate, orderpriority, clerk, shippriority, comment. |
| `orderstatus` | `varchar(1)` | Код статуса заказа | Да | — | `raw.orders.orderstatus`. |
| `totalprice` | `decimal(15,2)` | Полная цена заказа из TPC-H | Да | — | `raw.orders.totalprice`. |
| `orderdate` | `date` | Дата заказа | Да | — | `raw.orders.orderdate`. |
| `orderpriority` | `varchar(15)` | Приоритет заказа | Да | — | `raw.orders.orderpriority`. |
| `clerk` | `varchar(15)` | Код сотрудника | Да | — | `raw.orders.clerk`. |
| `shippriority` | `integer` | Приоритет отгрузки | Да | — | `raw.orders.shippriority`. |
| `comment` | `varchar(79)` | Текстовое примечание TPC-H | Да | — | `raw.orders.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

### vault.s_lineitem

Одна изменившаяся версия атрибутов родителя в пакете.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `hk` | `varchar` | Хеш-ключ объекта или родительской записи | Нет | PK / FK → `vault.l_lineitem` | Хеш родительского `vault.l_lineitem.hk` из бизнес-ключей Raw. |
| `hashdiff` | `varchar` | Хеш бизнес-атрибутов сателлита | Нет | — | SHA-256 упорядоченных атрибутов: quantity, extendedprice, discount, tax, returnflag, linestatus, shipdate, commitdate, receiptdate, shipinstruct, shipmode, comment. |
| `quantity` | `decimal(15,2)` | Количество единиц в позиции | Да | — | `raw.lineitem.quantity`. |
| `extendedprice` | `decimal(15,2)` | Стоимость позиции до скидки и налога | Да | — | `raw.lineitem.extendedprice`. |
| `discount` | `decimal(4,2)` | Ставка скидки как доля единицы | Нет | — | `raw.lineitem.discount`. |
| `tax` | `decimal(4,2)` | Ставка налога как доля единицы | Да | — | `raw.lineitem.tax`. |
| `returnflag` | `varchar(1)` | Признак возврата позиции | Да | — | `raw.lineitem.returnflag`. |
| `linestatus` | `varchar(1)` | Код состояния позиции | Да | — | `raw.lineitem.linestatus`. |
| `shipdate` | `date` | Дата фактической отгрузки | Да | — | `raw.lineitem.shipdate`. |
| `commitdate` | `date` | Дата обязательства по отгрузке | Да | — | `raw.lineitem.commitdate`. |
| `receiptdate` | `date` | Дата получения | Да | — | `raw.lineitem.receiptdate`. |
| `shipinstruct` | `varchar(25)` | Инструкция для отгрузки | Да | — | `raw.lineitem.shipinstruct`. |
| `shipmode` | `varchar(10)` | Способ доставки | Да | — | `raw.lineitem.shipmode`. |
| `comment` | `varchar(44)` | Текстовое примечание TPC-H | Да | — | `raw.lineitem.comment`. |
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер пакета первой записи или версии из Raw. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `ops.batches.loaded_at` по номеру пакета. |
| `record_source` | `varchar` | Исходный набор данных | Нет | — | Константа `TPC-H`. |

## Служебные таблицы

### ops.batches

Один зарегистрированный пакет.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK | 1 для initial, 2 для delta. |
| `batch_id` | `varchar` | Имя пакета | Нет | — | Имя пакета из интерфейса загрузки. |
| `loaded_at` | `timestamp(6) with time zone` | Время регистрации пакета | Нет | — | `current_timestamp(6)` при регистрации пакета. |
| `status` | `varchar` | Состояние пакета или результат правила | Нет | — | `PENDING` при регистрации, `COMPLETE` после проверок. |

### ops.dq_results

Один результат правила на объект в фазе и попытке.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `run_id` | `varchar` | Идентификатор попытки | Нет | PK | UUID или ручной идентификатор. |
| `batch_id` | `varchar` | Имя пакета | Нет | — | Имя пакета, включая диагностический `invalid`. |
| `checked_at` | `timestamp(6) with time zone` | Время вычисления проверки | Нет | — | `current_timestamp(6)` при записи группы проверок. |
| `phase` | `varchar` | Фаза проверки | Нет | PK | `input` перед Raw, `model` перед публикацией. |
| `rule_id` | `varchar` | Код правила | Нет | PK | Литерал из SQL DQ. |
| `object_name` | `varchar` | Проверяемый объект | Нет | PK | Литерал из SQL DQ. |
| `expected_value` | `bigint` | Ожидаемое числовое значение | Нет | — | Ноль нарушений или число строк по источнику. |
| `actual_value` | `bigint` | Фактическое числовое значение | Нет | — | Число строк, нарушений или несовпавших групп. |
| `violations` | `bigint` | Абсолютное отклонение от ожидаемого | Нет | — | `abs(actual_value - expected_value)`. |
| `status` | `varchar` | Состояние пакета или результат правила | Нет | — | `PASS` при равенстве, иначе `FAIL`. |

## Бизнес-витрины

### mart.sales_by_region

Один месяц заказа и регион клиента.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | — | Максимальный COMPLETE в `ops.batches`. |
| `order_month` | `date` | Первый день месяца заказа | Нет | Ключ группы | `date_trunc('month', s_order.orderdate)`. |
| `customer_region` | `varchar` | Регион страны клиента | Нет | Ключ группы | `s_region.name` по цепочке заказ → клиент → страна → регион. |
| `orders` | `bigint` | Число уникальных заказов с позициями | Нет | — | `count(DISTINCT l_lineitem.hk_order)`. |
| `line_count` | `bigint` | Число позиций заказа | Нет | — | `count(*)` на уровне позиции. |
| `gross_sales` | `decimal(38,2)` | Сумма стоимости до скидки и налога | Нет | — | `sum(s_lineitem.extendedprice)`. |
| `net_sales` | `decimal(38,4)` | Сумма стоимости после скидки без налога | Нет | — | `sum(CAST(extendedprice * (1.00 - discount) AS decimal(22,4)))`. |

### mart.shipping_by_mode

Один месяц отгрузки и способ доставки.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | — | Максимальный COMPLETE в `ops.batches`. |
| `ship_month` | `date` | Первый день месяца отгрузки | Нет | Ключ группы | `date_trunc('month', s_lineitem.shipdate)`, только отгруженные позиции. |
| `ship_mode` | `varchar` | Способ доставки | Нет | Ключ группы | `s_lineitem.shipmode`. |
| `shipped_lines` | `bigint` | Число отгруженных позиций | Нет | — | `count(*)` отгруженных позиций. |
| `late_lines` | `bigint` | Число позиций с отгрузкой после даты обязательства | Нет | — | `count_if(shipdate > commitdate)`. |
| `late_share` | `double` | Доля отгруженных позиций с задержкой | Нет | — | `CAST(late_lines AS double) / shipped_lines`. |


### mart.sales_snapshot

Один агрегат на пакет, месяц заказа и регион клиента.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер обрабатываемого пакета. |
| `order_month` | `date` | Первый день месяца заказа | Нет | PK | `date_trunc('month', s_order.orderdate)`. |
| `customer_region` | `varchar` | Регион страны клиента | Нет | PK | `s_region.name` по цепочке заказ → клиент → страна → регион. |
| `orders` | `bigint` | Число уникальных заказов с позициями | Нет | — | `count(DISTINCT l_lineitem.hk_order)`. |
| `line_count` | `bigint` | Число позиций заказа | Нет | — | `count(*)` на уровне позиции. |
| `gross_sales` | `decimal(38,2)` | Сумма стоимости до скидки и налога | Нет | — | `sum(s_lineitem.extendedprice)`. |
| `net_sales` | `decimal(38,4)` | Сумма стоимости после скидки без налога | Нет | — | `sum(CAST(extendedprice * (1.00 - discount) AS decimal(22,4)))`. |


### mart.shipping_snapshot

Один агрегат на пакет, месяц отгрузки и способ доставки.

| Поле | Тип Trino | Назначение | NULL | Ключ | Источник или правило |
|---|---|---|---|---|---|
| `batch_seq` | `integer` | Порядковый номер пакета | Нет | PK / FK → `ops.batches` | Номер обрабатываемого пакета. |
| `ship_month` | `date` | Первый день месяца отгрузки | Нет | PK | `date_trunc('month', s_lineitem.shipdate)`, только отгруженные позиции. |
| `ship_mode` | `varchar` | Способ доставки | Нет | PK | `s_lineitem.shipmode`. |
| `shipped_lines` | `bigint` | Число отгруженных позиций | Нет | — | `count(*)` отгруженных позиций. |
| `late_lines` | `bigint` | Число позиций с отгрузкой после даты обязательства | Нет | — | `count_if(shipdate > commitdate)`. |
| `late_share` | `double` | Доля отгруженных позиций с задержкой | Нет | — | `CAST(late_lines AS double) / shipped_lines`. |

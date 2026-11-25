# Ручная проверка тестового задания

Проверяющий проходит семь пунктов по порядку. Команды выполняйте в **терминале на хосте из корня клона**. Запросы идут через **Trino CLI внутри контейнера**. Для просмотра S3 используйте **консоль MinIO**, для работы с дашбордом — **веб-интерфейс Superset**. Сценарии и критерии — в [ПМИ](acceptance.md). Настройка секретов, сборка и запуск — в [руководстве](deployment.md).

Откройте новый терминал. Чтобы оставить рабочие данные и тома в отдельном проекте, задайте имя и порты для ручной проверки. Если любой из этих портов уже занят, выберите свободный и используйте его далее в адресах.

```bash
export COMPOSE_PROJECT_NAME=lakehouse-manual
export TRINO_PORT=38080 REST_PORT=38181 MINIO_API_PORT=39000 MINIO_CONSOLE_PORT=39001
export SUPERSET_PORT=38088
docker compose up -d --wait --wait-timeout 180
```

## 1. Приёмка стенда

```bash
docker compose ps
bash scripts/stand-smoke.sh prepare
bash scripts/stand-smoke.sh prepare
```

В первом запуске ожидаются `MERGE: 2 rows`, строки `1 trino` и `2 minio` во втором — `MERGE: 0 rows` и те же строки. В браузере откройте [консоль MinIO](http://127.0.0.1:39001/), войдите с `MINIO_ROOT_USER` и `MINIO_ROOT_PASSWORD` из локального `.env`. В разделе **Buckets** выберите `warehouse`. В префиксе `stand_check/probe-…` проверьте `data/*.parquet` и `metadata/*.metadata.json`. Безопаснее сверять имена по выводу smoke-сценария, так как UUID объектов меняются.

```bash
docker compose down
docker compose up -d --wait --wait-timeout 180
bash scripts/stand-smoke.sh verify
```

Ожидаются те же строки и имена объектов. Trino UI по адресу [localhost:38080](http://127.0.0.1:38080/ui/) показывает состояние кластера и запросов. Для просмотра UI можно указать `analyst`, пароль пустой. SQL ниже выполняйте в CLI, доступном через `docker compose exec`.

## 2–4. Источник, модель и витрины

```bash
docker compose exec -T trino trino --execute 'SHOW TABLES FROM tpch.tiny'
python3 scripts/lakehouse.py bootstrap
python3 scripts/lakehouse.py register --batch initial
python3 scripts/lakehouse.py input --batch initial --run-id manual-initial
python3 scripts/lakehouse.py raw --batch initial --run-id manual-initial
python3 scripts/lakehouse.py vault --batch initial --run-id manual-initial
python3 scripts/lakehouse.py materialize --batch initial --run-id manual-initial
python3 scripts/lakehouse.py model --batch initial --run-id manual-initial
python3 scripts/lakehouse.py publish --batch initial --run-id manual-initial
```

`bootstrap` применяет `00-schema.sql`, `10-source.sql`, `40-marts.sql` и `46-public-marts.sql`. Команды `input`, `raw`, `vault`, `materialize` и `model` запускают соответствующие SQL-файлы из [sql/pipeline](../sql/pipeline), подставляя номер пакета и идентификатор попытки. Для независимой проверки числа строк и истории используйте диагностический SQL напрямую:

```bash
docker compose exec -T trino trino --output-format TSV --file /dev/stdin < sql/pipeline/90-evidence.sql
docker compose exec -T trino trino --execute 'SHOW TABLES FROM iceberg.vault'
docker compose exec -T trino trino --execute 'SHOW COLUMNS FROM iceberg.vault.s_lineitem'
docker compose exec -T trino trino --execute "SELECT rule_id, object_name, expected_value, actual_value, status
FROM iceberg.ops.dq_results WHERE run_id='manual-initial' AND rule_id IN ('RAW_COUNT','MART_RECONCILE')"
```

Ожидаются восемь наборов Raw, шесть Hubs, шесть Links и восемь Satellites. Для `MART_RECONCILE` обе строки показывают `0 → 0, PASS`. Сопоставьте физические колонки с [описанием модели](data-model.md). Для просмотра строк витрин используйте `SELECT * FROM iceberg.mart.sales_by_region` и `SELECT * FROM iceberg.mart.shipping_by_mode`.

## 5. Повторы, сбой и публикация

```bash
make load BATCH=initial
docker compose exec -T trino trino --output-format TSV --execute 'SELECT * FROM iceberg.mart.sales_by_region ORDER BY 2,3' > /tmp/lakehouse-manual-sales-before.tsv
python3 scripts/lakehouse.py load --batch delta --stop-after-raw
docker compose exec -T trino trino --output-format TSV --execute 'SELECT * FROM iceberg.mart.sales_by_region ORDER BY 2,3' > /tmp/lakehouse-manual-sales-pending.tsv
cmp /tmp/lakehouse-manual-sales-before.tsv /tmp/lakehouse-manual-sales-pending.tsv
```

Остановка после Raw возвращает код 1. Выполняйте блок в обычном интерактивном терминале и продолжите со следующей строки после ожидаемой остановки. Во время остановки опубликованный пакет — `initial`, `cmp` возвращает код 0.

```bash
make load BATCH=delta
make load BATCH=delta
docker compose exec -T trino trino --output-format TSV --file /dev/stdin < sql/pipeline/90-evidence.sql
```

У изменённой позиции две версии со скидками 0.04 и 0.05. Разница продажи соответствует `−247.1035`. Для сравнения отгрузок на двух опубликованных версиях выполните:

```bash
docker compose exec -T trino trino --execute "
SELECT count(*) AS changed_groups
FROM (
  SELECT ship_month, ship_mode, shipped_lines, late_lines, late_share
  FROM iceberg.mart.shipping_snapshot WHERE batch_seq=1
  EXCEPT
  SELECT ship_month, ship_mode, shipped_lines, late_lines, late_share
  FROM iceberg.mart.shipping_snapshot WHERE batch_seq=2
)"
```

Ожидается `0`. После каждого успешного повтора журнал DQ содержит новую попытку, а Raw и Satellites сохраняют прежнее число строк.

## 6. Отклонение DQ

```bash
make dq
python3 scripts/lakehouse.py input --batch invalid --run-id manual-invalid
echo "$?"
docker compose exec -T trino trino --execute "SELECT batch_id, rule_id, object_name, expected_value, actual_value, status
FROM iceberg.ops.dq_results WHERE run_id='manual-invalid' AND status='FAIL'"
docker compose exec -T trino trino --execute 'SELECT DISTINCT batch_seq FROM iceberg.mart.sales_by_region'
```

Вторая команда возвращает `1`. В результате сохранено `invalid / DISCOUNT_RANGE / lineitem / 0 / 1 / FAIL`. Витрина по-прежнему показывает `batch_seq=2`. У пакета `invalid` нет опубликованной версии.

## 7. Импорт Superset и проверка двух вкладок

1. Выполните команды запуска профиля `bi` из [руководства](deployment.md#superset). Откройте [localhost:38088](http://127.0.0.1:38088/) и войдите как `superset_admin` с `SUPERSET_ADMIN_PASSWORD`. При старте этот пользователь создаётся из локальных параметров.
2. В **Dashboards → Import** выберите файл [lakehouse-dashboard.zip](../superset/lakehouse-dashboard.zip). В экспорт входит подключение `Lakehouse Trino` через `trino://analyst@trino:8080/iceberg`. Если источника нет в списке, проверьте наличие подключения в **Settings → Database Connections**.
3. Откройте **Качество данных**. Выберите статус `FAIL` и правило `DISCOUNT_RANGE`, примените фильтры. Строка отклонённого запуска показывает `lineitem`, ожидание 0 и факт 1. Выберите другой запуск и `PASS`, убедитесь, что выбранная попытка меняет детали и сводку. Для SQL-подтверждения используйте запрос пункта 6.
4. Откройте **Бизнес-аналитика**. Сбросьте бизнес-фильтры и проверьте исторический период. Выберите регион из таблицы. Для проверки периода откройте «Период», выберите **Range type → Advanced**, задайте начало `1996-01-01` и конец `1996-02-01`, нажмите **APPLY**, затем **Apply filters**. Обе таблицы показывают только январь 1996 года. Выберите способ доставки и проверьте соответствующую таблицу и долю на графике. Фильтры DQ не меняют бизнес-показатели.
5. Для сверки запросите значения выбранного месяца и региона из `iceberg.mart.sales_by_region`. Сверьте долю способа доставки SQL-запросом ниже. Если фильтр периода включён, примените те же границы к `ship_month`.

```sql
SELECT ship_mode, CAST(sum(late_lines) AS double) / sum(shipped_lines) AS late_share
FROM iceberg.mart.shipping_by_mode
GROUP BY ship_mode
ORDER BY ship_mode;
```

Чтобы выполнить запрос из файла, используйте `docker compose exec -T trino trino --file /dev/stdin < имя_файла.sql`. Сохраните вывод проверок и выбранные значения в протоколе.

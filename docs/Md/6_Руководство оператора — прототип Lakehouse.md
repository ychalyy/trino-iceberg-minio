# РУКОВОДСТВО ОПЕРАТОРА

**Развёртывание и ручная проверка прототипа Lakehouse**

РО-ХД-LAKEHOUSE-01

Редакция 1.0 для рассмотрения

25 ноября 2026 г.

## 1 Назначение и условия применения

Руководство описывает запуск стенда, выполнение загрузки, проверку семи пунктов задания, диагностику и остановку. Выполняйте команды в терминале Mac из корня рабочей копии, содержащей docker-compose.yml, Makefile, scripts/lakehouse.py, sql/pipeline и экспорт Superset.

Испытанное окружение — Apple M1 Pro, Linux ARM64 в Docker Desktop 4.100.1, Engine 29.9.3, Compose v5.7.1. Нужны Docker с Compose, Git, Bash, Make и Python 3.9+. Начальный ориентир — 2 ядра, 6 ГиБ памяти Docker и 15 ГиБ свободного диска. Зафиксированный полный прогон использовал около 8 ГиБ, выделенных Docker. Для первого запуска требуется доступ к исходникам и реестрам образов.

Сквозную приёмку проводите в отдельном Compose-проекте с отдельными портами и чистыми томами. Рабочий проект подходит для просмотра уже опубликованных данных. Идентификаторы требований и ожидаемые результаты приведены в ПМИ-ХД-LAKEHOUSE-01.

## 2 Состав стенда

Таблица 1 — Точки доступа на Mac

| Сервис | Адрес по умолчанию | Вход и назначение |
| --- | --- | --- |
| Trino 484 | 127.0.0.1:8080 | UI: имя analyst, пароль пустой в локальной конфигурации. SQL: Trino CLI в контейнере или SQL Lab Superset. |
| Iceberg REST Fixture 1.10.1 | 127.0.0.1:8181 | REST API. Указатели на метаданные таблиц в SQLite на rest_data. |
| MinIO | 127.0.0.1:9000 и 9001 | S3 и консоль. Вход по MINIO_ROOT_USER и MINIO_ROOT_PASSWORD. Бакет warehouse, том minio_data. |
| mc | Внутренний сервис | Создаёт приватный бакет и проверяет готовность. |
| Superset 6.1.0 | 127.0.0.1:8088 | Профиль bi. Вход superset_admin с SUPERSET_ADMIN_PASSWORD. Метаданные в superset_data. |

Внутри Compose используются trino:8080, rest:8181, minio:9000 и superset:8088. На хосте значения портов задаются в окружении. Скрипт загрузки использует docker compose exec и не зависит от опубликованного порта Trino.

Редактируемая схема [«Физический стенд Lakehouse»](../diagrams/physical-stand.drawio) показывает порты, сеть, сервисы и тома. Схема [«Слои хранилища Lakehouse»](../diagrams/warehouse-layers.drawio) помогает найти нужную схему в Trino.

## 3 Развёртывание стенда

Откройте Docker Desktop и дождитесь доступности Engine. Перейдите в корень реализации. Для новой машины используйте переданную рабочую копию или ревизию репозитория со всеми файлами реализации. Базовая ревизия исходного стенда содержит только инфраструктуру.

```bash
docker version
docker compose version
python3 --version
make --version
```

Если CLI обращается к отсутствующему сокету при работающем Desktop, проверьте docker --context desktop-linux version. При успешном ответе задайте export DOCKER_CONTEXT=desktop-linux в этой сессии.

Для новой установки выполните блок ниже. Он создаёт .env из .env.example при отсутствии файла, дополняет пустые локальные секреты и сохраняет существующие значения. Не публикуйте .env.

```bash
(umask 077
python3 - <<'ENV_SETUP'
from pathlib import Path
from secrets import token_hex

path = Path(".env")
text = path.read_text() if path.exists() else Path(".env.example").read_text()
lines = text.splitlines()
for name in ("MINIO_ROOT_PASSWORD", "SUPERSET_SECRET_KEY",
             "SUPERSET_ADMIN_PASSWORD"):
    index = next((i for i, line in enumerate(lines)
                  if line.startswith(name + "=")), None)
    if index is None:
        lines.append(name + "=" + token_hex(24))
    elif not lines[index].split("=", 1)[1]:
        lines[index] = name + "=" + token_hex(24)
path.write_text("\n".join(lines) + "\n")
path.chmod(0o600)
ENV_SETUP
)
```

Для ручной приёмки оставьте эти переменные в одной сессии терминала. При конфликте выберите свободный порт и используйте его далее в браузере. Для второго чистого прогона задайте другое имя проекта и свободные порты.

```bash
export COMPOSE_PROJECT_NAME=lakehouse-manual
export TRINO_PORT=38080 REST_PORT=38181
export MINIO_API_PORT=39000 MINIO_CONSOLE_PORT=39001
export SUPERSET_PORT=38088

docker compose config --quiet
docker compose build minio mc
make up
docker compose ps
```

Ожидаются четыре базовых сервиса. mc создаёт приватный бакет, затем Trino становится healthy. Команда config --quiet проверяет итоговую конфигурацию без печати параметров.

## 4 Загрузка данных и запуск слоёв

Для автоматической загрузки из корня проекта выполните make load BATCH=initial, затем make load BATCH=delta. До первой delta убедитесь, что initial имеет статус COMPLETE. Make demo включает чистый проход, остановку, повторы и диагностический пакет. Запускайте его в отдельном проекте до регистрации delta. При таком прогоне загрузка и проверки проходят автоматически.

Для пошаговой приёмки в отдельном чистом проекте запускайте строки по одной. Один run_id связывает входной и модельный контроль с записью и публикацией. Для повторной попытки с проверками задайте новый run_id.

```bash
make bootstrap
python3 scripts/lakehouse.py register --batch initial
python3 scripts/lakehouse.py input --batch initial --run-id manual-initial
python3 scripts/lakehouse.py raw --batch initial --run-id manual-initial
python3 scripts/lakehouse.py vault --batch initial --run-id manual-initial
python3 scripts/lakehouse.py materialize --batch initial --run-id manual-initial
python3 scripts/lakehouse.py model --batch initial --run-id manual-initial
python3 scripts/lakehouse.py publish --batch initial --run-id manual-initial
```

Фазы используют 50-input-dq.sql, 20-raw.sql, 30-vault.sql, 45-mart-snapshots.sql и 60-model-dq.sql. Оболочка подставляет параметры пакета и попытки. Самостоятельные SQL-запросы и 90-evidence.sql можно запускать напрямую.

```bash
docker compose exec -T trino trino --output-format TSV \
  --file /dev/stdin < sql/pipeline/90-evidence.sql
docker compose exec trino trino
```

Вторая команда открывает интерактивный Trino CLI. Запросы завершаются точкой с запятой. Для выхода введите quit. Для просмотра источника выполните SHOW TABLES FROM tpch.tiny и SELECT \* FROM tpch.tiny.lineitem LIMIT 10. В SQL Lab выберите подключение Lakehouse Trino и используйте полные имена в запросах к Iceberg. Для исходного tpch.tiny в ручной приёмке используйте CLI.

Таблица 2 — Где смотреть данные

| Что смотреть | Полное имя или схема |
| --- | --- |
| Исходные данные | tpch.tiny |
| Подготовленные входы | iceberg.stage |
| Raw и Vault | iceberg.raw и iceberg.vault |
| Витрины | iceberg.mart.sales_by_region и iceberg.mart.shipping_by_mode |
| Статусы и проверки | iceberg.ops.batches и iceberg.ops.dq_results |

## 5 Проверка работоспособности

### 5.1 Docker-стенд и сохранность

В терминале с переменными §3 выполните проверку дважды. В первом выводе ожидается MERGE: 2 rows, во втором MERGE: 0 rows. Оба чтения показывают (1, trino) и (2, minio).

```bash
bash scripts/stand-smoke.sh prepare
bash scripts/stand-smoke.sh prepare
```

В браузере откройте http://127.0.0.1:39001 для проекта из §3. Войдите в MinIO, откройте Buckets → warehouse и префикс таблицы stand_check/probe-… из вывода smoke. Проверьте private, один или несколько Parquet-объектов и .metadata.json. Запишите имена объектов до пересоздания.

```bash
docker compose down
make up
bash scripts/stand-smoke.sh verify
```

При повторном чтении ожидаются те же записи и объекты. В Docker-проекте испытаний не удаляйте тома между prepare и verify. В Trino UI по адресу http://127.0.0.1:38080/ui/ проверьте готовность, а SQL выполняйте в CLI.

### 5.2 Источник, Vault и витрины

После initial из §4 откройте Trino CLI. Сверьте восемь объёмов из make evidence с TPC-H. В отчёте должны быть 5, 25, 100, 1 500, 2 000, 8 000, 15 000 и 60 175 по порядку таблицы 1 модели данных.

```sql
SHOW TABLES FROM tpch.tiny;
DESCRIBE tpch.tiny.lineitem;
DESCRIBE iceberg.raw.lineitem;
SHOW TABLES FROM iceberg.vault;
SHOW COLUMNS FROM iceberg.vault.s_lineitem;
SELECT * FROM iceberg.mart.sales_by_region LIMIT 5;
SELECT * FROM iceberg.mart.shipping_by_mode LIMIT 5;
```

В Vault ожидаются 6 Hubs, 6 Links и 8 Satellites. В Raw extendedprice имеет DECIMAL(15,2), скидка и налог — DECIMAL(4,2). В журнале initial проверьте KEY_NULL, KEY_DUPLICATE, INPUT_FK, RAW_COUNT, VAULT_FK, VAULT_KEY_DUPLICATE и обе строки MART_RECONCILE с нулём расхождений.

```sql
SELECT rule_id, object_name, expected_value, actual_value, status
FROM iceberg.ops.dq_results
WHERE run_id='manual-initial'
ORDER BY phase, rule_id, object_name;
```

### 5.3 Повтор, восстановление и эффект дельты

Начните после initial из §4, пока delta ещё не опубликована. В терминале определите функцию ниже. Она сохраняет бизнес-вывод в изолированный временный каталог для точного сравнения.

```bash
check_dir=$(mktemp -d)
capture() {
  for view in sales_by_region shipping_by_mode; do
    docker compose exec -T trino trino --output-format TSV \
      --execute "SELECT * FROM iceberg.mart.$view ORDER BY 2,3" \
      > "$check_dir/$1-$view.tsv" || return 1
  done
}
compare() {
  for view in sales_by_region shipping_by_mode; do
    cmp "$check_dir/$1-$view.tsv" "$check_dir/$2-$view.tsv" || return 1
  done
}
```

```bash
capture initial
make load BATCH=initial
capture initial-repeat
compare initial initial-repeat
python3 scripts/lakehouse.py load --batch delta --stop-after-raw
echo "$?"
capture pending
compare initial pending
make load BATCH=delta
capture delta
make load BATCH=delta
capture delta-repeat
compare delta delta-repeat
make evidence
```

При остановке код 1 ожидаем. Продолжайте команды вручную, а не в режиме set -e. До завершения delta сравнение с initial возвращает 0. После завершения обе витрины показывают batch_seq = 2. Повтор возвращает те же результаты. У позиции (1, 1) две версии со скидками 0,04 и 0,05. В ASIA за январь 1996 г. разница net_sales равна −247,1035.

Для сравнения самих отгрузок между пакетами 1 и 2 используйте SQL ниже. Исключение batch_seq позволяет сравнить бизнес-значения. Группы уникальны по месяцам и способам в каждом пакете. Ожидается 0 строк.

```sql
SELECT ship_month, ship_mode, shipped_lines, late_lines, late_share
FROM iceberg.mart.shipping_snapshot
WHERE batch_seq IN (1,2)
GROUP BY 1,2,3,4,5
HAVING count(DISTINCT batch_seq) <> 2;
```

### 5.4 Качество данных и отказ

```bash
make dq
python3 scripts/lakehouse.py input --batch invalid --run-id manual-invalid
echo "$?"
capture invalid
compare delta invalid
```

Make dq пишет новую попытку для последнего COMPLETE. Ожидаются 33 входных и 59 модельных PASS. Команда input на invalid возвращает код 1. Обе витрины сохраняют те же строки, compare возвращает 0.

```sql
SELECT batch_id, rule_id, object_name, expected_value, actual_value, status
FROM iceberg.ops.dq_results
WHERE run_id='manual-invalid' AND status='FAIL';
SELECT batch_id, batch_seq, status
FROM iceberg.ops.batches ORDER BY batch_seq;
```

Ожидается invalid / DISCOUNT_RANGE / lineitem / 0 / 1 / FAIL. В реестре пакетов после успешной delta видны только initial и delta со статусом COMPLETE.

### 5.5 Superset и две вкладки

```bash
docker compose --profile bi build superset
docker compose --profile bi up -d --wait --wait-timeout 180 superset
```

Откройте http://127.0.0.1:38088/ для проекта §3. Войдите как superset_admin с локальным паролем. На чистом экземпляре в Dashboards → Import выберите superset/lakehouse-dashboard.zip. Проверьте подключение Lakehouse Trino в Settings → Database Connections. URI внутри Compose — trino://analyst@trino:8080/iceberg.

В «Качество данных» выберите FAIL, DISCOUNT_RANGE и нужный запуск. Сверьте ожидаемое 0 и факт 1 со строкой SQL. Затем выберите успешную попытку и PASS. Изменение этих фильтров не меняет бизнес-данные.

В «Бизнес-аналитике» сбросьте фильтры. Для проверки января выберите «Период» → Advanced, задайте 1996-01-01 и 1996-02-01 и примените фильтры. До выбора региона или способа доставки ожидаются 5 групп продаж и 7 групп отгрузок. Затем выберите регион и способ доставки и сравните с фильтрованным SQL. Для SQL-сверки продаж укажите январь в order_month и тот же customer_region. Зафиксируйте обе вкладки снимками экрана.

```sql
SELECT ship_mode, CAST(sum(late_lines) AS double) / sum(shipped_lines)
FROM iceberg.mart.shipping_by_mode
WHERE ship_month >= DATE '1996-01-01' AND ship_month < DATE '1996-02-01'
GROUP BY ship_mode ORDER BY ship_mode;
```

Без WHERE запрос возвращает долю за весь период. Для REG AIR за весь период контрольное отношение равно 4 302 / 8 616. При изменении фильтров сверяйте бизнес-числа за те же даты.

## 6 Типовые проблемы и способы устранения

Таблица 3 — Диагностика стенда

| Симптом | Что проверить и что сделать |
| --- | --- |
| Docker CLI не видит Engine | Проверьте Docker Desktop и docker --context desktop-linux version. При доступном Engine задайте DOCKER_CONTEXT. |
| Конфликт порта на Mac | Проверьте, какой процесс слушает порт. Измените хостовый порт в окружении. Внутренние адреса Compose остаются прежними. |
| Trino остановился или код 137 | Проверьте docker compose ps, логи trino и OOMKilled. Сверьте доступную память Docker и TRINO_MEMORY_LIMIT. |
| Бакет или S3 недоступен | Посмотрите docker compose logs --tail=100 minio mc rest. Проверьте готовность mc, бакет и локальные параметры. |
| Ошибка каталога или SQLITE_BUSY | Посмотрите логи rest и trino. Дождитесь завершения другого запроса или запуска. Сверьте статус и повторите пакет штатной командой. |
| DQ вернул FAIL | Откройте ops.dq_results по run_id, фазе и правилу. После сбоя повторите тот же пакет. При изменении частично записанного входа или расчёта проверьте на чистом проекте. |
| Витрина пуста или запаздывает | Проверьте ops.batches, наличие снимков обеих витрин и подключение Superset к trino:8080. При PENDING виден предыдущий COMPLETE. |
| Superset не загружается | Проверьте профиль bi, docker compose --profile bi ps и логи superset. После запуска проверьте подключение, наличие витрин и фильтры. |

## 7 Завершение работы и очистка

Перед остановкой сохраните вывод make evidence, выбранные факты DQ и скриншоты. Для паузы и повторного запуска используйте команды в окружении того же Compose-проекта.

```bash
docker compose --profile bi stop
docker compose --profile bi up -d --wait --wait-timeout 180
```

Для пересоздания контейнеров удалите их командой docker compose --profile bi down. Именованные тома и данные сохранятся. Если использовали только базовый профиль, достаточно docker compose down.

Полная очистка изолированного проекта выполняется командой docker compose --profile bi down --volumes. Она удаляет данные MinIO, каталог Iceberg и метаданные Superset выбранного проекта. Сохраните нужные материалы и проверьте имя проекта перед выполнением.

Дополнительные материалы  Развёртывание (docs/deployment.md) · Ручная проверка (docs/manual-verification.md) · Протокол (docs/acceptance-results.md)

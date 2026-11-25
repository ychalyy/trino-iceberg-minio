# Руководство по развёртыванию Lakehouse

## Окружение

Нужны Docker Engine с плагином Docker Compose, Git, Bash и OpenSSL. Для первого запуска нужен сетевой доступ к GitHub и реестру образов. На Mac с Apple Silicon установите и запустите [Docker Desktop для ARM64](https://docs.docker.com/desktop/setup/install/mac-install/). Начните с 2 ядер, 6 ГБ памяти для Docker и 15 ГБ свободного диска — это ориентир исходного стенда.

Все команды выполняются в корне репозитория. Файл `.env` содержит локальные параметры. Для первой настройки выполните:

```bash
if [ ! -e .env ]; then
  (umask 077
    secret=$(openssl rand -hex 24) &&
    sed "s/^MINIO_ROOT_PASSWORD=$/MINIO_ROOT_PASSWORD=$secret/" .env.example > .env)
fi
```

По умолчанию имя пользователя MinIO — `admin`, а бакет — `warehouse`. Сохраните действующий `.env` при перезапуске. Для входа в консоль MinIO используйте `MINIO_ROOT_USER` и `MINIO_ROOT_PASSWORD` из локального файла.

## Сборка и запуск

Стенд проверен на Mac Apple Silicon с Docker Desktop 4.100.1, Engine 29.9.3 и Compose v5.7.1. Проверенные версии сервисов — Trino 484, Iceberg REST Fixture 1.10.1, MinIO RELEASE.2025-04-22T22-12-26Z и mc RELEASE.2025-04-16T18-13-26Z. Все контейнеры запускались на Linux ARM64. Базовый коммит исходного репозитория — `ef567cbd53b902fe6fe8064dc835226c4c6b15be`.

Если терминал обращается к `/var/run/docker.sock`, а Docker Desktop запущен, проверьте `docker --context desktop-linux version`. Если команда видит сервер, задайте `export DOCKER_CONTEXT=desktop-linux` для этого терминала. Когда Buildx не может записать служебные файлы в пользовательский каталог Docker, можно указать доступный на запись каталог через `BUILDX_CONFIG`.

```bash
docker version
docker compose version
docker compose config --quiet
docker compose build minio
docker compose build mc
docker compose up -d --wait --wait-timeout 180
docker compose ps
```

`docker compose config --quiet` проверяет конфигурацию без вывода переменных окружения. MinIO и `mc` собираются из исходников по тегам из `.env.example`. `mc` создаёт бакет, устанавливает приватную политику и проходит проверку готовности. Trino запускается после готовности бакета.

| Компонент | Адрес на Mac | Назначение |
|---|---|---|
| Trino | `http://127.0.0.1:8080` | SQL и интерфейс наблюдения за запросами |
| Iceberg REST Catalog | `http://127.0.0.1:8181` | API каталога Iceberg |
| MinIO API | `http://127.0.0.1:9000` | S3-совместимое хранилище |
| Консоль MinIO | `http://127.0.0.1:9001` | Просмотр бакетов и объектов |

Порты на Mac переопределяются в `.env`. Контейнеры общаются по внутренней сети Compose. MinIO хранит файлы таблиц и метаданные Iceberg в томе `minio_data`. REST Catalog хранит указатели на актуальные метаданные таблиц в SQLite в томе `rest_data`.

## Проверка стенда

```bash
bash scripts/stand-smoke.sh prepare
```

Сценарий создаёт контрольную таблицу и добавляет строки `(1, trino)` и `(2, minio)`. Затем он сверяет точный результат SELECT, проверяет политику бакета и ищет файлы Parquet и метаданные Iceberg в MinIO. Признак успеха — сообщение `OK: Iceberg rows, private MinIO bucket, Parquet and Iceberg metadata.`

После перезапуска можно выполнить проверку без записи:

```bash
docker compose down
docker compose up -d --wait --wait-timeout 180
bash scripts/stand-smoke.sh verify
```

`down` убирает контейнеры и сеть проекта. Именованные тома сохраняются, пока не указан флаг `--volumes`. Для паузы и последующего возобновления можно использовать `docker compose stop` и `docker compose start`.

## Диагностика

| Симптом | Что проверить |
|---|---|
| CLI доступен, но Engine не отвечает | Запущен ли Docker Desktop и что показывает серверная часть `docker version` |
| Порт занят | `lsof -nP -iTCP:8080 -sTCP:LISTEN`. Измените соответствующую переменную порта в `.env` |
| Бакет не готов | `docker compose logs --tail=100 minio mc`. Проверьте совпадение локальных параметров и состояние MinIO |
| Trino стартовал, но запрос к Iceberg падает | `docker compose logs --tail=100 trino rest`. Проверьте доступность REST Catalog, S3 и настройки региона |

## Настройка полного прототипа

В корне репозитория заполните недостающие параметры `.env`. Следующий фрагмент создаёт случайные значения для пустых параметров, сохраняет существующие значения и ограничивает права файла. Для пайплайна нужен Python 3.9+ и Make.

```bash
(umask 077
python3 - <<'PY'
from pathlib import Path
import secrets

path = Path(".env")
text = path.read_text() if path.exists() else Path(".env.example").read_text()
for name in ("MINIO_ROOT_PASSWORD", "SUPERSET_SECRET_KEY", "SUPERSET_ADMIN_PASSWORD"):
    lines = text.splitlines()
    index = next((i for i, line in enumerate(lines) if line.startswith(name + "=")), None)
    if index is None:
        lines.append(name + "=" + secrets.token_hex(24))
    elif not lines[index].split("=", 1)[1]:
        lines[index] = name + "=" + secrets.token_hex(24)
    text = "\n".join(lines) + "\n"
path.write_text(text)
path.chmod(0o600)
PY
)
```

Для нового проекта выполните `make up` и `make demo`. Демо включает положительные пакеты, повторы, намеренную остановку после Raw и отрицательный пакет. Чтобы запустить пакеты по отдельности, используйте `make load BATCH=initial` и `make load BATCH=delta`. `make dq` проверяет последний опубликованный пакет и пишет отдельную попытку. `make evidence` выводит числа строк, историю позиции, изменение продаж и сводку DQ. Пошаговая альтернатива приведена в [ручной инструкции](manual-verification.md).

## Superset

```bash
docker compose --profile bi build superset
docker compose --profile bi up -d --wait --wait-timeout 180 superset
```

Откройте [localhost:8088](http://127.0.0.1:8088/) или порт из `SUPERSET_PORT`. Имя пользователя — `superset_admin`, пароль — локальный `SUPERSET_ADMIN_PASSWORD`. На чистом экземпляре импортируйте [экспорт дашборда](../superset/lakehouse-dashboard.zip) через **Dashboards → Import**. Экспорт подключается к `trino:8080` по внутренней сети Compose. После загрузки данных откройте обе вкладки и обновите графики.

На проверенном Mac Docker Desktop выделял приблизительно 8 ГиБ. Лимит Trino по умолчанию — 3 ГиБ, его можно переопределить через `TRINO_MEMORY_LIMIT`. Конфигурация JVM резервирует не более 60% этого лимита под heap, чтобы оставить память для нативных буферов. При коде завершения 137 проверьте `docker inspect` на `OOMKilled`. Запускайте прогоны последовательно и останавливайте завершённые тестовые проекты через `docker compose stop` из их окружения.

`make bootstrap` создаёт схемы. Для существующего проекта команда пополняет отсутствующие снимки ранее опубликованных пакетов, затем переключает витрины на эти снимки.

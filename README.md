# Lakehouse на Trino, Iceberg и MinIO

Прототип тестового задания системного аналитика. TPC-H проходит через Raw и Data Vault 2.0 до двух витрин. Один дашборд Superset показывает бизнес-метрики и результаты контроля качества по каждой попытке загрузки.

## Запуск и проверка

Подготовьте Docker и локальный `.env` по [руководству оператора](docs/Md/6_%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE%20%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%BE%D1%80%D0%B0%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md). Все команды выполняются из корня проекта.

1. Для сквозной приёмки в отдельном Compose-проекте выполните `make up`, затем `make demo`.
2. Запустите профиль `bi` и импортируйте [дашборд Superset](superset/lakehouse-dashboard.zip). Порядок ручной проверки в терминале, Trino CLI, MinIO и Superset приведён в [руководстве оператора](docs/Md/6_%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE%20%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%BE%D1%80%D0%B0%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md).
3. Для просмотра контрольных данных в уже запущенном проекте `lakehouse-proof` выполните:

   ```bash
   DOCKER_CONTEXT=desktop-linux COMPOSE_PROJECT_NAME=lakehouse-proof make evidence
   ```

   В этом проекте [дашборд Superset](http://127.0.0.1:28088/superset/dashboard/lakehouse-demo/) доступен на порту 28088. На чистом стенде используйте адрес из настроек запуска своего проекта.

## Документация

| Документ | Содержание |
|---|---|
| [Техническое задание](docs/Md/1_%D0%A2%D0%B5%D1%85%D0%BD%D0%B8%D1%87%D0%B5%D1%81%D0%BA%D0%BE%D0%B5%20%D0%B7%D0%B0%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md) | Семь требований и критерии приёмки |
| [Пояснительная записка](docs/Md/2_%D0%9F%D0%BE%D1%8F%D1%81%D0%BD%D0%B8%D1%82%D0%B5%D0%BB%D1%8C%D0%BD%D0%B0%D1%8F%20%D0%B7%D0%B0%D0%BF%D0%B8%D1%81%D0%BA%D0%B0%20%E2%80%94%20%D0%B0%D1%80%D1%85%D0%B8%D1%82%D0%B5%D0%BA%D1%82%D1%83%D1%80%D0%B0%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%D0%B0%20Lakehouse.md) | Архитектура, слои хранилища и физический стенд |
| [Модель данных](docs/Md/3_%D0%9C%D0%BE%D0%B4%D0%B5%D0%BB%D1%8C%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md) | Таблицы, поля, ключи, маппинг и формулы витрин |
| [Регламент загрузки](docs/Md/4_%D0%A0%D0%B5%D0%B3%D0%BB%D0%B0%D0%BC%D0%B5%D0%BD%D1%82%20%D0%B7%D0%B0%D0%B3%D1%80%D1%83%D0%B7%D0%BA%D0%B8%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md) | Первичная загрузка, инкремент, повтор и восстановление |
| [Качество данных и ПМИ](docs/Md/5_%D0%9A%D0%B0%D1%87%D0%B5%D1%81%D1%82%D0%B2%D0%BE%20%D0%B4%D0%B0%D0%BD%D0%BD%D1%8B%D1%85%20%D0%B8%20%D0%9F%D0%9C%D0%98%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md) | Правила DQ и сценарии испытаний по семи пунктам |
| [Руководство оператора](docs/Md/6_%D0%A0%D1%83%D0%BA%D0%BE%D0%B2%D0%BE%D0%B4%D1%81%D1%82%D0%B2%D0%BE%20%D0%BE%D0%BF%D0%B5%D1%80%D0%B0%D1%82%D0%BE%D1%80%D0%B0%20%E2%80%94%20%D0%BF%D1%80%D0%BE%D1%82%D0%BE%D1%82%D0%B8%D0%BF%20Lakehouse.md) | Развёртывание, команды ручной проверки и диагностика |
| [Комплект в формате Word](docs/Word) | Шесть документов DOCX |
| [Редактируемые схемы draw.io](docs/diagrams) | Семь схем архитектуры, модели, загрузки и DQ |

## Свидетельства испытаний

Сохранённый прогон, контрольные выгрузки и скриншот вкладки качества доступны в ревизии приёмки. Скриншот бизнес-вкладки показывает текущий дашборд.

- [Протокол сквозной приёмки](https://github.com/ychalyy/trino-iceberg-minio/blob/b54621d5e5dd7844302a62232cae438bad39d5a5/docs/acceptance-results.md)
- [Контрольные значения чистого прогона](https://github.com/ychalyy/trino-iceberg-minio/blob/b54621d5e5dd7844302a62232cae438bad39d5a5/docs/evidence/release-control-values.tsv)
- [Выгрузка DQ](https://github.com/ychalyy/trino-iceberg-minio/blob/b54621d5e5dd7844302a62232cae438bad39d5a5/docs/evidence/dq-results.tsv)
- [Контрольные значения отгрузок](https://github.com/ychalyy/trino-iceberg-minio/blob/b54621d5e5dd7844302a62232cae438bad39d5a5/docs/evidence/shipping-by-mode.tsv)
- [Скриншот вкладки качества](https://github.com/ychalyy/trino-iceberg-minio/blob/b54621d5e5dd7844302a62232cae438bad39d5a5/docs/superset-dq.png)
- [Актуальный скриншот бизнес-вкладки](docs/superset-business.png)

Исходный стенд — [maxalyapyshev/trino-iceberg-minio](https://github.com/maxalyapyshev/trino-iceberg-minio), базовый коммит `ef567cbd53b902fe6fe8064dc835226c4c6b15be`.

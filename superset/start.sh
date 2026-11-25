#!/bin/sh
set -eu

: "${SUPERSET_SECRET_KEY:?Set SUPERSET_SECRET_KEY in .env}"
: "${SUPERSET_ADMIN_PASSWORD:?Set SUPERSET_ADMIN_PASSWORD in .env}"

superset db upgrade
users=$(superset fab list-users 2>/dev/null)
if ! printf '%s\n' "$users" | grep -q 'username:superset_admin'; then
    superset fab create-admin --username superset_admin --firstname Lakehouse \
        --lastname Administrator --email superset-admin@example.invalid \
        --password "$SUPERSET_ADMIN_PASSWORD"
fi
superset init
exec gunicorn --bind 0.0.0.0:8088 --workers 1 --threads 4 --timeout 120 'superset.app:create_app()'

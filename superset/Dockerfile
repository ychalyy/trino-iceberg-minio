FROM apache/superset:6.1.0

USER root
RUN uv pip install --python /app/.venv/bin/python trino==0.337.0
USER superset

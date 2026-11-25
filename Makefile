PYTHON ?= python3
BATCH ?= initial

.PHONY: up bootstrap load dq demo evidence
up:
	docker compose up -d --wait --wait-timeout 180

bootstrap:
	$(PYTHON) scripts/lakehouse.py bootstrap

load:
	$(PYTHON) scripts/lakehouse.py load --batch $(BATCH)

dq:
	$(PYTHON) scripts/lakehouse.py dq

demo:
	$(PYTHON) scripts/lakehouse.py demo

evidence:
	$(PYTHON) scripts/lakehouse.py evidence

SHELL := /bin/bash
.PHONY: start stop status logs-postgres logs-metabase dbt-run dbt-docs

start:
	docker compose -f docker/compose.dev.yml up -d
	-docker start metabase || docker run -d -p 3000:3000 --name metabase metabase/metabase
	source .venv/bin/activate && export $$(grep -v '^#' .env | xargs) && cd dbt_project/eu_energy && dbt docs generate && dbt docs serve

stop:
	docker compose -f docker/compose.dev.yml down
	-docker stop metabase || true
	@echo "Stopped Postgres + Metabase"

status:
	docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

logs-postgres:
	docker logs -f docker-postgres-1

logs-metabase:
	docker logs -f metabase

dbt-run:
	source .venv/bin/activate && export $$(grep -v '^#' .env | xargs) && cd dbt_project/eu_energy && dbt run && dbt test

dbt-docs:
	cd dbt_project/eu_energy && dbt docs generate && dbt docs serve

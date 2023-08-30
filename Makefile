.phony: up down build up-infra

up-infra:
	@docker compose up -d

up: up-infra

down:
	@docker compose down --remove-orphans

build:
	@docker build -t app -f app/.docker/Dockerfile app

bootstrap:
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app get --start-date 2022-08-05 --finish-date 2022-11-11 --bootstrap
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app get --start-date 2022-11-12 --finish-date 2023-05-29
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/dim_cards.sql
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/dim_goals.sql
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/fct_matches.sql

get-answers:
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/away_goals_scored.sql --output-csv --output-csv-path output/test.csv

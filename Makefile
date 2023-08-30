.phony: up down build up-infra

up-infra:
	@docker compose up -d

up: build up-infra bootstrap get-answers

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
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/final_league_table.sql --output-csv --output-csv-path output/query_a.csv
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/away_goals_scored.sql --output-csv --output-csv-path output/query_b.csv
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/top_5_referees_with_most_cards.sql --output-csv --output-csv-path output/query_c.csv
	@docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/goalscore_by_round_14.sql --output-csv --output-csv-path output/query_d.csv
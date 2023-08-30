## FootballAPI Data

Simple Python App that reads the API from [apifootball](https://apifootball.com/) and insert its contents into a PostgreSQL database.

I have included scripts  to run against the data, just follow the instructions.
Everything should work within docker.

A Metabase instance is bundled together if you want to do some exploratory data analysis, accessible from http://localhost:3000

### Prerequisites

- Docker
- Docker Compose
- Make

### Usage

1. Open a terminal or command prompt.
2. Clone this repository
3. Navigate to the directory containing the Makefile
4. Run `make up` to set up everything (Create a PSQL instance, a database, query the API and inserts it into the database).
5. In case something goes wrong, you can run everything step by step:

Building the app:
```
docker build -t app -f app/.docker/Dockerfile app
```

Setting up the infrastructure (PostreSQL database and Metabase)
```
docker compose up -d
```

Bootstrapping raw data table and model tables (fact and dimensions)
```
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app get --start-date 2022-08-05 --finish-date 2022-11-11 --bootstrap
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app get --start-date 2022-11-12 --finish-date 2023-05-29
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/dim_cards.sql
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/dim_goals.sql
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/models/fct_matches.sql
```

Creating csv answers:
```
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/final_league_table.sql --output-csv --output-csv-path output/query_a.csv
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/away_goals_scored.sql --output-csv --output-csv-path output/query_b.csv
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/top_5_referees_with_most_cards.sql --output-csv --output-csv-path output/query_c.csv
	docker run --rm --network host --volume $$(pwd)/output:/workspace/output app execute-sql --path scripts/questions/goalscore_by_round_14.sql --output-csv --output-csv-path output/query_d.csv
```


### Scripts

All scripts (models and questions/answers) are located in the folder: `app/scripts`
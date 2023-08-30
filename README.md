## FootballAPI Data

Simple Python App that reads the API from [apifootball](https://apifootball.com/), extracts Premier League data and insert its contents into a PostgreSQL database.

The app was developed as an CLI and containerized with Docker in order to make it easier to use with scheduling applications, such as Airflow.
Some parameters such as `start-date` and `finish-date` can be used in conjunction with Airflow's timetable, making it easy to run a backfill on previous dates or re-run a failed execution.

I have included scripts  to run against the data, including some models located within `scripts/models` folder.
The premise of the modelling is that the application won't manipulate the data, inserting it as it is, so it's up to the model to create facts and dimensions.
All models have a deduplication step because it can't guarantee that the raw data will be unique.
For simplicity's sake, every model is only a SQL with multiple CTE's. In a real world use case, like in a dbt model, we would separate some of the CTE's into staging/intermediate models for better readability.

CSVs are included in the folder `output`.

The API token is included in the repository also for making the setup process easier, since it was created with a temporary email. Again, in a real world scenario, it would be best if a Secret Store was used (GCP Secret Manager/AWS Parameter Store/ Hashicorp Vault), with the API key being injected into the container either during build time by the CI process or during execution by the Scheduler.

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

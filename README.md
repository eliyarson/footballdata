## FootballAPI Data

Simple Python App that reads the API from [apifootball](https://apifootball.com/) and insert its contents into a PostgreSQL database.

I have included scripts  to run against the data, just follow the instructions.

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



### Scripts

- 
import json
import requests
from requests import HTTPError
import logging
import time
import random
import warnings
import os
import psycopg2
from pprint import pp
import csv
import os


class FootballAPIConsumer:
    def __init__(
        self,
        url: str = "https://apiv3.apifootball.com/",
        host: str = "",
        database: str = "",
        user: str = "",
        start_date: str = "2022-01-01",
        finish_date: str = "2023-04-20",
        league_id: str = "152",
        raw_table_name="raw_football_data",
    ) -> None:
        self.url = url
        self.host = "localhost"
        self.database = "postgres"
        self.user = "postgres"
        self.password = os.getenv("POSTGRES_PASSWORD", "passwd")
        self.api_key = os.getenv("FOOTBALLAPI_KEY")
        self.start_date = start_date
        self.finish_date = finish_date
        self.league_id = league_id
        self.final_url = ""
        self.raw_table_name = raw_table_name

    def build_url(self):
        final_url = f"{self.url}?action=get_events&from={self.start_date}&to={self.finish_date}&league_id={self.league_id}&APIkey={self.api_key}"
        return final_url

    def get_data(self, retries=5, backoff_in_seconds=1):
        x = 0
        for i in range(retries):
            try:
                r = requests.get(self.final_url, stream=True, allow_redirects=True)
                if r.ok:
                    return r.json()
                elif r.status_code == 404:
                    raise HTTPError("URL not found. Did you input the correct url?")
            except requests.exceptions.ReadTimeout:
                logging.debug("Failure querying data")
                logging.debug("Retrying")
                sleep = backoff_in_seconds * 2**x + random.uniform(0, 1)
                time.sleep(sleep)
                continue

    def create_conn(self):
        return psycopg2.connect(
            host=self.host,
            database=self.database,
            user=self.user,
            password=self.password,
        )

    def create_psql_table(self):
        query = f"""
        CREATE TABLE {self.raw_table_name} (
	    id serial NOT NULL PRIMARY KEY,
        data json NOT NULL,
        inserted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
        );
        """
        try:
            with self.create_conn() as conn:
                with conn.cursor() as cur:
                    cur.execute(query)
                conn.commit()
        except psycopg2.DatabaseError:
            raise

    def insert_data(self, row):
        clean = json.dumps(row).replace("'", "''")
        query = f"""
        INSERT INTO {self.raw_table_name}(
            data
        )
        VALUES ('{clean}')
        RETURNING id;
        """
        with self.create_conn() as conn:
            cur = conn.cursor()
            cur.execute(query)
            conn.commit()

    def execute_sql_file(
        self, path, print_result, output_csv, output_csv_path, rows_to_fetch
    ):
        with self.create_conn() as conn:
            with conn.cursor() as cur:
                logging.info(f"Reading script: {path}")
                cur.execute(open(f"{path}", "r").read())
                columns = [column[0] for column in cur.description]
                print(columns)
                if bool(output_csv):
                    dir_name = os.path.dirname(output_csv_path)
                    if dir_name:
                        os.makedirs(dir_name, exist_ok=True)
                    with open(output_csv_path, "w+") as f:
                        writer = csv.writer(f)
                        writer.writerow(columns)
                result = cur.fetchmany(rows_to_fetch)
                for row in result:
                    if bool(print_result):
                        pp(dict(zip(columns, row)))
                    if bool(output_csv):
                        with open(output_csv_path, "a") as f:
                            writer = csv.writer(f)
                            writer.writerow(row)


def configure_logging(verbose: bool = False) -> None:
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        format="%(asctime)s %(levelname)-8s %(message)s",
        level=level,
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    warnings.filterwarnings("ignore", r".*end user credentials.*", UserWarning)
    return None

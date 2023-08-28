import zipfile
import json
import requests
from requests import HTTPError
import logging
import time
import random
import warnings
import os
import glob
import psycopg2
from pprint import pp

class FootballAPIConsumer:
    def __init__(
        self, url: str = "https://apiv3.apifootball.com/", host: str = "", database: str = "", user: str = ""
    ) -> None:
        self.url = url
        self.path = ""
        self.json_dir = "output/json_files"
        self.host = "localhost"
        self.database = "postgres"
        self.user = "postgres"
        self.password = os.getenv("POSTGRES_PASSWORD", "passwd")
        self.api_key = os.getenv("FOOTBALLAPI_KEY")
        self.start_date ="2023-04-05"
        self.finish_date = "2023-04-05"
        self.league_id = "152"
        self.final_url = ""
        

    def build_url(self):
        final_url = f"{self.url}?action=get_events&from={self.start_date}&to={self.finish_date}&league_id={self.league_id}&APIkey={self.api_key}"
        return final_url

    def get_data(self, retries=5, backoff_in_seconds=1):
        x = 0
        for i in range(retries):
            try:
                r = requests.get(self.final_url, stream=True, allow_redirects=True)
                if r.ok:
                    print(r.content)
                    return self.path
                elif r.status_code == 404:
                    raise HTTPError("URL not found. Did you input the correct url?")
            except requests.exceptions.ReadTimeout:
                logging.debug("Failure querying data")
                logging.debug("Retrying")
                sleep = backoff_in_seconds * 2**x + random.uniform(0, 1)
                time.sleep(sleep)
                continue

def configure_logging(verbose: bool = False) -> None:
    """
    Configures the logging settings.

    Args:
        verbose (bool): If True, sets the logging level to DEBUG; otherwise, sets it to INFO. Defaults to False.

    Returns:
        None

    """
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        format="%(asctime)s %(levelname)-8s %(message)s",
        level=level,
        datefmt="%Y-%m-%d %H:%M:%S",
    )
    warnings.filterwarnings("ignore", r".*end user credentials.*", UserWarning)
    return None

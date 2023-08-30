from commands import FootballAPIConsumer, configure_logging
import logging
import click
from psycopg2.errors import DuplicateTable


@click.group()
@click.option(
    "--verbose",
    required=False,
    is_flag=True,
    default=False,
    help="Enable debug/verbose logging info",
)
def cli(verbose):
    configure_logging(verbose)


@click.command(name="get")
@click.option("--start-date", required=True, help="Start date")
@click.option("--finish-date", required=True, help="Finish date")
@click.option(
    "--bootstrap",
    required=False,
    is_flag=True,
    default=False,
    help="Bootstrap the table",
)
def get(start_date, finish_date, bootstrap):
    fc = FootballAPIConsumer(start_date=start_date, finish_date=finish_date)
    if bootstrap:
        logging.info("Boostrap enabled. Creating raw data table...")
        try:
            fc.create_psql_table()
        except DuplicateTable:
            logging.info("Table already exists. Dropping.")
            fc.drop_psql_table()
            logging.info("Done")
            logging.info("Recreating...")
            fc.create_psql_table()
            logging.info("Creating models...")

        logging.info("Done")
    fc.final_url = fc.build_url()
    logging.info(f"Getting data from Football API from {start_date} to {finish_date}")
    data = fc.get_data()
    for element in data:
        logging.debug(f"Inserting data {element}")
        fc.insert_data(element)


@click.command(name="execute-sql")
@click.option("--path", required=True, help="Path to sql file")
@click.option(
    "--print-result", required=False, default=False, help="Print result in console"
)
@click.option(
    "--output-csv",
    required=False,
    default=False,
    is_flag=True,
    help="Print output to csv",
)
@click.option("--output-csv-path", required=False, help="Print output to csv")
@click.option(
    "--rows_to_fetch",
    required=False,
    default=100,
    help="Number of rows to fetch. Defaults to 100",
)
def execute_sql_file(path, print_result, output_csv, output_csv_path, rows_to_fetch):
    fc = FootballAPIConsumer()
    fc.execute_sql_file(
        path=path,
        print_result=print_result,
        output_csv=output_csv,
        output_csv_path=output_csv_path,
        rows_to_fetch=rows_to_fetch,
    )


cli.add_command(get)
cli.add_command(execute_sql_file)

if __name__ == "__main__":
    cli()

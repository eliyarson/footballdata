from commands import FootballAPIConsumer, configure_logging
import logging
import click


@click.group()
@click.option("--verbose", required=False, help="Enable debug/verbose logging info")
def cli(verbose):
    configure_logging(verbose)


@click.command(name="get")
@click.option("--start-date", required=True, help="Start date")
@click.option("--finish-date", required=True, help="Finish date")
@click.option("--bootstrap", required=False, default=False, help="Bootstrap the table")
def get(start_date, finish_date, bootstrap):
    fc = FootballAPIConsumer(start_date=start_date, finish_date=finish_date)
    if bootstrap:
        logging.info("Boostrap enabled. Creating raw data table...")
        fc.create_psql_table()
        logging.info("Done")
    fc.final_url = fc.build_url()
    data = fc.get_data()
    for element in data:
        logging.debug(f"Inserting data {element}")
        fc.insert_data(element)


@click.command(name="execute-sql")
@click.option("--path", required=True, help="Path to sql file")
@click.option(
    "--rows_to_fetch",
    required=False,
    default=10,
    help="Number of rows to fetch. Defaults to 10",
)
def execute_sql_file(path, rows_to_fetch):
    fc = FootballAPIConsumer()
    fc.execute_sql_file(path, rows_to_fetch)


cli.add_command(get)
cli.add_command(execute_sql_file)

if __name__ == "__main__":
    cli()

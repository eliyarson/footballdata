from commands import FootballAPIConsumer, configure_logging
import logging
import click


@click.group()
@click.option("--verbose", required=False, help="Enable debug/verbose logging info")
def cli(verbose):
    configure_logging(verbose)

@click.command(name="get")
@click.option("--start-date", required=False, help="Start date")
@click.option("--finish-date", required=False, help="Finish date")
def download(start_date,finish_date):
    fc = FootballAPIConsumer()
    fc.final_url = fc.build_url()
    fc.get_data()

if __name__ == "__main__":
    cli()

# Football Data CLI

The Football Data CLI is a command-line tool that allows you to interact with a Football API and perform various actions related to retrieving and manipulating football data. This tool is designed to help you fetch football-related data, bootstrap a data table, and execute SQL queries on the data.

## Installation

To use the Football Data CLI, you need to follow these steps to set up the environment and install the necessary dependencies.

1. Clone the repository:
   ```
   git clone https://github.com/eliyarson/footballdata
   ```

2. Navigate to the project directory:
   ```
   cd footballdata
   ```

3. Create a virtual environment (recommended):
   ```
   python -m venv venv
   ```

4. Activate the virtual environment:
   - On Windows:
     ```
     venv\Scripts\activate
     ```
   - On macOS and Linux:
     ```
     source venv/bin/activate
     ```

5. Install the required packages:
   ```
   pip install -r requirements.txt
   ```

## Usage

The Football Data CLI provides the following commands that you can use to interact with football data:

### `get` Command

Use the `get` command to retrieve football data based on the specified date range.

```bash
python app/main.py get --start-date <start_date> --finish-date <finish_date> [--bootstrap]
```

- `--start-date`: The start date of the data range.
- `--finish-date`: The finish date of the data range.
- `--bootstrap`: (Optional) Enable this flag to bootstrap the raw data table before fetching new data.

### `execute-sql` Command

The `execute-sql` command allows you to execute SQL queries on the football data.

```bash
python app/main.py execute-sql --path <sql_file_path> [--print-result] [--output-csv] [--output-csv-path <output_csv_path>] [--rows_to_fetch <num_rows>]
```

- `--path`: The path to the SQL file containing the query.
- `--print-result`: (Optional) Enable this flag to print the query result in the console.
- `--output-csv`: (Optional) Enable this flag to output the query result to a CSV file.
- `--output-csv-path`: (Optional) Specify the path for the CSV output file.
- `--rows_to_fetch`: (Optional) The number of rows to fetch from the query result. Defaults to 100.

### Global Options

The CLI also supports the following global options:

- `--verbose`: Enable debug/verbose logging information.

## Examples

1. Fetch football data for a specific date range:
   ```bash
   python app/main.py get --start-date 2023-01-01 --finish-date 2023-08-01
   ```

2. Fetch football data and bootstrap the data table:
   ```bash
   python app/main.py get --start-date 2023-01-01 --finish-date 2023-08-01 --bootstrap
   ```

3. Execute an SQL query and print the result:
   ```bash
   python app/main.py execute-sql --path query.sql --print-result
   ```

4. Execute an SQL query and save the result to a CSV file:
   ```bash
   python app/main.py execute-sql --path query.sql --output-csv --output-csv-path result.csv
   ```

## License

This project is licensed under the [MIT License](LICENSE).

---

For additional information and support, please contact [eli.yarson@gmail.com](mailto:eli.yarson@gmail.com).
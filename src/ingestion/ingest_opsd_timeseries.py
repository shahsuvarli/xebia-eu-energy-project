import os
import zipfile
import pandas as pd
import requests
from sqlalchemy import create_engine, text

DATABASE_URL = os.getenv(
    "DATABASE_URL", "postgresql://analytics:analytics@localhost:55432/energy")
RAW_DIR = os.getenv("RAW_DIR", "./data/raw")

# OPSD hourly time series (public open data)
OPSD_URL = "https://data.open-power-system-data.org/time_series/2020-10-06/time_series_60min_singleindex.csv"
RAW_CSV = os.path.join(RAW_DIR, "time_series_60min_singleindex.csv")


def download_opsd():
    os.makedirs(RAW_DIR, exist_ok=True)
    r = requests.get(OPSD_URL, timeout=300)
    r.raise_for_status()
    with open(RAW_CSV, "wb") as f:
        f.write(r.content)
    return RAW_CSV


def load_to_postgres(csv_path):
    engine = create_engine(DATABASE_URL)
    from sqlalchemy import text
    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS raw;"))

    # discover the time column first
    head = pd.read_csv(csv_path, nrows=5)
    time_col = "utc_timestamp" if "utc_timestamp" in head.columns else (
        "time" if "time" in head.columns else None)
    if not time_col:
        raise RuntimeError("Could not detect time column in OPSD CSV.")

    table = "opsd_timeseries_raw"
    selected_cols = None
    total = 0

    

    for i, chunk in enumerate(pd.read_csv(csv_path, chunksize=100_000)):
        if selected_cols is None:
            nl_de_cols = [
                c for c in chunk.columns if c.startswith(("NL_", "DE_"))]
            selected_cols = [time_col] + nl_de_cols
        df = chunk[selected_cols].copy()
        df[time_col] = pd.to_datetime(df[time_col], utc=True, errors="coerce")

        if_exists = "replace" if i == 0 else "append"
        df.to_sql(table, con=engine, schema="raw", index=False,
                  if_exists=if_exists, method="multi", chunksize=5000)
        total += len(df)
        print(f"chunk {i}: {len(df)} rows (total {total})")

    # harmless if exists

    print(f"Loaded raw.{table}: {total} rows")


if __name__ == "__main__":
    path = download_opsd()
    print(f"Downloaded: {path}")
    load_to_postgres(path)

import os
from dotenv import load_dotenv
import time
import pandas as pd
import requests
from sqlalchemy import create_engine, text
from datetime import datetime

# --- Configuration ---
load_dotenv() # Loads variables from .env file

DB_URL = os.getenv("DATABASE_URL")
if not DB_URL:
    raise ValueError("DATABASE_URL environment variable is not set. Please create a .env file or set the variable.")

STAGING_SCHEMA = "staging"
STAGING_TABLE = "raw_match_data"
DATA_DIR = "./data"
BASE_URL = "https://www.football-data.co.uk/mmz4280"
LEAGUE = "E0" 

def get_season_list(num_years: int) -> list[str]:
    """
    Generates season strings like '2526', '2425' based on the current date.
    Football seasons usually start in August.
    """
    now = datetime.now()
    # If we are in the first half of 2026, the current season started in 2025.
    current_start_year = now.year if now.month >= 8 else now.year - 1
    
    seasons = []
    for i in range(num_years):
        year_1 = (current_start_year - i) % 100
        year_2 = (current_start_year - i + 1) % 100
        seasons.append(f"{year_1:02d}{year_2:02d}")
    return seasons

def download_and_clean(url: str, season: str) -> pd.DataFrame:
    """Downloads the CSV and performs basic cleaning before returning a DataFrame."""
    try:
        response = requests.get(url, timeout=15)
        response.raise_for_status()
        
        # Site returns HTML 'Not Found' pages even with 200 status sometimes
        if "<html" in response.text.lower():
            print(f"  [!] URL exists but returned HTML (likely 404): {url}")
            return None
            
        # Use a temporary local save or read directly from memory
        from io import StringIO
        df = pd.read_csv(StringIO(response.text), on_bad_lines='skip')
        
        # --- Industry Standard Cleaning ---
        # 1. Drop rows that are completely empty
        df = df.dropna(how='all')
        # 2. Ensure the crucial 'HomeTeam' exists
        df = df.dropna(subset=['HomeTeam'])
        # 3. Standardize Dates (handles 2 or 4 digit years)
        df['Date'] = pd.to_datetime(df['Date'], dayfirst=True, errors='coerce')
        # 4. Add a column so we know which season this data belongs to
        df['season_tag'] = season
        
        return df

    except Exception as e:
        print(f"  [!] Failed to process {url}: {e}")
        return None

def main():
    print("--- Starting Ingestion Pipeline ---")
    engine = create_engine(DB_URL)
    os.makedirs(DATA_DIR, exist_ok=True)
    
    # 1. Extract and Clean ALL seasons first
    seasons = get_season_list(10)
    all_dfs = []
    
    for season in seasons:
        url = f"{BASE_URL}/{season}/{LEAGUE}.csv"
        print(f"Processing Season: {season}...")
        
        df = download_and_clean(url, season)
        
        if df is not None and not df.empty:
            all_dfs.append(df)
            print(f"  [+] Downloaded {len(df)} rows.")
            time.sleep(1) # Politeness
        else:
            print(f"  [-] Skipping {season} (No data).")
    
    if not all_dfs:
        print("\n--- Failure: No data was downloaded. ---")
        return

    # 2. Combine into a single DataFrame
    print("\nCombining all seasons into a single dataset...")
    combined_df = pd.concat(all_dfs, ignore_index=True)
    print(f"Total columns in combined data: {len(combined_df.columns)}")
    
    # 3. Prepare Target and Load
    print(f"Preparing database and loading {len(combined_df)} rows...")
    with engine.connect() as conn:
        conn.execute(text(f'CREATE SCHEMA IF NOT EXISTS {STAGING_SCHEMA};'))
        conn.execute(text(f'DROP TABLE IF EXISTS {STAGING_SCHEMA}.\"{STAGING_TABLE}\";'))
        conn.commit()
    
    combined_df.to_sql(
        STAGING_TABLE,
        engine,
        schema=STAGING_SCHEMA,
        if_exists='replace', # Let pandas create the table with the full superset of columns
        index=False,
        chunksize=1000 # More efficient for large datasets
    )

    print(f"\n--- Success: Ingested {len(combined_df)} total rows into {STAGING_SCHEMA}.{STAGING_TABLE} ---")

if __name__ == "__main__":
    main()
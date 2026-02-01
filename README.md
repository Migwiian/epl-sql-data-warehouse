# premier-league-data-analytics

## Problem Statement
*   Difficulty in consolidating and analyzing Premier League match data from various seasons.
*   Lack of a structured, analytics-ready data source for historical match performance.

## Goal
Establish a robust ETL pipeline to extract, transform, and load Premier League match data into a PostgreSQL database, optimized for Power BI reporting and data analysis.

## Dataset
*   **Source:** football-data.co.uk (CSV files)
*   **Content:** Historical Premier League match results and statistics.

## Project Structure
- 01_schema_ddl.sql          -- Database schema definition (DDL)
- 02_transformation.sql      -- ETL transformations to populate star schema
- 03_eda_validation.sql      -- Exploratory Data Analysis (EDA) and data validation queries
- 04_powerbi_view.sql        -- Optimized views for Power BI reporting
- ingest_pipeline.py         -- Python script for data ingestion
- README.md
- context.md
- progress.md
- pyproject.toml
- uv.lock

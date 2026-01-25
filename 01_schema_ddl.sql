/*
Premier League Data Warehouse Setup
*/


DROP SCHEMA IF EXISTS production CASCADE;
DROP SCHEMA IF EXISTS staging CASCADE;
DROP SCHEMA IF EXISTS util CASCADE;

-- ============================================================================
-- STEP 2: Create Schemas
-- ============================================================================
CREATE SCHEMA staging;    -- For raw data import
CREATE SCHEMA production; -- For clean data warehouse
CREATE SCHEMA util;       -- For helper functions

-- ============================================================================
-- STEP 3: Create Dimension Tables
-- ============================================================================

-- Dimension 1: Date
CREATE TABLE production.Dim_Date (
    Date_ID         DATE PRIMARY KEY,
    Year            SMALLINT NOT NULL,
    Month           SMALLINT NOT NULL,
    Day             SMALLINT NOT NULL,
    Day_Of_Week     SMALLINT NOT NULL,
    Day_Name        VARCHAR(10) NOT NULL,
    Month_Name      VARCHAR(10) NOT NULL,
    Quarter         SMALLINT NOT NULL,
    Week_Of_Year    SMALLINT NOT NULL,
    Is_Weekend      BOOLEAN NOT NULL,
    Season          VARCHAR(10)
);

-- Dimension 2: Team
CREATE TABLE production.Dim_Team (
    Team_ID         SERIAL PRIMARY KEY,
    Team_Name       VARCHAR(50) NOT NULL UNIQUE
);

-- ============================================================================
-- STEP 4: Create Fact Table (references dimensions)
-- ============================================================================
CREATE TABLE production.Fact_Match (
    Match_ID                SERIAL PRIMARY KEY,
    Date_ID                 DATE NOT NULL,
    Home_Team_ID            INTEGER NOT NULL,
    Away_Team_ID            INTEGER NOT NULL,
    Full_Time_Home_Goals    SMALLINT NOT NULL,
    Full_Time_Away_Goals    SMALLINT NOT NULL,
    Full_Time_Result        CHAR(1) NOT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_date FOREIGN KEY (Date_ID) 
        REFERENCES production.Dim_Date (Date_ID),
    
    CONSTRAINT fk_home_team FOREIGN KEY (Home_Team_ID) 
        REFERENCES production.Dim_Team (Team_ID),
        
    CONSTRAINT fk_away_team FOREIGN KEY (Away_Team_ID) 
        REFERENCES production.Dim_Team (Team_ID),
    
    -- Business Rule: Teams must be different
    CONSTRAINT chk_different_teams 
        CHECK (Home_Team_ID <> Away_Team_ID)
);

-- ============================================================================
-- STEP 5: Create Staging Table for CSV Import
-- ============================================================================
CREATE TABLE staging.raw_match_data (
    Div         VARCHAR(10),
    Date        VARCHAR(10),      -- Will convert to DATE later
    HomeTeam    VARCHAR(50),
    AwayTeam    VARCHAR(50),
    FTHG        SMALLINT,
    FTAG        SMALLINT,
    FTR         CHAR(1)
    -- Add other columns as needed
);

-- ============================================================================
-- STEP 6: Verification - Check what was created
-- ============================================================================
SELECT 'Schemas created:' as check_item;
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name IN ('staging', 'production', 'util');

SELECT 'Tables in production:' as check_item;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'production' ORDER BY table_name;

SELECT 'Tables in staging:' as check_item;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'staging' ORDER BY table_name;



SELECT schema_name FROM information_schema.schemata 
WHERE schema_name IN ('staging', 'production', 'util');

SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema IN ('staging', 'production')
ORDER BY table_schema, table_name;
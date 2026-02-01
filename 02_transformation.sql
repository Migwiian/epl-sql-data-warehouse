-- ==========================================
-- STEP 3: TRANSFORMATION & LOADING
-- ==========================================

-- 1. Clean Production Tables (Make it safe to re-run)
TRUNCATE production.Dim_Team, production.Dim_Date, production.Fact_Match RESTART IDENTITY CASCADE;

-- 2. Populate Dim_Team
INSERT INTO production.Dim_Team (Team_Name)
WITH all_teams AS (
    SELECT "HomeTeam" AS team_name FROM staging.raw_match_data WHERE "HomeTeam" IS NOT NULL
    UNION
    SELECT "AwayTeam" AS team_name FROM staging.raw_match_data WHERE "AwayTeam" IS NOT NULL
)
SELECT DISTINCT team_name
FROM all_teams;

-- 3. Populate Dim_Date
INSERT INTO production.Dim_Date (
    Date_ID,
    Year,
    Month,
    Day,
    Day_Of_Week,
    Day_Name,
    Month_Name,
    Quarter,
    Week_Of_Year,
    Is_Weekend,
    Season
)
WITH distinct_dates AS (
    -- FIXED: Changed "Date" to "Date"
    SELECT DISTINCT "Date"::date AS game_date
    FROM staging.raw_match_data
    WHERE "Date" IS NOT NULL
)
SELECT
    game_date AS Date_ID,
    EXTRACT(YEAR FROM game_date) AS Year,
    EXTRACT(MONTH FROM game_date) AS Month,
    EXTRACT(DAY FROM game_date) AS Day,
    EXTRACT(ISODOW FROM game_date) AS Day_Of_Week,
    TO_CHAR(game_date, 'Day') AS Day_Name,
    TO_CHAR(game_date, 'Month') AS Month_Name,
    EXTRACT(QUARTER FROM game_date) AS Quarter,
    EXTRACT(WEEK FROM game_date) AS Week_Of_Year,
    CASE WHEN EXTRACT(ISODOW FROM game_date) IN (6, 7) THEN TRUE ELSE FALSE END AS Is_Weekend,
    CASE
        WHEN EXTRACT(MONTH FROM game_date) >= 8 THEN
            EXTRACT(YEAR FROM game_date)::VARCHAR || '/' || (EXTRACT(YEAR FROM game_date) + 1)::VARCHAR
        ELSE
            (EXTRACT(YEAR FROM game_date) - 1)::VARCHAR || '/' || EXTRACT(YEAR FROM game_date)::VARCHAR
    END AS Season
FROM distinct_dates;

-- 4. Populate Fact_Match
INSERT INTO production.Fact_Match (
    Date_ID,
    Home_Team_ID,
    Away_Team_ID,
    Full_Time_Home_Goals,
    Full_Time_Away_Goals,
    Full_Time_Result
)
SELECT
    d.Date_ID,
    ht.Team_ID AS Home_Team_ID,
    at.Team_ID AS Away_Team_ID,
    -- FIXED: Mapping standard columns
    s."FTHG"::SMALLINT AS Full_Time_Home_Goals,
    s."FTAG"::SMALLINT AS Full_Time_Away_Goals,
    s."FTR" AS Full_Time_Result
FROM
    staging.raw_match_data s
JOIN
    production.Dim_Date d ON s."Date"::date = d.Date_ID
JOIN
    production.Dim_Team ht ON s."HomeTeam" = ht.Team_Name
JOIN
    production.Dim_Team at ON s."AwayTeam" = at.Team_Name
WHERE
    s."FTHG" IS NOT NULL
    AND s."FTAG" IS NOT NULL
    AND s."FTR" IS NOT NULL;
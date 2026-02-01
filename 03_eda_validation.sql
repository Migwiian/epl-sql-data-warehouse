-- Step 3: EDA & Validation Script
-- This script contains a series of queries to validate the data integrity
-- and perform exploratory data analysis on the production data warehouse.
-- These are read-only queries and do not modify any data.

-- Query 1: Row Count Validation
-- Description: Check the row counts in each production table to ensure data was loaded.
SELECT 'Dim_Date' AS table_name, COUNT(*) AS row_count FROM production.Dim_Date
UNION ALL
SELECT 'Dim_Team' AS table_name, COUNT(*) AS row_count FROM production.Dim_Team
UNION ALL
SELECT 'Fact_Match' AS table_name, COUNT(*) AS row_count FROM production.Fact_Match;


-- Query 2: NULL Value Check
-- Description: Verify that key columns in the Fact_Match table do not contain NULL values.
-- We expect 0 rows returned from this query.
SELECT
    COUNT(CASE WHEN Date_ID IS NULL THEN 1 END) AS null_date_ids,
    COUNT(CASE WHEN Home_Team_ID IS NULL THEN 1 END) AS null_home_team_ids,
    COUNT(CASE WHEN Away_Team_ID IS NULL THEN 1 END) AS null_away_team_ids,
    COUNT(CASE WHEN Full_Time_Result IS NULL THEN 1 END) AS null_results
FROM production.Fact_Match;


-- Query 3: Foreign Key Integrity Check
-- Description: Ensure that all team and date IDs in the fact table exist in their respective dimension tables.
-- This query should return 0 rows if all foreign keys are valid.
SELECT 'Orphaned Home_Team_ID' AS issue, COUNT(*)
FROM production.Fact_Match fm
LEFT JOIN production.Dim_Team dt ON fm.Home_Team_ID = dt.Team_ID
WHERE dt.Team_ID IS NULL
UNION ALL
SELECT 'Orphaned Away_Team_ID' AS issue, COUNT(*)
FROM production.Fact_Match fm
LEFT JOIN production.Dim_Team dt ON fm.Away_Team_ID = dt.Team_ID
WHERE dt.Team_ID IS NULL
UNION ALL
SELECT 'Orphaned Date_ID' AS issue, COUNT(*)
FROM production.Fact_Match fm
LEFT JOIN production.Dim_Date dd ON fm.Date_ID = dd.Date_ID
WHERE dd.Date_ID IS NULL;


-- Query 4: Date Range Sanity Check
-- Description: Check the minimum and maximum dates in the Dim_Date table to ensure they align with expectations.
SELECT
    MIN(Date_ID) AS min_date,
    MAX(Date_ID) AS max_date
FROM production.Dim_Date;


-- Query 5: EDA - Total Goals per Season
-- Description: A classic EDA query to see the trend of total goals scored over different seasons.
SELECT
    d.Season,
    SUM(fm.Full_Time_Home_Goals + fm.Full_Time_Away_Goals) AS total_goals,
    AVG(fm.Full_Time_Home_Goals + fm.Full_Time_Away_Goals) AS avg_goals_per_match
FROM
    production.Fact_Match fm
JOIN
    production.Dim_Date d ON fm.Date_ID = d.Date_ID
GROUP BY
    d.Season
ORDER BY
    d.Season;


-- Query 6: EDA - Top 10 Goal-Scoring Teams
-- Description: Identifies the teams that have scored the most goals (both home and away) across all seasons.
WITH team_goals AS (
    -- Calculate goals scored by home teams
    SELECT
        t.Team_Name,
        SUM(fm.Full_Time_Home_Goals) AS goals_scored
    FROM production.Fact_Match fm
    JOIN production.Dim_Team t ON fm.Home_Team_ID = t.Team_ID
    GROUP BY t.Team_Name
    
    UNION ALL
    
    -- Calculate goals scored by away teams
    SELECT
        t.Team_Name,
        SUM(fm.Full_Time_Away_Goals) AS goals_scored
    FROM production.Fact_Match fm
    JOIN production.Dim_Team t ON fm.Away_Team_ID = t.Team_ID
    GROUP BY t.Team_Name
)
SELECT
    Team_Name,
    SUM(goals_scored) AS total_goals_scored
FROM team_goals
GROUP BY Team_Name
ORDER BY total_goals_scored DESC
LIMIT 10;


-- Query 7: EDA - Home vs. Away Win Percentage
-- Description: Calculates the percentage of matches won by the home team, away team, or resulted in a draw.
SELECT
    Full_Time_Result,
    COUNT(*) AS number_of_matches,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM production.Fact_Match)) AS percentage
FROM
    production.Fact_Match
GROUP BY
    Full_Time_Result
ORDER BY
    Full_Time_Result;

-- End of Script

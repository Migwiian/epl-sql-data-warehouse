CREATE OR REPLACE VIEW production.vw_powerbi_match_data AS
WITH MatchData AS (
    SELECT
        fm.Date_ID,
        fm.Home_Team_ID,
        fm.Away_Team_ID,
        fm.Full_Time_Home_Goals,
        fm.Full_Time_Away_Goals,
        fm.Full_Time_Result,
        (fm.Full_Time_Home_Goals + fm.Full_Time_Away_Goals) AS Total_Goals,
        (fm.Full_Time_Home_Goals - fm.Full_Time_Away_Goals) AS Goal_Difference
    FROM
        production.Fact_Match fm
)
SELECT
    dd.Date_ID,
    dd.Year,
    dd.Month,
    dd.Day,
    dd.Day_Of_Week,
    dd.Day_Name,
    dd.Month_Name,
    dd.Quarter,
    dd.Week_Of_Year,
    dd.Is_Weekend,
    dd.Season,
    ht.Team_Name AS Home_Team_Name,
    at.Team_Name AS Away_Team_Name,
    md.Full_Time_Home_Goals,
    md.Full_Time_Away_Goals,
    md.Full_Time_Result,
    md.Total_Goals,
    md.Goal_Difference
FROM
    MatchData md
JOIN
    production.Dim_Date dd ON md.Date_ID = dd.Date_ID
JOIN
    production.Dim_Team ht ON md.Home_Team_ID = ht.Team_ID
JOIN
    production.Dim_Team at ON md.Away_Team_ID = at.Team_ID;
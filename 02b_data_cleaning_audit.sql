-- ==========================================
-- STEP 2b: DATA CLEANING AUDIT
-- ==========================================

SET search_path TO staging;

-- 1. Null Value Check: Core Data Completeness
SELECT 'Missing Critical Data' AS audit_type,
       COUNT(*) AS issue_count,
       'Rows missing Date, HomeTeam, or AwayTeam' AS description
FROM raw_match_data
WHERE "date" IS NULL 
   OR "hometeam" IS NULL 
   OR "awayteam" IS NULL;

-- 2. Outlier Detection: Score Anomalies
SELECT 'Score Outliers' AS audit_type,
       COUNT(*) AS issue_count,
       'Matches where a team scored > 15 goals' AS description
FROM raw_match_data
WHERE "fthg" > 15 OR "ftag" > 15;

-- 3. String Consistency: Whitespace and Case Validation
SELECT 'Suspect Team Names' AS audit_type,
       COUNT(*) AS issue_count,
       'Teams with leading/trailing whitespace or mixed case' AS description
FROM (
    SELECT DISTINCT "hometeam" FROM raw_match_data
    UNION
    SELECT DISTINCT "awayteam" FROM raw_match_data
) teams
WHERE "hometeam" != trim("hometeam");

-- 4. Date Range Validation: Temporal Integrity
SELECT 'Date Anomalies' AS audit_type,
       COUNT(*) AS issue_count,
       'Dates before 2010 or after 2030' AS description
FROM raw_match_data
WHERE "date" < '2010-01-01' OR "date" > '2030-01-01';

-- 5. Logical Integrity: Result vs Score Validation
SELECT 'Logic Violations' AS audit_type,
       COUNT(*) AS issue_count,
       'Results (H/D/A) that do not match the actual score' AS description
FROM raw_match_data
WHERE 
   ("ftr" = 'H' AND NOT ("fthg" > "ftag")) OR
   ("ftr" = 'A' AND NOT ("fthg" < "ftag")) OR
   ("ftr" = 'D' AND NOT ("fthg" = "ftag"));

-- 6. Detailed Output: Logical Integrity Issues
SELECT "date", "hometeam", "awayteam", "fthg", "ftag", "ftr" 
FROM raw_match_data
WHERE 
   ("ftr" = 'H' AND NOT ("fthg" > "ftag")) OR
   ("ftr" = 'A' AND NOT ("fthg" < "ftag")) OR
   ("ftr" = 'D' AND NOT ("fthg" = "ftag"))
ORDER BY "date" DESC
LIMIT 10;

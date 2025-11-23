ALTER TABLE total_charges
MODIFY COLUMN online_backup VARCHAR(100);

LOAD DATA INFILE '/var/lib/mysql-files/Telco-Customer-Churn.csv'
INTO TABLE raw_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE raw_customers;


USE telco;

LOAD DATA INFILE '/var/lib/mysql-files/Telco-Customer-Churn.csv'
INTO TABLE raw_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @customer_id_var, @gender, @senior_citizen, @partner, @dependents, 
    @tenure, @phone_service, @multiple_lines, @internet_service, 
    @online_security, @online_backup, @device_protection, @tech_support, 
    @streaming_tv, @streaming_movies, @contract, @paperless_billing, 
    @payment_method, @monthly_charges, @total_charges_var, @churn
)
SET
    customer_id = @customer_id_var, 
    gender = @gender,
    senior_citizen = @senior_citizen,
    partner = @partner,
    dependents = @dependents,
    tenure = @tenure,
    phone_service = @phone_service,
    multiple_lines = @multiple_lines,
    internet_service = @internet_service,
    online_security = @online_security,
    online_backup = @online_backup,
    device_protection = @device_protection,
    tech_support = @tech_support,
    streaming_tv = @streaming_tv,
    streaming_movies = @streaming_movies,
    contract = @contract,
    paperless_billing = @paperless_billing,
    payment_method = @payment_method,
    monthly_charges = @monthly_charges,
    churn = @churn,
    total_charges = IF(@total_charges_var = ' ' OR @total_charges_var = '', 0, @total_charges_var);
    
UPDATE raw_customers
SET
    partner = CASE WHEN partner = 'Yes' THEN 1 ELSE 0 END,
    dependents = CASE WHEN dependents = 'Yes' THEN 1 ELSE 0 END,
    phone_service = CASE WHEN phone_service = 'Yes' THEN 1 ELSE 0 END,
    paperless_billing = CASE WHEN paperless_billing = 'Yes' THEN 1 ELSE 0 END,
    churn = CASE WHEN churn = 'Yes' THEN 1 ELSE 0 END;
UPDATE raw_customers
SET gender = CASE WHEN gender = 'Female' THEN 1 ELSE 0 END;
ALTER TABLE raw_customers
    MODIFY COLUMN partner TINYINT(1),
    MODIFY COLUMN dependents TINYINT(1),
    MODIFY COLUMN phone_service TINYINT(1),
    MODIFY COLUMN paperless_billing TINYINT(1),
    MODIFY COLUMN churn TINYINT(1),
    MODIFY COLUMN gender TINYINT(1);
CREATE TABLE telco_clean AS
SELECT *
FROM raw_customers;
DROP TABLE telco_clean;

USE telco;

UPDATE raw_customers
SET multiple_lines = CASE
    WHEN multiple_lines = 'Yes' THEN 1
    ELSE 0
END;

UPDATE raw_customers
SET
    online_security   = CASE WHEN online_security = 'Yes' THEN 1 ELSE 0 END,
    online_backup     = CASE WHEN online_backup = 'Yes' THEN 1 ELSE 0 END,
    device_protection = CASE WHEN device_protection = 'Yes' THEN 1 ELSE 0 END,
    tech_support      = CASE WHEN tech_support = 'Yes' THEN 1 ELSE 0 END,
    streaming_tv      = CASE WHEN streaming_tv = 'Yes' THEN 1 ELSE 0 END,
    streaming_movies  = CASE WHEN streaming_movies = 'Yes' THEN 1 ELSE 0 END;
ALTER TABLE raw_customers
    MODIFY COLUMN multiple_lines TINYINT(1),
    MODIFY COLUMN online_security TINYINT(1),
    MODIFY COLUMN online_backup TINYINT(1),
    MODIFY COLUMN device_protection TINYINT(1),
    MODIFY COLUMN tech_support TINYINT(1),
    MODIFY COLUMN streaming_tv TINYINT(1),
    MODIFY COLUMN streaming_movies TINYINT(1);

CREATE TABLE telco_clean AS
SELECT *
FROM raw_customers;
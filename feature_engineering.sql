USE telco;

SELECT *
FROM telco_clean
LIMIT 5;

SELECT DISTINCT internet_service
FROM telco_clean;

ALTER TABLE telco_clean
ADD Contract_Month_to_month TINYINT(1) DEFAULT 0,
ADD Contract_One_year TINYINT(1) DEFAULT 0,
ADD Contract_Two_year TINYINT(1) DEFAULT 0;

UPDATE telco_clean
SET
    Contract_Month_to_month = CASE WHEN contract = 'Month-to-month' THEN 1 ELSE 0 END,
    Contract_One_year = CASE WHEN contract = 'One year' THEN 1 ELSE 0 END,
    Contract_Two_year = CASE WHEN contract = 'Two year' THEN 1 ELSE 0 END;
    
ALTER TABLE telco_clean
ADD Internet_DSL TINYINT(1) DEFAULT 0,
ADD Internet_Fiber_optic TINYINT(1) DEFAULT 0,
ADD Internet_No TINYINT(1) DEFAULT 0;

UPDATE telco_clean
SET
    Internet_DSL = CASE WHEN internet_service = 'DSL' THEN 1 ELSE 0 END,
    Internet_Fiber_optic = CASE WHEN internet_service = 'Fiber optic' THEN 1 ELSE 0 END,
    Internet_No = CASE WHEN internet_service = 'No' THEN 1 ELSE 0 END;
    

ALTER TABLE telco_clean
ADD Payment_Electronic_check TINYINT(1) DEFAULT 0,
ADD Payment_Mailed_check TINYINT(1) DEFAULT 0,
ADD Payment_Bank_transfer TINYINT(1) DEFAULT 0,
ADD Payment_Credit_card TINYINT(1) DEFAULT 0;


UPDATE telco_clean
SET
    Payment_Electronic_check = CASE WHEN payment_method = 'Electronic check' THEN 1 ELSE 0 END,
    Payment_Mailed_check = CASE WHEN payment_method = 'Mailed check' THEN 1 ELSE 0 END,
    Payment_Bank_transfer = CASE WHEN payment_method = 'Bank transfer (automatic)' THEN 1 ELSE 0 END,
    Payment_Credit_card = CASE WHEN payment_method = 'Credit card (automatic)' THEN 1 ELSE 0 END;
    
ALTER TABLE telco_clean
DROP COLUMN internet_service,
DROP COLUMN contract,
DROP COLUMN payment_method;
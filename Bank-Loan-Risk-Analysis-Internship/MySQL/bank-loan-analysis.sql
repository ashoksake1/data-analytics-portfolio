/* BANK LOAN ANALYTICS - MYSQL PROJECT */
-------------------------------------------------------------
# CREATE DATABASE 
create database bank_analytics_project;
use bank_analytics_project;

# CREATE TABLE AND INSERT DATASET INTO THAT TABLE
CREATE TABLE bank (
State_Abbr VARCHAR(20),
Account_ID VARCHAR(50),
Age VARCHAR(20),
BH_Name VARCHAR(100),
Bank_Name VARCHAR(100),
Branch_Name VARCHAR(100),
Caste VARCHAR(50),
Center_Id VARCHAR(50),
City VARCHAR(100),
Client_id VARCHAR(50),
Client_Name VARCHAR(100),
Close_Client VARCHAR(50),
Closed_Date VARCHAR(50),
Credit_Officer_Name VARCHAR(100),
Disb_By VARCHAR(100),
Disbursement_Date VARCHAR(50),
Disbursement_Date_Years VARCHAR(20),
Gender_ID VARCHAR(20),
Home_Ownership VARCHAR(50),
Loan_Status VARCHAR(50),
Loan_Transfer_date VARCHAR(50),
Next_Meeting_Date VARCHAR(50),
Product_Code VARCHAR(50),
Grade VARCHAR(20),
Sub_Grade VARCHAR(20),
Product_Id VARCHAR(50),
Purpose_Category VARCHAR(100),
Region_Name VARCHAR(100),
Religion VARCHAR(50),
Verification_Status VARCHAR(50),
State_Abbr_1 VARCHAR(20),
State_Name VARCHAR(100),
Tranfer_Logic VARCHAR(50),
Is_Delinquent_Loan VARCHAR(50),
Is_Default_Loan VARCHAR(50),
Delinq_2_Yrs INT,
Application_Type VARCHAR(50),
Loan_Amount DECIMAL(12,2),
Funded_Amount DECIMAL(12,2),
Funded_Amount_Inv DECIMAL(12,2),
Term VARCHAR(50),
Int_Rate DECIMAL(5,2),
Total_Pymnt DECIMAL(12,2),
Total_Pymnt_inv DECIMAL(12,2),
Total_Rec_Prncp DECIMAL(12,2),
Total_Fees DECIMAL(12,2),
Total_Rrec_int DECIMAL(12,2),
Total_Rec_Late_fee DECIMAL(12,2),
Recoveries DECIMAL(12,2),
Collection_Recovery_fee DECIMAL(12,2)
);

# LOAD CSV DATA FILE
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/bda1.csv'
INTO TABLE bank
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM bank;

# CHANGE / UPDATE disbursement_date COLUMN DATA TYPE FROM VARCHAR TO DATE
SET SQL_SAFE_UPDATES = 0;

UPDATE bank 
SET 
    disbursement_date = NULL
WHERE
    disbursement_date = '';

UPDATE bank 
SET 
    disbursement_date = STR_TO_DATE(disbursement_date, '%m/%d/%Y')
WHERE
    disbursement_date <> ''
        AND disbursement_date IS NOT NULL;

SELECT DISTINCT
    (YEAR(disbursement_date))
FROM
    bank;

# CHANGE / UPDATE next_meeting_date COLUMN DATA TYPE FROM VARCHAR TO DATE
UPDATE bank 
SET 
    next_meeting_date = NULL
WHERE
    next_meeting_date = '';

UPDATE bank 
SET 
    next_meeting_date = STR_TO_DATE(next_meeting_date, '%m/%d/%Y')
WHERE
    next_meeting_date IS NOT NULL;

SELECT DISTINCT
    (YEAR(Next_Meeting_Date))
FROM
    bank;

# CHANGE / UPDATE closed_date COLUMN DATA TYPE FROM VARCHAR TO DATE
UPDATE bank 
SET 
    closed_date = NULL
WHERE
    closed_date = '';

UPDATE bank 
SET 
    closed_date = STR_TO_DATE(closed_date, '%m/%d/%Y')
WHERE
    closed_date <> ''
        AND closed_date IS NOT NULL;

SELECT DISTINCT
    (YEAR(closed_date))
FROM
    bank;
    
-----------

# TOTAL LOAN AMOUNT
Create view Total_Loan_Amount as
SELECT 
    CONCAT(FORMAT(SUM(funded_amount) / 1000000, 2),
            ' M') AS Funded_Amount
FROM
    bank;
    
# TOTAL LOANS
Create view Total_Loans as
SELECT 
    CONCAT(FORMAT(COUNT(account_id) / 100000,
                2),
            ' L') AS Total_Loans
FROM
    bank;

# TOTAL UNIQUE LOAN IDs
Create view Unique_Account_Ids as
SELECT 
    CONCAT(FORMAT(COUNT(DISTINCT account_id) / 1000,
                2),
            ' K') AS Total_Loans
FROM
    bank
WHERE
    account_id <> 'unknown';
    
# TOTAL NO OF MISSING LOAN IDs
Create view Missing_Account_Ids as
SELECT 
    CONCAT(FORMAT(COUNT(ACCOUNT_ID) / 1000, 2),
            ' K') AS Missing_ID_Count
FROM
    bank
WHERE
    account_id = 'unknown';
    
# TOTAL COLLECTI0N 
Create view Total_Collection as
SELECT 
    CONCAT(FORMAT(SUM(total_pymnt) / 1000000, 2),
            ' M') AS Total_Collection
FROM
    bank;

# TOTAL INTEREST AMOUNT
Create view Total_Interest_Amount as
SELECT 
    concat(format(SUM(Total_Rrec_int)/1000000,2)," M") AS Total_Interest_Amount
FROM
    bank;

# TOTAL REVENUE
Create view Total_Revenue as
SELECT 
    CONCAT(FORMAT(SUM(total_fees + Total_Rrec_int + Total_Rec_Late_fee + recoveries + Collection_Recovery_fee) / 1000000,
                2),
            ' M') AS Total_Revenue
FROM
    bank;

# AVERAGE INTEREST RATE
Create view Average_Interest_Rate as
SELECT 
    CONCAT(ROUND(AVG(Int_rate) * 100, 2), '%') `Average_Interest_Rate`
FROM
    bank;

# DEFAULT LOANS RATE
Create view Default_Loans_Rate as
SELECT 
    CONCAT(ROUND(SUM(CASE
                        WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
                        ELSE 0
                    END) / count( loan_status ) * 100,
                    2),
            '%') as Default_Loan_Rate
FROM
    bank;

# TOTAL DEFAULT CLIENTS
Create view Total_Default_Clients as
SELECT 
    COUNT(client_id) AS Total_Default_Clients
FROM
    bank
WHERE
    loan_status IN ('write off' , 'npa', 'net-off')
        AND client_id <> 'unknown';
        
# TOTAL DELINQUENT CLIENTS
Create view Total_Delinquent_Clients as
SELECT 
    COUNT(client_id) AS Total_Delinquent_Clients
FROM
    bank
WHERE
    Is_Delinquent_Loan = 'Y'
        AND client_id <> 'unknown';

# DELINQUENT LOAN RATE
Create view Delinquent_Loan_Rate as
SELECT 
    CONCAT(ROUND(SUM(CASE
                        WHEN Is_Delinquent_Loan = 'y' THEN 1
                        ELSE 0
                    END) / COUNT(*) * 100,
                    2),
            '%') AS Delinquent_Loans_Rate
FROM
    bank;

# BRANCH-WISE REVENUE
Create view branch_wise_revenue as
WITH
branch AS (
SELECT Branch_Name,
	SUM(total_fees + Total_Rrec_int + Total_Rec_Late_fee + recoveries + Collection_Recovery_fee) AS Ttl_Revenue
FROM
	bank
group by
	branch_name
order by
	Ttl_Revenue desc
)

select branch_name,
	case
		when Ttl_Revenue >=1000000 then concat(format(Ttl_Revenue/1000000,2)," M")
		WHEN Ttl_Revenue >=100000 then concat(format(Ttl_Revenue/100000,2),' L')
		when Ttl_Revenue >=1000 THEN concat(format(Ttl_Revenue/1000,2),' K')
		else Ttl_Revenue
	end as Total_Revenue
from
	branch
where
	branch_name <> 'unknown';
    
# STATE-WISE LOANS
Create view state_wise_loans as
WITH
	State as (
SELECT 
    state_name, COUNT(account_id) AS Total_Loans
FROM
    bank
WHERE
    state_name <> 'unknown'
GROUP BY state_name
ORDER BY total_loans DESC
)

SELECT
	state_name,
	CASE
		WHEN total_loans >=1000 then concat(format(total_loans/1000,2),' K')
        ELSE total_loans
	END as Total_Loans
FROM
	state;

# STATE-WISE DEFAULT RATE
Create view State_wise_default_rate as
SELECT 
    State_name,
    COUNT(Account_ID) AS Total_Loans,
    SUM(CASE
        WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
        ELSE 0
    END) AS Default_Loans,
    CONCAT(ROUND(SUM(CASE
                        WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
                        ELSE 0
                    END) * 100.0 / COUNT(Account_ID),
                    2),
            ' %') AS Default_Rate_Percentage
FROM
    bank
WHERE
    State_name NOT IN ( 'unknown', 'State Name')
GROUP BY State_name
ORDER BY ROUND(SUM(CASE
            WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
            ELSE 0
        END) * 100.0 / COUNT(*),
        2) DESC;
        
# STATE-WISE DELINQUENT RATE
CREATE VIEW State_wise_Delinquent_rate AS
    SELECT 
        State_name,
        COUNT(Account_ID) AS Total_Loans,
        SUM(CASE
            WHEN IS_DELINQUENT_LOAN = 'Y' THEN 1
            ELSE 0
        END) AS Delinquent_Loans,
        CONCAT(ROUND(SUM(CASE
                            WHEN IS_DELINQUENT_LOAN = 'Y' THEN 1
                            ELSE 0
                        END) * 100.0 / COUNT(*),
                        2),
                ' %') AS Delinquent_Rate
    FROM
        bank
    GROUP BY State_name
    ORDER BY ROUND(SUM(CASE
                WHEN IS_DELINQUENT_LOAN = 'Y' THEN 1
                ELSE 0
            END) * 100.0 / COUNT(*),
            2) DESC;
    
# PURPOSE CATEGORY-WISE LOAN AMOUNT
Create view Category_wise_loan_amount as
WITH
Caterogy as (
SELECT 
    Purpose_Category, SUM(funded_amount) AS Loan_Amount
FROM
    bank
WHERE
	purpose_category <> 'unknown'
GROUP BY Purpose_Category
ORDER BY Loan_Amount DESC
)

SELECT 
	purpose_category,
    case
		WHEN loan_amount >= 1000000 THEN concat(format(loan_amount/1000000,2),' M')
        WHEN loan_amount >= 100000 THEN concat(format(loan_amount/100000,2),' L')
        WHEN loan_amount >= 1000 THEN concat(format(loan_amount/1000,2),' K')
        ELSE loan_amount
	END as Loan_Amount
FROM
	caterogy;
    
# DISBURSEMENT TREND
Create view Disbursement_trend as
WITH 
Trend as 
(SELECT 
    YEAR(Disbursement_Date) AS Year,
    QUARTER(Disbursement_Date) AS Quarter,
    MONTH(Disbursement_Date) AS Month_No,
    MONTHNAME(Disbursement_Date) AS Month,
    SUM(funded_amount) AS Loan_Amount
FROM
    bank
WHERE
    Disbursement_Date IS NOT NULL
GROUP BY Year , Quarter , Month_No , Month
ORDER BY Year , Quarter , Month_No , Month ASC
)

SELECT
	YEAR,
    Concat('Qtr-',QUARTER) as Quarter,
	CASE 
		WHEN sum(Loan_amount) >=1000000 THEN concat(format(sum(loan_amount)/1000000,2),' M')
        WHEN sum(Loan_amount) >=100000 THEN concat(format(sum(loan_amount)/100000,2),' L')
        WHEN sum(loan_amount) >=1000 THEN concat(format(sum(loan_amount)/1000,2),' K')
        ELSE sum(Loan_amount)
	END As Loan_Amount
FROM Trend
group by Year, Quarter;

# GRADE-WISE LOANS
Create view grade_wise_loans as
SELECT 
    Grade, COUNT(account_id) AS Total_Loans
FROM
    bank
WHERE
    grade <> 'unknown'
GROUP BY grade order by Total_loans desc;

# AGE-GROUP DEFAULT LOANS
Create view age_group_wise_default_loans as
SELECT 
    *
FROM
    (SELECT 
        Age,
            SUM(CASE
                WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
                ELSE 0
            END) AS Default_Loans
    FROM
        bank
    GROUP BY age
    ORDER BY Default_Loans DESC) age
WHERE
    default_loans > 0;

# LOAN STATUS-WISE DISTRIBUTION
Create view loan_status_wise_distribution as
SELECT 
    Loan_status,
    CONCAT(ROUND(COUNT(account_id) * 100.0 / (SELECT 
                    COUNT(account_id)
                FROM
                    Bank
                WHERE
                    Loan_status <> 'unknown'),
            2),'%') AS Loan_Percentage
FROM
    Bank
WHERE
    Loan_status <> 'unknown'
GROUP BY Loan_status
ORDER BY COUNT(account_id) * 100.0 / (SELECT 
                    COUNT(account_id)
                FROM
                    Bank
                WHERE
                    Loan_status <> 'unknown') DESC;

# LOAN STATUS-WISE TOTAL LOANS
Create view loan_status_wise_total_loans as
SELECT 
    Loan_status, COUNT(account_id) AS Total_Loans
FROM
    bank
WHERE
    loan_status <> 'unknown'
GROUP BY Loan_Status
ORDER BY Total_Loans DESC;

# VERIFICATION STATUS-WISE LOANS
Create view verification_status_wise_loans as
SELECT 
    Verification_Status,
    CONCAT(FORMAT(COUNT(account_id) / 1000, 2),
            ' K') AS Total_Loans
FROM
    bank
WHERE
    Verification_Status <> 'Unknown'
GROUP BY Verification_Status;

-------------------------------------------------------------
# VIEW

select * from total_loans;
select * from total_loan_amount;
select * from total_collection;
select * from total_revenue;
select * from total_interest_amount;
select * from average_interest_rate;
select * from total_delinquent_clients;
select * from delinquent_loan_rate;
select * from total_default_clients;
select * from default_loan_rate;
select * from state_wise_loans;
select * from state_wise_default_rate;
select * from State_wise_Delinquent_rate;
select * from branch_wise_revenue;
select * from category_wise_loan_amount;
select * from loan_status_wise_total_loans;
select * from loan_status_wise_distribution;
select * from grade_wise_loans;
select * from age_group_wise_default_loans;
select * from disbursement_trend;
select * from verification_status_wise_loans;

-------------------------------------------------------------
# STORED PROCEDURE

Delimiter $$
CREATE PROCEDURE `State Info`(IN `STATE NAME` varchar(50))
BEGIN
SELECT 
    state_name AS `State Name`,
    COUNT(account_id) AS `Total Loans`,
    CONCAT(FORMAT(SUM(FUNDED_AMOUNT) / 1000000, 2),
            'M') AS `Total Loan Amount`,
    CONCAT(FORMAT(SUM(total_pymnt) / 1000000, 2),
            ' M') AS `Total Collection`,
    CONCAT(FORMAT(SUM(total_fees + Total_Rrec_int + Total_Rec_Late_fee + recoveries + Collection_Recovery_fee) / 1000000,
                2),
            ' M') AS `Total Revenue`,
    CONCAT(ROUND(AVG(int_rate) * 100, 2), '%') AS `Average Interest Rate`,
    CONCAT(ROUND(SUM(CASE
                        WHEN loan_status IN ('write off' , 'npa', 'net-off') THEN 1
                        ELSE 0
                    END) / COUNT(*) * 100,
                    2),
            '%') AS `Default Loan Rate`,
    CONCAT(ROUND(SUM(CASE
                        WHEN is_delinquent_loan = 'y' THEN 1
                        ELSE 0
                    END) / COUNT(*) * 100,
                    2),
            '%') AS `Delinquent Loan Rate`
FROM
    bank
WHERE
    STATE_NAME = `STATE NAME`
GROUP BY state_name;
END $$
Delimiter ;

call bank_analytics_project.`State Info`('Assam');



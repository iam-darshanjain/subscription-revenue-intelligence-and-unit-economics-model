SELECT COUNT(*) AS raw_row_count
FROM telco_raw;


--cretaing cleaned table with proper dtypes
DROP TABLE IF EXISTS telco;

CREATE TABLE telco AS 
SELECT 
	customerID,
	gender,
	SeniorCitizen::INT AS SeniorCitizen,
	Partner,
	Dependents,
	tenure::INT AS tenure,
	PhoneService,
	MultipleLines,
	InternetService,
	OnlineSecurity,
	OnlineBackup,
	DeviceProtection,
	TechSupport,
	StreamingTV,
	StreamingMovies,
	Contract,
	PaperlessBilling,
	PaymentMethod,
	MonthlyCharges::NUMERIC AS MonthlyCharges,
	NULLIF(TRIM(TotalCharges), '')::NUMERIC AS TotalCharges,
	Churn
FROM telco_raw;

--Removing Invalid Records
DELETE FROM telco
WHERE TotalCharges IS NULL;

SELECT COUNT(*) AS cleaned_rows FROM telco;

--Tenure Range

SELECT MIN(tenure) as min_tenure, MAX(tenure) as max_tenure
FROM telco;
--(1,72)


--MonthlyCharges Range
SELECT MIN(MonthlyCharges) as min_monthly_charge, MAX(MonthlyCharges) as max_monthly_charge
FROM telco
--(18.25,118.75)

--Churn Distribution
SELECT Churn, COUNT(*) AS customer_count,
	ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),2) as percentage
FROM telco
GROUP BY Churn;
--Churned Customer: 1869(26.58), Not Churned: 5163(73.42)


--Check if MonthlyCharges*tenure = TotalCharges
SELECT *
FROM telco
WHERE ROUND(MonthlyCharges*tenure,2) <> TotalCharges
LIMIT 20;

WITH subscription_base AS (
SELECT customerid, tenure, churn,
	DATE '2017-01-01' - (tenure::text || ' months')::interval as start_date, monthlycharges,
	generate_series(1, tenure) as month_number
FROM telco
),
subscription_lifecycle as (
select customerid, churn, start_date + ((month_number - 1)::text || ' months')::interval as active_month, monthlycharges
from subscription_base
),
subscription_events as (
SELECT customerid, active_month, monthlycharges, churn,
	MAX(active_month) OVER (PARTITION BY customerid) as last_active_month,
	CASE
		WHEN churn = 'Yes'
	   		AND active_month = MAX(active_month) OVER (PARTITION BY customerid)
		THEN 1
		ELSE 0
	END AS churn_event
FROM subscription_lifecycle
), 
churn_cte AS (
SELECT
    active_month,
    COUNT(DISTINCT customerid) AS active_customers,
    SUM(churn_event) AS churned_customers,
    SUM(churn_event)::numeric / COUNT(DISTINCT customerid) AS churn_rate
FROM subscription_events
GROUP BY active_month
ORDER BY active_month
)
SELECT * FROM churn_cte;
--Monthly churn trend Not realistic due to snapshot limitation.
--the dataset is a snapshot, churn timing is not recorded. lifecycle reconstruction was done 
--using tenure and assumed churn occurred at the snapshot boundary.
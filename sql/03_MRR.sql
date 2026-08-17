--assuming snapshot_date to be 2021-01-01
--
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
mrr_cte AS (
SELECT
    active_month,
    COUNT(DISTINCT customerid) AS active_customers,
    SUM(monthlycharges) AS mrr
FROM subscription_events
GROUP BY active_month
ORDER BY active_month
)
SELECT * FROM mrr_cte;
WITH subscription_base AS (
SELECT customerid, tenure, churn,
	DATE '2017-01-01' - (tenure::text || ' months')::interval as start_date, monthlycharges,
	generate_series(1, tenure) as month_number
FROM telco
),
subscription_lifecycle as (
select customerid, churn, start_date, start_date + ((month_number - 1)::text || ' months')::interval as active_month,
	monthlycharges
from subscription_base
),
cohort_base AS (
	SELECT
    	customerid,
    	DATE_TRUNC('month', start_date) AS cohort_month,
    	active_month
	FROM subscription_lifecycle
)
,
cohort_activity AS (
SELECT
    cohort_month,
     (EXTRACT(YEAR FROM AGE(active_month, cohort_month))*12) + EXTRACT(MONTH FROM AGE(active_month, cohort_month))
	 		AS months_since_cohort,
    COUNT(DISTINCT customerid) AS active_customers
FROM cohort_base
GROUP BY cohort_month, months_since_cohort
ORDER BY cohort_month, months_since_cohort
),
cohort_size AS (
    SELECT
        cohort_month,
        active_customers AS cohort_size
    FROM cohort_activity
    WHERE months_since_cohort = 0
),
retention as (
SELECT
    ca.cohort_month,
    ca.months_since_cohort,
    ca.active_customers,
    cs.cohort_size,
    ca.active_customers*1.0 / cs.cohort_size AS retention_rate
FROM cohort_activity ca
JOIN cohort_size cs
ON ca.cohort_month = cs.cohort_month
ORDER BY ca.cohort_month, ca.months_since_cohort
)
SELECT *
FROM retention
ORDER BY cohort_month, months_since_cohort;

--retention rate never drops because this dataset is a snapshot, the reconstructed using tenure
--Thus the retention rate is flat until the churned month

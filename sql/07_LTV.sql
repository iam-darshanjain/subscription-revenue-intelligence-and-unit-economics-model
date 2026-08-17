WITH base_ltv as (SELECT customerid,
	tenure,
	monthlycharges,
	monthlycharges*tenure AS ltv
FROM telco
),
ltv_maths as (
SELECT MAX(ltv) as max_ltv, percentile_cont(0.5) WITHIN GROUP (ORDER BY ltv) as median_ltv, 
	ROUND(AVG(ltv),2) as avg_ltv
FROM base_ltv
)

SELECT * FROM ltv_maths
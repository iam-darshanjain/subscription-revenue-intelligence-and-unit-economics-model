WITH base_ltv AS (
    SELECT
        customerid,
        monthlycharges * tenure AS ltv
    FROM telco
),

ranked_customers AS (
    SELECT
        customerid,
        ltv,
        NTILE(10) OVER (ORDER BY ltv DESC) AS decile
    FROM base_ltv
),

decile_agg AS (
    SELECT
        decile,
        COUNT(*) AS customers,
        SUM(ltv) AS revenue
    FROM ranked_customers
    GROUP BY decile
),

final AS (
    SELECT
        decile,
        customers,
        revenue,
        revenue * 1.0 / SUM(revenue) OVER () AS revenue_share,
        SUM(revenue) OVER (ORDER BY decile) * 1.0 / SUM(revenue) OVER () AS cumulative_revenue_share
    FROM decile_agg
)

SELECT decile, customers, revenue, ROUND(revenue_share,2) as revenue_share, ROUND(cumulative_revenue_share,2) as cumulative_revenue_share
FROM final
ORDER BY decile;
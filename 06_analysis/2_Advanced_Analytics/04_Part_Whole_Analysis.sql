/*
===============================================================================
IV. Part-to-Whole Analysis
===============================================================================
Purpose:
    Understand which category has the greatest impact on the business.
===============================================================================
*/

WITH totals_cte AS (
    SELECT
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers
    FROM gold.fact_sales
)
SELECT
    category,
    category_sales,
    SUM(category_sales) OVER () AS total_sales,
    ROUND(category_sales * 100.0 / SUM(category_sales) OVER (), 2) || '%' AS category_sales_percentage,
    category_orders,
    tc.total_orders,
    ROUND(category_orders * 100.0 / tc.total_orders, 2) || '%' AS category_frequency_orders,
    category_customers,
    tc.total_customers AS total_customers,
    ROUND(category_customers * 100.0 / tc.total_customers, 2) || '%' AS category_frequency_customers
FROM (
    SELECT
        p.category,
        SUM(sales_amount) AS category_sales,
        COUNT(DISTINCT order_number) AS category_orders,
        COUNT(DISTINCT customer_key) AS category_customers
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY p.category
) sub
CROSS JOIN totals_cte tc;

/* Result:
 category    | category_sales | total_sales | category_sales_percentage | category_orders | total_orders | category_frequency_orders | category_customers | total_customers | category_frequency_customers
-------------+----------------+-------------+---------------------------+-----------------+--------------+---------------------------+--------------------+-----------------+-----------------------------
 Accessories |         700262 |    29356250 | 2.39%                     |           18208 |        27659 | 65.83%                    |              15114 |           18484 | 81.77%
 Bikes       |       28316272 |    29356250 | 96.46%                    |           15205 |        27659 | 54.97%                    |               9132 |           18484 | 49.40%
 Clothing    |         339716 |    29356250 | 1.16%                     |            7461 |        27659 | 26.97%                    |               6852 |           18484 | 37.07%
*/
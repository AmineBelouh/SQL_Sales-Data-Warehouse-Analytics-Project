/*
===============================================================================
V. Data Segmentation
===============================================================================
    When existing dimensions are not sufficient, convert a measure into a
    dimension using CASE WHEN, then aggregate other measures by that dimension.
===============================================================================
*/

-- 1. Segment products into cost ranges
SELECT
    cost_segments,
    COUNT(product_key) AS product_count
FROM (
    SELECT
        product_key,
        cost,
        CASE
            WHEN cost < 100 THEN '< 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 501 AND 1000 THEN '501 - 1000'
            ELSE '> 1000'
        END AS cost_segments
    FROM gold.dim_products
) t
GROUP BY cost_segments;

/* Result:
 cost_segments | product_count
---------------+--------------
 > 1000        |           39
 501 - 1000    |           45
 100 - 500     |          101
 < 100         |          110
*/

-- 2. Segment customers based on customer history and total sales
WITH customer_segmentation_cte AS (
    SELECT
        customer_key,
        history,
        EXTRACT(YEAR FROM history) * 12 + EXTRACT(MONTH FROM history) AS history_months,
        total_sales,
        CASE
            WHEN EXTRACT(YEAR FROM history) * 12 + EXTRACT(MONTH FROM history) >= 12
                 AND total_sales > 5000 THEN 'VIP'
            WHEN EXTRACT(YEAR FROM history) * 12 + EXTRACT(MONTH FROM history) >= 12
                 AND total_sales <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segments
    FROM (
        SELECT
            customer_key,
            SUM(sales_amount) AS total_sales,
            MIN(order_date),
            MAX(order_date),
            AGE(MAX(order_date), MIN(order_date)) AS history
        FROM gold.fact_sales
        GROUP BY customer_key
    ) customer_history
)
SELECT
    customer_segments,
    COUNT(customer_key) AS customer_count
FROM customer_segmentation_cte
GROUP BY customer_segments;

/* Result:
 customer_segments | customer_count
-------------------+---------------
 New               |         14828
 Regular           |          2037
 VIP               |          1619
*/
/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, and Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (total sales / total_orders)
       - average monthly revenue (total_sales / lifespan)
===============================================================================
*/


DROP VIEW IF EXISTS gold.report_products;

CREATE VIEW gold.report_products AS
WITH products_base_query AS (
    SELECT
        s.order_number,
        s.customer_key,
        p.product_key,
        p.product_number,
        p.product_name,
        p.product_line,
        p.category_id,
        p.category,
        p.subcategory,
        p.maintenance,
        p.cost,
        s.order_date,
        s.price,
        s.quantity,
        s.sales_amount
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    WHERE order_date IS NOT NULL
),
aggregations_query AS (
    SELECT
        product_key,
        product_number,
        product_name,
        product_line,
        category_id,
        category,
        subcategory,
        maintenance,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS quantity_sold,
        ROUND(AVG(price), 2) AS avg_price,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
            + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan_months
    FROM products_base_query
    GROUP BY
        product_key,
        product_number,
        product_name,
        product_line,
        category_id,
        category,
        subcategory,
        maintenance,
        cost
)
SELECT
    product_key,
    product_number,
    product_name,
    product_line,
    category_id,
    category,
    subcategory,
    maintenance,
    cost,
    total_orders,
    total_customers,
    total_sales,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performers'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performers'
    END AS product_segment,
    quantity_sold,
    avg_price,
    first_order_date,
    last_order_date,
    lifespan_months,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12
        + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency_months,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_revenue,
    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan_months, 2)
    END AS avg_monthly_revenue
FROM aggregations_query;


-- Preview the product report

SELECT *
FROM gold.report_products;

/*
Sample Result (first 10 rows):
 product_key | product_number | product_name             | product_line | category_id | category | subcategory   | maintenance | cost | total_orders | total_customers | total_sales | product_segment  | quantity_sold | avg_price | first_order_date | last_order_date | lifespan_months | recency_months | avg_order_revenue | avg_monthly_revenue
-------------+----------------+--------------------------+--------------+-------------+----------+---------------+-------------+------+--------------+-----------------+-------------+------------------+---------------+-----------+------------------+-----------------+-----------------+----------------+-------------------+--------------------
           3 | BK-M82B-38     | Mountain-100 Black- 38   | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1898 |           49 |              49 |      165375 | High-Performers  |            49 |   3375.00 | 2011-01-25       | 2011-12-27      |              11 |            178 |           3375.00 |           15034.09
           4 | BK-M82B-42     | Mountain-100 Black- 42   | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1898 |           45 |              45 |      151875 | High-Performers  |            45 |   3375.00 | 2011-01-26       | 2011-12-27      |              11 |            178 |           3375.00 |           13806.82
           5 | BK-M82B-44     | Mountain-100 Black- 44   | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1898 |           60 |              60 |      202500 | High-Performers  |            60 |   3375.00 | 2011-01-06       | 2011-12-21      |              11 |            178 |           3375.00 |           18409.09
           6 | BK-M82B-48     | Mountain-100 Black- 48   | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1898 |           57 |              57 |      192375 | High-Performers  |            57 |   3375.00 | 2010-12-30       | 2011-12-26      |              11 |            178 |           3375.00 |           17488.64
           7 | BK-M82S-38     | Mountain-100 Silver- 38  | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1912 |           58 |              58 |      197200 | High-Performers  |            58 |   3400.00 | 2010-12-30       | 2011-12-22      |              11 |            178 |           3400.00 |           17927.27
           8 | BK-M82S-42     | Mountain-100 Silver- 42  | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1912 |           42 |              42 |      142800 | High-Performers  |            42 |   3400.00 | 2011-01-17       | 2011-12-28      |              11 |            178 |           3400.00 |           12981.82
           9 | BK-M82S-44     | Mountain-100 Silver- 44  | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1912 |           49 |              49 |      166600 | High-Performers  |            49 |   3400.00 | 2010-12-29       | 2011-12-12      |              11 |            178 |           3400.00 |           15145.45
          10 | BK-M82S-48     | Mountain-100 Silver- 48  | Mountain     | BI_MB       | Bikes    | Mountain Bikes| Yes         | 1912 |           36 |              36 |      122400 | High-Performers  |            36 |   3400.00 | 2011-01-09       | 2011-12-23      |              11 |            178 |           3400.00 |           11127.27
          16 | BK-R93R-44     | Road-150 Red- 44         | Road         | BI_RB       | Bikes    | Road Bikes    | Yes         | 2171 |          281 |             281 |     1005418 | High-Performers  |           281 |   3578.00 | 2010-12-30       | 2011-12-28      |              11 |            178 |           3578.00 |           91401.64
          17 | BK-R93R-48     | Road-150 Red- 48         | Road         | BI_RB       | Bikes    | Road Bikes    | Yes         | 2171 |          337 |             337 |     1205786 | High-Performers  |           337 |   3578.00 | 2010-12-31       | 2011-12-28      |              11 |            178 |           3578.00 |          109616.91
*/

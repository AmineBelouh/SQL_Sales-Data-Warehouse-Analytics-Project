/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total products 
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value (total sales / total orders)
        - average monthly spend (total sales / lifespan)
===============================================================================
*/

DROP VIEW IF EXISTS gold.report_customers;

CREATE VIEW gold.report_customers AS
WITH customer_base_query AS (
    SELECT
        s.order_number,
        s.product_key,
        c.customer_key,
        c.customer_number,
        c.first_name || ' ' || c.last_name AS full_name,
        c.gender,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthdate)) AS age,
        c.country,
        c.marital_status,
        s.order_date,
        s.sales_amount
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_customers c
        ON s.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
),
aggregations_query AS (
    SELECT
        customer_key,
        customer_number,
        full_name,
        gender,
        age,
        country,
        marital_status,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT product_key) AS total_products,
        SUM(sales_amount) AS total_sales,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
            + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan_months
    FROM customer_base_query
    GROUP BY
        customer_key,
        customer_number,
        full_name,
        gender,
        age,
        country,
        marital_status
)
SELECT
    customer_key,
    customer_number,
    full_name,
    gender,
    age,
    CASE
        WHEN age < 50 THEN 'Below 50'
        WHEN age BETWEEN 50 AND 59 THEN '50-59'
        WHEN age BETWEEN 60 AND 69 THEN '60-69'
        WHEN age BETWEEN 70 AND 79 THEN '70-79'
        ELSE 'Above 80'
    END AS age_group,
    country,
    marital_status,
    total_orders,
    total_products,
    total_sales,
    first_order_date,
    last_order_date,
    lifespan_months,
    CASE
        WHEN lifespan_months >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan_months >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order_date)) * 12
        + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order_date)) AS recency_months,
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE ROUND(total_sales / total_orders, 2)
    END AS avg_order_value,
    CASE
        WHEN lifespan_months = 0 THEN total_sales
        ELSE ROUND(total_sales / lifespan_months, 2)
    END AS avg_monthly_spending
FROM aggregations_query;


-- Preview the customer report

SELECT *
FROM gold.report_customers;

/*
Sample Result (first 10 rows):
 customer_key | customer_number | full_name           | gender | age | age_group | country   | marital_status | total_orders | total_products | total_sales | first_order_date | last_order_date | lifespan_months | customer_segment | recency_months | avg_order_value | avg_monthly_spending
--------------+-----------------+--------------------+--------+-----+-----------+-----------+----------------+--------------+----------------+-------------+------------------+-----------------+-----------------+------------------+----------------+-----------------+---------------------
            1 | AW00011000      | Jon Yang            | Male   |  55 | 50-59     | Australia | Married        |            3 |              8 |        8249 | 2011-01-19       | 2013-05-03      |              27 | VIP              |            161 |         2749.00 |              305.52
            2 | AW00011001      | Eugene Huang        | Male   |  50 | 50-59     | Australia | Single         |            3 |             10 |        6384 | 2011-01-15       | 2013-12-10      |              34 | VIP              |            154 |         2128.00 |              187.76
            3 | AW00011002      | Ruben Torres        | Male   |  55 | 50-59     | Australia | Married        |            3 |              4 |        8114 | 2011-01-07       | 2013-02-23      |              25 | VIP              |            164 |         2704.00 |              324.56
            4 | AW00011003      | Christy Zhu         | Female |  53 | 50-59     | Australia | Single         |            3 |              9 |        8139 | 2010-12-29       | 2013-05-10      |              28 | VIP              |            161 |         2713.00 |              290.68
            5 | AW00011004      | Elizabeth Johnson   | Female |  47 | Below 50  | Australia | Single         |            3 |              6 |        8196 | 2011-01-23       | 2013-05-01      |              27 | VIP              |            161 |         2732.00 |              303.56
            6 | AW00011005      | Julio Ruiz          | Male   |  50 | 50-59     | Australia | Single         |            3 |              6 |        8121 | 2010-12-30       | 2013-05-02      |              28 | VIP              |            161 |         2707.00 |              290.04
            7 | AW00011006      | Janet Alvarez       | Female |  49 | Below 50  | Australia | Single         |            3 |              5 |        8119 | 2011-01-24       | 2013-05-14      |              27 | VIP              |            161 |         2706.00 |              300.70
            8 | AW00011007      | Marco Mehta         | Male   |  56 | 50-59     | Australia | Married        |            3 |              8 |        8211 | 2011-01-09       | 2013-03-19      |              26 | VIP              |            163 |         2737.00 |              315.81
            9 | AW00011008      | Rob Verhoff         | Female |  51 | 50-59     | Australia | Single         |            3 |              7 |        8106 | 2011-01-25       | 2013-03-02      |              25 | VIP              |            163 |         2702.00 |              324.24
           10 | AW00011009      | Shannon Carlson     | Male   |  57 | 50-59     | Australia | Single         |            3 |              5 |        8091 | 2011-01-27       | 2013-05-09      |              27 | VIP              |            161 |         2697.00 |              299.67
*/
/*
===============================================================================
III. Performance Analysis
===============================================================================
Purpose:
    Compare the current value to a target value.
===============================================================================
*/

-- Analyze yearly product sales against the product average and previous year.
SELECT
    product_name,
    order_year,
    total_sales,
    ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 2) AS avg_product_sales,
    total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 2) AS diff_avg,
    CASE
        WHEN total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 2) > 0
            THEN 'Above Average'
        WHEN total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 2) < 0
            THEN 'Below Average'
        ELSE '= Average'
    END AS diff_avg_segment,
    total_sales AS current_year_sales,
    LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS yoy_analysis,
    (
        total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year)
    ) * 100
      / LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) || '%' AS prcnt_change
FROM (
    SELECT
        p.product_name,
        EXTRACT(YEAR FROM s.order_date) AS order_year,
        SUM(s.sales_amount) AS total_sales
    FROM gold.fact_sales s
    LEFT JOIN gold.dim_products p
        ON s.product_key = p.product_key
    GROUP BY
        p.product_name,
        EXTRACT(YEAR FROM s.order_date)
) t;

/* Sample Result:
 product_name           | order_year | total_sales | avg_product_sales | diff_avg | diff_avg_segment | current_year_sales | prev_year_sales | yoy_analysis | prcnt_change
------------------------+------------+-------------+-------------------+----------+------------------+--------------------+-----------------+--------------+-------------
 All-Purpose Bike Stand |       2012 |         159 |          13197.00 |   -13038 | Below Average    |                159 |                 |              |
 All-Purpose Bike Stand |       2013 |       37683 |          13197.00 |    24486 | Above Average    |              37683 |             159 |        37524 | 23600%
 All-Purpose Bike Stand |       2014 |        1749 |          13197.00 |   -11448 | Below Average    |               1749 |           37683 |       -35934 | -95%
 AWC Logo Cap           |       2012 |          72 |           6570.00 |    -6498 | Below Average    |                 72 |                 |              |
 AWC Logo Cap           |       2013 |       18891 |           6570.00 |    12321 | Above Average    |              18891 |              72 |        18819 | 26137%
 AWC Logo Cap           |       2014 |         747 |           6570.00 |    -5823 | Below Average    |                747 |           18891 |       -18144 | -96%
 Bike Wash - Dissolver  |       2013 |        6960 |           3636.00 |     3324 | Above Average    |               6960 |                 |              |
 Bike Wash - Dissolver  |       2014 |         312 |           3636.00 |    -3324 | Below Average    |                312 |            6960 |        -6648 | -95%
 Classic Vest- L        |       2013 |       11968 |           6240.00 |     5728 | Above Average    |              11968 |                 |              |
 Classic Vest- L        |       2014 |         512 |           6240.00 |    -5728 | Below Average    |                512 |           11968 |       -11456 | -95%
*/
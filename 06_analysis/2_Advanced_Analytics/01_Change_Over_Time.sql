/*
===============================================================================
I. Change Over Time
===============================================================================
Purpose:
    Analyze how a measure evolves over time.
    Helps track trends and identify seasonality in the data.
===============================================================================
*/

-- 1. Yearly sales
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

/* Result:
 year | total_sales
------+------------
 2010 |       43419
 2011 |     7075088
 2012 |     5842231
 2013 |    16344878
 2014 |       45642
*/

-- 2. Monthly sales (aggregated across all years)
SELECT
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(MONTH FROM order_date)
ORDER BY month;

/* Result:
 month | total_sales
-------+------------
     1 |     1868558
     2 |     1744517
     3 |     1908375
     4 |     1948226
     5 |     2204969
     6 |     2935883
     7 |     2412838
     8 |     2684313
     9 |     2536520
    10 |     2916550
    11 |     2979113
    12 |     3211396
*/

-- 3. Monthly sales by year
SELECT
    DATE_TRUNC('month', order_date)::DATE AS year_month,
    TO_CHAR(order_date, 'yyyy-Mon') AS year_month2,
    SUM(sales_amount) AS total_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY
    DATE_TRUNC('month', order_date),
    TO_CHAR(order_date, 'yyyy-Mon')
ORDER BY year_month;

/* Result:
 year_month | year_month2 | total_sales
------------+-------------+------------
 2010-12-01 | 2010-Dec    |       43419
 2011-01-01 | 2011-Jan    |      469795
 2011-02-01 | 2011-Feb    |      466307
 2011-03-01 | 2011-Mar    |      485165
 2011-04-01 | 2011-Apr    |      502042
 2011-05-01 | 2011-May    |      561647
 2011-06-01 | 2011-Jun    |      737793
 2011-07-01 | 2011-Jul    |      596710
 2011-08-01 | 2011-Aug    |      614516
 2011-09-01 | 2011-Sep    |      603047
 2011-10-01 | 2011-Oct    |      708164
 2011-11-01 | 2011-Nov    |      660507
 2011-12-01 | 2011-Dec    |      669395
 2012-01-01 | 2012-Jan    |      495363
 2012-02-01 | 2012-Feb    |      506992
 2012-03-01 | 2012-Mar    |      373478
 2012-04-01 | 2012-Apr    |      400324
 2012-05-01 | 2012-May    |      358866
 2012-06-01 | 2012-Jun    |      555142
 2012-07-01 | 2012-Jul    |      444533
 2012-08-01 | 2012-Aug    |      523887
 2012-09-01 | 2012-Sep    |      486149
 2012-10-01 | 2012-Oct    |      535125
 2012-11-01 | 2012-Nov    |      537918
 2012-12-01 | 2012-Dec    |      624454
 2013-01-01 | 2013-Jan    |      857758
 2013-02-01 | 2013-Feb    |      771218
 2013-03-01 | 2013-Mar    |     1049732
 2013-04-01 | 2013-Apr    |     1045860
 2013-05-01 | 2013-May    |     1284456
 2013-06-01 | 2013-Jun    |     1642948
 2013-07-01 | 2013-Jul    |     1371595
 2013-08-01 | 2013-Aug    |     1545910
 2013-09-01 | 2013-Sep    |     1447324
 2013-10-01 | 2013-Oct    |     1673261
 2013-11-01 | 2013-Nov    |     1780688
 2013-12-01 | 2013-Dec    |     1874128
 2014-01-01 | 2014-Jan    |       45642
*/
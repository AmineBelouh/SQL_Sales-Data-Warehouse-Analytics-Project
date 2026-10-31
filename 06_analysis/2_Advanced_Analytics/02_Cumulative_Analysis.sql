/*
===============================================================================
II. Cumulative Analysis
===============================================================================
Purpose:
    Aggregate data progressively over time.
    Helps understand whether the business is growing or declining.
===============================================================================
*/

-- 1. Yearly running total and moving average
SELECT
    year,
    total_sales,
    SUM(total_sales) OVER (ORDER BY year) AS sales_running_total,
    ROUND(AVG(total_sales) OVER (ORDER BY year), 2) AS sales_moving_avg
FROM (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY EXTRACT(YEAR FROM order_date)
) t;

/* Result:
 year | total_sales | sales_running_total | sales_moving_avg
------+-------------+---------------------+-----------------
 2010 |       43419 |               43419 |         43419.00
 2011 |     7075088 |             7118507 |       3559253.50
 2012 |     5842231 |            12960738 |       4320246.00
 2013 |    16344878 |            29305616 |       7326404.00
 2014 |       45642 |            29351258 |       5870251.60
*/

-- 2. Monthly running total and moving average (restarts each year)
SELECT
    year_month,
    year_month2,
    total_sales,
    SUM(total_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM year_month)
        ORDER BY year_month
    ) AS sales_running_total,
    ROUND(AVG(total_sales) OVER (
        PARTITION BY EXTRACT(YEAR FROM year_month)
        ORDER BY year_month
    ), 2) AS sales_moving_avg
FROM (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS year_month,
        TO_CHAR(order_date, 'yyyy-Mon') AS year_month2,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY
        DATE_TRUNC('month', order_date),
        TO_CHAR(order_date, 'yyyy-Mon')
) t;

/* Result:
 year_month | year_month2 | total_sales | sales_running_total | sales_moving_avg
------------+-------------+-------------+---------------------+-----------------
 2010-12-01 | 2010-Dec    |       43419 |               43419 |         43419.00

 2011-01-01 | 2011-Jan    |      469795 |              469795 |        469795.00
 2011-02-01 | 2011-Feb    |      466307 |              936102 |        468051.00
 2011-03-01 | 2011-Mar    |      485165 |             1421267 |        473755.67
 2011-04-01 | 2011-Apr    |      502042 |             1923309 |        480827.25
 2011-05-01 | 2011-May    |      561647 |             2484956 |        496991.20
 2011-06-01 | 2011-Jun    |      737793 |             3222749 |        537124.83
 2011-07-01 | 2011-Jul    |      596710 |             3819459 |        545637.00
 2011-08-01 | 2011-Aug    |      614516 |             4433975 |        554246.88
 2011-09-01 | 2011-Sep    |      603047 |             5037022 |        559669.11
 2011-10-01 | 2011-Oct    |      708164 |             5745186 |        574518.60
 2011-11-01 | 2011-Nov    |      660507 |             6405693 |        582335.73
 2011-12-01 | 2011-Dec    |      669395 |             7075088 |        589590.67

 2012-01-01 | 2012-Jan    |      495363 |              495363 |        495363.00
 2012-02-01 | 2012-Feb    |      506992 |             1002355 |        501177.50
 2012-03-01 | 2012-Mar    |      373478 |             1375833 |        458611.00
 2012-04-01 | 2012-Apr    |      400324 |             1776157 |        444039.25
 2012-05-01 | 2012-May    |      358866 |             2135023 |        427004.60
 2012-06-01 | 2012-Jun    |      555142 |             2690165 |        448360.83
 2012-07-01 | 2012-Jul    |      444533 |             3134698 |        447814.00
 2012-08-01 | 2012-Aug    |      523887 |             3658585 |        457323.13
 2012-09-01 | 2012-Sep    |      486149 |             4144734 |        460526.00
 2012-10-01 | 2012-Oct    |      535125 |             4679859 |        467985.90
 2012-11-01 | 2012-Nov    |      537918 |             5217777 |        474343.36
 2012-12-01 | 2012-Dec    |      624454 |             5842231 |        486852.58

 2013-01-01 | 2013-Jan    |      857758 |              857758 |        857758.00
 2013-02-01 | 2013-Feb    |      771218 |             1628976 |        814488.00
 2013-03-01 | 2013-Mar    |     1049732 |             2678708 |        892902.67
 2013-04-01 | 2013-Apr    |     1045860 |             3724568 |        931142.00
 2013-05-01 | 2013-May    |     1284456 |             5009024 |       1001804.80
 2013-06-01 | 2013-Jun    |     1642948 |             6651972 |       1108662.00
 2013-07-01 | 2013-Jul    |     1371595 |             8023567 |       1146223.86
 2013-08-01 | 2013-Aug    |     1545910 |             9569477 |       1196184.63
 2013-09-01 | 2013-Sep    |     1447324 |            11016801 |       1224089.00
 2013-10-01 | 2013-Oct    |     1673261 |            12690062 |       1269006.20
 2013-11-01 | 2013-Nov    |     1780688 |            14470750 |       1315522.73
 2013-12-01 | 2013-Dec    |     1874128 |            16344878 |       1362073.17
 
 2014-01-01 | 2014-Jan    |       45642 |               45642 |         45642.00
*/
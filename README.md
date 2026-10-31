# Data Warehouse and Analytics Project w/ PostgreSQL  
Welcome to my Data Warehouse and Analytics Project repository! This project demonstrates a comprehensive data warehousing and analytics solution, from building a data warehouse to generating actionable insights.  

## Project Overview

This project involves:  

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture (**Bronze**, **Silver**, and **Gold** layers).
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL Views to support reporting and future dashboard development.


## Data Architecture  

![Data Architecture](03_images/Data_Architecture.png)  

## Integration Model  

![Integration Model](03_images/Integration_Model.png)  

## Data Flow Diagram  

![Data Flow](03_images/Data_Flow_Diagram.png)  

## Data Model (Star Schema)  

![Star Schema](03_images/Star_Schema_Model.png)  

## Building Layers  

**Initialize the database first:** [Database Initialization](04_scripts/init_database.sql)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into ***Postgres*** Database.  
  - [DDL Bronze Layer](04_scripts/1_bronze/ddl_bronze.sql)
  - [Procedure Load Bronze](04_scripts/1_bronze/procedure_load_bronze.sql) (Update the file paths in the procedure to match the location where you stored the CSV files on your own computer.)
2. **Silver Layer**: Includes data cleaning processes to prepare data for analysis.
  - [DDL Silver Layer](04_scripts/2_silver/ddl_silver.sql)
  - [Procedure Load Silver](04_scripts/2_silver/procedure_load_silver.sql)
3. **Gold Layer**: Business-ready data, modeled into a star schema, required for reporting and analytics.
  - [DDL Gold Layer](04_scripts/3_gold/ddl_gold.sql)

**Gold Layer Data Catalog:** [Data Catalog](02_docs/data_catalog.md)  

---
# Data Analysis  
![Analytics_Roadmap](./03_images/Analytics_Roadmap.png)  

## EDA  
We try to understand all the aspects of our datasets.  

1. [Database Exploration](./06_analysis/1_EDA/01_Database_Exploration.sql): Inspect the tables/views and columns available in the Gold schema. 

2. [Dimensions Exploration](./06_analysis/1_EDA/02_Dimensions_Exploration.sql): Identify distinct values in dimension attributes and understand possible groupings and the granularity of the dimensions.  

3. [Date Exploration](./06_analysis/1_EDA/03_Date_Exploration.sql): Identify date boundaries and understand the timespan of sales data and the birth-date range of customers.  

4. [Measures Exploration](./06_analysis/1_EDA/04_Measures_Exploration.sql): Calculate key business metrics to establish a high-level overview of the business.  

5. [Magnitude and Ranking Analysis](./06_analysis/1_EDA/05_Magnitude_Ranking_Analysis.sql): Compare business measures across products, categories, subcategories, and customer segments. Rank the results from highest to lowest.  

## Advanced Analytics  

1. [Change Over Time](./06_analysis/2_Advanced_Analytics/01_Change_Over_Time.sql): Helps track trends and identify seasonality in the data.  

2. [Cumulative Analysis](./06_analysis/2_Advanced_Analytics/02_Cumulative_Analysis.sql): Helps understand whether the business is growing or declining.  

3. [Performance Analysis](./06_analysis/2_Advanced_Analytics/03_Performance_Analysis.sql): Compare the current value to a target value.  

4. [Part to Whole Analysis](./06_analysis/2_Advanced_Analytics/04_Part_Whole_Analysis.sql): Understand which category has the greatest impact on the business.  
5. [Data Segmentation](./06_analysis/2_Advanced_Analytics/05_Data_Segmentation.sql): Grouped customers and products into meaningful segments.   

## Reports  
- Built two business-ready **SQL views** in the Gold layer (Customers Report and Products Report), each combining descriptive attributes with aggregated measures
- Analysts can connect the views directly to dashboard tools and generate insights without extensive data preparation, or write queries on top of the views for quick analysis

1. [Customers Report](./06_analysis/3_Reports/01_report_customers.sql)  
2. [Products Report](./06_analysis/3_Reports/02_report_products.sql)

# Layoff Data Analysis

## Overview

Analysis on a layoff dataset with the objetive of cleaning the data and performing exploratory data analysis to find insights and possible trends.

## Data Cleaning

[Query](https://github.com/Felipe-Novais/Layoff-Database-Analysis/blob/main/data_cleaning.sql)

- **Duplicate Removal**

Creation of a working table and identification of duplicate records using ROW_NUMBER() with partitioning by multiple columns. Duplicates were isolated and removed, ensuring data consistency.

- **Data Standardization**

Handling of textual inconsistencies, including:

1- Removal of extra spaces in company names (TRIM) \
2- Standardization of categories (e.g., "Crypto") \
3- Correction of country names \
4- Conversion of data from text format to DATE format.

- **Null Value Handling**

Filling of null fields in the industry column based on existing information for the same company (self-join). Empty values ​​("") were also normalized to NULL.

- **Removal of Irrelevant Data and Finalization**

Deletion of records without essential information (total_laid_off and percentage_laid_off) and final tables organization, removing internal structures and consolidating the final clean database for analysis.

## Exploratory Data Analysis

[Query](https://github.com/Felipe-Novais/Layoff-Database-Analysis/blob/main/exploratory_data_analysis.sql)

- **Data Overview**

Analysis of the period covered by the database, identifying minimum and maximum dates, corresponding years and the total interval in months between layoff events.

- **Identification of Main Impacts**

Survey of the main contributors to layoffs:

1- Top 10 companies with the highest number of layoffs \
2- Companies that ceased operations (100% layoffs) \
3- Top 5 most affected industries \
4- Countries with the highest volume of layoffs

- **Analysis by Company Profile**

Exploration of layoffs based on the stage of the companies, accounting for:

1- Total number of companies per stage \
2- Total number of employees laid off per stage \
3- Allowing an understanding of which phases the impacts were most significant.

- **Time Series Analysis and Trends**

Final investigations using CTEs and window functions calculating the total accumulated (rolling total) of layoffs over time (year/month) and an annual ranking of companies with the most layoffs, highlighting the top 5 per year.

## Technical Details

- **Database and Query Tools**: MySQL

# Data-Cleaning

Data Cleaning is an important step in data preparation. This involves identifying appropriate data types and correcting errors, inconsistencies, and inaccuracies in your dataset to ensure that it is accurate, reliable, and suitable for analysis or modeling.

Different tools and programming languages are leveraged to wrangle data, but all have pros and cons. When you have large datasets, SQL is one of the best ways to select and clean data efficiently.  

This project showcases how data can be cleaned using SQL. I make use of a publically available dataset "Nashville Housing Dataset" from Kaggle using MySQL.

My approach to cleaning the dataset was loading the CSV file to MySQL creating a table that stores the data and immediately creating another temporary table as a copy of the original table, as a good practice not to make changes that can’t be reversed with the original dataset/table.

## Knowing the Data
Before beginning the data cleaning process, it’s critical to understand the dataset. By exploring the dataset’s structure, I identified and detected potential issues like wrong datatypes, missing data, and formatting inconsistencies. During the data exploration, I identified several data quality issues such as:

## Summary of Data Quality Issues Observed and the Cleaning Approach

- **Wrangling the Date Column**: Standardizing inconsistent date formats for uniformity.

- **Handling Missing Values in the Property Addresses**: Identifying and addressing missing or incomplete entries in the address field.

- **Splitting & Dicing Addresses**: Breaking down address components and trimming leading and trailing spaces for consistency.

- **Making ‘SoldAsVacant’ Speak Clearly**: Converting inconsistent values (e.g., "Y" and "N") to more meaningful values like "Yes" and "No."

- **Removing Duplicate Records**: Utilizing the `ROW_NUMBER()` window function to identify and remove duplicate rows.

- **Streamlining for Clarity**: Refining the dataset to ensure data is clean, clear, and ready for analysis.

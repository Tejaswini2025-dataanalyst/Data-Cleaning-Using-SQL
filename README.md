# SQL Data Cleaning & Layoffs Analysis Project

This project focuses on cleaning and exploring a real-world layoffs dataset using Structured Query Language (SQL) The goal is to transform messy, inconsistent data into a clean, analysis-ready format and uncover meaningful trends in layoffs across companies, industries, and geographies.

## Project Objective

To use SQL to:
- Clean and preprocess raw layoff data
- Remove duplicates and standardize formats
- Handle null values efficiently
- Drop irrelevant or redundant columns
- Perform exploratory data analysis (EDA) to find patterns and insights

---

## Data Cleaning Steps

 1. Remove Duplicates
- Used `ROW_NUMBER()` with `PARTITION BY` clause to identify duplicates
- Retained only unique rows in the staging table

```sql
WITH duplicate_cte AS (
  SELECT *, 
         ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
         ) AS row_num
  FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;
```

 2. Standardize Data
- Trimmed white spaces from columns like company, country, industry

- Converted date column from TEXT to DATE using STR_TO_DATE

- Renamed inconsistent values (e.g., 'United States of America' → 'united states')

```sql
UPDATE layoffs_staging2
SET company = TRIM(company);

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;
```
3. Handle NULL Values
- Retained NULLs for analytical fields like total_laid_off and percentage_laid_off

- Deleted rows where both fields were NULL
```sql
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;
```
4. Drop Unnecessary Columns
- Removed helper columns such as row_num
```sql
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;
 Exploratory Data Analysis (EDA)
Key Insights
```
-- Top 5 companies with highest total layoffs
```sql
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 5;
```
----Layoffs by Year
```sql
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY year
ORDER BY year ASC;
```
-----Layoffs by Country & Industry
```sql
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
```
```sql
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
```
-----Companies with 100% Layoffs
```sql
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

----- Rolling Total Layoffs (Month-wise Trend)
```
```sql
WITH Date_CTE AS (
  SELECT DATE_FORMAT(date, '%Y-%m') AS month, SUM(total_laid_off) AS monthly_layoffs
  FROM layoffs_staging2
  GROUP BY month
)
SELECT month, SUM(monthly_layoffs) OVER (ORDER BY month) AS rolling_total
FROM Date_CTE;
```
## Summary & Recommendations
- Many startups laid off 100% of their workforce—mostly in tech/crypto sectors.
- United States had the highest total layoffs overall.
- Layoffs peaked during economic downturn periods (e.g., pandemic, funding slowdowns).
- Additional fields like employee ratings, financials, or sector growth could provide even deeper insights.

## Acknowledgments
- Special thanks to the SQL learning community and open-source platforms for making real-world datasets available.
-  This project strengthened my skills in:
  1. SQL Data Cleaning
  2. Window Functions
  3. rouped Aggregations
  4. EDA using SQL




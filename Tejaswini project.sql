-- data cleaning--

-- 1.Remove duplicates
-- 2.Standardizing data
-- 3 .null value or blank values
-- 4. remove any coloumn

create table layoffs_staging
like layoffs;

select * from layoffs;

-- impoting the data into new table-- 

insert layoffs_staging 
select * 
from layoffs;

select * from layoffs_staging;

select * ,
row_number() over (
partition by company,industry,total_laid_off,percentage_laid_off,'data') as row_num 
from layoffs_staging;

with duplicate_cte as
(
select * ,
row_number() over (
partition by company,industry,total_laid_off,percentage_laid_off,'data') as row_num 
from layoffs_staging 
)
select * 
from duplicate_cte
where row_num> 1;

select  * 
from layoffs_staging 
 where company ='oda';
 
 select  * 
from layoffs_staging 
 where company ='oda';
 
 with duplicate_cte as
(
select * ,
row_number() over (
partition by company,industry,total_laid_off,percentage_laid_off,`date` ,stage,country,funds_raised_millions) as row_num 
from layoffs_staging 
)
select * 
from duplicate_cte
where row_num> 1;


 select  * 
from layoffs_staging 
 where company ='cazoo';
 
 with duplicate_cte as
(
select * ,
row_number() over (
partition by company,industry,total_laid_off,percentage_laid_off,`date` ,stage,country,funds_raised_millions) as row_num 
from layoffs_staging 
)
delete 
from duplicate_cte
where row_num> 1;

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row num` int 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

insert into layoffs_staging2
select * ,
row_number() over (
partition by company,industry,total_laid_off,percentage_laid_off,`date` ,stage,country,funds_raised_millions) as row_num 
from layoffs_staging ;

alter table layoffs_staging2
rename column `row num` to row_num;

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Run your DELETE query
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- (Optional) Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

select * from layoffs_staging2 where row_num>1;


-- 2. Standardize Data

SELECT * 
FROM world_layoff.layoffs_staging2;

select country
from layoffs_staging2;

select country,trim(country)
from layoffs_staging2;

select company,trim(company)
from layoffs_staging2;

update layoffs_staging2 
set company = trim(company);

SET @@SESSION.sql_safe_updates = 0;

UPDATE layoffs_staging2
SET company = TRIM(company);

SET @@SESSION.sql_safe_updates = 1;  

select  company  from layoffs_staging2 ;

select distinct industry 
from layoffs_staging2
order by 1;


select *
from layoffs_staging2
where industry like 'crypto%';

update layoffs_staging2
set industry ='crypto'
where industry like 'crypto%';

SELECT  distinct country 
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;

update layoffs_staging2
set country ='united states'
where country like 'united states%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY location;

update layoffs_staging2
set country = trim( trailing ' . ' from country)
where country like 'united states%';

select date ,
str_to_date('date','%m/%d/%Y')
FROM layoffs_staging2;
-- we can use str to date to update this field--
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- now we can convert the data type properly--

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM world_layoff.layoffs_staging2;

use world_layoff;

-- 3. Look at Null Values--
-- the null values in total_laid_off, percentage_laid_off, and funds_raised_millions all look normal. I don't think I want to change that
-- I like having them null because it makes it easier for calculations during the EDA phase
-- so there isn't anything I want to change with the null values

-- 4. remove any columns and rows we need to--

SELECT *
FROM world_layoff.layoffs_staging2
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoff.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use

DELETE FROM world_layoff.layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * 
FROM world_layoff.layoffs_staging2;


SELECT * 
FROM world_layoff.layoffs_staging2;


-- EDA

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

SELECT * 
FROM world_layoff.layoffs_staging2;

-- EASIER QUERIES

SELECT MAX(total_laid_off)
FROM world_layoff.layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM world_layoff.layoffs_staging2
WHERE  percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM world_layoff.layoffs_staging2
WHERE  percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM world_layoff.layoffs_staging2
WHERE  percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff

SELECT company, total_laid_off
FROM world_layoff.layoffs_staging
ORDER BY 2 DESC
LIMIT 5;
-- now that's just on a single day

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- by location
SELECT location, SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT country, SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(date), SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;


SELECT industry, SUM(total_laid_off)
FROM world_layoff.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT stage, SUM(total_laid_off)
FROM world_layof.layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at 

WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS years, SUM(total_laid_off) AS total_laid_off
  FROM layoffs_staging2
  GROUP BY company, YEAR(date)
)
, Company_Year_Rank AS (
  SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
  FROM Company_Year
)
SELECT company, years, total_laid_off, ranking
FROM Company_Year_Rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- now use it in a CTE so we can query off of it
WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;










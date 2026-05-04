/*
Step 1 - Remove duplicate rows
*/

-- Create a new schema and import the data

CREATE SCHEMA global_job_layoffs;
USE global_job_layoffs; -- data imported via import wizard


-- Create a new table with the same data as the raw table

CREATE TABLE layoffs_treated LIKE layoffs_raw;
INSERT INTO layoffs_treated SELECT * FROM layoffs_raw;


-- Insert unique indexes for each row, allowing locating duplicates

WITH CTE_check_duplicate AS
(
	SELECT
		*,
		ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
		percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_flag
	FROM 
		layoffs_treated
)
SELECT *
FROM CTE_check_duplicate
WHERE duplicate_flag = 2;


-- Create a new table with the CTE flag

CREATE TABLE layoffs_treated_2
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, `date`, stage, country, funds_raised_millions) AS duplicate_flag
FROM 
	layoffs_treated;
    

-- Delete duplicate rows

SELECT *
FROM layoffs_treated_2
WHERE duplicate_flag > 1;

DELETE FROM layoffs_treated_2
WHERE duplicate_flag > 1;

ALTER TABLE layoffs_treated_2
DROP COLUMN duplicate_flag;


/*
Step 2 - Standardize the data
*/

-- Locate and cleanse company names with spaces at the beginning or end

SELECT DISTINCT
	company,
	LENGTH(company),
	TRIM(company),
	LENGTH(TRIM(company))
FROM 
	layoffs_treated_2
WHERE
	LENGTH(company) <> LENGTH(TRIM(company));
    
UPDATE layoffs_treated_2
SET company = TRIM(company);


-- Locating and cleaning similar industry names

SELECT DISTINCT industry
FROM layoffs_treated_2
ORDER BY industry;

SELECT DISTINCT industry
FROM layoffs_treated_2
WHERE industry LIKE "crypto%";
    
UPDATE layoffs_treated_2
SET industry = "Crypto"
WHERE industry LIKE "Crypto%";


-- Locating and cleaning discrepancies in country names

SELECT DISTINCT country
FROM layoffs_treated_2
ORDER BY country;

SELECT DISTINCT country
FROM layoffs_treated_2
WHERE country LIKE "united states%";

UPDATE layoffs_treated_2
SET country = TRIM(TRAILING "." FROM country)
WHERE country LIKE "united states%";


-- Converting dates from text to date and changing the data type in the table

SELECT  `date`, STR_TO_DATE(`date`, "%m/%d/%Y") AS str_to_date
FROM  layoffs_treated_2;

UPDATE layoffs_treated_2
SET `date` = STR_TO_DATE(`date`, "%m/%d/%Y");

ALTER TABLE layoffs_treated_2
MODIFY COLUMN `date` DATE;


/*
Step 3 - Populate empty fields and delete rows that will not be useful for analysis
*/

-- Popular industry column with information already present in the table

SELECT *
FROM layoffs_treated_2
WHERE
	industry IS NULL OR
    industry = "";
    
UPDATE layoffs_treated_2
SET industry = NULL
WHERE industry = "";

SELECT 
	lt1.company,
    lt1.industry,
	lt2.company,
    lt2.industry
FROM 
	layoffs_treated_2 AS lt1
INNER JOIN
	layoffs_treated_2 AS lt2
ON
	lt1.company = lt2.company
WHERE
	lt1.industry IS NULL AND
    lt2.industry IS NOT NULL;
    
UPDATE 
	layoffs_treated_2 AS lt1
INNER JOIN
	layoffs_treated_2 AS lt2
ON
	lt1.company = lt2.company
SET 
	lt1.industry = lt2.industry
WHERE
	lt1.industry IS NULL AND
    lt2.industry IS NOT NULL;
    

-- Delete rows with total_laid_off and percentage_laid_off NULL

SELECT *
FROM layoffs_treated_2
WHERE 
	total_laid_off IS NULL AND
    percentage_laid_off IS NULL;
    
DELETE FROM layoffs_treated_2
WHERE 
	total_laid_off IS NULL AND
    percentage_laid_off IS NULL;
    
-- Delete the first layoffs_treated table and renaming the second

DROP TABLE layoffs_treated;

RENAME TABLE layoffs_treated_2 TO layoffs_treated;

SELECT * FROM layoffs_treated;
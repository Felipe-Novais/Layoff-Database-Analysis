USE global_job_layoffs;

/*
Initial analysis
*/

-- Time gap between layoffs
SELECT
	MIN(`date`) AS starting_date,
	MAX(`date`) AS ending_date,
	MIN(YEAR(`date`)) AS starting_year,
	MAX(YEAR(`date`)) AS ending_yeat,
    TIMESTAMPDIFF(MONTH, MIN(`date`), MAX(`date`)) AS month_time_gap
FROM
	layoffs_treated;

-- Locating top 10 companies with most employees laid off
SELECT
	company,
	SUM(total_laid_off) AS sum_total_laid_off,
	DENSE_RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking
FROM 
	layoffs_treated
GROUP BY
	company
ORDER BY
	sum_total_laid_off DESC
LIMIT 10;

-- Locating all companies that went under and orderding them by total_laid_off
SELECT
	*
FROM 
	layoffs_treated
WHERE
	percentage_laid_off = 1
ORDER BY
	total_laid_off DESC;
    
-- Consulting  top 5 industries that had the most layoffs
SELECT
	industry,
	SUM(total_laid_off) AS sum_total_laid_off,
    DENSE_RANK() OVER(ORDER BY SUM(total_laid_off) DESC) AS ranking
FROM
	layoffs_treated
GROUP BY
	industry
LIMIT 5;
    
-- Checking countries with the most layoffs
SELECT
	country,
    SUM(total_laid_off) AS sum_total_layoffs
FROM
	layoffs_treated
GROUP BY
	country
ORDER BY
	sum_total_layoffs DESC;
    
-- Total companies and laid off employees by stage
SELECT
	stage,
    COUNT(company) AS total_companies,
    SUM(total_laid_off) AS sum_total_laid_off
FROM 
	layoffs_treated
GROUP BY
	stage
ORDER BY
	sum_total_laid_off DESC;
    
/*
In-depth analysis
*/

-- Rolling total of layoffs by year and month gaps
WITH rolling_total AS
(
	SELECT
		SUBSTRING(`date`, 1, 7) AS `year_month`,
		SUM(total_laid_off) AS sum_total_laid_off
	FROM
		layoffs_treated
	WHERE 
		SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY
		`year_month`
	ORDER BY
		`year_month`
)
SELECT
	*,
    SUM(sum_total_laid_off) OVER(ORDER BY `year_month`) AS rolling_total
FROM
	rolling_total;
    
-- Total layoffs by company ranking by year
WITH layoffs_by_year AS
(
	SELECT
		company,
		SUM(total_laid_off) AS sum_total_laid_off,
		YEAR(`date`) AS year_date
	FROM 
		layoffs_treated
	GROUP BY
		company,
		year_date
	HAVING
		sum_total_laid_off IS NOT NULL AND
        year_date IS NOT NULL
),
company_ranking AS
(
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY year_date ORDER BY sum_total_laid_off DESC) AS ranking
	FROM
		layoffs_by_year
)
SELECT 
	*
FROM 
	company_ranking
WHERE
	ranking <= 5;
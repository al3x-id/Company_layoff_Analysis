SELECT * FROM layoff_prep2;

-- Descriptive Analytics
-- Total number of layoffs by year
SELECT
YEAR(`date`) AS `YEAR`,
SUM(total_laid_off)
FROM layoff_prep2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`); 

-- Number of affected companies per year.
SELECT
YEAR(`date`) AS `YEAR`,
COUNT(company) AS company_count
FROM layoff_prep2
WHERE YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`);

-- Average number of employees laid off per company.
SELECT
company,
ROUND(SUM(total_laid_off)/COUNT(DISTINCT company), 2) AS AVG_employee_laidoff
 FROM layoff_prep2
 WHERE total_laid_off IS NOT NULL
 GROUP BY company
 Order by 1;
 
-- Company-Level Analysis
-- Rank the top 5 layoff company in each year
/*SELECT company, YEAR(`date`) AS `year`, 
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
GROUP BY company, YEAR(`date`);*/

WITH company_layoff AS
(SELECT company, YEAR(`date`) AS `year`, 
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
GROUP BY company, YEAR(`date`)),
company_rank AS(
SELECT *,
DENSE_RANK() OVER(PARTITION BY `year` ORDER BY total_layoff DESC) AS ranking
FROM company_layoff
WHERE `year` AND total_layoff IS NOT NULL
/*;*/)
SELECT * FROM company_rank
WHERE ranking <= 5;

-- Top 10 companies with the most layoffs.
SELECT 
company,
SUM(total_laid_off) AS sumtotal_laidoff
FROM layoff_prep2
 WHERE total_laid_off IS NOT NULL
 GROUP BY company
 ORDER BY SUM(total_laid_off) DESC
 LIMIT 10;

-- Layoff % as a proportion of total company size (if percentage_laid_off column exists).
SELECT company,
total_laid_off,
percentage_laid_off
FROM layoff_prep2
WHERE percentage_laid_off IS NOT NULL
ORDER BY percentage_laid_off DESC
LIMIT 10;

-- Comparison of layoffs by startup vs. large tech companies (if distinguishable).
SELECT stage,
COUNT(company) AS num_of_companies,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND stage is NOT NULL
GROUP BY stage
ORDER BY total_layoff DESC;

-- Country and Industry Breakdown
-- Top countries by number of layoffs.
SELECT company,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND company IS NOT NULL
GROUP BY company
ORDER BY total_layoff DESC;

-- Sector-based distribution: Fintech, E-commerce, AI, etc.
SELECT industry,
COUNT(*) AS layoff_event,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND industry IS NOT NULL
GROUP BY industry
ORDER BY total_layoff DESC;

-- Country-wise trends over time.
SELECT country,
YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND YEAR(`date`) AND country IS NOT NULL
GROUP BY country, `year`
ORDER BY total_layoff DESC;

-- Time Series Trend Analysis
-- Rolling total over the month
WITH Rolling_Total AS(
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `month`,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY `month`
ORDER BY `month`)
SELECT *,
SUM(total_layoff) OVER(ORDER BY `month`) rolling_total
FROM Rolling_Total;

-- Monthly layoff trends (highlight peak periods)
SELECT DATE_FORMAT(`date`, '%Y-%m') AS `month`,
SUM(total_laid_off) AS total_layoff
FROM layoff_prep2
WHERE total_laid_off AND DATE_FORMAT(`date`, '%Y-%m') IS NOT NULL
GROUP BY `month`
ORDER BY total_layoff DESC
LIMIT 5;

-- Correlation with external events (e.g., economic recession, COVID-19 wave).
SELECT YEAR(`date`) AS `year`,
SUM(total_laid_off) AS total_layoff,
CASE
	WHEN YEAR(`date`) <= '2021' THEN 'post_recession_period'
ELSE 'recession_period'
END AS external_event1,
CASE
	WHEN YEAR(`date`) <= '2021-12'
    THEN 'COVID19_period'
ELSE 'post_COVID19_period'
END AS external_event2
FROM layoff_prep2
WHERE total_laid_off AND YEAR(`date`) IS NOT NULL
GROUP BY `year`, external_event1, external_event2
ORDER BY total_layoff DESC;




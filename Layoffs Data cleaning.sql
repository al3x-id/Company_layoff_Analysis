-- Data cleaning
-- Skill used: Window functions, CTEs, Temptables, Strings, Changing Data type

CREATE DATABASE layoffs;

SELECT * FROM layoffs;

-- Creating a copy of the table as 'layoff_prep'
CREATE TABLE layoff_prep
LIKE layoffs;

INSERT layoff_prep
SELECT * FROM layoffs;

SELECT * FROM layoff_prep;

-- Removing duplicates
-- Add row numbers
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoff_prep;

-- Create CTE
WITH layoff_cte AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoff_prep)
SELECT *
FROM layoff_cte
WHERE row_num > 1;

-- Create a new copy of the table adding the 'row_num' column
CREATE TABLE `layoff_prep2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT layoff_prep2
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num 
FROM layoff_prep;

SELECT * FROM layoff_prep2;

-- Delete dupilicates
DELETE FROM layoff_prep2
WHERE row_num > 1;

-- Standardize the Data
-- Trim company
SELECT company, TRIM(company) FROM layoff_prep2
ORDER BY 1;

UPDATE layoff_prep2
SET company = TRIM(company);

-- Correct Industry 
SELECT DISTINCT industry FROM layoff_prep2
WHERE industry LIKE 'Crypto%';

UPDATE layoff_prep2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Trim country
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) FROM layoff_prep2
ORDER BY 1;

UPDATE layoff_prep2
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT country FROM layoff_prep2
ORDER BY 1;

-- Set date format
SELECT `date`, str_to_date(`date`, '%m/%d/%Y') FROM layoff_prep2;

UPDATE layoff_prep2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

ALTER TABLE layoff_prep2
MODIFY COLUMN `date` DATE;

-- Remove Null and empty values
SELECT * FROM layoff_prep2
WHERE industry IS NULL OR industry = '';

UPDATE layoff_prep2
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoff_prep2 t1
JOIN layoff_prep2 t2
	ON t1.country = t2.country
	AND t1.location = t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoff_prep2 t1
JOIN layoff_prep2 t2
	ON t1.country = t2.country
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM layoff_prep2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
    
DELETE
FROM layoff_prep2
WHERE total_laid_off IS NULL
	AND percentage_laid_off IS NULL;
    
SELECT * 
FROM layoff_prep2;

-- Remove row_num column
ALTER TABLE layoff_prep2
DROP COLUMN row_num;

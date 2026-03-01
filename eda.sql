-- EDA

SELECT * 
FROM layoffs_cleaned;

-- Company-Wise Layoff Analysis
-- Identify companies with the highest total layoffs

SELECT company, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY total_layoffs DESC;


-- Companies with 100% Layoffs
-- Identify companies where 100% of employees were laid off

SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Date Range of Layoffs
-- Determine overall time span of the dataset

SELECT MIN(`date`) AS start_date,
       MAX(`date`) AS end_date
FROM layoffs_cleaned;


-- Industry-Wise Layoff Analysis
-- Identify industries most affected by layoffs

SELECT industry, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY industry
ORDER BY total_layoffs DESC;


-- Country-Wise Layoff Analysis
-- Analyze layoffs across different countries

SELECT country, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY country
ORDER BY total_layoffs DESC;


-- Year-Wise Layoff Trends
-- Analyze total layoffs per year

SELECT YEAR(`date`) AS year,
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY YEAR(`date`)
ORDER BY year;


-- Top 5 Companies by Total Layoffs

SELECT company, 
       SUM(total_laid_off) AS total_layoffs
FROM layoffs_cleaned
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 5;

-- Top 3 Companies by Layoffs Each Year

SELECT *
FROM (
    SELECT YEAR(`date`) AS year,
           company,
           SUM(total_laid_off) AS total_layoffs,
           DENSE_RANK() OVER (
               PARTITION BY YEAR(`date`)
               ORDER BY SUM(total_laid_off) DESC
           ) AS ranking
    FROM layoffs_cleaned
    GROUP BY YEAR(`date`), company
) ranked
WHERE ranking <= 3;
ORDER BY year,ranking;
-- Rolling Total Layoffs by Year

SELECT year,
       total_layoffs,
       SUM(total_layoffs) OVER (ORDER BY year) AS cumulative_layoffs
FROM (
    SELECT YEAR(`date`) AS year,
           SUM(total_laid_off) AS total_layoffs
    FROM layoffs_cleaned
    GROUP BY YEAR(`date`)
) yearly_data;

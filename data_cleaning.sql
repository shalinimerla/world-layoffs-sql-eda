use world_layoff;
select * from layoffs;

-- Create Staging Table (Preserve Raw Data)

create table layoffs_staging
like layoffs;

insert into layoffs_staging
select * from layoffs;

-- Remove Duplicates Using ROW_NUMBER()

with duplicate_cte as (
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) 
  as row_num 
from layoffs_staging )
select * from duplicate_cte 
where row_num>1;

CREATE TABLE `layoffs_cleaned` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
select * from layoffs_cleaned;

insert into layoffs_cleaned
select *,
row_number() over(
partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
  as row_num 
from layoffs_staging;

delete from layoffs_cleaned where row_num>1;

-- Standardize Text Values

update layoffs_cleaned
set company=trim(company);

update layoffs_cleaned
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_cleaned
set country = 'United States'
where country like 'United States%';

-- Convert Date Column from TEXT to DATE

update layoffs_cleaned
set `date`=STR_TO_DATE(`date`,'%m/%d/%Y');

alter table layoffs_cleaned
modify column `date` DATE;

-- Handle Missing Values

update layoffs_cleaned
set industry = null 
where industry = '';

update layoffs_cleaned t1 join layoffs_cleaned t2
on t1.company=t2.company 
set t1.industry=t2.industry 
where t1.industry is null 
and t2.industry is not null;

delete from layoffs_cleaned
where total_laid_off is null 
and percentage_laid_off is null;

-- Remove Helper Column
alter table layoffs_cleaned
drop column row_num;

select * from layoffs_cleaned 
order by 1;

# World Layoffs Data Analysis (SQL Project)

## Project Overview
This project focuses on data cleaning and exploratory data analysis (EDA) of a global layoffs dataset using MySQL. The objective is to analyze layoff trends across companies, industries, countries, and years.

---

## Tools Used
- MySQL Workbench(Data Cleaning & EDA)
- SQL (Joins, Aggregations, Group By, Window Functions)

---

## Dataset
The dataset contains global layoff records including:
- Company
- Location
- Industry
- Total laid off
- Percentage laid off
- Date
- Country
- Funds raised (in millions)

Dataset Source: https://www.kaggle.com/datasets/vardhannharsh/world-layoffs?select=layoffs.csv

---

## Data Cleaning Steps
1. Created a Staging Table 
To preserve the original raw dataset, a staging table was created:
```sql
create table layoffs_cleaned
like layoffs;

insert into layoffs_cleaned
select* from layoffs;
```
This created a new staging table called 'layoffs_cleaned' to safely perform data cleaning operations.

2. Removed duplicate records
To identify and remove the duplicates we have to add one more column called row_num which will show the duplicate rows.
```sql
select *,row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) row_num from layoffs_cleaned;
```
Rows where 'row_num > 1' were identified as duplicates and removed.
 
3. Handled NULL values
- Identified records where both 'total_laid_off' and 'percentage_laid_off' were NULL and removed those records.
- Converted empty string values in the 'industry' column to NULL.
- Used self-join logic to populate missing industry values from existing company records.

4. Standardized inconsistent values
Industry column contained entries like 'Crypto','Cryptocurrency' and 'Crypto Currency' all are referring to the same which were standardized into single term,'Crypto'. Similarly for country column 'United States' and 'United States.' were standardized into 'United States'.
```sql
update layoffs_cleaned
set industry= 'Crypto'
where industry like 'Crypto%';
```
5. Converted date formats
The data type of date was changed from 'text' into 'date'.
```sql
update layoffs_cleaned
set `date`=STR_TO_DATE(`date`,'%m/%d/%Y');
```

---

## Exploratory Data Analysis
After cleaning the dataset, exploratory data analysis was performed to identify patterns and trends in global layoffs.
1. Companies with Highest layoffs
Analyzed total layoffs group by company to determine which organizations were most impacted.
```sql
select company, sum(total_laid_off) as total_layoffs
from layoffs_cleaned
group by company
order by total_layoffs desc;
```
This helped identify companies with the highest number of layoffs.
2. Companies with 100% layoffs
Identified companies where 100% of employees were laid off.
```sql
select *
from layoffs_cleaned
where percentage_laid_off = 1
order by funds_raised_millions desc;
```
This provided insight into companies that completely shut down operations.
3. Date Range of Layoffs
```sql
select min(`date`) as start_date,
       max(`date`) as end_date
from layoffs_cleaned;
```
This helped understand the overall timeline of layoffs.
4. Industry-Wise Layoff
```sql
select industry, sum(total_laid_off) as total_layoffs
from layoffs_cleaned
group by industry
order by total_layoffs desc;
```
This helps in Analysing which industry is most affected.
5. Country-Wise Layoff
```sql
select country, sum(total_laid_off) as total_layoffs
from layoffs_cleaned
group by country
order by total_layoffs desc;
```
Analysed layoffs across different Countries.
6. Year-Wise Layoff Trends
```sql
select 
    year(`date`) as year,
    sum(total_laid_off) as total_layoffs
from layoffs_cleaned
group by year(`date`)
order by year;
```
This helped identify peak layoff years.
7. Top 5 Companies by Total Layoffs
```sql
select company, 
       sum(total_laid_off) as total_layoffs
from layoffs_cleaned
group by company
order by total_layoffs desc
limit 5;
```
This helped identify the top 5 companies with the highest total layoffs.
---

## Key Insights
- 2022 recorded the highest number of layoffs, indicating a peak in workforce reductions during that year.
- The Technology industry was the most impacted sector, contributing the largest share of total layoffs.
- The United States accounted for the highest number of layoffs compared to other countries.
- Several companies experienced 100% layoffs, suggesting complete shutdowns or business failures.
- A small number of companies contributed disproportionately to total layoffs, showing concentrated impact among major organizations.
- Layoffs followed noticeable monthly spikes, reflecting periods of economic or market instability.

---

## Reference 
https://www.youtube.com/watch?v=OT1RErkfLNQ&t=12666s

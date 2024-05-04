-- Exploratory Data analysis

select * from layoffs_staging2;

select max(total_laid_off),MAX(percentage_laid_off) from layoffs_staging2;

select * from layoffs_staging2 where percentage_laid_off = 1
order by funds_raised_millions desc;

select company,sum(total_laid_off) from layoffs_staging2 
group by company
order by 2 desc;

select min(`date`), max(`date`)
from layoffs_staging2;

select industry,sum(total_laid_off) from layoffs_staging2 
group by industry
order by 2 desc;

select country,sum(total_laid_off) from layoffs_staging2 
group by country
order by 2 desc;

select Year(`date`),sum(total_laid_off) from layoffs_staging2 
group by Year(`date`)
order by 1 desc;


select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc;

with Rolling_Total as
(
select substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off from layoffs_staging2
where substring(`date`,1,7) is not null
group by `MONTH`
order by 1 asc
) select `MONTH`,total_off, sum(total_off) over (order by `MONTH`) as rolling_total
From Rolling_Total;

select company,Year(`date`),sum(total_laid_off) from layoffs_staging2 
group by company,Year(`date`)
order by 3 desc;

with Company_Year(company,years,total_laid_off) as
(
select company,Year(`date`),sum(total_laid_off) from layoffs_staging2 
group by company,Year(`date`)
) , Company_Year_Rank as
(
select * , DENSE_RANK() Over (PARTITION BY years order by total_laid_off desc) as Ranking
from Company_year
where years is not null
)
SELECT * 
from Company_Year_Rank where ranking <=5;

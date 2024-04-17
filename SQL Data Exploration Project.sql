select * from CovidDeaths order by 3,4

select * from CovidVaccinations order by 3,4

Select Location ,date, total_cases,new_cases,total_deaths, population
from CovidDeaths order by 1,2

--total cases vs total deaths

Select Location ,date, total_cases,total_deaths,(total_deaths/total_cases *100) as DeathsPercentage
from CovidDeaths 
where Location='Lebanon'
order by 1,2

--total cases vs population

Select Location ,date, total_cases,population,(total_cases/population *100) as CasesPercentage
from CovidDeaths 
where Location='Lebanon'
order by 1,2

--Countries with highest infection rate compared to population

Select Location ,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population *100)) as PercentageOfPopulationInfected
from CovidDeaths 
group by location,population
order by 4 desc

--Countries with highest death count per population

Select Location ,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths 
where continent is not null
group by location
order by TotalDeaths desc

--Group by Continent

Select location ,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths 
where continent is null
group by location
order by TotalDeaths desc
--or
Select continent ,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeaths 
where continent is not null
group by continent
order by TotalDeaths desc


--global numbers

Select /*date*/ sum(new_cases) as TotalCases,sum(cast(new_deaths as int))  as TotalDeaths,sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from CovidDeaths 
where continent is not null
/*group by date*/
order by 1,2

-- total population vs vaccinations + per day

select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations 
,sum(Convert(int,vaccs.new_vaccinations)) over (partition by deaths.location 
												order by deaths.location,deaths.date) 
												as CumulativeNewVaccinations
from CovidDeaths deaths
join CovidVaccinations vaccs
	on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
order by 2,3

--use CTE to get the CumulativeNewVaccinations as column

With PopulationVsVacctionations(Continent,Location,Date,Population,New_Vacctionations,CumulativeNewVaccinations)
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations 
,sum(Convert(int,vaccs.new_vaccinations)) over (partition by deaths.location 
												order by deaths.location,deaths.date) 
												as CumulativeNewVaccinations
from CovidDeaths deaths
join CovidVaccinations vaccs
	on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null
)
Select *,(CumulativeNewVaccinations/Population)*100 from PopulationVsVacctionations

--use TempTable

drop table if exists #PopulationVsVacctionations
create table #PopulationVsVacctionations
(Continent nvarchar(255),Location nvarchar(255),Date datetime,Population numeric,New_Vacctionations numeric,CumulativeNewVaccinations  numeric)
insert into #PopulationVsVacctionations
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations 
,sum(Convert(int,vaccs.new_vaccinations)) over (partition by deaths.location 
												order by deaths.location,deaths.date) 
												as CumulativeNewVaccinations
from CovidDeaths deaths
join CovidVaccinations vaccs
	on deaths.location = vaccs.location
	and deaths.date = vaccs.date
--where deaths.continent is not null

Select *,(CumulativeNewVaccinations/Population)*100 from #PopulationVsVacctionations

-- create view to store data for later visualizations

create view PopulationVsVacctionations as 
select deaths.continent, deaths.location, deaths.date, deaths.population, vaccs.new_vaccinations 
,sum(Convert(int,vaccs.new_vaccinations)) over (partition by deaths.location 
												order by deaths.location,deaths.date) 
												as CumulativeNewVaccinations
from CovidDeaths deaths
join CovidVaccinations vaccs
	on deaths.location = vaccs.location
	and deaths.date = vaccs.date
where deaths.continent is not null

select * from PopulationVsVacctionations order by 5
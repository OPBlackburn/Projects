---Queries from table "covid deaths"

Select *
From coviddeaths
where continent is not null
order by 3,4

----Select *
----From [covid vaccinations]
----order by 3,4


--Here are the exact columns that will be used for now
Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
where continent is not null
order by 1,2

-- viewing the most recent deaths based on the last data update
Select location, date, total_cases, new_cases, total_deaths, population
From coviddeaths
order by date desc


--showing the total cases vs total deaths 
Select location, date, total_cases, total_deaths
From coviddeaths
order by 1


--showing the percentage of covid deaths based on the total covid cases in Ghana
Select location, date, total_cases, total_deaths, cast(total_deaths as int)/cast(total_cases as int)*100 as DeathPercentage
From coviddeaths
where location= 'Ghana' and total_cases is not null and total_deaths is not null
order by 1,2

--total covid cases and deaths in the U.S.
Select location, date, total_cases, total_deaths, population
From coviddeaths
where location like '%states%'
and continent is not null
order by 1,5

--percentage of the population in the U.S. actually got covid
Select location, population, total_cases, date, (total_cases/population)*100 as PercentageUSPopulationInfected
From coviddeaths
where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
From coviddeaths
--where location like '%states%'
Group by location, population
order by PercentagePopulationInfected Desc

-- countries with highest death count per population
Select location, population, MAX(cast (total_deaths as int)) as Total_Deaths
From coviddeaths
where continent is not null and location not in ('World', 'Africa', 'Oceania', 'North America','Asia', 'European Union', 'International')
Group by location, population
order by Total_Deaths Desc

-- countries with highest death percentage per population
Create View DeathPercentage (location, population, Total_Deaths) as
Select location, population, MAX(cast (total_deaths as int)) as Total_Deaths
From coviddeaths
where continent is not null and location not in ('World', 'Africa', 'Oceania', 'North America','Asia', 'European Union', 'International')
Group by location, population

Select *
From DeathPercentage



---total death count by location
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
and location not in ('World', 'Africa', 'Oceania', 'North America','Asia', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

select *
from DeathPercentage order by location asc

-- continents with hieghest death count 
select continent, Max(cast(total_deaths as int)) as ContinentsWithHighestCovidDeaths
from coviddeaths
where continent is not null
group by continent
order by ContinentsWithHighestCovidDeaths desc


---Global Covid death
Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(new_cases as int))*100 as DeathPercentage
From coviddeaths
where continent is not null
group by new_cases, new_deaths
order by 1,2

Select SUM(cast(total_deaths as int)) as GlobalCovidDeaths, SUM(cast(total_cases as int)) as GlobalCovidCases
From coviddeaths
where continent is not null
group by continent


Select SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(cast(New_cases as int))*100 as DeathPercentage
From coviddeaths
where continent is not null
order by 1,2


---Queries from table "covid vaccinations"
--join syntax 

select *
from [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date


-- Countries Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations
from [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- Thailand's Population, death and vaccination (did the vaccination potentially reduce/increase death rate or had no impact?)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, new_deaths
from [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location = 'Thailand'
order by date asc, population


-- Rolling count of vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccination
From [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

-- Percentage of Vaccinated population based on 'RollingVaccination' using Common Table Expression (CTE)
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccination)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccination
From [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingVaccination / Population)*100 as PopVsVacPercentage
from PopvsVac


-- Creating views for dashboards
--continent death percentage 
Create View ContinentsDeathPercent AS
Select continent, SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(cast(New_Cases as float))*100 as DeathPercentage
From CovidDeaths
where continent is not null 
group by continent
--order by 1,2

--covid infection percentage in the countries per population
Create View PercentPopInfected AS
Select date, Location, Population, MAX(cast(total_cases as float)) as total_Infection,  Max(cast(total_cases as float))/(population)*100 as PercentPopulationInfected
From CovidDeaths
where not location='World' and not location='Africa' and not location='Oceania' 
and not location='North America' and not location='European Union' and not location='International'
Group by Location, Population, date
--order by location desc

--^^^CONTINUE HERE!!!!!



--vaccinated population 
Create View VaccinatedPopulation AS
select dea.continent, dea.location, dea.date, dea.population, vac.total_vaccinations
from [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2 desc;

-- Highest death count per population
Create View DeathCountPerPop AS
select dea.location, dea.date, dea.population, vac.total_vaccinations, dea.total_deaths
from [covid vaccinations] vac
join coviddeaths dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.location not in ('World', 'Africa', 'Oceania', 'North America','Asia', 'European Union', 'International')
or vac.location not in ('World', 'Africa', 'Oceania', 'North America','Asia', 'European Union', 'International')
--order by 1 desc;


--confirm new view created 
select * 
from ContinentsDeathPercent 

Select *
from PercentPopInfected

select * 
from  VaccinatedPopulation

select * 
from DeathCountPerPop

--drop a view
drop view DeathCountPerPop

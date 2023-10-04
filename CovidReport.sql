SELECT * 
FROM CovidReport..CovidDeaths
where continent IS NOT NULL
Order by 3,4

----SELECT * 
----FROM CovidReport..CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidReport..CovidDeaths
where continent IS NOT NULL
Order by 1,2

--Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidReport..CovidDeaths
where location like '%sia'
and continent IS NOT NULL
Order by 1,2

--Total Cases vs Population
--what percentage of population gets COVID

SELECT location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage 
FROM CovidReport..CovidDeaths
where location like '%europe%'
Order by 1,2

--Looking at countries with highest infection rate compared to total population
SELECT location, population, max(total_cases) as HighestInfectionCount,  max((total_cases/population))*100 as PercentPopulationInfected 
FROM CovidReport..CovidDeaths
--where location like 'Asia'
group by location, population
Order by PercentPopulationInfected desc

--Showing countries with highest deadth count per population
SELECT location, max(total_deaths) as TotalDeathCount
FROM CovidReport..CovidDeaths
--where location like 'Asia'
where continent is not null
group by location
Order by TotalDeathCount desc

--Breaking Things by Continent
--Showing continent with highest deadth count per population
SELECT continent, max(total_deaths) as TotalDeathCount
FROM CovidReport..CovidDeaths
--where location like 'Asia'
where continent is not null
group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT sum(new_cases) as TotalCases, SUM(CAST(new_deaths AS int)) as TotalDeaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))* 100 as DeathPercentage
FROM CovidReport..CovidDeaths
--where location like 'Asia'
where continent is not null
--group by date
Order by 1,2


--Join total population vs vaccinations

select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidReport..CovidDeaths dea
Join CovidReport..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null
order by 2,3

--Using CTE

With PopvsVac (Continent, location, date, Population,  new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidReport..CovidDeaths dea
Join CovidReport..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
from PopvsVac


--TEMP TABLE


DROP table if exists #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidReport..CovidDeaths dea
Join CovidReport..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 as PercentRollingPeopleVaccinated
from #PercentPeopleVaccinated

--Creating view to store data for later visualization

Create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidReport..CovidDeaths dea
Join CovidReport..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where vac.continent is not null
--order by 2,3

select *
from PercentPeopleVaccinated
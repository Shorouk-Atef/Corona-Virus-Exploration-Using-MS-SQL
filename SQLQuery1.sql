Select *
From PortfolioProject..CovidDeaths$
order by 3,4

Select *
From PortfolioProject..CovidVaccinations$
order by 3,4

--Select the data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
order by 1,2

--Looking at total cases vs population
Select location, date,population, total_cases,(total_cases/population)*100 as CasesPercentage
from PortfolioProject..CovidDeaths$
--where location like '%egypt%'
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
--where location like '%egypt%'
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--Showing Countries  with highest death count per population
Select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location,population
order by HighestDeathCount desc

--Showing contintents with the highest death count per population
Select continent ,MAX(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by HighestDeathCount desc

--GLOBAL NUMBERS
Select date ,SUM(new_cases) AS TotalCases ,SUM(cast(new_deaths as int)) AS TotalDeaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPoeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPoeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date= vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPoeopleVaccinated/population)*100
from PopvsVac


DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPoeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date= vac.date
where dea.continent is not null
Select * , (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated


--Create View
create view Percent_PopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPoeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location= vac.location
	AND dea.date= vac.date
where dea.continent is not null
--order by 2,3

SELECT *
from Percent_PopulationVaccinated
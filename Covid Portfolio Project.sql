SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVacinations
--order by 3,4

--SELECT Data that we are going to be using


Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2



--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (Total_deaths/Total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
and continent is not null
order by 1,2


-- Looling at Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, Population, total_cases, (total_cases/population)*100 as percentPopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
order by 1,2


-- Looking at countries with Highest Infection Rate compared to population 


Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as percentPopulationinfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, Population
order by percentPopulationinfected DESC 



-- Showing Countries with Highest Death Count per Population


Select location, MAX(CAST(Total_Deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount DESC 


-- LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing Continents with highest death count per population


Select Continent, MAX(CAST(Total_Deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
WHERE continent is not null
GROUP BY Continent
order by TotalDeathCount DESC 



-- GLOBAL NUMBERS

Select Sum(new_cases) as total_cases, Sum(CAST(new_deaths as int)) as total_deaths, Sum(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
where continent is not null
--group by date 
order by 1,2


-- Looking at total Population vs Vacinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
order by 2,3   




-- Use CTE


With PopvsVac (Continent, location, date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3   
)
SELECT *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



-- TEMP TABLE


drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(max),
Location varchar(max),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--where dea.continent is not null
--order by 2,3   

SELECT *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store datta for later visualization


Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(int,vac.new_vaccinations)) over (PARTITION by dea.location order by dea.location, dea.date) as RollingpeopleVaccinated
--, (RollingpeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
    on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
--order by 2,3   


SELECT *
FROM PercentPopulationVaccinated










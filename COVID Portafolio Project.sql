SELECT* 
FROM PortafolioProject..CovidDeaths
WHERE continent is not null
order by 3, 4

--SELECT* 
--FROM PortafolioProject..CovidVaccinations
--order by 3, 4

-- Select Data that we are going to be using ;

SELECT location , date , total_cases , new_cases , total_deaths , population
FROM PortafolioProject..CovidDeaths
order by 1 , 2 

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country 

SELECT location , date , total_cases , total_deaths, (total_deaths/total_cases)*100 AS DeathPorcentage
FROM PortafolioProject..CovidDeaths
WHERE location like '%states%' 
order by 1 , 2 


-- Looking at Total Cases vs Population 
-- Shows what porcentage of population got Covid 


SELECT location , date , total_cases , population , (total_cases/population)*100 AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
order by 1 , 2 


-- Looking at  Countries with Hieghest Infection Rate to Population 

SELECT location , MAX(total_cases) AS HighestInfectionCount , population , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
GROUP BY location , population 
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Population  


SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc


-- Breaking things down by continent 


SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is null
GROUP by location 
order by TotalDeathCount desc 


SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
GROUP by continent 
order by TotalDeathCount desc 


-- Global numbers 

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths , SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 as DeathPorcentage
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
GROUP BY date
order by 1 , 2 


SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths , SUM(CAST(new_deaths AS INT))/SUM(new_cases)* 100 as DeathPorcentage
FROM PortafolioProject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
order by 1 , 2 



-- Looking at Total Population vs Vaccinations 


SELECT *
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date


SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations , SUM(CONVERT(BIGINT , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3 


--USE CTE

WITH PopvsVac(Continent , Location, Date, Population , New_vaccinations , RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(BIGINT , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated)
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
)
SELECT* ,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac




--TEMP TABLE 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(BIGINT , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated)
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
SELECT* ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated




DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime, 
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(BIGINT , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated)
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3 
SELECT* ,(RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Create View to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location , dea.date, dea.population , vac.new_vaccinations , 
SUM(CONVERT(BIGINT , vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location , dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated)*100
FROM PortafolioProject..CovidVaccinations vac
JOIN PortafolioProject..CovidDeaths dea
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 
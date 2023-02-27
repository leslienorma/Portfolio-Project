/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 AS deathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, total_cases/population *100 AS populationPercentageInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population) *100 AS populationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY populationPercentage DESC


-- Showing Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- CORRECT WAY BELOW:
--SELECT location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
--FROM PortfolioProject.dbo.CovidDeaths
----WHERE location LIKE '%states%'
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY TotalDeathCount DESC

SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations AS INT)) OVER (Partition by death.location ORDER BY death.location, death.date) AS rollingPeopleVaccinated,

FROM PortfolioProject.dbo.CovidDeaths AS death
JOIN PortfolioProject.dbo.CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

-- Use CTE

With PopvsVax AS (SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations AS INT)) OVER (Partition by death.location ORDER BY death.location, death.date) AS rollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS death
JOIN PortfolioProject.dbo.CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL)
--ORDER BY 2,3

SELECT *, (rollingPeopleVaccinated/Population) *100
FROM PopvsVax


-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations AS INT)) OVER (Partition by death.location ORDER BY death.location, death.date) AS rollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS death
JOIN PortfolioProject.dbo.CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL

SELECT *, (rollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations, 
SUM(cast(vax.new_vaccinations AS INT)) OVER (Partition by death.location ORDER BY death.location, death.date) AS rollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths AS death
JOIN PortfolioProject.dbo.CovidVaccinations AS vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated

SELECT *
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM [Portfolio Project].dbo.CovidVaccine
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- Above is to see the main tables for the project

SELECT location, date,total_cases, new_cases,total_deaths, population
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs Total deaths in Malaysia
-- Likelihood of dying if contract Covid in Malaysia

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE location LIKE '%MALAYSIA%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Total cases vs Population
-- Chances to get Covid in Malaysia

SELECT location, date,total_cases, population, (total_cases/population)*100 AS CovidChancesPercentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE location LIKE '%MALAYSIA%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Countries with highest infection count
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_Cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths as BIGINT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Breaking up as continent
-- Showing continents with highest death count

SELECT continent, MAX(CAST(total_deaths as BIGINT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as BIGINT)) AS total_deaths, SUM(CAST(new_deaths as BIGINT))/SUM(new_cases) *100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at total population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidVaccine vac
JOIN [Portfolio Project].dbo.CovidDeath dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE

WITH PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidVaccine vac
JOIN [Portfolio Project].dbo.CovidDeath dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentage
FROM PopVSVac;

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_Vaccination NUMERIC, 
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidVaccine vac
JOIN [Portfolio Project].dbo.CovidDeath dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100 AS RollingPercentage
FROM #PercentPopulationVaccinated


-- CREATE VIEW TO STORE DATA FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidVaccine vac
JOIN [Portfolio Project].dbo.CovidDeath dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

/*
Queries used for Tableau Project
*/



-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeath
--Where location like '%states%'
WHERE continent is not null 
--Group By date
ORDER BY 1,2


-- 2. 

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeath
--Where location like '%states%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeath
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeath
--Where location like '%states%'
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected DESC

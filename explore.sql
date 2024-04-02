SELECT *
FROM dbo.CovidVaccinations
WHERE continent IS NOT NULL;

SELECT *
FROM dbo.CovidDeaths;
-- order by (column number, column number)


-- CASES VS DEATHS 
--resulting data type determined by data types of operands. Need to CAST floating type for the value to be float, instead of data type being INT
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 AS death_rate
FROM dbo.CovidDeaths


-- HIGHEST INFECTION RATE VS DEATHS
--each country will have multiple dates with changing data - e.g more people infected
-- MAX with GROUPBY allows you to find max total cases for each location
SELECT location, population,  MAX(total_cases) AS HighestAmountInfected, MAX((CAST(total_cases AS FLOAT)/population) *100) AS PercentInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentInfected DESC;

-- GLOBAL CASES VS DEATHS
SELECT SUM(new_cases) as TotalCases, SUM(CAST(new_deaths AS INT)) AS totalDeaths, SUM(CAST(new_deaths AS FLOAT))/SUM(new_cases)*100 AS deathPercentage
FROM dbo.CovidDeaths
-- where location LIKE '%states'
WHERE continent IS NOT NULL
ORDER BY TotalCases, totalDeaths

SELECT location
FROM dbo.CovidDeaths
WHERE location LIKE '%_e%'

--- DEATHS VS POPULATION
--test putting into views
SELECT location, population, MAX(total_deaths) AS Deaths, MAX(CAST(total_deaths AS FLOAT)/ population)*100 AS PercentDeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentDeaths DESC;

SELECT location, population, MAX(total_deaths) AS TotalDeaths
FROM dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Deaths DESC;

/*

    JOINING DEATHS TABLE WITH VACCINATIONS TABLE

*/

--total amount of people in the world that are vaccinated?
-- new vaccinations in only for that one date - not total
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations
FROM dbo.CovidDeaths death
JOIN dbo.CovidVaccinations vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY continent, location

--make new column to add up total
--partition per location so it starts over for new countries, without ordering it wont seperate sum over time it just sums everything
-- if you want to use the result of an aggregate function like CountVaccinations in another calculation, theres several methods:

SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CountVaccinations
FROM dbo.CovidDeaths AS death
JOIN dbo.CovidVaccinations AS vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

--1) USE CTE 
WITH populationVacc(continent, location, date, population, new_vaccinations, CountVaccinations)
AS
(
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CountVaccinations
FROM dbo.CovidDeaths AS death
JOIN dbo.CovidVaccinations AS vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
--ORDER BY location, date
)
SELECT *, (CountVaccinations/population)*100
FROM populationVacc

--2) TEMP table
--DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric,
CountVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS CountVaccinations
FROM dbo.CovidDeaths AS death
JOIN dbo.CovidVaccinations AS vac
    ON death.location = vac.location
    AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3

SELECT *, (CountVaccinations/population)*100
FROM #PercentPopulationVaccinated

/*
MY OWN EXPLORATION
*/

-- TOTAL DEATHS  VS TOTAL VACCINATIONS 
--need to improve by using CTE TO split up by location with rolling dates
SELECT 
    deaths.continent, 
    deaths.location, 
    deaths.date, 
    deaths.population, 
    MAX(CAST(total_deaths AS FLOAT)/deaths.population)*100 AS totalDeaths, 
    (MAX(CAST(vacc.total_vaccinations AS FLOAT))/deaths.population)*100 AS totalVaccinations
FROM 
    dbo.CovidDeaths AS deaths
INNER JOIN 
    dbo.CovidVaccinations AS vacc
ON 
    deaths.location = vacc.location
    AND deaths.date = vacc.date
WHERE 
    deaths.continent IS NOT NULL 
    AND deaths.population IS NOT NULL
GROUP BY 
    deaths.continent,
    deaths.location,
    deaths.date,
    deaths.population
ORDER BY 
    totalDeaths DESC, 
    deaths.population ASC, 
    deaths.date DESC;

-- DEATHS VS HANDWASHING FACILITIES, LIFE EXPECTANCY, HOSPITAL BEDS

-- DEATH RATE OVER TIME

-- AMOUNT OF TESTS, POSITIVE RATES, DEATHS


/*CREATING VIEW to store data for later visualisations(T) or queries(saved in views folder)
CREATE View PercentPopulationVaccinated AS
SELECT %%%%
*/

/*
SELECT COUNT(*)
FROM dbo.CovidVaccinations;

SELECT COUNT(*)
FROM dbo.CovidDeaths;
*/

--select data we need
-- order by (column number, column number)
/*
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths;
*/

-- cases vs deaths
--resulting data type determined by data types of operands. Need to CAST floating type for the value to be float, instead of data type being INT
/*
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 AS death_rate
FROM dbo.CovidDeaths
*/


-- countries with highest infection rate compared to population
--each country will have multiple dates with changing data - e.g more people infected
-- MAX with GROUPBY allows you to find max total cases for each location
SELECT location, population,  MAX(total_cases) AS HighestAmountInfected, MAX((CAST(total_cases AS FLOAT)/population) *100) AS PercentInfected
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentInfected DESC

--- highest death per population
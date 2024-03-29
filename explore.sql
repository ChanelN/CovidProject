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

-- cases vs deaths?
--resulting data type determined by data types of operands. Need to CAST floating type for the value to be float, instead of data type being INT
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 AS death_rate
FROM dbo.CovidDeaths

-- total cases vs population

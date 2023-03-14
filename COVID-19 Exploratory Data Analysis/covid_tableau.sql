/*
Queries used for Tableau Project
*/

-- 1. 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS death_percentage
FROM covid_project..covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- 2. 

WITH t1 AS
	(
		SELECT continent, location, population, MAX(CAST(total_deaths AS bigint)) AS total_deaths
		FROM covid_project..covid_deaths
		GROUP BY location, continent, population
	)
SELECT continent, SUM(total_deaths) AS total_deaths
FROM t1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC;

-- 3.

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infected_population_percentage
FROM covid_project..covid_deaths
GROUP BY location, population
ORDER BY infected_population_percentage DESC;


-- 4.

SELECT location, population, date, MAX(total_cases) AS infection_count, MAX((total_cases/population))*100 AS infected_population_percentage
FROM covid_project..covid_deaths
GROUP BY location, population, date
ORDER BY infected_population_percentage DESC;

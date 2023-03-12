-- Exploring the data
SELECT TOP(5000) *
FROM covid_project..covid_deaths;

-- Selecting the data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_project..covid_deaths
ORDER BY 1,2;

-- Looking at total cases vs total deaths in the US
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_project..covid_deaths
WHERE location = 'United States'
ORDER BY 1,2;

-- Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_percentage
FROM covid_project..covid_deaths
WHERE location = 'United States'
ORDER BY 1,2;

-- Comparing covid death percentage of population for each country
SELECT location, AVG(population) AS population, MAX(CAST(total_deaths AS bigint)) AS total_deaths, (MAX(CAST(total_deaths AS bigint))/AVG(population))*100
		AS death_percentage
FROM covid_project..covid_deaths
GROUP BY location
ORDER BY death_percentage DESC;

-- Showing number of new cases and deaths day by day, globally
SELECT date, SUM(new_cases) AS new_cases, SUM(CAST(new_deaths AS int)) AS new_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases+0.01))*100 AS death_percentage
FROM covid_project..covid_deaths
GROUP BY date
ORDER BY date;

-- Looking at total population vs vaccination per day (new vaccinations)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;

-- Pulling up the day with the most vaccinations in the US
WITH t1 AS
	(
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
		FROM covid_project..covid_deaths dea
		JOIN covid_project..covid_vaccinations vac
			ON dea.location = vac.location AND dea.date = vac.date
		WHERE dea.location = 'United States'
	)
SELECT *
FROM t1
WHERE new_vaccinations = 
	(SELECT MAX(CAST(new_vaccinations AS int))
	 FROM t1);

/* Creating a rolling count for vaccinations
  (this is given by total_vaccinations, but we'll do it using new_vaccinations) */
SELECT  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS rolling_vac_count
FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Showing the death figures for continents using Temp Tables
DROP TABLE IF EXISTS #continent_death
CREATE TABLE #continent_death
(
continent nvarchar(255),
location nvarchar(255),
population float,
total_deaths bigint
)
INSERT INTO #continent_death
SELECT continent, location, population, MAX(CAST(total_deaths AS bigint)) AS total_deaths
FROM covid_project..covid_deaths
WHERE continent IS NOT NULL
GROUP BY location, continent, population

SELECT continent, SUM(population) AS population, SUM(total_deaths) AS total_deaths, (SUM(total_deaths)/SUM(population))*100 AS death_percentage
FROM #continent_death
GROUP BY continent
ORDER BY death_percentage DESC;

-- Showing the death figures for continents using a CTE
WITH t1 AS
	(
		SELECT continent, location, population, MAX(CAST(total_deaths AS bigint)) AS total_deaths
		FROM covid_project..covid_deaths
		GROUP BY location, continent, population
	)
SELECT continent, SUM(population) AS population, SUM(total_deaths) AS total_deaths, (SUM(total_deaths)/SUM(population))*100 AS death_percentage
FROM t1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY death_percentage DESC;

-- Creating a VIEW to store data for later visualizations
CREATE VIEW death_by_continent AS
WITH t1 AS
	(
		SELECT continent, location, population, MAX(CAST(total_deaths AS bigint)) AS total_deaths
		FROM covid_project..covid_deaths
		GROUP BY location, continent, population
	)
(
SELECT continent, SUM(population) AS population, SUM(total_deaths) AS total_deaths, (SUM(total_deaths)/SUM(population))*100 AS death_percentage
FROM t1
WHERE continent IS NOT NULL
GROUP BY continent
)

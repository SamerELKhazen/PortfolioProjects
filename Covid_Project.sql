SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `covid-385522.Covid.covid_deaths`
Order By 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM `covid-385522.Covid.covid_deaths`
where location = "Canada"
Order By 2

-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_percentage
FROM `covid-385522.Covid.covid_deaths`
where location = "Canada"
ORDER BY 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS highest_infection_count, max((total_cases/population))*100 AS infected_percentage
FROM `covid-385522.Covid.covid_deaths`
GROUP BY LOCATION, population
ORDER BY 4 DESC

-- Looking at countries with highest death count per population

SELECT location, population, MAX(total_deaths) AS highest_death_count, max((total_deaths/population))*100 AS death_percentage
FROM `covid-385522.Covid.covid_deaths`
GROUP BY LOCATION, population
ORDER BY 4 DESC

-- Looking at countries with highest death count

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM `covid-385522.Covid.covid_deaths`
WHERE continent is not null
GROUP BY LOCATION
ORDER BY 2 DESC

-- Looking at continents with highest death count

SELECT location, MAX(cast(total_deaths as int)) AS highest_death_count
FROM `covid-385522.Covid.covid_deaths`
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC

-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100 ELSE 0 END as death_percentage
FROM `covid-385522.Covid.covid_deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Joining the 2 tables

SELECT *
from  `covid-385522.Covid.covid_deaths` as dea
join  `covid-385522.Covid.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date

-- Looking at total vaccination vs population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from  `covid-385522.Covid.covid_deaths` as dea
join  `covid-385522.Covid.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  `covid-385522.Covid.covid_deaths` as dea
join  `covid-385522.Covid.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE 

with PopvsVac
AS (select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from  `covid-385522.Covid.covid_deaths` as dea
join  `covid-385522.Covid.covid_vaccinations` as vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3)
SELECT*, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM PopvsVac

-- Creating a Temp Table

DROP TABLE IF EXISTS covid-385522.Covid.PopvsVac;
CREATE TEMPORARY TABLE PopvsVac (
continent STRING,
location STRING,
date DATE,
population INT64,
new_vaccinations INT64,
RollingPeopleVaccinated INT64
);

INSERT INTO PopvsVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-385522.Covid.covid_deaths` AS dea
JOIN `covid-385522.Covid.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;
SELECT*, (RollingPeopleVaccinated/population)*100 AS Vaccination_Percentage
FROM PopvsVac
order by 2,3

-- Creating Views to store for visualizations

CREATE VIEW covid-385522.Covid.PopvsVac as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM `covid-385522.Covid.covid_deaths` AS dea
JOIN `covid-385522.Covid.covid_vaccinations` AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;



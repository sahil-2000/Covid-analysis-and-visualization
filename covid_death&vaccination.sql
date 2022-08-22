use portfolioProject
SELECT * FROM covid_death$
WHERE continent IS NOT NULL
ORDER BY 3,4
--this order by will order my data based on collumn 3 and 4


--LETS JUST SELECT THE DATA THAT WE WANTTO USE

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_death$
WHERE continent IS NOT NULL
ORDER BY 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATH

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS death_percent
FROM covid_death$
WHERE location ='india'
AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
SELECT location,date,total_cases,population,(total_cases/population)*100 AS infected_percent
FROM covid_death$
WHERE location ='india'
AND continent IS NOT NULL
ORDER BY 1,2


--LOOKING AT COUNTRY WITH HIGHEST INFECTION RATE COMPARED TO POPOULATION
SELECT location,population,MAX(total_cases) AS highestInfectionCount,MAX((total_cases/population)*100) AS highestInfected_percent
FROM covid_death$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY highestInfected_percent desc


--LOOKING AT COUNTRIES WITH HIGHEST DEATH RATE
SELECT location,population,MAX(total_cases) AS totalInfectionCount,MAX(total_deaths) AS totalDeathCount,((MAX(total_deaths)/MAX(total_cases))*100) AS highestDeath_percent
FROM covid_death$
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY highestDeath_percent desc


--SHOWING COUNTRY WITH HIGHEST DEATH COUNT
SELECT location,MAX(CAST(total_deaths as int)) AS totalDeathCount
FROM covid_death$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totalDeathCount DESC


--CONTINENT DATA
SELECT location,MAX(CAST(total_deaths as int)) AS totalDeathCount
FROM covid_death$
WHERE continent IS NULL
GROUP BY location
ORDER BY totalDeathCount DESC

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT
SELECT continent,sum(cast(new_deaths as int)) as totalDeathContinent
FROM covid_death$
where continent is not null
GROUP BY continent


--GLOBAL COVID DATA GROUPED BY THE DATE

SELECT date,sum(cast(new_cases as int)) as totalCases,sum(cast(new_deaths as int)) as totalDeaths
FROM covid_death$
GROUP BY date
order by 1,2

--JOINING TWO TABLE
--TOTAL POPULATION VS VACCINATION

SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccinatedPeople 
FROM covid_death$ dea INNER JOIN covid_vaccination$ vac 
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 1,2

--USING CTE 

with PopVsVac (location,date,population,new_vaccinations,rollingVaccinatedPeople)
as
(
SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccinatedPeople 
FROM covid_death$ dea INNER JOIN covid_vaccination$ vac 
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

)
SELECT location,(rollingVaccinatedPeople/population)*100 as percentvaccinated
from PopVsVac
order by 1,2


--CREATE VIEW TO STORE DATA FOR LATER VISUALISATION
CREATE VIEW PercentPopulationVacinated as

SELECT dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingVaccinatedPeople 
FROM covid_death$ dea INNER JOIN covid_vaccination$ vac 
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject ..CovidDeaths
ORDER BY 1,2

-- total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Portfolioproject ..CovidDeaths
WHERE location = 'kenya'
ORDER BY 1,2

--total people infected in the population
SELECT location, date, population, total_cases, (total_deaths/population)*100 AS DeathPercentage
FROM Portfolioproject ..CovidDeaths
WHERE location = 'kenya'
ORDER BY 1,2

-- Countries with the highest infection rate
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Portfolioproject ..CovidDeaths
--WHERE location = 'kenya'
GROUP BY location,population
ORDER BY PercentPopulationInfected desc

-- Showing countries with highest death rate
SELECT location, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject ..CovidDeaths
--WHERE location = 'kenya'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing continents with highest death rate
SELECT continent, MAX(cast(Total_deaths AS int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
--WHERE location = 'kenya'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
--covid infection cases and deaths around the globe

SELECT date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/SUM(new_cases)*100 as death_percentage
FROM Portfolioproject ..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--total covid infection cases and deaths

SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))
/SUM(new_cases)*100 as death_percentage
FROM Portfolioproject ..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--total population vs total vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,SUM(cast(vacci.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativePeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vacci
ON dea.location = vacci.location
and dea.date = vacci.date
WHERE dea.continent is not null
ORDER BY 2,3
 
 --CTE

 WITH TotalpopvsVac (Continent, Location, Date, Population,New_vaccinations, CummulativePeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,SUM(cast(vacci.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativePeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vacci
ON dea.location = vacci.location
and dea.date = vacci.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (CummulativePeopleVaccinated/Population)*100
FROM TotalpopvsVac
 
 --TEMP TABLE

 DROP TABLE if exists #populationpercentagevaccinated
CREATE TABLE #populationpercentagevaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
CummulativePeopleVaccinated numeric
)

 INSERT INTO #populationpercentagevaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,SUM(cast(vacci.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativePeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vacci
ON dea.location = vacci.location
and dea.date = vacci.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (CummulativePeopleVaccinated/Population)*100
FROM #populationpercentagevaccinated

--creating view to store data for later visualizations

CREATE VIEW populationpercentagevaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vacci.new_vaccinations
,SUM(cast(vacci.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CummulativePeopleVaccinated
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vacci
ON dea.location = vacci.location
and dea.date = vacci.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM populationpercentagevaccinated
 









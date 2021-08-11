SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--WHERE continent is NOT NULL
--ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases VS Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' and continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases VS Population

SELECT location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%state%' and continent is NOT NULL
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rates VS Population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY InfectedPercentage desc


-- Looking at Countries with Highest Death Count VS Population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc


-- Looking at Continents with Highest Death Count VS Population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Looking at Data Globally: Total Cases VS Total Deaths

SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as INT)) as TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


-- Looking at Total Population VS Total Vaccinations
-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaccinationCount)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinationCount/population)*100 as VaccinationPercentage
FROM PopvsVac


-- USE TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinationCount numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (RollingVaccinationCount/population)*100 as VaccinationPercentage
FROM #PercentPopulationVaccinated


-- Create View for Data Visualization

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
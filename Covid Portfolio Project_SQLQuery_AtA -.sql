SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC

--Showing continents with the highest death counts per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC



-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
Group by date
order by 1,2

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--Group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date)
	AS Rolling_People_Vaccinated, 
	--(Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Deaths
JOIN  PortfolioProject..CovidVaccinations as Vac
	ON Deaths.location = Vac.location
	and Deaths.date = Vac.date
	WHERE Deaths.continent is NOT NULL
	ORDER BY 2,3
	
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date)
	AS Rolling_People_Vaccinated 
	--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Deaths
JOIN  PortfolioProject..CovidVaccinations as Vac
	ON Deaths.location = Vac.location
	and Deaths.date = Vac.date
	WHERE Deaths.continent is NOT NULL
	--ORDER BY 2,3
)
Select *, (Rolling_People_Vaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date)
	AS Rolling_People_Vaccinated 
	--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Deaths
JOIN  PortfolioProject..CovidVaccinations as Vac
	ON Deaths.location = Vac.location
	and Deaths.date = Vac.date
	WHERE Deaths.continent is NOT NULL
	--ORDER BY 2,3

Select *, (Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated as 
Select Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vac.new_vaccinations, 
SUM(CONVERT(int, Vac.new_vaccinations)) OVER (Partition by Deaths.location ORDER BY Deaths.location, Deaths.date)
	AS Rolling_People_Vaccinated 
	--, (Rolling_People_Vaccinated/population)*100
FROM PortfolioProject..CovidDeaths as Deaths
JOIN  PortfolioProject..CovidVaccinations as Vac
	ON Deaths.location = Vac.location
	and Deaths.date = Vac.date
	WHERE Deaths.continent is NOT NULL
	--ORDER BY 2,3
SELECT * 
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..Covid_vaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_deaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM PortfolioProject..Covid_deaths
WHERE location like 'india' and continent is not null
ORDER BY 1,2

-- Shows the likelihood of dying if you infect in India
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM PortfolioProject..Covid_deaths
WHERE location like 'india' and continent is not null
ORDER BY 1,2

-- Looking at the Total Cases vs Total Population
-- Shows the %age of Population got Covid
SELECT location, date, Population, total_cases, round((total_cases/Population)*100,5) as Infected_percentage
FROM PortfolioProject..Covid_deaths
-- WHERE location like 'india'
WHERE continent is not null
ORDER BY 1,2

-- Looking at the Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(round((total_cases/Population)*100,5)) as Infected_Population_percentage
FROM PortfolioProject..Covid_deaths
-- WHERE location like 'india'
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 desc

-- Showing Countries with the Highest Death Counts per Population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..Covid_deaths
-- WHERE location like 'india'
WHERE continent is not null
GROUP BY location
ORDER BY HighestDeathCount desc

-- LET'S BREAK THINGS BY CONTINENT WISE

-- Showing the continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS HighestDeathCount
FROM PortfolioProject..Covid_deaths
-- WHERE location like 'india'
WHERE continent is not null
GROUP BY continent
ORDER BY HighestDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, 100*SUM(cast(new_deaths as int))/SUM(new_cases) as Death_Perc
FROM PortfolioProject..Covid_deaths
-- WHERE location like 'india' 
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location=vac.location and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location=vac.location and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, 100*(Rolling_People_Vaccinated/Population)
FROM PopvsVac


-- TEMP TABLE

Drop Table #Percent_Population_Vaccinated
Create Table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

INSERT INTO #Percent_Population_Vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location=vac.location and dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT *, 100*(Rolling_People_Vaccinated/Population)
FROM #Percent_Population_Vaccinated
 

-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
,SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_People_Vaccinated
FROM PortfolioProject..Covid_deaths dea
JOIN PortfolioProject..Covid_vaccinations vac
	ON dea.location=vac.location and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
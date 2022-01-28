/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Previewing data

Select *
FROM PortfolioProject..CovidDeaths_Project_1$
Where continent is not null
order by 3,4

Select *
FROM PortfolioProject..CovidVaccinations$
order by 3,4

-- Select data for exploration

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths_Project_1$
order by 1,2

-- Looking at total cases vs Total Deaths
-- Shows how likely is someone diying infected by covid in my country, Dominican Republic
Select Location, date, total_cases, total_deaths, (Total_deaths/Total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_Project_1$
Where Location like '%Dominican%'
order by 1,2

--Looking at total cases X population
Select Location, date, Population, Total_cases, (Total_cases/Population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths_Project_1$
Where Location like '%Dominican%'
order by 1,2

-- Looking at the countries with highest infection rate compared to Population

Select Location, Population, MAX(Total_cases) as highestInfectionCount, MAX((Total_cases/Population))*100 AS PercentofpopulationInfected
FROM PortfolioProject..CovidDeaths_Project_1$
--Where Location like '%Dominican%'
Group by Location, Population
order by PercentofpopulationInfected desc

--Showing countries with highest death count per population

--Breaking things down by continent

--Showing the continents with highest death counts 

Select continent, Max(cast(total_deaths as int)) as totaldeathcount
FROM PortfolioProject..CovidDeaths_Project_1$
--Where Location like '%Dominican%'
Where continent is not null
Group by continent
order by totaldeathcount desc;

-- Global Numbers

Select date, SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths_Project_1$
--Where Location like '%Dominican%'
Where continent is not null
Group by date
order by 1,2;

-- Global Deaths 
Select SUM(new_cases) as cases, SUM(cast(new_deaths as int)) as deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths_Project_1$
--Where Location like '%Dominican%'
Where continent is not null
--Group by date
order by 1,2;

--Looking at total population vs vaccinations

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, Rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order By dea.location,
dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100 --Shows percentage of population that has received at least one Covid vaccine
FROM PortfolioProject..CovidDeaths_Project_1$ dea
Join PortfolioProject..CovidVaccinations$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

--CTE calculations on partition by previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths_Project_1$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table to perform calculation
DROP TABLE if exists #PercentPopulationVaccinated
Create Table  #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order By dea.location,
dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_Project_1$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
    On dea.location = vac.location
	and dea.date = dea.date
WHERE dea.continent is not null

Select *, (Rollingpeoplevaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for tableau viz

Create View PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order By dea.location,
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths_Project_1$ dea
Join PortfolioProject..CovidVaccinations$ vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * 
From PercentPopulationVaccinated2

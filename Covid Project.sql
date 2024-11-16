/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- Selecting data 

Select location,date, total_cases , new_cases, total_deaths,population
FROM CovidProject..CovidDeaths
order by 1,2

--Checking for death percentage 
Select location , date , total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
order by 1,2

-- Checking for total cases vs Population 
-- gives us percentage of population infected by covid.
Select location , date , total_cases , population, (total_cases/population)*100 as InfectionPercentage
FROM CovidProject..CovidDeaths
order by 1,2

-- Countries with Highest Infection Rate compared to Population
Select location , MAX(total_cases)  as TotalInfected, population, MAX((total_cases/population)*100 )as InfectionPercentage
FROM CovidProject..CovidDeaths
group by location,population
order by InfectionPercentage desc

-- Countries with Highest Death count per Population
Select location  , MAX(cast(total_deaths as int)) as totalDeaths
FROM CovidProject..CovidDeaths
group by location 
order by totalDeaths desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent  , MAX(cast(total_deaths as int)) as totalDeaths
FROM CovidProject..CovidDeaths
where continent is not null
group by continent 
order by totalDeaths desc

-- GLOBAL NUMBERS

Select SUM(cast(new_cases as int)) as total_cases , SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null AND dea.location = 'India'
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent , Location , Date , Population	, New_Vaccinations , RollingPeopleVaccinated)

as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select * , (RollingPeopleVaccinated/Population)*100  FROM PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated 
as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * FROM PercentPopulationVaccinated
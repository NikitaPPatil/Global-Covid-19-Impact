
Select * 
From CovidProject..CovidDeaths
Order by 3,4

--Select * 
--From CovidProject..CovidVaccinations
--Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths
Order by 1,2


--Total case vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like '%state%'
Order by 1,2

-- shows what percentage of population got covid
Select Location, date, Population, total_cases, (total_cases/population)*100 as DeathPercentage
From CovidProject..CovidDeaths
where location like '%state%'
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select Location, Population, MAX (total_cases) as HighestInfection, Max (total_cases/population)*100 as PercentagePopulationInfected
From CovidProject..CovidDeaths
-- where location like '%state%'
Group by Location, Population
Order by PercentagePopulationInfected desc


-- Showing countries with highest deadth counts per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
-- where location like '%state%'
where continent is not null
Group by Location
Order by TotalDeathCount desc


--Breaking by Continent
--Showing the contintents with the highest death rates per populations
Select Continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
-- where location like '%state%'
where continent is not null
Group by Continent
Order by TotalDeathCount desc



-- Global Numbers

Select SUM (new_cases), SUM(cast(new_deaths as int )) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
--where location like '%state%'
where continent is not null
--Group by date 
Order by 1,2


-- Total Populations VS Vaccination
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations ,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table
--Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_Vaccinated numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating view to store data for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated


Select *
From PortfolioProject..[COVID-DEATHS]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[covid vaccinations]
--order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..[COVID-DEATHS]
order by 1,2


-- Looking at Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..[COVID-DEATHS]
Where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..[COVID-DEATHS]
--Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infections Rate compared to Population


Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..[COVID-DEATHS]
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- LETS BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID-DEATHS]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..[COVID-DEATHS]
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers



Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..[COVID-DEATHS]
--Where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[COVID-DEATHS] dea
Join PortfolioProject..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[COVID-DEATHS] dea
Join PortfolioProject..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- TEMP TABLE


Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population Numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[COVID-DEATHS] dea
Join PortfolioProject..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated






--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..[COVID-DEATHS] dea
Join PortfolioProject..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


Select*
From PercentPopulationVaccinated
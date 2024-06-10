SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
ORDER BY 3,4

-- SELECT *
-- FROM PortfolioProject..CovidVaccinations$
-- ORDER BY 3,4

-- Select data to use
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases Vs Total Deaths
-- Calculate the likelihood of dying from Covid

Select Location, date, total_cases, total_deaths, Round((total_deaths / total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2

-- Total Cases Vs Population
-- Calculate the percentage of people getting Covid
Select Location, date, population, total_cases, Round((total_cases / population)*100,2) as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
where location like '%india%'
and continent is not null
order by 1,2

-- Countries with the highest infection rate compared to population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(Round((total_cases / population)*100,2)) as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location, population
order by InfectedPopulationPercentage desc

-- Countries with the highest death count per population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathCount desc


-- Breaking things down by Continent
-- Continents with the highest death counts per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Continents with the highest infection rate compared to population
Select Continent, population, MAX(total_cases) as HighestInfectionCount, MAX(Round((total_cases / population)*100,2)) as InfectedPopulationPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by Continent, population
order by InfectedPopulationPercentage desc

-- Global Numbers
-- Summarize the global total cases, total deaths, and death percentage by date

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
order by 1,2

-- Total Death Percentage Globally
-- Calculate the global total cases, total deaths, and death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, ROUND(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Population Vs Vaccinations
-- Join CovidDeaths and CovidVaccinations tables and calculate the rolling number of people vaccinated

Select D.continent, D.location, D.date, D.population,V.new_vaccinations,
SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.Location Order by D.Location, D.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
On D.location = V.location
and D.date = V.date
Where D.continent is not null
order by 2,3

-- Use CTE (Common Table Expression)
-- Calculate the percentage of people vaccinated over time

With PopulationVSVaccinations(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select D.continent, D.location, D.date, D.population,V.new_vaccinations,
SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.Location Order by D.Location, D.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
On D.location = V.location
and D.date = V.date
Where D.continent is not null
--order by 2,3
) Select *, ROUND((RollingPeopleVaccinated/population)*100,2) as VaccinationRate
From PopulationVSVaccinations


-- Use a temp Table
-- Drop the temp table if it exists
Drop Table if exists #PercentPopulationVaccinated

-- Create a temp table to store the percentage of population vaccinated
Create Table #PercentPopulationVaccinated
(continent varchar(255), 
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

-- Insert data into the temp table
Insert Into #PercentPopulationVaccinated 
Select D.continent, D.location, D.date, D.population,V.new_vaccinations,
SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.Location Order by D.Location, D.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
On D.location = V.location
and D.date = V.date
Where D.continent is not null
--order by 2,3

-- Select data from the temp table and calculate the percentage of population vaccinated
Select *, ROUND((RollingPeopleVaccinated/population)*100,2) as VaccinationRate
From #PercentPopulationVaccinated 


-- Create a View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select D.continent, D.location, D.date, D.population,V.new_vaccinations,
SUM(Cast(V.new_vaccinations as int)) OVER (Partition by D.Location Order by D.Location, D.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ D
Join PortfolioProject..CovidVaccinations$ V
On D.location = V.location
and D.date = V.date
Where D.continent is not null


-- Select all data from the view for analysis
Select *From PercentPopulationVaccinated

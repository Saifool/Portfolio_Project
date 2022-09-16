--select * from CovidDeaths
--order by 3,4

Select * from CovidVaccinations where continent is not null
Order by 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths

-- Shows liklihood of dying if you contract covid in your contry
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like 'bang%'
order by 1,2

-- Looking at Total cases vs Total Deaths
Select location, date, population,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
from CovidDeaths
where location like 'bang%'
order by 1,2

-- Countries with the Hightest Infection Rate compared to population

Select location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
--where location like 'bang%'
group by location,population
order by PercentagePopulationInfected desc


-- Countries with Hightes Death Count per population

select location, max(cast(Total_deaths as int)) as TotalDeathCount --use cast becasus of wrong data type in the column
from PortfolioProject..CovidDeaths
where continent is not null
Group by  location
Order by TotalDeathCount desc

-- Let's Break things down by Continents

-- Continent with the Highest Death count per population 
select continent, max(cast(Total_deaths as int)) as TotalDeathCount --use cast becasus of wrong data type in the column
from PortfolioProject..CovidDeaths
where continent is NOT null
Group by  continent
Order by TotalDeathCount desc

-- Global Numbers

Select date, sum(new_cases), sum(cast(new_deaths as int))
from PortfolioProject..CovidDeaths
--where location like 'bang%'
where continent is not null
group by date
order by 1,2

-- Death % globally per day

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercetage
from PortfolioProject..CovidDeaths
--where location like 'bang%'
where continent is not null
group by date
order by 1,2

-- Death % globally

Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercetage
from PortfolioProject..CovidDeaths
--where location like 'bang%'
where continent is not null
--group by date
order by 1,2

--- Join both death & vacc table
select * 
from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
ON dea.location = vac.location
and dea.date = vac.date


-- Total Population vs Vaccinations

select dea.continent, dea.location, dea.population, vac.new_vaccinations

from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

-- 

select dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location)

from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

---
select dea.continent, dea.location, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date)
from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	)
	select * , (RollingPeopleVaccinated/population)*100
	from PopvsVac


	--- TEMP Table

	Drop table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar (255),
	location nvarchar (255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	insert into #PercentPopulationVaccinated
	select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
select * , (RollingPeopleVaccinated/population)*100
	from #PercentPopulationVaccinated


	--Creating view to store data for later visualisation

	create view PercentPopulationVaccinated as
	select dea.continent, dea.location, dea. date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea JOIN
PortfolioProject..CovidVaccinations vac 
	ON dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	select * 
	from PercentPopulationVaccinated
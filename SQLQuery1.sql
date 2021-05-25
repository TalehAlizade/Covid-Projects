
select *
from SqlProject..['owid-covid-data$']
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from SqlProject..['owid-covid-data$']
where continent is not null
order by 1,2

--Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 as DeathPercentage
from SqlProject..['owid-covid-data$']
where continent is not null
order by 1,2

-- The Highest Infection rate compared to Population

select location, population , MAX(total_cases) as HighestInfection, MAX((total_cases/population))*100.0 as PercentPopulationInfected
from SqlProject..['owid-covid-data$']
where continent is not null
Group by population, location
order by PercentPopulationInfected desc

-- Countries with the highest death rate

select location,  MAX(cast(total_deaths as int)) as TotalDeath 
from SqlProject..['owid-covid-data$']
where continent is not null
Group by  location
order by TotalDeath desc

--Continent with the highest death rate

select continent,  MAX(cast(total_deaths as int)) as TotalDeath 
from SqlProject..['owid-covid-data$']
where continent is not  null
Group by  continent
order by TotalDeath desc

--Global Numbers

select   SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100.0 as  DeathPercentage
from SqlProject..['owid-covid-data$']
where continent is not null
order by 1,2


Select *
from SqlProject..['owid-covid-data$'] dea
Join SqlProject..['Covid vactions$'] vac
On d.location = v.location
and d.date = v.date

--Total population vs vaccinaitons

Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as peopleVaccinated
from SqlProject..['owid-covid-data$'] d
Join SqlProject..['Covid vactions$'] v
On d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1,2

With VaccinatedRate (continent, location, date, population, new_vaccinations, peopleVaccinated) 
as (
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as int)) OVER (partition by d.location order by d.location, d.date) as peopleVaccinated
from SqlProject..['owid-covid-data$'] d
Join SqlProject..['Covid vactions$'] v
On d.location = v.location
and d.date = v.date
where d.continent is not null )
select *, (peopleVaccinated/population)*100
from VaccinatedRate

--creating Table
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
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as peopleVaccinated
from SqlProject..['owid-covid-data$'] d
Join SqlProject..['Covid vactions$'] v
On d.location = v.location
and d.date = v.date


--Creating view 
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(int,v.new_vaccinations)) OVER (Partition by d.Location Order by d.location, d.Date) as peopleVaccinated
from SqlProject..['owid-covid-data$'] d
Join SqlProject..['Covid vactions$'] v
On d.location = v.location
	and d.date = v.date
where d.continent is not null 


--select * 
--from PortfolioProject..Covidvactination 
--where continent is not null
--order by 3,4

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths 
where continent is not null
order by 1,2

-- total cases vs total deaths
-- likelihood of dying if you have covid in Poland 
select location,date, total_cases,total_deaths,(total_deaths/total_cases)* 100 as death_percentage
from PortfolioProject..coviddeaths
where location like '%Poland%' and continent is not null
order by 1,2


-- total cases/population
select location,date, total_cases,population,(total_cases/population)* 100 as gotcovid
from PortfolioProject..coviddeaths
where location like '%Poland%'  and continent is not null
order by 1,2
--highest infection rate 
select location, MAX(total_cases) as highest_infection ,population,MAX((total_cases/population)* 100) as Percentageinfected
from PortfolioProject..coviddeaths
where continent is not null
group by location,population
order by Percentageinfected desc

--highest death count by country 
select location, MAX(cast(total_deaths as int)) as highest_deathcount 
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by highest_deathcount  desc

--highest death count by continent 
select location, MAX(cast(total_deaths as int)) as highest_deathcount 
from PortfolioProject..coviddeaths
where continent is null
group by location
order by highest_deathcount  desc

-- continents with highest death 
select location, MAX(cast(total_deaths as int)) as highest_deathcount 
from PortfolioProject..coviddeaths
where continent is null
group by location
order by highest_deathcount  desc


--global numbers 
select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Deathpercentage 
from PortfolioProject..coviddeaths
Where continent is not null
group by date 
order by 1,2


select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Deathpercentage 
from PortfolioProject..coviddeaths
Where continent is not null
order by 1,2
--  total vactination rate 
with popandvac ( continent,location,date, population,new_vaccinations,rollingvaccinated )
as 
(
select de.continent,de.location, de.date,de.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by de.location order by de.date) 
as rollingvaccinated 
from PortfolioProject..coviddeaths de join 
PortfolioProject..covidvactinations  vac on (de.location=vac.location and de.date=vac.date)
where de.continent is not null
--order by 2,3
)
Select *,(rollingvaccinated/population)*100 from popandvac



-- temp table 
drop table  if exists #percentpopvac
Create Table #percentpopvac 
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaccinated numeric
)
insert into #percentpopvac 
select de.continent,de.location, de.date,de.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by de.location order by de.date) 
as rollingvaccinated 
from PortfolioProject..coviddeaths de join 
PortfolioProject..covidvactinations  vac on (de.location=vac.location and de.date=vac.date)
where de.continent is not null
--order by 2,3
Select *,(rollingvaccinated/population)*100 from 
#percentpopvac

--create view to store data
create view percentpopulationvaccinated as 
select de.continent,de.location, de.date,de.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER(Partition by de.location order by de.date) 
as rollingvaccinated 
from PortfolioProject..coviddeaths de join 
PortfolioProject..covidvactinations  vac on (de.location=vac.location and de.date=vac.date)
where de.continent is not null
--order by 2,3
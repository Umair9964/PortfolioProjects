select *
From PortfolioProject..[Covid deaths]
where continent!=' ' 
order by 3,4


--select *
--From PortfolioProject..[Covid vaccinations]
--order by 3,4

-- select the data that we are going to be using

--select location, date , total_cases,new_cases,total_deaths, population
--From PortfolioProject..[Covid deaths]
--order by 1,2


--Looking at total_cases vs total_deaths
--Shows the likelihood of dying if you contract Covid in your country
select location, date ,total_cases,total_deaths,cast(total_deaths as float)/nullif(cast(total_cases as float),0)*100 as DeathPercentage
From PortfolioProject..[Covid deaths]
where location like '%states%'
order by 1,2


--SELECT 
--TABLE_CATALOG,
--TABLE_SCHEMA,
--TABLE_NAME, 
--COLUMN_NAME, 
--DATA_TYPE 
--FROM INFORMATION_SCHEMA.COLUMNS


--Looking at the total cases vs the population

select location, cast(date as datetime) ,total_cases,population,cast(total_cases as float)/nullif(cast(population as float),0)*100 as DeathPercentage
From PortfolioProject..[Covid deaths]
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rates

select location,max(total_cases) as HighestInfectioncount,population,max(cast(total_cases as float)/nullif(cast(population as float),0))*100 as PercentPopulationinfected
From PortfolioProject..[Covid deaths]
--where location like '%states%'
Group by population,location
order by PercentPopulationinfected desc

--Showing countries with highest death count per population

select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid deaths]
where continent!=' ' 
Group by location
order by TotalDeathCount desc


--Lets break things down by continent
--Showing continents with highest death count

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..[Covid deaths]
where continent!=' ' 
Group by continent
order by TotalDeathCount desc

--Global numbers

select sum(cast(new_cases as float)) as Total_cases,sum(cast(new_deaths as float)) as Total_Deaths,sum(cast(new_deaths as float))/SUM(nullif(cast(new_cases as float),0))*100 as DeathPercentage
From PortfolioProject..[Covid deaths]
where continent!=' '
--group by date
order by 1,2

--looking at total populations vs vaccinations
--Creating a CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,cast(dea.date as datetime) as date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..[Covid deaths] as dea
join PortfolioProject..[Covid vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=' '
)

select*,(RollingPeopleVaccinated/population)
from PopvsVac

--Temp table approach

Drop table if exists #PercentPopulationVaccinated 

Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccination float,
RollingPeopleVaccinated float
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,cast(dea.date as datetime) as date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..[Covid deaths] as dea
join PortfolioProject..[Covid vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=' '

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data from later visualization

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,cast(dea.date as datetime) as date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, cast(dea.date as datetime)) as RollingPeopleVaccinated
from PortfolioProject..[Covid deaths] as dea
join PortfolioProject..[Covid vaccinations] as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=' '

select * 
from PercentPopulationVaccinated



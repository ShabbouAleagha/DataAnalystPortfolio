select *
from Portfolio..[Covid Deaths]
order by 3,4

select location, date,total_cases,new_cases,new_deaths, population
from Portfolio..[Covid Deaths]
order by 1,2

--total cases vs total deathes
--show liklihood of dying in france
select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentages
from Portfolio..[Covid Deaths]
where location like '%france%'
order by 1,2

--total-cases vs population in frnace
select location, date,population,total_cases,(total_cases/population)*100 as DeathPercentages
from Portfolio..[Covid Deaths]
where location like '%france%'
order by 1,2

--in the world
select location, date, population, total_cases,(total_cases/population)*100 as PrecentPopulationInfected
from Portfolio..[Covid Deaths]
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectedCounts,max((total_cases/population)*100) as HighestPercentageInfected
from Portfolio..[Covid Deaths]
group by location,population
order by  HighestPercentageInfected desc

--showing countries with highest daeths counts per population
select location, max(cast(total_cases as int)) as TotalDeathsCount
from Portfolio..[Covid Deaths]
where continent is not null
group by location
order by TotalDeathsCount desc

--breaking down by continint
select continent, max(cast(total_cases as int)) as TotalDeathsCount
from Portfolio..[Covid Deaths]
where continent is not null
group by continent
order by TotalDeathsCount desc

--there's a location ="worls,Africa,..." ??
select *
from Portfolio..[Covid Deaths]
where continent is not null
order by 3,4

select location, max(cast(total_cases as int)) as TotalDeathsCount
from Portfolio..[Covid Deaths]
where continent is null
group by location
order by TotalDeathsCount desc
 
 --Global numbers
 select date, sum(new_cases) as total_caces,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)))/sum(new_cases)*100 as DeathPercentages
 from Portfolio..[Covid Deaths]
 where continent is not null
 group by date
 order by 1,2

--generally
select sum(new_cases) as total_caces,sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int)))/sum(new_cases)*100 as DeathPercentages
 from Portfolio..[Covid Deaths]
 where continent is not null
 order by 1,2

 --vaccination table
 select *
 from Portfolio..[Covid Deaths]
 
 --joining tables together
 
 select *
 from Portfolio..[Covid Deaths] dea
join Portfolio..[Covid Vacciantions] vac
 on dea.location=vac.location
 and dea.date=vac.date

 --looking at total population vs vaccination 
select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
  sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)  
  as RollingPeopleVaccinated
from Portfolio..[Covid Deaths] dea
join Portfolio..[Covid Vacciantions] vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

--as we wanna use RollingPeopleVaccination and it's not posibble in the same query we'll use CTE

with PopvsVac(continent ,location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
  sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)  
  as RollingPeopleVaccinated
 from Portfolio..[Covid Deaths] dea
  join Portfolio..[Covid Vacciantions] vac
  on dea.location=vac.location
  and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )
 select * , (RollingPeopleVaccinated/population)*100 as vaccinationPercentage
 from PopvsVac
 
 --Temp Table
Drop table if exists #PercentPopulatoinVaccinated
 create table #PercentPopulatoinVaccinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentPopulatoinVaccinated
 select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
  sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)  
  as RollingPeopleVaccinated
  from Portfolio..[Covid Deaths] dea
  join Portfolio..[Covid Vacciantions] vac
  on dea.location=vac.location
  and dea.date=vac.date
 --where dea.continent is not null
 --order by 2,3

 select * , (RollingPeopleVaccinated/population)*100 as vaccinationPercentage
 from #PercentPopulatoinVaccinated
 
--creating view to store data for later vizualization 
drop view PercentPopulatoinVaccinated
Create View PercentPopulatoinVaccinated as
select dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
 sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio..[Covid Deaths] dea
join Portfolio..[Covid Vacciantions] vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
 --order by 2,3

 select * 
 from PercentPopulatoinVaccinated

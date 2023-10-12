

  --select * from [portofolioproject1].[dbo].[covidvacination$]
  --select * from portofolioproject1..covidvacination$
  --order by 3,4
  select * from portofolioproject1..coviddeath$
  where continent is not null
  order by 3,4
--select data i am going to use
select location ,date ,total_cases ,new_cases ,total_deaths,population from portofolioproject1..coviddeath$
  where continent is not null
order by 1,2
--total case of covid vs total of deaths
select * from portofolioproject1..coviddeath$
  where continent is not null


--shows likehood of dying if you contract covid in your contry
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from portofolioproject1..coviddeath$
where location like '%united kingdom%'
  and continent is not null
order by 1,2
--total case vs population

Select location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS casesperpopulationpercentage
from portofolioproject1..coviddeath$
where location like '%china%'
order by 1,2


--contry with hiht infection rate

Select location, population, max(total_cases) as highestinfectioncontry,
max((CONVERT(float, total_cases)) / NULLIF(CONVERT(float, population), 0)) * 100 AS infectionperpopulationpercentage
from portofolioproject1..coviddeath$
--where location like '%united kingdom%'
group by location, population
order by infectionperpopulationpercentage desc

--contry with deaths count per population
Select location,max (cast(total_deaths as int )) as totaldeaths
from portofolioproject1..coviddeath$
--where location like '%united kingdom%'
  where continent is not null
group by location, population
order by totaldeaths  desc
--lets break down by continent
Select continent,max (cast(total_deaths as int )) as totaldeaths
from portofolioproject1..coviddeath$
--where location like '%united kingdom%'
  where continent is not null
group by continent
order by totaldeaths  desc



--showing contient with death
Select continent,max (cast(total_deaths as int )) as totaldeaths
from portofolioproject1..coviddeath$
--where location like '%united kingdom%'
  where continent is not null
group by continent
order by totaldeaths  



--global numbers
Select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,max((CONVERT(float, new_deaths)) / NULLIF(CONVERT(float, new_cases), 0)) * 100 AS infectionperpopulationpercentage
from portofolioproject1..coviddeath$
--where location like '%united kingdom%'
  where continent is not null
group by date
order by 1,2

--loking total population vaccinited
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpoeplevaccined
from portofolioproject1..coviddeath$ dea
join portofolioproject1..covidvacination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3
--use cte
with PopvsVac (continent,location,date,population,new_vaccinations,rollingpoeplevaccined)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpoeplevaccined
from portofolioproject1..coviddeath$ dea
join portofolioproject1..covidvacination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not  null
--order by 2,3
)
select *, (CONVERT(float, rollingpoeplevaccined) / NULLIF(CONVERT(float, population), 0)) * 100 from PopvsVac

--tem table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated

(continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpoeplevaccined numeric,
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpoeplevaccined
from portofolioproject1..coviddeath$ dea
join portofolioproject1..covidvacination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not  null
select *, (CONVERT(float, rollingpoeplevaccined) / NULLIF(CONVERT(float, population), 0)) * 100 from #percentpopulationvaccinated

--creating view to store data for later visualisation
create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as rollingpoeplevaccined
from portofolioproject1..coviddeath$ dea
join portofolioproject1..covidvacination$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not  null

select * from percentpopulationvaccinated
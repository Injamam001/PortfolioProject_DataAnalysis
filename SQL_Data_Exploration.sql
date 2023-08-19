-- select data we will be using 
use portfolio_project; 

-- total cases vs total death dayewise
select 
	location, 
    date, 
    total_cases, 
	total_deaths, 
    format((total_deaths/total_cases*100),3) as death_rate
from covid_death;

-- total cases vs population daywise
select 
	location, 
    date, 
    total_cases, 
	population,
    format((total_cases/population*100),3) as infection_rate
from covid_death;

-- countries with highest infected rate compared to population

select 
	location, 
    population,
    max(total_cases) as highest_infection, 
    max(format((total_cases/population)*100,3)) as infection_rate
from covid_death
group by location, population
order by infection_rate desc;

-- countries with highest death count per population
select 
	location, 
    max(convert(total_deaths,signed)) as totaldeath 
from covid_death
group by location
order by totaldeath desc;

-- continents with highest deaths
select 
	continent, 
    max(convert(total_deaths,signed)) as total_death 
from covid_death
group by continent
order by total_death desc;

-- datewise total infection and death
-- convert text to date

select 
	str_to_date(date,'%d-%m-%y')as converteddate,
    sum(new_cases) as infection,
    sum(new_deaths) as death,
    (sum(new_deaths)/sum(new_cases))*100 as death_percantage
from covid_death
group by converteddate
order by converteddate;

-- total population vs vaccination

select 
	cd.continent, 
	cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as moving_sum
from covid_death cd
join covid_vaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cv.new_vaccinations !='';

-- use CTE 

with population_vs_vaccination (continent, location, date, population,new_vaccinations, moving_sum)
as
(select 
	cd.continent, 
	cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as moving_sum
from covid_death cd
join covid_vaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cv.new_vaccinations !='')
select *, format((moving_sum/population)*100,4) as vac_percent
from population_vs_vaccination;

-- temp table
drop table if exists populationvaccinated;
create temporary table populationvaccinated 
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
moving_sum numeric
);
insert into populationvaccinated
select 
	cd.continent, 
	cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as moving_sum
from covid_death cd
join covid_vaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cv.new_vaccinations !='';

select *, format((moving_sum/population)*100,4) as vac_percent
from populationvaccinated;

-- creating view

create view populationvaccinated as
select 
	cd.continent, 
	cd.location, 
    cd.date, 
    cd.population, 
    cv.new_vaccinations,
    sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as moving_sum
from covid_death cd
join covid_vaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cv.new_vaccinations !='';

select * from populationvaccinated;



use Portfolio_Project
select *
from CovidDeaths
order by 3,5

alter table dbo.CovidDeaths alter column total_deaths float

--select *
--from CovidVaccinations
--order by 4

select location,date,total_cases,new_cases,total_deaths,population
from CovidDeaths
order by 1,2

--Find out the percentage of deaths against the total number of cases(let's say United States over here)
select 
	location,
	date,
	total_cases,
	total_deaths,
	round((total_deaths/total_cases)*100,2) as "Death Percentage"
from CovidDeaths
where location like '%states%'
order by 1,2;

--Find out the percentage of cases against the population(let's say United States over here)
select 
	location,
	date,
	total_cases,
	population,
	round((total_cases/population)*100,2) as "Percentage of people who contracted Covid"
from CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to their population
select
	location,
	population,
	MAX(total_cases) as Highest_Cases,
	ROUND(MAX(total_cases/population)*100,2) as Highest_Infection_Rate
from CovidDeaths
group by location, population
order by Highest_Infection_Rate desc


--Showing Countries with Highest Death Count per Popultaion
select
	location,
	MAX(total_deaths) as Death_Count
from CovidDeaths
where continent is not null
group by location
order by 2 desc;

-- Showing Continents with the Highest Death Count per population
select
	continent,
	MAX(CAST(total_deaths as float)) as Death_Count
from CovidDeaths
where continent is not null
group by continent
order by Death_Count desc;

-- Global death percentage
select
	date,
	SUM(new_cases) as Total_New_Cases,
	SUM(new_deaths) as Total_New_Deaths,
	(SUM(new_deaths)/nullif(SUM(new_cases),0))*100 as New_Death_Percentage
from CovidDeaths
where continent is not null
group by date
order by 1,2 desc

-- Looking at Total Population vs the Number of people who got vaccinated
with cte as(
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as float)) OVER(partition by dea.location order by dea.location, dea.date) as Rolling_Count_Vaccinated_People
	from CovidDeaths dea
	inner join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
)

select *, ROUND((Rolling_Count_Vaccinated_People/population),2) as Percentage_of_people_vaccinated
from cte
order by 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Count_Vaccinated_People numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Count_Vaccinated_People
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (Rolling_Count_Vaccinated_People/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated_vw as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 





Select *
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 3,4


--when Continent is null the location is assigned as the continent ,hence continent not null should be considered

--Select *
--from PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--Select Data that we are going to be using	

Select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2

--Looking at TotalCases vs TotalDeaths
Select Location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
Where Location like'%states%'
and continent is not null
order by 1,2 

--Looking at Total Cases vs Population
--What % popluation got covid
Select Location,date,total_cases,new_cases,population,(total_cases/population)*100 as InfectedPercentage
from PortfolioProject.dbo.CovidDeaths
Where Location like '%ndia%'
and continent is not null
order by 1,2 

--Looking at countries with highest infection rate
Select Location,population,Max(total_cases)as HighestInfection,Max((total_cases/population))*100 as InfectedPercentage
from PortfolioProject.dbo.CovidDeaths
Where Location like '%ndia%'
and continent is not null
Group BY Location,population
order by 4 desc

--Looking for countries with highest death rate 

--here nvarchar is typecasted to integer because the results shown were not accurate so after type casting it turned out to be accurate

Select Location,population,Max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where Location like '%ndia%'
Where continent is not null
Group BY Location,population
order by 3 desc

--Consdering the continents with highest death counts

Select continent,Max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where Location like '%ndia%'
Where continent is not null
Group BY continent
order by TotalDeathCount desc

--Considering location here changing continent from notnull to null (it will include the correct numbers)
--Select location,Max(cast(total_deaths as int))as TotalDeathCount
--from PortfolioProject.dbo.CovidDeaths
----Where Location like '%ndia%'
--Where continent is null
--Group BY location
--order by TotalDeathCount desc

--Showing the continents with highest death counts
Select continent,Max(cast(total_deaths as int))as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--Where Location like '%ndia%'
Where continent is not null
Group BY continent
order by TotalDeathCount desc

--Consider the whole world

Select Sum(new_cases) as total_cases,Sum(cast(new_deaths as int)) as total_deaths ,Sum(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
--Group by date
order by 1,2 

--Join

--looking at total population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location order by dea.location,dea.date) as PeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--forour data explporation further wecannot use just made column PeopleVaccinated so we will have to make a CTE  

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopvsVac

--TEMP 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_Vaccinations numeric,
  PeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location order by dea.location,dea.date) as PeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating a View for Visualisation

--Drop View if exists PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) over (Partition By dea.location order by dea.location,dea.date) as PeopleVaccinated
from PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
ON dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated
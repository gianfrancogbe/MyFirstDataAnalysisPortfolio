Select * 
From PortfolioProject..CovidDeaths$ 
Where continent is not null
Order by 3,4

--Select * From PortfolioProject..CovidVaccination$ Order by 3,4

--1 
--Seleccionar la data que vamos a usar
Select Location,date, total_cases,new_cases,total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--2
--Revisando el total de casos vs total muertes (probabilidad)
Select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%states'
order by 1,2

--3
--Revisando porcentaje de la poblacion infectada
Select Location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Where location like '%states'
order by 1,2

--4
--Revisando paises con porcentaje de infecciones mas altas vs poblacion
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by location, population
order by PercentPopulationInfected desc

--5
--Revisando paises con mas muertes por poblacion
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
order by TotalDeathCount desc

--REVISANDO POR CONTINENTES
--6
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc

--7
--Revisando los continentes con numero de muertes mas altas
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
--8
Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where continent is not null 
order by 1,2

--9
--Revisando poblacion total vacunada
--Usando CTE
With PopvsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From Popvsvac


--Usando TEMP Table
Drop table if exists #PorcentajePoblacionVacunada
Create table #PorcentajePoblacionVacunada
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
new_vaccinations float,
RollingPeopleVaccinated float
)

insert into #PorcentajePoblacionVacunada
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as RollingPercentageVaccinated
From #PorcentajePoblacionVacunada


-- Creando una vista que pueda almacenar informacion para visualizarlo
Create view PorcentajePoblacionVacunada as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as float)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- Creando consultas para visualizarlas en Tableau:

-- 1. 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. Informacion adicional sobre las consultas, 'European Union' es aun Europa 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High Income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-- 3.
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

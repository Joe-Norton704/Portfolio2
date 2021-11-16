Select *
From PortfolioProject..CovidDeaths
Where continent Is Not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1, 2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of death if you contract covid in your country

Select Location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
WHERE location like '%states%' And
continent Is Not null
Order By 1, 2


-- Looking at Total Cases vs. Population
-- Shows what percentage of population gets covid

Select Location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
From PortfolioProject..CovidDeaths
--WHERE location like '%states%' And continent Is Not null
Order By 1, 2


--Looking at what countries with highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%states%' And continent Is Not null
Group By Location, population
Order By PercentPopulationInfected desc


--Looking at countries with highest death count per population

Select Location, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent Is Not null
Group By Location
Order By TotalDeathCount desc


--Now breaking things down by continent

--Showing continents with the highest death count per population

Select continent, Max(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent Is not null
Group By continent
Order By TotalDeathCount desc


--Global numbers

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as DeathRate
From PortfolioProject..CovidDeaths
--WHERE location like '%states%' 
Where continent is not null
--Group By date
Order By 1, 2


--Looking at total population vs vaccinations

Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, Sum(Convert(int,CovidVaccinations.new_vaccinations)) Over (Partition By CovidDeaths.location Order by CovidDeaths.location,
	CovidDeaths.date) as RollingPeopleVaccinated
	,
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location	
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent Is Not null
Order By 2,3


--Use CTE

With PopvsVac (continent, Location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, Sum(Convert(int,CovidVaccinations.new_vaccinations)) Over (Partition By CovidDeaths.location Order by CovidDeaths.location,
	CovidDeaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location	
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent Is Not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated s4rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrt
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, Sum(Convert(int,CovidVaccinations.new_vaccinations)) Over (Partition By CovidDeaths.location Order by CovidDeaths.location,
	CovidDeaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location	
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent Is Not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated




--Creating view to store for later visualizations

Create View PercentPopulationVaccinated as
Select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations
, Sum(Convert(int,CovidVaccinations.new_vaccinations)) Over (Partition By CovidDeaths.location Order by CovidDeaths.location,
	CovidDeaths.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths
Join PortfolioProject..CovidVaccinations
	On CovidDeaths.location = CovidVaccinations.location	
	and CovidDeaths.date = CovidVaccinations.date
Where CovidDeaths.continent Is Not null



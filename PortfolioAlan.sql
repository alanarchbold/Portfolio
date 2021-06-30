 
 --Data exploration
 -- Checking table CovidDeath
 
 Select *
 from Portfolio1..CovidDeath
 order by location, date

 --Removing Continenet null value, when Continent is null/empty Location take Continent values
 
 Select *
 from Portfolio1..CovidDeath
 where continent is not null
 order by location, date

 --Checking 2nd table CovidVaccinations
 Select *
 from Portfolio1..CovidVaccinations
 order by location, date
 
 --Important colums 

 Select location, date, total_cases, new_cases, total_deaths, population
 from Portfolio1..CovidDeath
 order by location, date

 -- What are the Total Cases per day and Total Deaths

 Select location, date, total_cases, total_deaths
 from Portfolio1..CovidDeath
 order by location, date

 ---Calculations
 -- Calculate the percentage of death depending on total cases
 -- likelihood of dying if you get Covid19 infected

 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from Portfolio1..CovidDeath
 where location = 'Colombia'
 order by location, date

 -- Not sure how Unites States is written in the original table
 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 from Portfolio1..CovidDeath
 where location like '%states%'
 order by location, date


 --Total cases VS Population
 -- Population that got Covid19 

 Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
 from Portfolio1..CovidDeath 
 where location like '%states%'
 order by location, date
 --Table3
 --Highest infection rate according population
 Select location, population, max(total_cases) as HighesInfectionCount
 from Portfolio1..CovidDeath
 Group by location, population
 order by HighesInfectionCount desc

 
 --tbale 4
 -- the same as table 3 but including date
 Select location, date, population, max(total_cases) as HighesInfectionCount
 from Portfolio1..CovidDeath
 Group by location, population, date
 order by HighesInfectionCount desc

 -- Countries with Highest deaths count depending in population
 Select location,  Max(cast(total_deaths as int)) as TotalDeathPerCountry, MAx( (total_deaths/population))*100 as DeathPerPopulation
 from Portfolio1..CovidDeath
 Group by location
 order by TotalDeathPerCountry desc

 -- Removing continents on Locations

 Select location,  Max(cast(total_deaths as int)) as TotalDeathPerCountry, MAx( (total_deaths/population))*100 as DeathPerPopulation
 from Portfolio1..CovidDeath
 where continent is not null
 Group by location
 order by TotalDeathPerCountry desc


 --Table2
 ---- European Union is part of Europe
 Select location,  SUM(cast(new_deaths as int)) as TotalDeathCount
From Portfolio1..CovidDeath
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

 -- Comparing Continents
 Select continent,  Max(cast(total_deaths as int)) as TotalDeathPerContinent
 from Portfolio1..CovidDeath
 where continent is not null
 Group by continent
 order by TotalDeathPerContinent desc

 

 
 --table1
 --Globally
 Select sum(new_cases) as TotalCasesPerDay, sum(cast (new_deaths as int)) as TotalDeathsPerDay, (sum(cast (new_deaths as int))/sum(new_cases))*100 as PercentageDeathPerDailyCases
 from Portfolio1..CovidDeath
 where continent is not null

 --Using 2 tables
 Select *
 from Portfolio1..CovidDeath dea
 join Portfolio1..CovidVaccinations vac
	 on dea.location = vac.location
	and dea.date = vac.date

 -- Checking how many have been vaccinated according Country population
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
 from Portfolio1..CovidDeath dea
 join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Partitions, showing the total of new vaccinations per country per day and agreagting the total in the next columns

Select dea.location, dea.date, vac.new_vaccinations, 
sum(convert( int, vac.new_vaccinations)) over ( Partition by dea.location order by dea.date ) as AgregatedVaccinated
 from Portfolio1..CovidDeath dea
 join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

-- Percentage total vaccinated per Country population

Select dea.location, dea.population, dea.date, vac.new_vaccinations, 
(sum(convert( int, vac.new_vaccinations)) over ( Partition by dea.location order by dea.date )/dea.population) as PercentagevaccinatedPopulation
 from Portfolio1..CovidDeath dea
 join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--view 
create view AgregatedVaccinated2 as
Select dea.location, dea.date, vac.new_vaccinations, 
sum(convert( int, vac.new_vaccinations)) over ( Partition by dea.location order by dea.date ) as AgregatedVaccinated
 from Portfolio1..CovidDeath dea
 join Portfolio1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
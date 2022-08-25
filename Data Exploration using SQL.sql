

--print the death table
SELECT * FROM dbo.[COVID_Death$]


--Check total cases vs total deaths 
SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject.[dbo].[COVID_Death$]
order by 1,2

--Get the percentage number of people affected in germany
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS death_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE location like '%Germ%'
ORDER BY 1,2

--Get the percetage of population infected 
SELECT location, date, population, total_cases,  (total_cases/population) * 100 AS population_cases_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
--WHERE location like '%Germ%'    -to get a particular country; use germany as an example 
 ORDER BY 1,2 ASC

--Looking at countries wth highest infection rate compared to population 
SELECT location, population, MAX (total_cases),  MAX((total_cases/population)) * 100 AS population_cases_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location, population
ORDER BY population_cases_percentage DESC

--Showing countries with highest death count per population
SELECT location, MAX (total_deaths) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location
ORDER BY death_count DESC

--formatting the total_death datatype using cast
SELECT location, MAX (CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
GROUP BY location
ORDER BY death_count DESC


--Group data showing the contitnent where value is null
SELECT location, MAX (CAST (total_deaths AS INT)) AS death_count
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE continent is null
GROUP BY location
ORDER BY death_count DESC


--Drop some rows like world, low middle income, low income and international columns



--Create a dropdown of continent



--Get the sum of new cases and deaths and percentage
SELECT location,date, SUM (new_cases) AS total_newcases, SUM (CAST(new_deaths AS INT)) AS total_newdeaths, 
SUM(CAST(new_deaths AS INT))/ SUM (new_cases) * 100 AS new_percentage 
FROM PortfolioProject.[dbo].[COVID_Death$]
WHERE continent is null
GROUP BY date 
ORDER BY new_percentage DESC


--print the vaccination table
SELECT * FROM PortfolioProject.[dbo].[COVID_Vaccination$]


--Get the total number of people vaccinated 



--Join the two Tables 
SELECT * FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date




--Get the total number of people vaccinated 
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations 
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null
ORDER BY 1,2,3


--Rolling count of 
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null
ORDER BY 1,2,3


--Get the percentage of of rolling people vaccinated using UTE
WITH population_vaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) AS
(SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null)
--ORDER BY 1,2,3)
SELECT * , (rolling_people_vaccinated/ population) * 100 FROM population_vaccination

--Get the max


-- TEMP table

DROP TABLE IF EXISTS ---add this when making alteration
CREATE TABLE #percent_population_vaccination 
(continent nvarchar (255), location nvarchar (255), date DATETIME, population NUMERIC,
new_vaccinations NUMERIC, rolling_people_vaccinated NUMERIC)

INSERT INTO 
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null)
--ORDER BY 1,2,3)
SELECT * , (rolling_people_vaccinated/ population) * 100 FROM #percent_population_vaccination




--print needed column 


--delete the columns where value is not null


-------CREATE MULTIPLE VIEWS

--create view to store data later for visualization
CREATE VIEW #percent_population_vaccinated
SELECT death.continent,death.location,death.date,death.population, vaccination.new_vaccinations, 
SUM(CONVERT(INT, vaccination.new_vaccinations)) 
OVER (PARTITION BY death.location ORDER BY death.location,death.date) AS rolling_people_vaccinated
FROM PortfolioProject.[dbo].[COVID_Death$] AS death
Join PortfolioProject.[dbo].[COVID_Vaccination$] AS vaccination
	ON death.location = death.location
	AND death.date = death.date
WHERE vaccination.continent is not null
--ORDER BY 1,2,3)

SELECT * FROM percent_population_vaccinated



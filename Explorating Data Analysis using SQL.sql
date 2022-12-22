
-- This project is to explore the air pollution death rate to generate insights 


--print the data of imported table
 
SELECT * FROM A_pollution.[dbo].[DR]


-- Get the number of rows 
SELECT count (*) AS total_count FROM A_pollution.[dbo].[DR]


-- Rename column headers 
SELECT Entity, Code, year, 
	'Total_airpollution'=Deaths_Air_pollution_sex_both_Age_Age_standardized_Rate, 
	'solidfuels_pollution'=Deaths_Household_Air_pollution_from_solid_fuels_sex_both_Age_Age_standardized_Rate,
	'particulate_pollution'=Deaths_Ambient_particulate_matter_pollution_sex_both_Age_Age_standardized_Rate,
	'ozone_pollution'=Deaths_Ambient_ozone_pollution_sex_both_Age_Age_standardized_Rate
FROM A_pollution.[dbo].[DR]

		ALTER TABLE A_pollution.[dbo].[DR]
		ADD Total_airpollution float;
		

		UPDATE A_pollution.[dbo].[DR]
		SET Total_airpollution = Deaths_Air_pollution_sex_both_Age_Age_standardized_Rate

		ALTER TABLE A_pollution.[dbo].[DR]
		ADD solidfuels_pollution float;

		UPDATE A_pollution.[dbo].[DR]
		SET solidfuels_pollution = Deaths_Household_Air_pollution_from_solid_fuels_sex_both_Age_Age_standardized_Rate

		ALTER TABLE A_pollution.[dbo].[DR]
		ADD particulate_pollution float;

		UPDATE A_pollution.[dbo].[DR]
		SET particulate_pollution = Deaths_Ambient_particulate_matter_pollution_sex_both_Age_Age_standardized_Rate

		ALTER TABLE A_pollution.[dbo].[DR]
		ADD ozone_pollution float;

		UPDATE A_pollution.[dbo].[DR]
		SET ozone_pollution = Deaths_Ambient_ozone_pollution_sex_both_Age_Age_standardized_Rate

-- Drop columns
SELECT * FROM A_pollution.[dbo].[DR]

ALTER TABLE A_pollution.[dbo].[DR]
DROP COLUMN Deaths_Air_pollution_sex_both_Age_Age_standardized_Rate, 
		Deaths_Household_Air_pollution_from_solid_fuels_sex_both_Age_Age_standardized_Rate,
		Deaths_Ambient_particulate_matter_pollution_sex_both_Age_Age_standardized_Rate, 
		Deaths_Ambient_ozone_pollution_sex_both_Age_Age_standardized_Rate

SELECT * FROM A_pollution.[dbo].[DR]


--Check number of  air population deaths
SELECT entity, code, year, total_airpollution, particulate_pollution, solidfuels_pollution 
FROM A_pollution.[dbo].[DR]
ORDER BY 1,2

SELECT entity, SUM (total_airpollution) AS total
FROM A_pollution.[dbo].[DR]
GROUP BY entity 
ORDER BY 2 DESC



--Show the percentage number of total deaths cause by differend types of pollution in germany
SELECT entity, code, year, total_airpollution, particulate_pollution, solidfuels_pollution, ozone_pollution, 
	(particulate_pollution/total_airpollution) * 100 AS particulate_percentage, 
	(solidfuels_pollution/total_airpollution) * 100 AS solidfuels_percentage, 
	(ozone_pollution/total_airpollution) * 100 AS ozone_percentage 
FROM A_pollution.[dbo].[DR]
WHERE entity like '%Germ%'
ORDER BY 1,2

--Join the Tables (dr; share_death) using left outer join 
SELECT * FROM A_pollution.[dbo].[DR] AS DR
LEFT Join A_pollution.[dbo].[share_death] AS risk
	ON dr.code = dr.code
	AND risk.entity = risk.entity


--Get the percetage of total deaths vs air pollution total IHME
SELECT Air_pollution_total_IHME_2019, total_airpollution,  (Air_pollution_total_IHME_2019/ total_airpollution) * 100 AS IHMEpercent
FROM A_pollution.[dbo].[DR] AS dr
LEFT Join A_pollution.[dbo].[share_death] AS risk
	ON dr.code = dr.code
	AND risk.entity = risk.entity
ORDER BY 1 ASC

--Looking at countries with highest air pollution affected rate
SELECT entity, code, year, total_airpollution, 
MAX (total_airpollution) AS highest_cases  
FROM A_pollution.[dbo].[DR]
GROUP BY entity
ORDER BY highest_cases DESC



--Formatting the total_airpolluion death datatype using CAST function
SELECT entity, MAX (CAST (total_airpollution AS INT)) AS death_count
FROM A_pollution.[dbo].[DR]
GROUP BY entity
ORDER BY death_count DESC


--Group data showing the entity where value is null
SELECT entity, MAX (CAST (total_airpollution AS INT)) AS death_count
FROM A_pollution.[dbo].[DR]
WHERE entity is null
GROUP BY code
ORDER BY death_count DESC



--Get the sum of total air pollution deaths cases by particulate_pollution in percentage
SELECT entity,code, year, SUM (total_airpollution) AS total_airpol_death, 
SUM (CAST(particulate_pollution AS INT)) AS part_death, 
SUM(CAST(total_airpol_death AS INT))/ SUM (part_death) * 100 AS airpol_death_percent
FROM A_pollution.[dbo].[DR]
WHERE entity is null
GROUP BY year
ORDER BY airpol_death_percent DESC


--Get the sum of total air pollution deaths in percentage
SELECT entity, year, total_airpollution, total_airpollution * 100 
	/ (SELECT SUM(CAST(total_airpollution AS INT))) AS airpol_death_percent
FROM A_pollution.[dbo].[DR]
WHERE entity is null
--GROUP BY year
ORDER BY airpol_death_percent DESC



-- show total number of death with Rolling sum 
SELECT entity, year,  total_airpollution,
SUM(CAST(total_airpollution AS INT))
OVER (PARTITION BY entity 
ORDER BY year) AS rollnum
FROM A_pollution.[dbo].[DR]



--Get the percentage of global air pollution death using CTE
WITH pol (entity, code, year, total_airpollution, rollnum) 
AS
(
SELECT entity, code, year, total_airpollution, SUM(CONVERT(INT,total_airpollution))
OVER (PARTITION BY entity 
ORDER BY year) AS rollnum
FROM A_pollution.[dbo].[DR]
)
Select * , (rollnum/total_airpollution)*100 as airpol_death_percent
From pol





-- Create Temporary (temp) table

--####DROP TABLE IF EXISTS 
CREATE TABLE Airpollution_deathrate
( 
		[Code] [nvarchar] (255),
		[Entity] [nvarchar] (255),  
		[Year] [DATETIME], 
		[Total_airpollution] [NUMERIC],
		[Ozone_pollution] [NUMERIC], 
		[Solidfuels_pollution] [NUMERIC],
		[particulate_pollution] [NUMERIC]
)
  


INSERT INTO Airpollution_deathrate
SELECT entity, code, year, Ozone_pollution,Solidfuels_pollution,particulate_pollution, 
total_airpollution,Solidfuels_pollution, SUM(CONVERT(INT,total_airpollution))
OVER (PARTITION BY entity ORDER BY year) AS rollnum
FROM A_pollution.[dbo].[DR]
ORDER BY 1,2


--create view to store data later for visualization
	--# To develop a map showing the global air pollution death rate 
	--# Identify top 10 countries with highest death rate cause by solidfuels pollution and particulate pollution
	--# Make graph showing the death rate cause by solidfuels pollution, ozone pollution and particulate pollution in the recent years (2010 - 2017)

CREATE VIEW Airpollution_deathrate 
SELECT entity, code, year, Ozone_pollution,Solidfuels_pollution,particulate_pollution, 
total_airpollution,Solidfuels_pollution, SUM(CONVERT(INT,total_airpollution))
OVER (PARTITION BY entity ORDER BY year) AS rollnum
FROM A_pollution.[dbo].[DR]
ORDER BY 1,2

SELECT * FROM Airpollution_deathrate





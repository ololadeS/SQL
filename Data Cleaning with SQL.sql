

--Cleaning data in MSSQL
SELECT * FROM Crime.[dbo].[crime]


-- Get the number of rows 
SELECT count (*) FROM Crime.[dbo].[crime]

-- Count the mumber of values for shooting 
SELECT year, count (shooting) AS PositionCount
FROM Crime.[dbo].[crime]
GROUP BY YEAR

	SELECT count(*) - count(shooting), count(shooting) FROM Crime.[dbo].[crime]


--Populate street, district and reporting area columns to get isnull
	-- Check missong values for street, district and reporting area columns
		SELECT * FROM Crime.[dbo].[crime]
		WHERE street is null AND district is null AND reporting_area IS NULL
		ORDER BY year


		-- count
		SELECT year, count (*) FROM Crime.[dbo].[crime]
		WHERE street IS NULL AND district IS NULL AND reporting_area IS NULL
		GROUP BY year


SELECT I.incident_number, II.incident_number, I.street, II.street, I.district, II.district, I.reporting_area, II.reporting_area
ISNULL ((I.street, II.street) AS Populatestreet, (I.district, II.district) AS Populatedistrict, (I.reporting_area, II.reporting_area) AS PopulateR_area)
FROM Crime.[dbo].[crime]  I
JOIN Crime.[dbo].[crime] II
	ON I.incident_number = II.incident_number
	AND I.[UniqueID ]<> II.[UniqueID ]
WHERE I.street IS NULL AND I.district is null AND I.reporting_area IS NULL


UPDATE I
SET street = ISNULL (I.street, II.street) 
SET district = ISNULL (I.district, II.district)
SET reporting_area = ISNULL (I.reporting_area, II.reporting_area)
FROM Crime.[dbo].[crime]  I
JOIN Crime.[dbo].[crime] II
	ON I.incident_number = II.incident_number
	AND I.[UniqueID ]<> II.[UniqueID ]
WHERE I.street IS NULL AND I.district is null AND I.reporting_area IS NULL



--Split Location column into individual columns i.e latitude and Longitude using CHARINDEX
SELECT location FROM Crime.[dbo].[crime]

SELECT 
SUBSTRING (location, 1, CHARINDEX (' ', location)-1) AS Latitude, 
SUBSTRING (location, CHARINDEX (' ', location)+1, LEN(location)) AS Longitude  
FROM Crime.[dbo].[crime]


ALTER TABLE Crime.[dbo].[crime]
ADD SplitLatitude NVARCHAR (255);

UPDATE Crime.[dbo].[crime]
SET SplitLatitude = SUBSTRING (location, 1, CHARINDEX (' ', location)-1)


ALTER TABLE Crime.[dbo].[crime]
ADD SplitLongitude NVARCHAR (255);

UPDATE Crime.[dbo].[crime]
SET SplitLongitude = SUBSTRING (location, CHARINDEX (' ', location)+1, LEN(location));

SELECT * FROM Crime.[dbo].[crime]


--Split occurred_on_date using PARSENAME 
SELECT 
PARSENAME (REPLACE (occurred_on_date, ' ', ' ' ), 2) Datetime, 
PARSENAME (REPLACE (occurred_on_date, '', ' ' ), 1) Hours 
FROM Crime.[dbo].[crime]


ALTER TABLE Crime.[dbo].[crime]
ADD SplitDatetime date;


UPDATE Crime.[dbo].[crime]
SET SplitDatetime = PARSENAME (REPLACE (occurred_on_date, ' ', ' '), 2) 


ALTER TABLE Crime.[dbo].[crime]
ADD SplitHours date;

UPDATE Crime.[dbo].[crime]
SET SplitHours = PARSENAME (REPLACE (occurred_on_date, ' ', ' '), 1) 


--Standardize date format
SELECT occurred_on_date, CONVERT(Date,occurred_on_date) Date FROM Crime.[dbo].[crime]

UPDATE Crime.[dbo].[crime]
SET occurred_on_date =  CONVERT(Date,occurred_on_date)

	ALTER TABLE Crime.[dbo].[crime]
	ADD occurred_on_dateconverted Date;

	UPDATE Crime.[dbo].[crime]
	SET occurred_on_date = CONVERT(Date,occurred_on_date)




--Find and replace value i.e y and null to yes and unknown using CASE STATEMENT
SELECT DISTINCT (shooting), COUNT (shooting) Sold_Count
FROM Crime.[dbo].[crime]
GROUP BY (shooting) 
ORDER BY 2

SELECT shooting,
CASE WHEN shooting = 'Y' THEN 'Yes'
	WHEN shooting IS NULL THEN 'Unknown'
	ELSE shooting END
FROM Crime.[dbo].[crime]

UPDATE [crime]
SET Shooting  =
CASE WHEN shooting = 'Y' THEN 'Yes'
	WHEN shooting IS NULL THEN 'Unknown'
	ELSE shooting END
FROM Crime.[dbo].[crime]


--Remove duplicates using CTE, ROW_NUMBER, PARTITION BY 
WITH crimeCTE AS 
(
SELECT *,
        ROW_NUMBER() OVER (PARTITION BY 
                Incident_number
            ORDER BY 
                Incident_number ) AS row_num
FROM Crime.[dbo].[crime] 
)
DELETE FROM crimeCTE
WHERE row_num > 1


-- --Join two Tables (Crime and offense code) using inner join 
SELECT * FROM Crime.[dbo].[crime] AS crime
INNER Join Crime.[dbo].[offense_codes] AS code
	ON crime.offense_code = crime.offense_code
	AND code.Name = code.Name


--Delete unused columns using DROP
SELECT * FROM Crime.[dbo].[crime]

ALTER TABLE Crime.[dbo].[crime]
DROP COLUMN Lat, Long



-- What types of crimes are most common?
-- Where are different types of crimes most likely to occur?
-- Does the frequency of crimes change over the day? Week? Year?


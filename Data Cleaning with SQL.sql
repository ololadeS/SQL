

--Cleaning data in MSSQL
SELECT * FROM Crime.[dbo].[crime]


-- Get the number of rows 
SELECT count(*) FROM Crime.[dbo].[crime]


-- Identify and remove duplicates using CTE, ROW_NUMBER, PARTITION BY 
WITH CTE AS 
(
SELECT *,
        ROW_NUMBER() OVER (PARTITION BY 
                Incident_number
            ORDER BY 
                Incident_number ) AS row_num
FROM Crime.[dbo].[crime] 
)
DELETE FROM CTE
WHERE row_num > 1


-- Count the mumber of values for shooting  
SELECT year, count (shooting) AS PositionCount
FROM Crime.[dbo].[crime]
WHERE SHOOTING IS NOT NULL
GROUP BY YEAR

SELECT count(*) - count(shooting), count(shooting) FROM Crime.[dbo].[crime]


-- Replacing shooting column null values with U (i.e unknown):
UPDATE Crime.[dbo].[crime]
SET shooting = 'U'
WHERE shooting IS NULL;

--Find and replace value i.e y and u to yes and unknown using CASE STATEMENT
SELECT DISTINCT (shooting), COUNT (shooting) Sold_Count
FROM Crime.[dbo].[crime]
GROUP BY (shooting) 
ORDER BY 2

SELECT shooting,
CASE WHEN shooting = 'Y' THEN 'Yes'
	WHEN shooting = 'U' THEN 'Unknown'
	ELSE shooting END
FROM Crime.[dbo].[crime]

UPDATE [crime]
SET Shooting  =
CASE WHEN shooting = 'Y' THEN 'Yes'
	WHEN shooting = 'U' THEN 'Unknown'
	ELSE shooting END
FROM Crime.[dbo].[crime]


--Split Location column into individual columns i.e latitude and Longitude using substring and CHARINDEX
SELECT location FROM Crime.[dbo].[crime]

SELECT 
SUBSTRING (location, 1, CHARINDEX (' ', location)-1) AS Latitude, 
SUBSTRING (location, CHARINDEX (' ', location)+1, LEN(location)) AS Longitude  
FROM Crime.[dbo].[crime]


ALTER TABLE Crime.[dbo].[crime]
ADD Latitude NVARCHAR (255);
UPDATE Crime.[dbo].[crime]
SET Latitude = SUBSTRING (location, 1, CHARINDEX (' ', location)-1)


ALTER TABLE Crime.[dbo].[crime]
ADD Longitude NVARCHAR (255);
UPDATE Crime.[dbo].[crime]
SET Longitude = SUBSTRING (location, CHARINDEX (' ', location)+1, LEN(location));


--Removing leading and trailing whitespaces:
UPDATE Crime.[dbo].[crime]
SET Latitude = LTRIM(RTRIM(Latitude));

UPDATE Crime.[dbo].[crime]
SET Longitude = LTRIM(RTRIM(Longitude));


-- Removing special characters:
UPDATE Crime.[dbo].[crime]
SET Latitude = REPLACE(Latitude, '(', '');

UPDATE Crime.[dbo].[crime]
SET Longitude = REPLACE(Longitude, ')', '');


--Standardize date format
SELECT occurred_on_date, CONVERT(Date,occurred_on_date) Date FROM Crime.[dbo].[crime]

UPDATE Crime.[dbo].[crime]
SET occurred_on_date =  CONVERT(Date,occurred_on_date)

	ALTER TABLE Crime.[dbo].[crime]
	ADD occurred_on_dateconverted Date;

	UPDATE Crime.[dbo].[crime]
	SET occurred_on_date = CONVERT(Date,occurred_on_date)

--Split occurred_on_date using PARSENAME 
SELECT 
PARSENAME (REPLACE (occurred_on_date, ' ', ' ' ), 2) DATE_, 
PARSENAME (REPLACE (occurred_on_date, ' ', ' ' ), 1) Hours 
FROM Crime.[dbo].[crime]


ALTER TABLE Crime.[dbo].[crime]
ADD Date_ date;
UPDATE Crime.[dbo].[crime]
SET Date_ = PARSENAME (REPLACE (occurred_on_date, ' ', ' '), 2) 


ALTER TABLE Crime.[dbo].[crime]
ADD Hours_ date;
UPDATE Crime.[dbo].[crime]
SET Hours_ = PARSENAME (REPLACE (occurred_on_date, ' ', ' '), 1) 


--Populate street, district and reporting area columns to get isnull
	-- Check missng values for street, district and reporting area columns
		SELECT * FROM Crime.[dbo].[crime]
		WHERE street is null AND district is null AND reporting_area IS NULL
		ORDER BY year

		-- count
		SELECT year, count (*) FROM Crime.[dbo].[crime]
		WHERE street IS NULL AND district IS NULL AND reporting_area IS NULL
		GROUP BY year;


-- Identifying and Updating incorrect data:
UPDATE Crime.[dbo].[crime]
SET District = 'Unknown'
WHERE District IS NULL;

-- Identifying and Updating incorrect data:
UPDATE Crime.[dbo].[crime]
SET STREET = 'Unknown'
WHERE STREET IS NULL;

-- Removing rows with invalid data:
DELETE FROM  Crime.[dbo].[crime]
WHERE STREET IS NULL OR REPORTING_AREA IS NULL OR OFFENSE_CODE < 0;

-- Changing the case of a column:
UPDATE Crime.[dbo].[crime]
SET OFFENSE_DESCRIPTION = STUFF(LOWER(OFFENSE_DESCRIPTION), 1, 1, UPPER(LEFT(OFFENSE_DESCRIPTION, 1)))


-- Removing duplicate rows:
DELETE FROM Crime.[dbo].[crime]
WHERE INCIDENT_NUMBER NOT IN (SELECT MIN(INCIDENT_NUMBER) FROM Crime.[dbo].[crime] GROUP BY OFFENSE_CODE);

-- Removing unwanted columns:
SELECT * FROM Crime.[dbo].[crime]

ALTER TABLE Crime.[dbo].[crime]
DROP COLUMN Hours_, occurred_on_dateconverted




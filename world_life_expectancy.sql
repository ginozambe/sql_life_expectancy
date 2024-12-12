# World Life Expectancy

SELECT * FROM world_life_expectancy_staging;

# CLEANING
## Remove duplicates

-- Find Duplicates
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy_staging
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Select Duplicates
SELECT *
FROM (
	SELECT Row_ID, 
	CONCAT(Country, Year), 
	ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) As Count
	FROM world_life_expectancy_staging) as Row_table
WHERE Count > 1;

-- Delete Duplicates
DELETE 
FROM world_life_expectancy_staging
WHERE Row_ID IN (
	SELECT Row_ID
	FROM (
		SELECT Row_ID, 
		CONCAT(Country, Year), 
		ROW_NUMBER() OVER( PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) As Count
		FROM world_life_expectancy_staging) as Row_table
	WHERE Count > 1);

## NULLs Status

-- Find Null Values In Status
SELECT *
FROM world_life_expectancy_staging
WHERE `status` = '';

-- Identify values In Status
SELECT DISTINCT(status)
FROM world_life_expectancy_staging
WHERE `status` <> ' ';

-- Select Developing countries
SELECT DISTINCT(country)
FROM world_life_expectancy_staging
WHERE status = 'Developing';

-- Select Developed countries
SELECT DISTINCT(country)
FROM world_life_expectancy_staging
WHERE status = 'Developed';

-- Updated Null values for developing countries
UPDATE world_life_expectancy_staging as t1
JOIN world_life_expectancy_staging as t2
	 ON t1.Country = t2.Country
SET t1.status = 'Developing'
WHERE t1.status = '' AND t2.status <> ''AND t2.status = 'Developing';

-- Updated Null values for developed countries
UPDATE world_life_expectancy_staging as t1
JOIN world_life_expectancy_staging as t2
	 ON t1.Country = t2.Country
SET t1.status = 'Developed'
WHERE t1.status = '' AND t2.status <> ''AND t2.status = 'Developed';

## NULLs Life expectancy

-- Find NULLs in Life_expectancy
SELECT *
FROM world_life_expectancy_staging
WHERE `Life expectancy` = '';

-- Calculate the average to fill in NULLs
SELECT 
t1.Country, t1.YEAR, t1.`Life expectancy`, 
t2.Country, t2.YEAR, t2.`Life expectancy`,
t3.Country, t3.YEAR, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy_staging as t1
JOIN world_life_expectancy_staging as t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy_staging as t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

-- Fill the Nulls with Averages
UPDATE world_life_expectancy_staging as t1
JOIN world_life_expectancy_staging as t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy_staging as t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';


# ANALYSIS

## View Dataset
SELECT *
FROM world_life_expectancy_staging;

-- Which Country has seen their Life Expectancy increase the most?

SELECT 
Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) As Life_Expectancy_Increase_Over_15_Years
FROM world_life_expectancy_staging
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Expectancy_Increase_Over_15_Years DESC;

-- Average Life Expectancy globally year by year

SELECT YEAR, ROUND(AVG(`Life expectancy`),2) As average_life_expectancy 
FROM world_life_expectancy_staging
WHERE `Life Expectancy` <> 0
GROUP BY YEAR
ORDER BY YEAR DESC;

-- Correlation between life expectancy and GDP

SELECT country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy_staging 
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;

-- Compare High GDP Country Life Expectancy to Low GDP Countries Life Expectancy

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) As High_GDP_Countries,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END)) As High_GDP_Countries_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) As Low_GDP_Countries,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END)) As Low_GDP_Countries_Life_Expectancy
FROM world_life_expectancy_staging;

-- Compare Developed Countries Life Expectancy to Developing Countries Life Expectancy

SELECT status, COUNT(DISTINCT Country) AS Num_Of_Countries, ROUND(AVG(`Life expectancy`),1) AS Life_Exp
FROM world_life_expectancy_staging
GROUP BY status;
## Introduction

This project involves cleaning and preparing a life expectancy dataset, structuring it for analysis, and uncovering valuable insights using SQL queries.

## 5 Questions answered by the SQL queries

1. Which Country has seen their Life Expectancy increase the most?
3. What is the Average Life Expectancy globally year on year?
3. What is the Correlation between life expectancy and GDP?
4. How does High GDP Countries Life Expectancy compare to Low GDP Countries Life Expectancy?
5. How does Developed Countries Life Expectancy compare to Developing Countries Life Expectancy?

# Tools Used

- **SQL**
- **MySQL**
- **Visual Studio Code**
- **Git & Github**

 ## The preparation

 ### Remove Duplicates

  ```SQL
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
 ```
 
 ![Analysis](<sql_results/cleaning1_duplicates.png>)

 ### Deal with Nulls

  ```SQL
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
-- Update Nulls with Averages
UPDATE world_life_expectancy_staging as t1
JOIN world_life_expectancy_staging as t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy_staging as t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = '';
 ```

  ![Analysis](<sql_results/cleaning2_status_null.png>)
  ![Analysis](<sql_results/cleaning3_life_expectancy_null.png>)
 
 ## The analysis
 
 ### Query1
 
 ```SQL
 SELECT 
Country, 
MIN(`Life expectancy`), 
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) As Life_Expectancy_Increase_Over_15_Years
FROM world_life_expectancy_staging
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Expectancy_Increase_Over_15_Years DESC;
 ```
 
 ![Analysis](<sql_results/q1.png>)
 
 ### Query2
 
 ```SQL
SELECT YEAR, ROUND(AVG(`Life expectancy`),2) As average_life_expectancy 
FROM world_life_expectancy_staging
WHERE `Life Expectancy` <> 0
GROUP BY YEAR
ORDER BY YEAR DESC;
 ```
 ![Analysis](<sql_results/q2.png>)
 
 ### Query3
 
 ```SQL
 SELECT country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy_staging 
GROUP BY Country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;
 ```
  ![Analysis](<sql_results/q3.png>)
 
 ### Query4
 
 ```SQL
 SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) As High_GDP_Countries,
ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END)) As High_GDP_Countries_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) As Low_GDP_Countries,
ROUND(AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END)) As Low_GDP_Countries_Life_Expectancy
FROM world_life_expectancy_staging;
 ```
 ![Analysis](<sql_results/q4_updated.png>)
 
 ### Query5
 
 ```SQL
 SELECT status, COUNT(DISTINCT Country) AS Num_Of_Countries, ROUND(AVG(`Life expectancy`),1) AS Life_Exp
FROM world_life_expectancy_staging
GROUP BY status;
 ```
 ![Analysis](<sql_results/q5.png>)
 

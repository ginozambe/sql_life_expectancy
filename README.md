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
 

/* 
A study of data on the number of land animals slaughtered for meat in different regions of the world 
over a time period from 1961 to 2022.
*/

------------------------------------------
-- Look at all data
SELECT *
FROM PortfolioProject.dbo.[land-animals-slaughtered-for-meat]
------------------------------------------

-- Rename the columns for the easiest understanding and writing
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_chickens_slaughtered_to_produce_meat]', 'chickens', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_ducks_slaughtered_to_produce_meat]', 'ducks', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_pigs_slaughtered_to_produce_meat]', 'pigs', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_geese_slaughtered_to_produce_meat]', 'geese', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_sheep_slaughtered_to_produce_meat]', 'sheep', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_rabbits_slaughtered_to_produce_meat]', 'rabbits', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_turkeys_slaughtered_to_produce_meat]', 'turkeys', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_goats_slaughtered_to_produce_meat]', 'goat', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_cattle_slaughtered_to_produce_meat]', 'cattle', 'COLUMN';
EXEC sp_rename 'PortfolioProject.dbo.[land-animals-slaughtered-for-meat].[Number_of_other_animals_slaughtered_to_produce_meat]', 'other_animals', 'COLUMN';

------------------------------------------

-- Determing the world regions with the different incomes
SELECT Entity AS income_areas, COUNT(Entity) AS count_of_entity
FROM PortfolioProject..[land-animals-slaughtered-for-meat]
WHERE CAST(Entity AS varchar) LIKE '%income%'
GROUP BY Entity;

------------------------------------------

-- Determing the world regions with different levels of developing
SELECT Entity AS regional_development_levels, COUNT(Entity) AS count_of_entity
FROM PortfolioProject..[land-animals-slaughtered-for-meat]
WHERE CAST(Entity AS varchar) LIKE '%develop%'
GROUP BY Entity;

------------------------------------------

-- Determing the continents that consumed meat of ungulates
SELECT Entity, SUM(CAST(COALESCE(sheep, 0) AS bigint) + CAST(COALESCE(goat, 0) AS bigint) + CAST(COALESCE(cattle, 0) AS bigint)) AS total_unguntle_consumption
FROM PortfolioProject..[land-animals-slaughtered-for-meat]
WHERE CAST(Entity AS varchar) LIKE 'Europe' OR CAST(Entity AS varchar) LIKE 'Asia' 
    OR CAST(Entity AS varchar) LIKE 'North America' OR CAST(Entity AS varchar) LIKE 'South America' 
    OR CAST(Entity AS varchar) LIKE 'Australia' OR CAST(Entity AS varchar) LIKE 'Antarctica' 
GROUP BY Entity
ORDER BY total_unguntle_consumption DESC;

----------------------------------------

-- Determing the amount of poultry that slaughtered for meat throughtout the period from 1961 to 2022 in the Europe FAO
WITH EuropeFAO_Total AS (
    SELECT
        SUM(CAST(COALESCE(chickens, 0) AS BIGINT) + CAST(COALESCE(ducks, 0) AS BIGINT) + CAST(COALESCE(turkeys, 0) AS BIGINT)) AS total_amount_poultry_consumption_in_EuropeFAO
    FROM PortfolioProject..[land-animals-slaughtered-for-meat]
    WHERE CAST(Entity AS VARCHAR) = 'Europe (FAO)'
)
SELECT
    a.Entity,
    SUM(CAST(a.chickens AS FLOAT)) AS chickens,
    SUM(CAST(a.ducks AS FLOAT)) AS ducks,
    SUM(CAST(a.turkeys AS FLOAT)) AS turkeys,
    SUM(CAST(COALESCE(chickens, 0) AS BIGINT) + CAST(COALESCE(ducks, 0) AS BIGINT) + CAST(COALESCE(turkeys, 0) AS BIGINT)) AS total_amount_poultry_consumption_in_region,
    (SELECT total_amount_poultry_consumption_in_EuropeFAO FROM EuropeFAO_Total) - SUM(CAST(COALESCE(chickens, 0) AS BIGINT) + CAST(COALESCE(ducks, 0) AS BIGINT) + CAST(COALESCE(turkeys, 0) AS BIGINT)) AS difference_from_EuropeFAO 
FROM PortfolioProject..[land-animals-slaughtered-for-meat] AS a
WHERE CAST(Entity AS VARCHAR) LIKE '%Eur%FAO%'
GROUP BY a.Entity
HAVING SUM(CAST(a.chickens AS FLOAT)) != 0
       AND SUM(CAST(a.ducks AS FLOAT)) != 0
       AND SUM(CAST(a.turkeys AS FLOAT)) != 0
ORDER BY total_amount_poultry_consumption_in_region;

------------------------------------------

-- Drop the column "Code"
ALTER TABLE PortfolioProject..[land-animals-slaughtered-for-meat]
DROP COLUMN Code;

------------------------------------------

-- Determination of the total amount of meat in the world with indicators of the difference compared to the beginning of the global
-- crisis in 2008, as well as in 2007 and 10 years later - in 2018
SELECT Entity, [Year], SUM(CAST(pigs AS bigint) + CAST(rabbits AS bigint) + CAST(goat AS bigint) + CAST(chickens AS bigint)
        + CAST(ducks AS bigint) + CAST(geese AS bigint) + CAST(sheep AS bigint) + CAST(turkeys AS bigint) + CAST(cattle AS bigint)
        + CAST(other_animals AS bigint) ) AS Total
FROM PortfolioProject..[land-animals-slaughtered-for-meat]
WHERE [Year] IN ('1961', '2022') AND Entity = 'World'
GROUP BY Entity, [Year]
ORDER BY [Year];

-----------------------------------------

-- Create an additional column counting the total number of other animals across all regions, accumulating each year using 
-- a window function
SELECT Entity, [Year], other_animals, 
    SUM(CAST(other_animals AS bigint)) OVER (PARTITION BY Entity
    ORDER BY [Year] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS sum_total_animals
FROM PortfolioProject..[land-animals-slaughtered-for-meat]
ORDER BY Entity;

------------------------------------------

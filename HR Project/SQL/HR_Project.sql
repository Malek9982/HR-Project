-- Create a new database named HR_Analysis_DataBase
CREATE DATABASE HR_Analysis_DataBase

-- Use the newly created database
USE HR_Analysis_DataBase

----------------------------- Week 1: Build Data Model, Data Cleaning and Preprocessing ------------------
----------------------------------------------------------------------------------------------------------
-- Step 1: Import CSV Files 

-- import Employee table 
-- Righ click on HR_Analysis_DataBase database >>>> import wizard 
-- Convert Data Type (OverTime Column) into  nvarchar(50)
-- Convert Data Type (Attrition) into  nvarchar(50)
select * from Employee

-- import PerformanceRating table 
-- Righ click on HR_Analysis_DataBase database >>>> import wizard 
-- Convert Data Type (ReviewData Column) into  nvarchar(50), because an error occured !!
select * from PerformanceRating

-- Re-Converte Data Type (ReviewData Column) into  date !!
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PerformanceRating'

ALTER TABLE PerformanceRating
ALTER COLUMN ReviewDate DATE;

-- import EducationLevel table 
-- Righ click on HR_Analysis_DataBase database >>>> import wizard 
select * from EducationLevel

-- import RatingLevel table 
-- Righ click on HR_Analysis_DataBase database >>>> import wizard 
select * from RatingLevel

-- import SatisfiedLevel table 
-- Righ click on HR_Analysis_DataBase database >>>> import wizard 
select * from SatisfiedLevel

----------------------------- Relationships Setup -----------------------------------
-- Ensure the tables have proper primary keys and relationships if available
-- Adding sample relationships based on assumed structure

-- Assuming EmployeeID as Primary Key in Employee table
ALTER TABLE Employee
ADD CONSTRAINT PK_Employee PRIMARY KEY (EmployeeID);

-- Assuming PerformanceRatingID as Primary Key in PerformanceRating table
ALTER TABLE PerformanceRating
ADD CONSTRAINT PK_PerformanceRating PRIMARY KEY (PerformanceID, EmployeeID);

-- Assuming EducatioID as Primary Key in EducationLevel table
ALTER TABLE EducationLevel
ADD CONSTRAINT PK_EducationLevel PRIMARY KEY (EducationLevelID);

-- Assuming RatingLevelID as Primary Key in RatingLevel table
ALTER TABLE RatingLevel
ADD CONSTRAINT PK_RatingLevelID PRIMARY KEY (RatingID);

-- Assuming SatisfactionID as Primary Key in SatisfiedLevel table
ALTER TABLE SatisfiedLevel
ADD CONSTRAINT PK_SatisfiedLevel PRIMARY KEY (SatisfactionID);

-- Establishing Relationships
-- Merging Primary Tables
-- Merge Employee table and PerformanceRating table using EmployeeID
SELECT e.*, p.*
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID;

-- Merging Secondary Tables
-- Merge with Education Level (mapping EducationLevelID to Education)
SELECT e.*, p.*, el.EducationLevel
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
JOIN EducationLevel el ON e.Education = el.EducationLevelID;

-- Merge with Satisfaction Level (mapping EnvironmentSatisfaction to SatisfactionID)
SELECT e.*, p.*, el.EducationLevel, sl.SatisfactionLevel
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
JOIN EducationLevel el ON e.Education = el.EducationLevelID
JOIN SatisfiedLevel sl ON p.EnvironmentSatisfaction = sl.SatisfactionID;

-- Merge with Rating Level (mapping ManagerRating to RatingLevelID)
SELECT e.*, p.*, el.EducationLevel, sl.SatisfactionLevel, rl.RatingLevel
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
JOIN EducationLevel el ON e.Education = el.EducationLevelID
JOIN SatisfiedLevel sl ON p.EnvironmentSatisfaction = sl.SatisfactionID
JOIN RatingLevel rl ON p.ManagerRating = rl.RatingID;

--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------
-------------------------------Data Cleaning and Preprocessing------------------------------------
--------------------------------------------------------------------------------------------------
-- Step 1: Identify Missing Data
-- Count missing values in each table
SELECT 'Employee' AS TableName, COUNT(*) AS MissingCount
FROM Employee
WHERE EmployeeID IS NULL OR JobRole IS NULL OR Gender IS NULL;

SELECT 'PerformanceRating' AS TableName, COUNT(*) AS MissingCount
FROM PerformanceRating
WHERE PerformanceID IS NULL OR EmployeeID IS NULL;

SELECT 'EducationLevel' AS TableName, COUNT(*) AS MissingCount
FROM EducationLevel
WHERE EducationLevelID IS NULL OR EducationLevel IS NULL;

SELECT 'RatingLevel' AS TableName, COUNT(*) AS MissingCount
FROM RatingLevel
WHERE RatingID IS NULL OR RatingLevel IS NULL;

SELECT 'SatisfiedLevel' AS TableName, COUNT(*) AS MissingCount
FROM SatisfiedLevel
WHERE SatisfactionID IS NULL OR SatisfactionLevel IS NULL;

-- Step 2: Identify Duplicates
-- Find duplicates by primary key in each table
SELECT EmployeeID, COUNT(*)
FROM Employee
GROUP BY EmployeeID
HAVING COUNT(*) > 1;

SELECT PerformanceID, EmployeeID, COUNT(*)
FROM PerformanceRating
GROUP BY PerformanceID, EmployeeID
HAVING COUNT(*) > 1;

SELECT EducationLevelID, COUNT(*)
FROM EducationLevel
GROUP BY EducationLevelID
HAVING COUNT(*) > 1;

SELECT RatingID, COUNT(*)
FROM RatingLevel
GROUP BY RatingID
HAVING COUNT(*) > 1;

SELECT SatisfactionID, COUNT(*)
FROM SatisfiedLevel
GROUP BY SatisfactionID
HAVING COUNT(*) > 1;

--------------------- Ending of Week 1: Build Data Model, Data Cleaning and Preprocessing
----------------------------- Week 2: Analysis Questions Phase -----------------------------------
--------------------------------------------------------------------------------------------------
-- First Categoty
-- Employee Demographics & Salary Analysis
-- 1.1 Calculate and display the total number of employees
SELECT COUNT(DISTINCT EmployeeID) AS TotalEmployees
FROM Employee;

-- 1.2 Count unique employees by gender
SELECT 
    Gender,
    COUNT(DISTINCT EmployeeID) AS UniqueEmployeeCount
FROM Employee
GROUP BY Gender;

-- 1.3 Count unique employees by department
SELECT 
    Department,
    COUNT(DISTINCT EmployeeID) AS UniqueEmployeeCount
FROM Employee
GROUP BY Department;

-- 1.4 Count unique employees by gender within each department
SELECT 
    Department,
    Gender,
    COUNT(DISTINCT EmployeeID) AS UniqueEmployeeCount
FROM Employee
GROUP BY Department, Gender
ORDER BY Department, Gender;

-- 1.5 Count unique employees by education level
SELECT 
    el.EducationLevel, 
    COUNT(DISTINCT e.EmployeeID) AS UniqueEmployeeCount
FROM Employee e
JOIN EducationLevel el ON e.Education = el.EducationLevelID
GROUP BY el.EducationLevel
ORDER BY el.EducationLevel;

-- 1.6 Count unique employees by job role
SELECT 
    JobRole,
    COUNT(DISTINCT EmployeeID) AS UniqueEmployeeCount
FROM Employee
GROUP BY JobRole
ORDER BY JobRole;

-- 2. How does the average salary vary by education level?
SELECT el.EducationLevel,
    AVG(CAST(e.Salary AS DECIMAL(18,2))) AS AverageSalary
FROM Employee e
JOIN EducationLevel el ON e.Education = el.EducationLevelID
GROUP BY el.EducationLevel;

-- 3. Is there a gender pay gap across different job roles and departments?
-- 3. (A) Count the unique number of employees per JobRole
SELECT JobRole, COUNT(DISTINCT EmployeeID) AS UniqueEmployeeCount
FROM Employee
GROUP BY JobRole;

-- 3. (B) Calculate the average salary based on unique employees per JobRole
SELECT e.JobRole, 
       CAST(AVG(CAST(e.Salary AS DECIMAL(18, 6))) AS DECIMAL(18, 6)) AS AverageSalary -- Ensure Salary is treated as decimal
FROM (SELECT DISTINCT EmployeeID, JobRole, Salary FROM Employee) e
GROUP BY e.JobRole;

-- 4. What is the salary distribution based on years of experience?
-- Calculate the promotion rate by JobRole, similar to the Python code
SELECT e.JobRole,
       COUNT(DISTINCT CASE WHEN e.YearsSinceLastPromotion = 0 THEN e.EmployeeID END) AS PromotedEmployeeCount,
       COUNT(DISTINCT e.EmployeeID) AS TotalEmployeeCount,
       (COUNT(DISTINCT CASE WHEN e.YearsSinceLastPromotion = 0 THEN e.EmployeeID END) * 100.0 / 
        COUNT(DISTINCT e.EmployeeID)) AS PromotionRate
FROM Employee e
GROUP BY e.JobRole
ORDER BY PromotionRate DESC;

-- 5 Calculate the average salary by department for unique employees?
SELECT e.Department, 
    CAST(AVG(CAST(e.Salary AS DECIMAL(18, 6))) AS DECIMAL(18, 6)) AS AverageSalary
FROM Employee e
GROUP BY e.Department
ORDER BY AverageSalary DESC;

-- Second Categoty
-- Employee Satisfaction & Engagement
-- 6. What is the average satisfaction level across different job roles?
SELECT e.JobRole,
    ROUND(AVG(CAST(p.JobSatisfaction AS DECIMAL(10, 2))), 6) AS AverageSatisfaction,
    CASE 
        WHEN AVG(p.JobSatisfaction) = 1 THEN 'Very Dissatisfied'
        WHEN AVG(p.JobSatisfaction) = 2 THEN 'Dissatisfied'
        WHEN AVG(p.JobSatisfaction) = 3 THEN 'Neutral'
        WHEN AVG(p.JobSatisfaction) = 4 THEN 'Satisfied'
        WHEN AVG(p.JobSatisfaction) = 5 THEN 'Very Satisfied'
        ELSE 'Unknown' 
    END AS SatisfactionLevel
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
JOIN SatisfiedLevel sl ON p.JobSatisfaction = sl.SatisfactionID
GROUP BY e.JobRole;

-- 7 Calculate average salary by satisfaction level for unique employees
WITH UniqueEmployees AS (
    SELECT E.EmployeeID, 
           (SELECT TOP 1 PR.JobSatisfaction 
            FROM PerformanceRating PR 
            WHERE PR.EmployeeID = E.EmployeeID 
            ORDER BY PR.EmployeeID) AS JobSatisfaction, 
           (SELECT TOP 1 E2.Salary 
            FROM Employee E2 
            WHERE E2.EmployeeID = E.EmployeeID 
            ORDER BY E2.EmployeeID) AS Salary
    FROM Employee E
    GROUP BY E.EmployeeID
)
SELECT JobSatisfaction, AVG(Salary * 1.0) AS AverageSalary
FROM UniqueEmployees
WHERE JobSatisfaction IS NOT NULL
GROUP BY JobSatisfaction
ORDER BY JobSatisfaction;

-- 8. Do employees with higher education levels report higher satisfaction?
SELECT el.EducationLevel,
    ROUND(AVG(CAST(p.JobSatisfaction AS DECIMAL(10, 2))), 6) AS AverageSatisfaction
FROM Employee e
JOIN EducationLevel el ON e.Education = el.EducationLevelID
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY el.EducationLevel;

-- 9. Which departments have the most satisfied and least satisfied employees?
SELECT e.Department,
    ROUND(AVG(CAST(p.JobSatisfaction AS DECIMAL(10, 2))), 6) AS AverageSatisfaction
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
GROUP BY e.Department;

-- 10. Does job role impact satisfaction level?
SELECT e.JobRole,
    ROUND(AVG(CAST(p.JobSatisfaction AS DECIMAL(10, 2))), 6) AS AverageSatisfaction,
    CASE 
        WHEN AVG(p.JobSatisfaction) = 1 THEN 'Very Dissatisfied'
        WHEN AVG(p.JobSatisfaction) = 2 THEN 'Dissatisfied'
        WHEN AVG(p.JobSatisfaction) = 3 THEN 'Neutral'
        WHEN AVG(p.JobSatisfaction) = 4 THEN 'Satisfied'
        WHEN AVG(p.JobSatisfaction) = 5 THEN 'Very Satisfied'
            ELSE NULL
    END AS AverageSatisfaction
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
JOIN SatisfiedLevel sl ON p.JobSatisfaction = sl.SatisfactionID
GROUP BY e.JobRole;

-- Third Categoty
-- Attrition & Turnover Analysis
-- 11. What is the overall employee attrition rate?
SELECT 
    e.Attrition,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Employee), 6) AS AttritionRate
FROM Employee e
GROUP BY e.Attrition
ORDER BY Attrition DESC;

-- 12. Which department has the highest employee turnover?
SELECT 
    e.Department,
    COUNT(*) AS TotalEmployees, -- Count total employees in each department
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionEmployees, -- Count employees who left
    (SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS AttritionRate -- Calculate attrition rate as a percentage
FROM Employee e
GROUP BY e.Department
ORDER BY AttritionRate DESC; -- Sort departments by highest attrition rate

-- 13. Is there a connection between satisfaction level and attrition?
SELECT sl.SatisfactionLevel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionEmployees,
    (SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS AttritionRate
FROM PerformanceRating p
JOIN SatisfiedLevel sl ON p.EnvironmentSatisfaction = sl.SatisfactionID
JOIN Employee e ON p.EmployeeID = e.EmployeeID
GROUP BY sl.SatisfactionLevel
ORDER BY AttritionRate DESC;

-- 13. Is there a connection between satisfaction level and attrition?
WITH LatestPerformance AS (
    SELECT 
        EmployeeID, 
        EnvironmentSatisfaction,
        ROW_NUMBER() OVER (PARTITION BY EmployeeID ORDER BY ReviewDate DESC) AS rn
    FROM PerformanceRating
)
SELECT 
    sl.SatisfactionLevel,
    COUNT(DISTINCT e.EmployeeID) AS TotalEmployees,
    COUNT(DISTINCT CASE WHEN e.Attrition = 'Yes' THEN e.EmployeeID END) AS AttritionEmployees,
    (COUNT(DISTINCT CASE WHEN e.Attrition = 'Yes' THEN e.EmployeeID END) * 100.0) / COUNT(DISTINCT e.EmployeeID) AS AttritionRate
FROM Employee e
JOIN LatestPerformance lp ON e.EmployeeID = lp.EmployeeID AND lp.rn = 1
JOIN SatisfiedLevel sl ON lp.EnvironmentSatisfaction = sl.SatisfactionID
GROUP BY sl.SatisfactionLevel
ORDER BY AttritionRate DESC;

-- 14. Do employees with higher education levels have lower attrition rates?
SELECT el.EducationLevel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionEmployees,
    (SUM(CASE WHEN e.Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS AttritionRate
FROM Employee e
LEFT JOIN EducationLevel el ON e.Education = el.EducationLevelID
GROUP BY el.EducationLevel
ORDER BY AttritionRate ASC;

-- 15. How does tenure (years at company) impact attrition?
WITH EmployeeTenure AS (
    SELECT 
        e.EmployeeID,
        e.YearsAtCompany,  -- Use the original YearsAtCompany value instead of recalculating it
        e.Attrition,
        ROW_NUMBER() OVER (PARTITION BY e.EmployeeID ORDER BY e.HireDate ASC) AS rn
    FROM Employee e
)
-- Step 2: Calculate attrition rate based on unique employees
SELECT 
    YearsAtCompany,
    COUNT(EmployeeID) AS TotalEmployees,  -- Count total unique employees per tenure
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritionEmployees,  -- Count employees who left
    (SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) * 100.0) / COUNT(EmployeeID) AS AttritionRate  -- Calculate attrition rate (%)
FROM EmployeeTenure
WHERE rn = 1  -- Select only the first record for each employee
GROUP BY YearsAtCompany
ORDER BY YearsAtCompany ASC;

-- Fourth Category 
-- Promotion & Career Growth
-- 16. How long does it take, on average, for employees to receive a promotion?
SELECT 
    CAST(AVG(CAST(e.YearsSinceLastPromotion AS DECIMAL(18, 6))) AS DECIMAL(18, 6)) AS AveragePromotionTime
FROM Employee e;

-- 17. Is there a correlation between education level and promotion frequency?
SELECT 
    el.EducationLevel,
    AVG(CAST(e.YearsSinceLastPromotion AS FLOAT)) AS AvgYearsSinceLastPromotion  -- Calculate the average time to promotion
FROM Employee e
LEFT JOIN EducationLevel el ON e.Education = el.EducationLevelID
GROUP BY el.EducationLevel
ORDER BY AvgYearsSinceLastPromotion ASC; 

-- 18. Which departments promote employees the fastest and the slowest?
SELECT e.Department,
    CAST(AVG(CAST(e.YearsSinceLastPromotion AS DECIMAL(18, 6))) AS DECIMAL(18, 6)) AS AveragePromotionTime
FROM Employee e
GROUP BY e.Department
ORDER BY AveragePromotionTime ASC;  -- Fastest promotion first

-- 19. What percentage of satisfied employees receive promotions?
-- 19.1. Select the first job satisfaction rating for each employee
WITH FirstSatisfaction AS (
    SELECT 
        e.EmployeeID,
        pr.JobSatisfaction,
        e.YearsSinceLastPromotion,
        ROW_NUMBER() OVER (PARTITION BY e.EmployeeID ORDER BY e.YearsSinceLastPromotion ASC) AS row_num
    FROM Employee e
    JOIN PerformanceRating pr ON e.EmployeeID = pr.EmployeeID
)
-- 19.2. Calculate the total number of employees and the number of promoted employees by job satisfaction level
, PromotionStats AS (
    SELECT 
        JobSatisfaction,
        COUNT(DISTINCT EmployeeID) AS TotalEmployees,  -- Ensure each employee is counted only once
        COUNT(DISTINCT CASE WHEN YearsSinceLastPromotion = 0 THEN EmployeeID END) AS PromotedEmployees
    FROM FirstSatisfaction
    WHERE row_num = 1  -- Select only the first record per employee
    GROUP BY JobSatisfaction
)
-- 19.3. Compute the promotion percentage by job satisfaction level
SELECT 
    JobSatisfaction,
    TotalEmployees,
    PromotedEmployees,
    (PromotedEmployees * 100.0) / NULLIF(TotalEmployees, 0) AS PromotionPercentage
FROM PromotionStats
ORDER BY JobSatisfaction;

-- 20. Does gender impact promotion opportunities?
WITH UniqueEmployees AS (
    SELECT 
        e.EmployeeID,
        e.Gender,
        e.YearsSinceLastPromotion
    FROM Employee e
    -- Ensure each employee appears only once based on first promotion date
    WHERE e.YearsSinceLastPromotion = (
        SELECT MIN(e2.YearsSinceLastPromotion) 
        FROM Employee e2 
        WHERE e2.EmployeeID = e.EmployeeID
    )
)
SELECT 
    Gender,
    COUNT(CASE WHEN YearsSinceLastPromotion = 0 THEN 1 END) AS PromotionFrequency,
    COUNT(*) AS TotalEmployees,
    (COUNT(CASE WHEN YearsSinceLastPromotion = 0 THEN 1 END) * 100.0) / COUNT(*) AS PromotionRate
FROM UniqueEmployees
GROUP BY Gender
ORDER BY PromotionRate DESC;

----------------------------- Additional Questions -----------------------------------------------
--------------------------------------------------------------------------------------------------
-- 21. Calculate the total salary of all employees
SELECT SUM(Salary) AS total_salary
FROM (
    SELECT DISTINCT EmployeeID, Salary 
    FROM Employee
) AS unique_salaries;

-- 22. Calculate total salary distribution by department
SELECT Department, SUM(Salary) AS total_salary
FROM (
    -- Select distinct EmployeeID and Salary to avoid duplicate salary calculations
    SELECT DISTINCT EmployeeID, Department, Salary 
    FROM Employee
) AS unique_salaries
GROUP BY Department;

-- 23. Calculate the number of employees hired in each year 
SELECT 
    YEAR(HireDate) AS Year, 
    COUNT(DISTINCT EmployeeID) AS EmployeeCount
FROM Employee
GROUP BY YEAR(HireDate)
ORDER BY Year;

-- 24. Calculate the Number of Embployees based on BusinessTravel and Attrition
SELECT 
    BusinessTravel, 
    Attrition, 
    COUNT(DISTINCT EmployeeID) AS EmployeeCount
FROM Employee
GROUP BY BusinessTravel, Attrition
ORDER BY BusinessTravel, Attrition;

-- 25. Calculate the Number of Employees based on OverTime and Attrition
-- Count unique employees based on OverTime and Attrition
SELECT 
    OverTime, 
    Attrition, 
    COUNT(DISTINCT EmployeeID) AS EmployeeCount
FROM Employee
GROUP BY OverTime, Attrition
ORDER BY OverTime, Attrition;

-- 26.1 Define the age ranges of Employees
WITH AgeRanges AS (
    SELECT
        EmployeeID,
        CASE
            WHEN Age >= 20 AND Age < 30 THEN '20-30'
            WHEN Age >= 30 AND Age < 40 THEN '30-40'
            WHEN Age >= 40 AND Age < 50 THEN '40-50'
            WHEN Age >= 50 AND Age < 60 THEN '50-60'
            WHEN Age >= 60 AND Age < 70 THEN '60-70'
            ELSE 'Other'
        END AS AgeRange
    FROM Employee
    WHERE Age IS NOT NULL  -- Exclude employees with missing age
)

-- Count employees in each age range
, AgeRangeCount AS (
    SELECT AgeRange, COUNT(DISTINCT EmployeeID) AS EmployeeCount
    FROM AgeRanges
    GROUP BY AgeRange
)

-- Display age range counts
SELECT * FROM AgeRangeCount
ORDER BY EmployeeCount DESC;

-- 26.2 Find the minimum and maximum age of employees (no duplicates)
SELECT
    MIN(Age) AS MinAge,
    MAX(Age) AS MaxAge
FROM Employee
WHERE Age IS NOT NULL;

-- 27. Calculate the correlation between ManagerRating and JobSatisfaction
WITH PerformanceManagerRating AS (
    -- Merge all necessary tables (Employee, PerformanceRating, EducationLevel, SatisfiedLevel, RatingLevel)
    SELECT 
        e.EmployeeID,
        p.ManagerRating,
        p.JobSatisfaction
    FROM Employee e
    JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
    JOIN EducationLevel el ON e.Education = el.EducationLevelID
    JOIN SatisfiedLevel sl ON p.EnvironmentSatisfaction = sl.SatisfactionID
    JOIN RatingLevel rl ON p.ManagerRating = rl.RatingID
    WHERE p.ManagerRating IS NOT NULL AND p.JobSatisfaction IS NOT NULL
)

-- Calculate the mean of JobSatisfaction for each ManagerRating
SELECT 
    ManagerRating, 
    AVG(JobSatisfaction) AS AverageJobSatisfaction
FROM PerformanceManagerRating
GROUP BY ManagerRating
ORDER BY ManagerRating;

-- 28. Count employees hired per year and Count employees who left (attrition) by each department
WITH HireCounts AS (
    SELECT 
        YEAR(HireDate) AS Year, 
        Department, 
        COUNT(DISTINCT EmployeeID) AS EmployeesHired
    FROM Employee
    GROUP BY YEAR(HireDate), Department
),
AttritionCounts AS (
    SELECT 
        YEAR(HireDate) AS Year, 
        Department, 
        COUNT(DISTINCT EmployeeID) AS EmployeesLeft
    FROM Employee
    WHERE Attrition = 'Yes'
    GROUP BY YEAR(HireDate), Department
)
SELECT 
    COALESCE(h.Year, a.Year) AS Year,
    COALESCE(h.Department, a.Department) AS Department,
    COALESCE(h.EmployeesHired, 0) AS EmployeesHired,
    COALESCE(a.EmployeesLeft, 0) AS EmployeesLeft
FROM HireCounts h
FULL OUTER JOIN AttritionCounts a 
ON h.Year = a.Year AND h.Department = a.Department
ORDER BY Year, Department;

-- 29. What is the most common reason for employee turnover?
-- JobRole
SELECT TOP 1 JobRole, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
WHERE e.Attrition = 'Yes'
GROUP BY JobRole
ORDER BY Count DESC;

-- BusinessTravel
SELECT TOP 1 BusinessTravel, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
WHERE e.Attrition = 'Yes'
GROUP BY BusinessTravel
ORDER BY Count DESC;

-- OverTime
SELECT TOP 1 OverTime, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
WHERE e.Attrition = 'Yes'
GROUP BY OverTime
ORDER BY Count DESC;

-- JobSatisfaction
SELECT TOP 1 CAST(JobSatisfaction AS DECIMAL(3,2)) AS JobSatisfaction, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
WHERE e.Attrition = 'Yes'
GROUP BY JobSatisfaction
ORDER BY Count DESC;

-- ManagerRating
SELECT TOP 1 CAST(ManagerRating AS DECIMAL(3,2)) AS ManagerRating, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
WHERE e.Attrition = 'Yes'
GROUP BY ManagerRating
ORDER BY Count DESC;

-- WorkLifeBalance
SELECT TOP 1 CAST(WorkLifeBalance AS DECIMAL(3,2)) AS WorkLifeBalance, COUNT(DISTINCT e.EmployeeID) AS Count
FROM Employee e
JOIN PerformanceRating p ON e.EmployeeID = p.EmployeeID
WHERE e.Attrition = 'Yes'
GROUP BY WorkLifeBalance
ORDER BY Count DESC;

--------------------- Ending of Week 2: Analysis Questions Phase ---------------------------------
----------------------------- Week 3: Forecasting Questions Phase --------------------------------
--------------------------------------------------------------------------------------------------
-- 1. Predict attrition for the next 3 years
WITH EmployeeStatus AS (
    SELECT 
        EmployeeID,
        YEAR(HireDate) AS HireYear,
        CASE 
            WHEN Attrition = 'Yes' THEN YEAR(HireDate) + YearsAtCompany 
            ELSE NULL 
        END AS ExitYear
    FROM Employee
),
Years AS (
    SELECT 2012 AS Year
    UNION ALL SELECT 2013
    UNION ALL SELECT 2014
    UNION ALL SELECT 2015
    UNION ALL SELECT 2016
    UNION ALL SELECT 2017
    UNION ALL SELECT 2018
    UNION ALL SELECT 2019
    UNION ALL SELECT 2020
    UNION ALL SELECT 2021
    UNION ALL SELECT 2022
),
YearlyAttrition AS (
    SELECT 
        y.Year,
        COUNT(DISTINCT e.EmployeeID) AS ActiveEmployees,
        COUNT(DISTINCT CASE WHEN e.ExitYear = y.Year THEN e.EmployeeID END) AS ExitedEmployees
    FROM Years y
    LEFT JOIN EmployeeStatus e
        ON y.Year BETWEEN e.HireYear AND ISNULL(e.ExitYear, 9999)
    GROUP BY y.Year
),
WithRates AS (
    SELECT 
        Year,
        ActiveEmployees,
        ExitedEmployees,
        CAST(ExitedEmployees AS FLOAT) / NULLIF(ActiveEmployees, 0) AS AttritionRate
    FROM YearlyAttrition
),
PredictedYears AS (
    SELECT 2023 AS Year
    UNION ALL SELECT 2024
    UNION ALL SELECT 2025
),
Predicted AS (
    SELECT 
        p.Year,
        NULL AS ActiveEmployees,
        NULL AS ExitedEmployees,
        (SELECT AVG(AttritionRate) FROM WithRates) AS AttritionRate
    FROM PredictedYears p
)
SELECT * FROM WithRates
UNION ALL
SELECT * FROM Predicted
ORDER BY Year;

-- 2. Predict Salary Growth Projection for next 3 years
--  Create year list from 2012 to 2025
WITH Years AS (
    SELECT 2012 AS Year
    UNION ALL SELECT 2013
    UNION ALL SELECT 2014
    UNION ALL SELECT 2015
    UNION ALL SELECT 2016
    UNION ALL SELECT 2017
    UNION ALL SELECT 2018
    UNION ALL SELECT 2019
    UNION ALL SELECT 2020
    UNION ALL SELECT 2021
    UNION ALL SELECT 2022
    UNION ALL SELECT 2023
    UNION ALL SELECT 2024
    UNION ALL SELECT 2025
),
-- Generate salary history based on YearsAtCompany
SalaryHistory AS (
    SELECT 
        EmployeeID,
        YEAR(HireDate) + diff.num AS Year,
        Salary * POWER(1.0 + 0.0, diff.num) AS EstimatedSalary  -- Placeholder
    FROM Employee
    CROSS APPLY (
        SELECT TOP (YearsAtCompany)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS num
        FROM master.dbo.spt_values
    ) AS diff
),
-- Calculate annual salary growth rates
SalaryDiffs AS (
    SELECT 
        s1.EmployeeID,
        s1.Year AS Year1,
        s2.Year AS Year2,
        s1.EstimatedSalary AS Salary1,
        s2.EstimatedSalary AS Salary2,
        (s2.EstimatedSalary - s1.EstimatedSalary) / NULLIF(s1.EstimatedSalary, 0) AS GrowthRate
    FROM SalaryHistory s1
    JOIN SalaryHistory s2
        ON s1.EmployeeID = s2.EmployeeID AND s2.Year = s1.Year + 1
),
-- Get average growth rate
AvgGrowth AS (
    SELECT AVG(GrowthRate) AS AvgSalaryGrowthRate FROM SalaryDiffs
),
-- Actual salary stats for years with real data
ActualYearlySalaries AS (
    SELECT 
        Year,
        COUNT(EmployeeID) AS EmployeeCount,
        ROUND(AVG(EstimatedSalary), 2) AS AvgSalary
    FROM SalaryHistory
    WHERE Year BETWEEN 2012 AND 2022
    GROUP BY Year
),
-- Get current salary of employees
CurrentSalaries AS (
    SELECT EmployeeID, MAX(Salary) AS CurrentSalary FROM Employee GROUP BY EmployeeID
),
-- Predict salaries for future years
FutureYears AS (
    SELECT 2023 AS Year
    UNION ALL SELECT 2024
    UNION ALL SELECT 2025
),
PredictedSalaries AS (
    SELECT 
        f.Year,
        c.EmployeeID,
        ROUND(c.CurrentSalary * POWER(1 + a.AvgSalaryGrowthRate, f.Year - 2022), 2) AS PredictedSalary
    FROM FutureYears f
    CROSS JOIN CurrentSalaries c
    CROSS JOIN AvgGrowth a
),
PredictedSummary AS (
    SELECT 
        Year,
        COUNT(EmployeeID) AS EmployeeCount,
        ROUND(AVG(PredictedSalary), 2) AS AvgSalary
    FROM PredictedSalaries
    GROUP BY Year
),
-- Combine actual and predicted data
Combined AS (
    SELECT * FROM ActualYearlySalaries
    UNION ALL
    SELECT * FROM PredictedSummary
)
-- Final output ordered by year
SELECT 
    Year,
    EmployeeCount,
    AvgSalary AS AvgPredictedSalary
FROM Combined
ORDER BY Year;

-- 3. Predection workforce in 3 years  by Department, Age Group & Education Level
WITH EducationMapping AS (
    SELECT 1 AS EducationLevel, 'High School' AS EducationName
    UNION ALL SELECT 2, 'Associate Degree'
    UNION ALL SELECT 3, 'Bachelor''s Degree'
    UNION ALL SELECT 4, 'Master''s Degree'
    UNION ALL SELECT 5, 'PhD'
),
EmployeeStatus AS (
    SELECT 
        e.EmployeeID,
        e.Department,
        CASE
            WHEN e.Age BETWEEN 18 AND 30 THEN '18-30'
            WHEN e.Age BETWEEN 31 AND 40 THEN '31-40'
            WHEN e.Age BETWEEN 41 AND 50 THEN '41-50'
            WHEN e.Age BETWEEN 51 AND 60 THEN '51-60'
            ELSE '60+' 
        END AS AgeGroup,
        el.EducationLevel AS Education,  -- Mapping EducationLevelID to Education Name
        em.EducationName AS EducationName, -- Mapping numeric value to actual name
        e.HireDate,
        DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YearsAtCompany,
        YEAR(GETDATE()) AS CurrentYear
    FROM Employee e
    LEFT JOIN EducationLevel el ON e.Education = el.EducationLevelID
    LEFT JOIN EducationMapping em ON el.EducationLevelID = em.EducationLevel
),
EmployeeCounts AS (
    SELECT 
        Department,
        AgeGroup,
        EducationName AS Education,
        COUNT(e.EmployeeID) AS EmployeeCount,
        CurrentYear
    FROM EmployeeStatus e
    GROUP BY Department, AgeGroup, EducationName, CurrentYear
),
YearlyGrowthRate AS (
    SELECT
        Department,
        AgeGroup,
        Education,
        EmployeeCount,
        CAST(EmployeeCount AS FLOAT) / NULLIF(LAG(EmployeeCount) OVER (PARTITION BY Department, AgeGroup, Education ORDER BY CurrentYear), 0) AS GrowthRate
    FROM EmployeeCounts
),
PredictedYears AS (
    SELECT 2023 AS Year
    UNION ALL SELECT 2024
    UNION ALL SELECT 2025
)
SELECT 
    p.Year,
    ec.Department,
    ec.AgeGroup,
    ec.Education,
    ROUND(ec.EmployeeCount * COALESCE(yg.GrowthRate, 1), 0) AS PredictedEmployeeCount
FROM PredictedYears p
JOIN EmployeeCounts ec ON 1 = 1  -- Cross join to apply prediction across all combinations
LEFT JOIN YearlyGrowthRate yg 
    ON ec.Department = yg.Department
    AND ec.AgeGroup = yg.AgeGroup
    AND ec.Education = yg.Education
ORDER BY p.Year, ec.Department, ec.AgeGroup, ec.Education;

--------------------- Ending of Week 3: Forecasting Questions Phase -----------------------------
--------------------------------------------------------------------------------------------------


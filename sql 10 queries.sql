use adventureworks;

-- Get all products with list price greater than 1000

SELECT ProductKey, EnglishProductName, ListPrice
FROM product_details
WHERE ListPrice > 1000;

--  List all sales territories in Europe

UPDATE salesterritory
SET SalesTerritoryGroup = TRIM(REPLACE(SalesTerritoryGroup, '\r', ''));

SELECT SalesTerritoryKey, SalesTerritoryRegion, SalesTerritoryCountry
FROM salesterritory
WHERE SalesTerritoryGroup = 'North America';

-- List top 5 most expensive products by list price

SELECT ProductKey, EnglishProductName, ListPrice
FROM product_details
ORDER BY ListPrice DESC
LIMIT 5;

-- Monthly Aggregated Sales Profit Report
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
    SUM(SalesAmount) AS TotalSales,
    SUM(ProductionCost) AS TotalCost,
    SUM(SalesAmount - ProductionCost) AS TotalProfit
FROM sales1
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY Month;

 --  Join sales1 and dimdate to see sales by weekday
 
SELECT d.EnglishDayNameOfWeek, COUNT(*) AS Total_Orders
FROM sales1 s
JOIN dimdate d ON s.OrderDateKey = d.DateKey
GROUP BY d.EnglishDayNameOfWeek
ORDER BY Total_Orders DESC;

-- finding the middle name N/A and getting customerfull name
SELECT *
FROM customers
WHERE LOWER(MiddleName) = 'N/A';

SELECT 
  CustomerKey,
  CONCAT_WS(' ', FirstName, 
    NULLIF(MiddleName, 'N/A'), 
    LastName
  ) AS FullName
FROM customers;

--- view 
CREATE VIEW vw_customer_territory AS
SELECT 
    c.CustomerKey,
    CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
    s.SalesTerritoryRegion,
    s.SalesTerritoryCountry
FROM customers c
JOIN salesterritory s 
    ON c.GeographyKey = s.SalesTerritoryKey;

SELECT 
    *
FROM
    vw_customer_territory
WHERE
    SalesTerritoryCountry = 'Germany';

-- Get top 3 territories by customer count using rank
SELECT 
    SalesTerritoryGroup,
    COUNT(CustomerKey) AS CustomerCount,
    ROW_NUMBER() OVER (ORDER BY COUNT(CustomerKey) DESC) AS row_num
FROM customers c
JOIN salesterritory s 
  ON c.GeographyKey = s.SalesTerritoryKey
GROUP BY SalesTerritoryGroup;

--- store procedure
DELIMITER $$

CREATE PROCEDURE Get_Customers_By_Region_Income (
    IN region_name VARCHAR(100),
    IN min_income DECIMAL(10,2)
)
BEGIN
    SELECT 
        c.CustomerKey,
        CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
        s.SalesTerritoryRegion,
        c.YearlyIncome
    FROM customers c
    JOIN salesterritory s 
      ON c.GeographyKey = s.SalesTerritoryKey
    WHERE s.SalesTerritoryRegion = region_name
      AND c.YearlyIncome > min_income;
END $$

DELIMITER ;
CALL Get_Customers_By_Region_Income('Germany', 100000);

-- conditional case
SELECT 
    CustomerKey,
    YearlyIncome,
    CASE 
        WHEN YearlyIncome >= 500000 THEN 'High Income'
        WHEN YearlyIncome >= 250000 THEN 'Mid Income'
        ELSE 'Low Income'
    END AS IncomeCategory
FROM customers;

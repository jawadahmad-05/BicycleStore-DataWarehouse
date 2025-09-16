USE BicycleStore
GO

-- Product Revenue Analysis
-- Identifies top revenue-generating products and their categories
-- Helps in inventory planning and category expansion decisions
SELECT 
    p.ProductCategoryName, 
    p.ProductName, 
    SUM(f.SalesAmount) AS TotalSales
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY 
    p.ProductCategoryName, 
    p.ProductName
ORDER BY 
    TotalSales DESC;


-- Customer Value Analysis
-- Tracks customer spending patterns and engagement levels
-- Used for customer segmentation and targeted marketing campaigns
SELECT 
    c.CustomerName, 
    c.CustomerEmail, 
    SUM(f.SalesAmount) AS TotalSpent, 
    COUNT(f.OrderNo) AS TotalOrders,
    SUM(f.SalesAmount)/COUNT(f.OrderNo) AS AverageOrderValue
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY 
    c.CustomerName, 
    c.CustomerEmail
ORDER BY 
    TotalSpent DESC;


-- Salesperson Performance Dashboard
-- Evaluates individual and store-level sales performance
-- Useful for commission calculations and performance reviews
SELECT 
    s.SalespersonName, 
    s.StoreName, 
    SUM(f.SalesAmount) AS TotalSales, 
    COUNT(f.OrderNo) AS TotalOrders,
    SUM(f.SalesAmount - f.Cost) AS TotalProfit
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimSalesperson s ON f.SalespersonKey = s.SalespersonKey
GROUP BY 
    s.SalespersonName, 
    s.StoreName
ORDER BY 
    TotalSales DESC;


-- Shipping Performance Metrics
-- Analyzes shipping company performance and revenue distribution
-- Helps in negotiating shipping contracts and optimizing delivery costs
SELECT 
    sp.ShipperName, 
    COUNT(f.OrderNo) AS TotalOrders, 
    SUM(f.SalesAmount) AS TotalRevenue,
    COUNT(DISTINCT d.MonthName) AS MonthsActive
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimShipper sp ON f.ShipperKey = sp.ShipperKey
JOIN 
    dw.DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY 
    sp.ShipperName
ORDER BY 
    TotalRevenue DESC;


-- Regional Sales Distribution
-- Maps sales performance across different regions and countries
-- Used for market expansion and regional marketing strategies
SELECT 
    g.Region, 
    g.Country, 
    SUM(f.SalesAmount) AS TotalSales,
    COUNT(DISTINCT f.OrderNo) AS TotalOrders,
    COUNT(DISTINCT c.CustomerKey) AS UniqueCustomers
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimGeography g ON f.SalespersonKey = g.GeographyKey
JOIN 
    dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY 
    g.Region, 
    g.Country
ORDER BY 
    TotalSales DESC;


-- Monthly Performance Dashboard
-- Tracks monthly sales trends and order volumes
-- Essential for seasonal planning and performance monitoring
SELECT 
    d.MonthName,
    COUNT(DISTINCT f.OrderNo) as TotalOrders,
    SUM(f.SalesAmount) as TotalSales,
    SUM(f.SalesAmount - f.Cost) as MonthlyProfit
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimDate d ON f.OrderDateKey = d.DateKey
GROUP BY 
    d.MonthName, d.MonthOfYear
ORDER BY 
    d.MonthOfYear;


-- High-Value Customer Analysis
-- Identifies and profiles top 10 customers by revenue
-- Used for VIP customer retention strategies
SELECT TOP 10
    c.CustomerKey,
    c.CustomerName,
    SUM(f.SalesAmount) as TotalSpent,
    COUNT(DISTINCT f.OrderNo) as NumberOfOrders,
    SUM(f.SalesAmount)/COUNT(DISTINCT f.OrderNo) as AverageOrderValue
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimCustomer c ON f.CustomerKey = c.CustomerKey
GROUP BY 
    c.CustomerKey, c.CustomerName
ORDER BY 
    TotalSpent DESC;


-- Category Profit Analysis
-- Analyzes profitability by product category
-- Helps in optimizing product mix and pricing strategies
SELECT 
    p.ProductCategoryName, 
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.Cost) AS TotalCost,
    SUM(f.SalesAmount - f.Cost) AS TotalProfit,
    (SUM(f.SalesAmount - f.Cost)/SUM(f.SalesAmount)) * 100 AS ProfitMargin
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY 
    p.ProductCategoryName
ORDER BY 
    TotalProfit DESC;


-- Price Optimization Opportunities
-- Identifies products with high volume but low revenue
-- Used for pricing strategy adjustments and promotions
SELECT 
    p.ProductName, 
    SUM(f.Quantity) AS TotalQuantity, 
    SUM(f.SalesAmount) AS TotalRevenue,
    SUM(f.SalesAmount)/SUM(f.Quantity) AS AverageUnitPrice,
    SUM(f.SalesAmount - f.Cost)/SUM(f.Quantity) AS ProfitPerUnit
FROM 
    dw.FactSalesOrders f
JOIN 
    dw.DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY 
    p.ProductName
HAVING 
    SUM(f.SalesAmount) < 10000
ORDER BY 
    TotalQuantity DESC;

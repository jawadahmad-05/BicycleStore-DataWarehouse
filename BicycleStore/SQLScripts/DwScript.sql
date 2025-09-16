-- Setting up Database
USE BicycleStore
GO

-- Schema Creation
CREATE SCHEMA dw
GO

CREATE SCHEMA stg
GO

-- Dimension Tables Creation
CREATE TABLE dw.DimProduct
(ProductKey int identity NOT NULL PRIMARY KEY NONCLUSTERED,
 ProductAltKey nvarchar(10) NOT NULL,
 ProductName nvarchar(50) NULL,
 ProductDescription nvarchar(100) NULL,
 ProductCategoryName nvarchar(50))
GO

CREATE TABLE dw.DimGeography
(GeographyKey int identity NOT NULL PRIMARY KEY NONCLUSTERED,
 PostalCode nvarchar(15) NULL,
 City nvarchar(50) NULL,
 Region nvarchar(50) NULL,
 Country nvarchar(50) NULL)
GO

CREATE TABLE dw.DimCustomer
(CustomerKey int identity NOT NULL PRIMARY KEY NONCLUSTERED,
 CustomerAltKey nvarchar(10) NOT NULL,
 CustomerName nvarchar(50) NULL,
 CustomerEmail nvarchar(50) NULL,
 CustomerGeographyKey int NULL REFERENCES dw.DimGeography(GeographyKey),
 CurrentRecord bit)
GO

CREATE TABLE dw.DimSalesperson
(SalespersonKey int identity NOT NULL PRIMARY KEY NONCLUSTERED,
 SalesPersonAltKey nvarchar(10) NOT NULL,
 SalespersonName nvarchar(50) NULL,
 StoreName nvarchar(50) NULL,
 StoreGeographyKey int NULL REFERENCES dw.DimGeography(GeographyKey),
 CurrentRecord bit)
GO

CREATE TABLE dw.DimShipper
(ShipperKey int identity NOT NULL PRIMARY KEY NONCLUSTERED,
 ShipperAltKey nvarchar(10) NOT NULL,
 ShipperName nvarchar(50) NULL,
 Deleted bit DEFAULT 0)
GO

CREATE TABLE dw.DimDate
(DateKey int NOT NULL PRIMARY KEY NONCLUSTERED,
 DateAltKey datetime NOT NULL,
 CalendarYear int NOT NULL,
 CalendarQuarter int NOT NULL,
 MonthOfYear int NOT NULL,
 [MonthName] nvarchar(15) NOT NULL,
 [DayOfMonth] int NOT NULL,
 [DayOfWeek] int NOT NULL,
 [DayName] nvarchar(15) NOT NULL,
 FiscalYear int NOT NULL,
 FiscalQuarter int NOT NULL)
GO

--  Fact Table Creation
CREATE TABLE dw.FactSalesOrders
(ProductKey int NOT NULL REFERENCES dw.DimProduct(ProductKey),
 CustomerKey int NOT NULL REFERENCES dw.DimCustomer(CustomerKey),
 SalespersonKey int NOT NULL REFERENCES dw.DimSalesperson(SalespersonKey),
 ShipperKey int NULL REFERENCES dw.DimShipper(ShipperKey),
 OrderDateKey int NOT NULL REFERENCES dw.DimDate(DateKey),
 OrderNo int NOT NULL,
 ItemNo int NOT NULL,
 Quantity int NOT NULL,
 SalesAmount money NOT NULL,
 Cost money NOT NULL,
 CONSTRAINT [PK_FactSalesOrder] PRIMARY KEY NONCLUSTERED
 (
	[ProductKey], [CustomerKey], [SalespersonKey], [OrderDateKey], [OrderNo], [ItemNo]
 )
)
GO



-- Populate Dimensions
-- DimProduct
DECLARE @i INT = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimProduct (ProductAltKey, ProductName, ProductDescription, ProductCategoryName)
    VALUES (
        CONCAT('P', FORMAT(@i, '0000')),             -- ProductAltKey
        CONCAT('Product ', @i),                      -- ProductName
        CONCAT('Description of Product ', @i),       -- ProductDescription
        CONCAT('Category ', @i % 10 + 1)             -- ProductCategoryName (10 categories)
    );
    SET @i = @i + 1;
END;

-- DimGeography
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimGeography (PostalCode, City, Region, Country)
    VALUES (
        CONCAT('ZIP', FORMAT(@i, '0000')),            -- PostalCode
        CONCAT('City ', @i),                          -- City
        CONCAT('Region ', @i % 50 + 1),               -- Region (50 unique regions)
        CASE WHEN @i % 4 = 0 THEN 'USA'               -- Rotate through 4 countries
             WHEN @i % 4 = 1 THEN 'Canada'
             WHEN @i % 4 = 2 THEN 'UK'
             ELSE 'Australia'
        END
    );
    SET @i = @i + 1;
END;

-- DimCustomer
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimCustomer (CustomerAltKey, CustomerName, CustomerEmail, CustomerGeographyKey, CurrentRecord)
    VALUES (
        CONCAT('C', FORMAT(@i, '0000')),              -- CustomerAltKey
        CONCAT('Customer ', @i),                      -- CustomerName
        CONCAT('customer', @i, '@example.com'),       -- CustomerEmail
        @i % 1000 + 1,                                -- Random GeographyKey
        @i % 2                                        -- CurrentRecord alternates between 0 and 1
    );
    SET @i = @i + 1;
END;

-- DimSalesperson
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimSalesperson (SalesPersonAltKey, SalespersonName, StoreName, StoreGeographyKey, CurrentRecord)
    VALUES (
        CONCAT('S', FORMAT(@i, '0000')),              -- SalesPersonAltKey
        CONCAT('Salesperson ', @i),                   -- SalespersonName
        CONCAT('Store ', @i % 50 + 1),                -- StoreName (50 stores)
        @i % 1000 + 1,                                -- Random GeographyKey
        @i % 2                                        -- CurrentRecord alternates between 0 and 1
    );
    SET @i = @i + 1;
END;

-- DimShipper
SET @i = 1;
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimShipper (ShipperAltKey, ShipperName, Deleted)
    VALUES (
        CONCAT('SH', FORMAT(@i, '0000')),             -- ShipperAltKey
        CONCAT('Shipper ', @i),                       -- ShipperName
        0                                             -- Deleted is always 0
    );
    SET @i = @i + 1;
END;

-- DimDate
SET @i = 1;
DECLARE @BaseDate DATE = '2022-01-01';
WHILE @i <= 1000
BEGIN
    INSERT INTO dw.DimDate (DateKey, DateAltKey, CalendarYear, CalendarQuarter, MonthOfYear, MonthName, DayOfMonth, DayOfWeek, DayName, FiscalYear, FiscalQuarter)
    VALUES (
        @i,                                           -- DateKey
        DATEADD(DAY, @i - 1, @BaseDate),              -- DateAltKey
        YEAR(DATEADD(DAY, @i - 1, @BaseDate)),        -- CalendarYear
        DATEPART(QUARTER, DATEADD(DAY, @i - 1, @BaseDate)), -- CalendarQuarter
        MONTH(DATEADD(DAY, @i - 1, @BaseDate)),       -- MonthOfYear
        DATENAME(MONTH, DATEADD(DAY, @i - 1, @BaseDate)), -- MonthName
        DAY(DATEADD(DAY, @i - 1, @BaseDate)),         -- DayOfMonth
        DATEPART(WEEKDAY, DATEADD(DAY, @i - 1, @BaseDate)), -- DayOfWeek
        DATENAME(WEEKDAY, DATEADD(DAY, @i - 1, @BaseDate)), -- DayName
        YEAR(DATEADD(DAY, @i - 1, @BaseDate)),        -- FiscalYear
        DATEPART(QUARTER, DATEADD(DAY, @i - 1, @BaseDate))  -- FiscalQuarter
    );
    SET @i = @i + 1;
END;

-- FactSalesOrders Data Population

DECLARE @z INT = 1;
DECLARE @MaxProduct INT = (SELECT MAX(ProductKey) FROM dw.DimProduct);
DECLARE @MaxCustomer INT = (SELECT MAX(CustomerKey) FROM dw.DimCustomer);
DECLARE @MaxSalesperson INT = (SELECT MAX(SalespersonKey) FROM dw.DimSalesperson);
DECLARE @MaxShipper INT = (SELECT MAX(ShipperKey) FROM dw.DimShipper);
DECLARE @MaxDate INT = (SELECT MAX(DateKey) FROM dw.DimDate);

WHILE @z <= 5000 -- Increase total rows for realistic data
BEGIN
    INSERT INTO dw.FactSalesOrders 
    (
        ProductKey, 
        CustomerKey, 
        SalespersonKey, 
        ShipperKey, 
        OrderDateKey, 
        OrderNo, 
        ItemNo, 
        Quantity, 
        SalesAmount, 
        Cost
    )
    VALUES 
    (
        ABS(CHECKSUM(NEWID())) % @MaxProduct + 1,   -- Random ProductKey
        ABS(CHECKSUM(NEWID())) % @MaxCustomer + 1, -- Random CustomerKey
        ABS(CHECKSUM(NEWID())) % @MaxSalesperson + 1, -- Random SalespersonKey
        ABS(CHECKSUM(NEWID())) % @MaxShipper + 1,  -- Random ShipperKey
        ABS(CHECKSUM(NEWID())) % @MaxDate + 1,     -- Random OrderDateKey
        @z,                                        -- OrderNo
        @z,                                        -- ItemNo
        ABS(CHECKSUM(NEWID())) % 50 + 1,           -- Quantity (1 to 50)
        ROUND(ABS(CHECKSUM(NEWID())) % 500 + 10, 2), -- SalesAmount (10 to 500)
        ROUND(ABS(CHECKSUM(NEWID())) % 100 + 5, 2)  -- Cost (5 to 100)
    );
    SET @z = @z + 1;
END;

-- Add Indexes for Better Query Performance
CREATE NONCLUSTERED INDEX IX_FactSalesOrders_ProductKey ON dw.FactSalesOrders (ProductKey);
CREATE NONCLUSTERED INDEX IX_FactSalesOrders_CustomerKey ON dw.FactSalesOrders (CustomerKey);
CREATE NONCLUSTERED INDEX IX_FactSalesOrders_SalespersonKey ON dw.FactSalesOrders (SalespersonKey);
CREATE NONCLUSTERED INDEX IX_FactSalesOrders_OrderDateKey ON dw.FactSalesOrders (OrderDateKey);



-- Additional parts for staging can be added similarly if needed.
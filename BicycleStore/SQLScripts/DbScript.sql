-- Setting up Database

CREATE DATABASE BicycleStore
GO

USE BicycleStore
GO

-- Creating the Customers table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(255),
    ContactNumber VARCHAR(20),
    Email VARCHAR(255),
    Address VARCHAR(255)
);

-- Creating the Products table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(255),
    Price DECIMAL(10, 2),
    StockQuantity INT,
    Category VARCHAR(50)
);

-- Creating the Orders table
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    TotalAmount DECIMAL(10, 2),
    Status VARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Creating the OrderDetails table
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10, 2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Creating the Suppliers table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(255),
    ContactNumber VARCHAR(20),
    Email VARCHAR(255),
    Address VARCHAR(255)
);

-- Creating the Categories table
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(255),
    Description TEXT
);

-- Creating the Shippers table
CREATE TABLE Shippers (
    ShipperID INT PRIMARY KEY,
    ShipperName VARCHAR(255),
    Phone VARCHAR(20)
);



---------------------------------------------------------------------------------------------------


-- Customers

DECLARE @a INT = 1;

WHILE @a <= 1000
BEGIN
    INSERT INTO Customers (CustomerID, CustomerName, ContactNumber, Email, Address)
    VALUES (
        @a,
        CONCAT('Customer ', @a),
        CONCAT('123-456-', FORMAT(@a, '0000')),
        CONCAT('customer', @a, '@example.com'),
        CONCAT(@a, ' Main Street')
    );
    SET @a = @a + 1;
END;


-- Products

DECLARE @b INT = 1;

WHILE @b <= 1000
BEGIN
    INSERT INTO Products (ProductID, ProductName, Price, StockQuantity, Category)
    VALUES (
        @b,
        CONCAT('Product ', @b),
        ROUND(RAND() * (1000 - 10) + 10, 2),  -- Random price between 10 and 1000
        ABS(CHECKSUM(NEWID())) % 1000 + 1,    -- Random stock between 1 and 1000
        CONCAT('Category ', @b % 10 + 1)     -- Categories from 1 to 10
    );
    SET @b = @b + 1;
END;


-- Orders

DECLARE @c INT = 1;

WHILE @c <= 1000
BEGIN
    INSERT INTO Orders (OrderID, OrderDate, CustomerID, TotalAmount, Status)
    VALUES (
        @c,
        DATEADD(DAY, -(@c % 365), GETDATE()),   -- Random order date within the past year
        ABS(CHECKSUM(NEWID())) % 1000 + 1,     -- Random CustomerID between 1 and 1000
        ROUND(RAND() * (5000 - 50) + 50, 2),   -- Random total amount between 50 and 5000
        CASE WHEN @c % 4 = 0 THEN 'Shipped'
             WHEN @c % 4 = 1 THEN 'Pending'
             WHEN @c % 4 = 2 THEN 'Cancelled'
             ELSE 'Delivered'
        END                                    -- Random order status
    );
    SET @c = @c + 1;
END;


-- OrderDetails

DECLARE @d INT = 1;

WHILE @d <= 1000
BEGIN
    INSERT INTO OrderDetails (OrderDetailID, OrderID, ProductID, Quantity, UnitPrice)
    VALUES (
        @d,
        ABS(CHECKSUM(NEWID())) % 1000 + 1,  -- Random OrderID between 1 and 1000
        ABS(CHECKSUM(NEWID())) % 1000 + 1,  -- Random ProductID between 1 and 1000
        ABS(CHECKSUM(NEWID())) % 10 + 1,    -- Random quantity between 1 and 10
        ROUND(RAND() * (100 - 10) + 10, 2) -- Random unit price between 10 and 100
    );
    SET @d = @d + 1;
END;


-- Suppliers

DECLARE @e INT = 1;

WHILE @e <= 1000
BEGIN
    INSERT INTO Suppliers (SupplierID, SupplierName, ContactNumber, Email, Address)
    VALUES (
        @e,
        CONCAT('Supplier ', @e),
        CONCAT('987-654-', FORMAT(@e, '0000')),
        CONCAT('supplier', @e, '@example.com'),
        CONCAT('Building ', @e, ', Industrial Area')
    );
    SET @e = @e + 1;
END;


-- Categories

DECLARE @f INT = 1;

WHILE @f <= 10
BEGIN
    INSERT INTO Categories (CategoryID, CategoryName, Description)
    VALUES (
        @f,
        CONCAT('Category ', @f),
        CONCAT('Description for Category ', @f)
    );
    SET @f = @f + 1;
END;


-- Shippers

DECLARE @g INT = 1;

WHILE @g <= 10
BEGIN
    INSERT INTO Shippers (ShipperID, ShipperName, Phone)
    VALUES (
        @g,
        CONCAT('Shipper ', @g),
        CONCAT('456-789-', FORMAT(@g, '0000'))
    );
    SET @g = @g + 1;
END;


select * from dbo.Customers
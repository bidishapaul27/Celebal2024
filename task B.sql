
-- procedures
-----------------------

-- Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice, Quantiy, Discount as input parameters and inserts that order information in the Order Details table. 
-- After each order inserted, check the @@rowcount value to make sure that order was inserted properly. If for any reason the order was not inserted, print the messages Failed to place the
-- order. Please try again. Also your procedure should have these functionalities

-- Make the UnitPrice and Discount parameters optional

-- If no UnitPrice is given, then use the UnitPrice value from the product table.

-- If no Discount is given, then use a discount of 0.

-- Adjust the quantity in stock (UnitsInStock) for the product by subtracting the quantity sold from inventory.

-- However, if there is not enough of a product in stock, then abort the stored procedure without making any changes to the database.

-- Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update.

use AdventureWorks2019;

CREATE PROCEDURE InsertOrderDetails
    @OrderID int,
    @ProductID int = NULL,
    @UnitPrice money = NULL,
    @Quantity int,
    @Discount money = NULL
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @ProductUnitPrice DECIMAL(10, 2);
    DECLARE @UnitsInStock INT;
    DECLARE @ReorderLevel INT;
    
    -- Get the product details
    SELECT 
        @ProductUnitPrice = ListPrice,
        @UnitsInStock = Quantity,
        @ReorderLevel = SafetyStockLevel
    FROM Production.ProductInventory
    JOIN Production.Product ON Production.Product.ProductID = Production.ProductInventory.ProductID
    WHERE Production.Product.ProductID = @ProductID;

    -- Check if there is enough stock
    IF @UnitsInStock < @Quantity
    BEGIN
        PRINT 'Not enough stock available. Aborting the transaction.';
        RETURN;
    END
    
    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;
        
        -- Insert the order details
        INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, UnitPriceDiscount)
        VALUES (@OrderID, @ProductID, @UnitPrice, @Quantity, @Discount);
        
        -- Check if the insertion was successful
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Failed to place the order. Please try again.';
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        -- Update the stock quantity
        UPDATE Production.ProductInventory
        SET Quantity = Quantity - @Quantity
        WHERE ProductID = @ProductID;
        
        -- Check if the stock drops below reorder level
        IF (SELECT Quantity FROM Production.ProductInventory WHERE ProductID = @ProductID) < @ReorderLevel
        BEGIN
            PRINT 'Warning: The quantity in stock of this product has dropped below its reorder level.';
        END
        
        -- Commit the transaction
        COMMIT TRANSACTION;
        
        PRINT 'Order placed successfully.';
        
    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. The transaction has been rolled back.';
    END CATCH
END



-- Create a procedure UpdateOrderDetails that takes OrderID, ProductID, Unit Price, Quantity, and discount, and updates these values for that ProductID in that Order. All the parameters
-- except the OrderID and ProductID should be optional so that if the user wants to only update Quantity s/he should be able to do so without providing the rest of the values. You need 
-- also make sure that if any of the values are being passed in as NULL, then you want to retain the original value instead of overwriting it with NULL. To accomplish this, look for the
-- ISNULL() function in google or sql server books online. Adjust the UnitsInStock value in products table accordingly.


CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice DECIMAL(10, 2) = NULL,
    @Quantity INT = NULL,
    @Discount DECIMAL(10, 2) = NULL
AS
BEGIN
    DECLARE @CurrentUnitPrice DECIMAL(10, 2);
    DECLARE @CurrentQuantity INT;
    DECLARE @CurrentDiscount DECIMAL(10, 2);
    DECLARE @UnitsInStock INT;
    DECLARE @OriginalQuantity INT;
    
    -- Get current order details
    SELECT 
        @CurrentUnitPrice = UnitPrice,
        @CurrentQuantity = OrderQty,
        @CurrentDiscount = UnitPriceDiscount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;
    
    -- Get current product inventory
    SELECT @UnitsInStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    -- Check if the original quantity is retrieved properly
    IF @CurrentQuantity IS NULL
    BEGIN
        PRINT 'Order details not found for the provided OrderID and ProductID.';
        RETURN;
    END

    -- Retain original values if parameters are not provided
    SET @UnitPrice = ISNULL(@UnitPrice, @CurrentUnitPrice);
    SET @Quantity = ISNULL(@Quantity, @CurrentQuantity);
    SET @Discount = ISNULL(@Discount, @CurrentDiscount);

    -- Adjust the quantity in stock
    SET @OriginalQuantity = @CurrentQuantity;
    SET @UnitsInStock = @UnitsInStock + @OriginalQuantity - @Quantity;

    -- Check if there is enough stock available for the update
    IF @UnitsInStock < 0
    BEGIN
        PRINT 'Not enough stock available. Aborting the transaction.';
        RETURN;
    END

    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Update the order details
        UPDATE Sales.SalesOrderDetail
        SET UnitPrice = @UnitPrice,
            OrderQty = @Quantity,
            UnitPriceDiscount = @Discount
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

        -- Check if the update was successful
        IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Failed to update the order. Please try again.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Update the stock quantity
        UPDATE Production.ProductInventory
        SET Quantity= @UnitsInStock
        WHERE ProductID = @ProductID;

        -- Check if the stock drops below reorder level
        IF (SELECT Quantity FROM Production.ProductInventory WHERE ProductID = @ProductID) < (SELECT SafetyStockLevel FROM Production.Product WHERE ProductID = @ProductID)
        BEGIN
            PRINT 'Warning: The quantity in stock of this product has dropped below its reorder level.';
        END

        -- Commit the transaction
        COMMIT TRANSACTION;

        PRINT 'Order updated successfully.';

    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. The transaction has been rolled back.';
    END CATCH
END


-- Create a procedure GetOrderDetails that takes OrderID as input parameter and returns all the records for that OrderID. If no records are found in Order Details table, then it should
-- print the line: "The OrderID XXXX does not exits", where XXX should be the OrderlD entered by user and the procedure should RETURN the value 1.


CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    -- Declare a variable to check if any rows are returned
    DECLARE @RowCount INT;

    -- Select the order details for the given OrderID
    SELECT 
        SalesOrderID,
        ProductID,
        UnitPrice,
        OrderQty,
        UnitPriceDiscount
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;

    -- Check if any rows were returned
    SET @RowCount = @@ROWCOUNT;

    -- If no rows were found, print the message and return 1
    IF @RowCount = 0
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' does not exist';
        RETURN 1;
    END
END





-- Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes that from Order Details table. Your procedure should validate parameters. It should retum an error
-- code (-1) and print a message if the parameters are invalid. Parameters are valid if the given order ID appears in the table and if the given product ID appears in that order.

CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    -- Declare a variable to check if any rows are returned
    DECLARE @RowCount INT;

    -- Check if the given OrderID and ProductID exist in the SalesOrderDetail table
    SELECT 
        @RowCount = COUNT(*)
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- If no rows are found, print the message and return -1
    IF @RowCount = 0
    BEGIN
        PRINT 'Invalid parameters: The OrderID ' + CAST(@OrderID AS VARCHAR(10)) + ' and ProductID ' + CAST(@ProductID AS VARCHAR(10)) + ' combination does not exist';
        RETURN -1;
    END

    BEGIN TRY
        -- Start a transaction
        BEGIN TRANSACTION;

        -- Delete the order details
        DELETE FROM Sales.SalesOrderDetail
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

        -- Commit the transaction
        COMMIT TRANSACTION;

        PRINT 'Order details deleted successfully.';

    END TRY
    BEGIN CATCH
        -- Rollback the transaction in case of an error
        ROLLBACK TRANSACTION;
        PRINT 'An error occurred. The transaction has been rolled back.';
        RETURN -1;
    END CATCH
END





-- Functions
-----------------

-- Review SQL Server date formats on this website and then create following functions
-- Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY. For example if I pass in 2006-11-21 23:34:05.920', the output of the
--  functions should be 11/21/2006


CREATE FUNCTION FormatDate1(@inputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN CONVERT(VARCHAR(10), @inputDate, 101) AS [MM/DD/YYYY]
END;
GO

SELECT FormatDate1('2006-11-21 23:34:05.920');


-- Create a function that takes an input parameter type datetime and returns the date in the fonnat YYYYMMDD



CREATE FUNCTION FormatDate(@datetime datetime)
RETURNS varchar(8)
AS
BEGIN
    RETURN CONVERT(varchar(8), CONVERT(date, @datetime), 112)
END


-- Views
------------------

-- Create a view vwCustomerOrders which returns CompanyName OrderID.OrderDate, ProductID ProductName Quantity UnitPrice.Quantity od. UnitPrice

CREATE VIEW vwCustomerOrders AS
SELECT 
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID;
GO


--

CREATE VIEW vwCustomerOrdersYesterday AS
SELECT 
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    sod.OrderQty * sod.UnitPrice AS TotalPrice
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Production.Product p ON sod.ProductID = p.ProductID
WHERE 
    CAST(soh.OrderDate AS DATE) = CAST(GETDATE() - 1 AS DATE);
GO


-- Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, ProductName, QuantityPerUnit and Unit Price columns from the Products table. It
-- should also contain the CompanyName column from the Suppliers table and the CategoryName column from the Categories table. Your view should only contain products that are 
-- not discontinued. 

CREATE VIEW dbo.MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Size AS QuantityPerUnit,
    p.ListPrice AS UnitPrice,
    s.Name AS CompanyName,
    pc.Name AS CategoryName
FROM 
    Production.Product p
JOIN 
    Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN 
    Purchasing.Vendor s ON pv.BusinessEntityID = s.BusinessEntityID
JOIN 
    Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE 
    p.DiscontinuedDate IS NULL;
GO


-- Triggers
-------------------

-- If someone cancels an order in northwind database, then you want to delete that order from the Orders table. But you will not be able to delete that Order before deleting the records 
-- from Order Details table for that particular order due to referential integrity constraints. Create an Instead of Delete trigger on Orders table so that if some one tries to delete an
-- Order that trigger gets fired and that trigger should first delete everything in order details table and then delete that order from the Orders table

CREATE TRIGGER trgDeleteOrder
ON Sales.SalesOrderHeader
INSTEAD OF DELETE
AS
BEGIN
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    DELETE FROM Sales.SalesOrderHeader
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);
END;

-- When an order is placed for X units of product Y, we must first check the Products table to ensure that there is sufficient stock to fill the order. This trigger will operate on the
-- Order Details table. If sufficient stock exists, then fill the order and decrement X units from the UnitsInStock column in Products. If insufficient stock exists, then refuse the order
-- (le. do not insert it) and notify the user that the order could not be filled because of insufficient stock.

CREATE TRIGGER trgCheckStock
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    DECLARE @ProductID INT, @Quantity INT;
    DECLARE @UnitsInStock INT;

    SELECT @ProductID = i.ProductID, @Quantity = i.OrderQty
    FROM INSERTED i;

    SELECT @UnitsInStock = p.Quantity
    FROM Production.ProductInventory p
    WHERE p.ProductID = @ProductID;

    IF @UnitsInStock >= @Quantity
    BEGIN
        -- Decrement the stock
        UPDATE Production.ProductInventory
        SET Quantity = Quantity - @Quantity
        WHERE ProductID = @ProductID;

        -- Insert the order detail
        INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, UnitPrice, OrderQty, ModifiedDate)
        SELECT SalesOrderID, ProductID, UnitPrice, OrderQty, GETDATE()
        FROM INSERTED;
    END
    ELSE
    BEGIN
        RAISERROR ('Insufficient stock for ProductID %d', 16, 1, @ProductID);
    END
END;
GO




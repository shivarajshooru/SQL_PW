/* =============================
   SETUP: Creating Tables & Data
   ============================= */
   
create database Advance;
use advance;
use advance;

-- 1. Create Products Table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);

-- 2. Insert Data into Products
INSERT INTO Products VALUES
(1, 'Keyboard', 'Electronics', 1200),
(2, 'Mouse', 'Electronics', 800),
(3, 'Chair', 'Furniture', 2500),
(4, 'Desk', 'Furniture', 5500);

-- 3. Create Sales Table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    Quantity INT,
    SaleDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products (ProductID)
);

-- 4. Insert Data into Sales
INSERT INTO Sales VALUES
(1, 1, 4, '2024-01-05'),
(2, 2, 10, '2024-01-06'),
(3, 3, 2, '2024-01-10'),
(4, 4, 1, '2024-01-11');

/* =============================================================
   ASSIGNMENT SOLUTIONS START HERE
   ============================================================= */

/* -------------------------------------------------------------
PART 1: THEORETICAL QUESTIONS (Q1 - Q5)
-------------------------------------------------------------
Q1. What is a Common Table Expression (CTE)? 
ANSWER: A CTE is a temporary result set defined within the execution scope of a single SQL statement. It improves readability by eliminating deep nested subqueries.

Q2. Why are some views updatable while others are read-only? 
ANSWER: 
- Updatable: Simple views selecting columns from a single table.
- Read-Only: Views with aggregates (SUM, COUNT), GROUP BY, or JOINs.

Q3. What advantages do stored procedures offer? 
ANSWER: Performance (caching), Security (prevents injection), Reusability.

Q4. What is the purpose of triggers? 
ANSWER: Triggers automatically execute on events (INSERT/UPDATE/DELETE). Essential for Audit Trails.

Q5. Need for data modelling and normalization? 
ANSWER: 
- Modelling: Defines structure.
- Normalization: Reduces redundancy and anomalies.
*/

-- ==========================================================
-- Q6. CTE to calculate Total Revenue and filter > 3000
-- ==========================================================
WITH ProductRevenue AS (
    SELECT 
        p.ProductName,
        (p.Price * s.Quantity) AS TotalRevenue
    FROM Products p
    JOIN Sales s ON p.ProductID = s.ProductID
)
SELECT ProductName, TotalRevenue 
FROM ProductRevenue
WHERE TotalRevenue > 3000;

-- ==========================================================
-- Q7. View vw_CategorySummary
-- ==========================================================
CREATE VIEW vw_CategorySummary AS
SELECT 
    Category,
    COUNT(ProductID) AS TotalProducts,
    AVG(Price) AS AveragePrice
FROM Products
GROUP BY Category;

-- ==========================================================
-- Q8. Updatable view and Price Update
-- ==========================================================
-- 1. Create the View
CREATE VIEW vw_ProductDetails AS
SELECT ProductID, ProductName, Price 
FROM Products;

-- 2. Update Price using the View
UPDATE vw_ProductDetails
SET Price = 1500
WHERE ProductID = 1;

-- ==========================================================
-- Q9. Stored Procedure GetProductsByCategory
-- ==========================================================
DELIMITER //

CREATE PROCEDURE GetProductsByCategory(IN categoryInput VARCHAR(50))
BEGIN
    SELECT * FROM Products 
    WHERE Category = categoryInput;
END //

DELIMITER ;

-- ==========================================================
-- Q10. AFTER DELETE Trigger to Archive Data
-- ==========================================================
-- 1. Create Archive Table
CREATE TABLE ProductArchive (
    ArchiveID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    DeletedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Create the Trigger
DELIMITER //

CREATE TRIGGER trg_AfterDeleteProduct
AFTER DELETE ON Products
FOR EACH ROW
BEGIN
    INSERT INTO ProductArchive (ProductID, ProductName, Category, Price, DeletedAt)
    VALUES (OLD.ProductID, OLD.ProductName, OLD.Category, OLD.Price, NOW());
END //

DELIMITER ;
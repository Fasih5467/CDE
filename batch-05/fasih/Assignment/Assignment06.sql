Q1. List top 5 customers by total order amount.
Retrieve the top 5 customers who have spent the most across all sales orders. Show CustomerID, CustomerName, and TotalSpent.
ANSWER

SELECT TOP 5 so.CustomerID,c.Name as customer_name,SUM(so.TotalAmount) as TotalSpent 
 FROM
   dbo.Customer as c
inner join 
   dbo.SalesOrder as so
ON 
   c.CustomerID = so.CustomerID
GROUP BY
       c.name,so.CustomerID
       ORDER BY 
       SUM(so.TotalAmount) DESC;

Q2. Find the number of products supplied by each supplier.
Display SupplierID, SupplierName, and ProductCount. Only include suppliers that have more than 10 products.

SELECT s.SupplierID,s.Name as Supplier_name,count(pod.ProductID) as product_count  
FROM
dbo.Product as p
inner join 
    dbo.PurchaseOrderDetail as pod
    ON
    p.ProductID = pod.ProductID
    inner join 
    dbo.PurchaseOrder as po
    ON
    pod.OrderID = po.OrderID
    inner join 
    dbo.Supplier as s
    ON
    po.SupplierID = s.SupplierID
    GROUP BY 
    s.SupplierID,s.Name
    HAVING
      count(pod.ProductID) > 10

Q3. Identify products that have been ordered but never returned.
Show ProductID, ProductName, and total order quantity.

SELECT p.ProductID, p.Name as ProductName, SUM(sod.Quantity) as TotalOrdered
FROM
dbo.Product as p
inner join
      dbo.SalesOrderDetail as sod
      ON
      p.ProductID = sod.ProductID   
inner join     
     dbo.SalesOrder as so 
      ON 
      sod.OrderID = so.OrderID
GROUP BY p.ProductID, p.Name
HAVING SUM(sod.Quantity) > 0 AND SUM(sod.Quantity) = (SELECT SUM(Quantity) FROM dbo.ReturnOrderDetail WHERE ProductID = p.ProductID)   


Q4. For each category, find the most expensive product.
Display CategoryID, CategoryName, ProductName, and Price. Use a subquery to get the max price per category.
   
SELECT c.CategoryID, c.Name as CategoryName, p.Name as ProductName, p.Price
FROM
dbo.Category as c
inner join
    dbo.Product as p
    ON
    c.CategoryID = p.CategoryID
WHERE 
    p.Price = (SELECT MAX(Price) FROM dbo.Product WHERE CategoryID = c.CategoryID)

Q5. List all sales orders with customer name, product name, category, and supplier.
For each sales order, display:
OrderID, CustomerName, ProductName, CategoryName, SupplierName, and Quantity.


Q6. Find all shipments with details of warehouse, manager, and products shipped.
Display:
ShipmentID, WarehouseName, ManagerName, ProductName, QuantityShipped, and TrackingNumber.

Q7. Find the top 3 highest-value orders per customer using RANK(). Display CustomerID, CustomerName, OrderID, and TotalAmount.

With cte_customer_detail(CustomerID, CustomerName, OrderID, TotalAmount, OrderRank)
AS(
SELECT CustomerID, CustomerName, OrderID, TotalAmount,
RANK() OVER (PARTITION BY CustomerID ORDER BY TotalAmount DESC) as OrderRank
FROM
(SELECT c.CustomerID, c.Name as CustomerName, so.OrderID, so.TotalAmount
FROM dbo.Customer as c
inner join
    dbo.SalesOrder as so
    ON
    c.CustomerID = so.CustomerID) as CustomerOrders
    )
SELECT * FROM cte_customer_detail
WHERE OrderRank <= 3

Q8. For each product, show its sales history with the previous and next sales quantities (based on order date). Display ProductID, ProductName, OrderID, OrderDate, Quantity, PrevQuantity, and NextQuantity.
   
WITH cte_sales_history AS (
SELECT p.ProductID, p.Name as ProductName, so.OrderID, so.OrderDate, sod.Quantity,
LAG(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) as PrevQuantity,
LEAD(sod.Quantity) OVER (PARTITION BY p.ProductID ORDER BY so.OrderDate) as NextQuantity
FROM  
dbo.Product as p
inner join
      dbo.SalesOrderDetail as sod
      ON
      p.ProductID = sod.ProductID   
inner join
      dbo.SalesOrder as so 
      ON
      sod.OrderID = so.OrderID   
)
SELECT * FROM cte_sales_history     
    
   
Q9. Create a view named vw_CustomerOrderSummary that shows for each customer:
CustomerID, CustomerName, TotalOrders, TotalAmountSpent, and LastOrderDate.

CREATE VIEW vw_CustomerOrderSummary AS 
SELECT c.CustomerID, c.Name as CustomerName, COUNT(so.OrderID) as TotalOrders, SUM(so.TotalAmount) as TotalAmountSpent, MAX(so.OrderDate) as LastOrderDate
FROM dbo.Customer as c
LEFT JOIN dbo.SalesOrder as so ON c.CustomerID = so.CustomerID
GROUP BY c.CustomerID, c.Name


Q10. Write a stored procedure sp_GetSupplierSales that takes a SupplierID as input and returns the total sales amount for all products supplied by that supplier.

CREATE PROCEDURE sp_GetSupplierSales
    @SupplierID INT
AS
BEGIN
    SELECT s.SupplierID, s.Name as SupplierName, SUM(so.TotalAmount) as TotalSales
    FROM dbo.Supplier as s
    INNER JOIN dbo.PurchaseOrder as po ON s.SupplierID = po.SupplierID
    INNER JOIN dbo.SalesOrderDetail as so ON po.OrderID = so.OrderID
    WHERE s.SupplierID = @SupplierID
    GROUP BY s.SupplierID, s.Name
END   
-- All views for the Elevate Retail Database
	-- Run one at a time on your local machine



-- Carts older than X days with no corresponding order (cart abandonment).
CREATE VIEW dbo.vw_AbandonedCarts AS
SELECT
  sc.Cart_ID,
  sc.Customer_ID,
  c.First_Name,
  c.Last_Name,
  sc.Created_At         AS Cart_Created,
  COUNT(sci.Inventory_ID) AS Items_In_Cart
FROM Shopping_Cart sc
LEFT JOIN Shopping_Cart_Item sci
  ON sci.Cart_ID = sc.Cart_ID
LEFT JOIN [Order] o
  ON o.Customer_ID = sc.Customer_ID
     AND DATEDIFF(day, sc.Created_At, o.Order_Date) BETWEEN 0 AND 1
LEFT JOIN Customer c
  ON sc.Customer_ID = c.Customer_ID
WHERE
  o.Order_ID IS NULL
  AND sc.Created_At < DATEADD(day, -7, GETUTCDATE())  -- e.g. 7?day abandonment
GROUP BY
  sc.Cart_ID, sc.Customer_ID, c.First_Name, c.Last_Name, sc.Created_At;
GO



-- View: CustomerOrderDetails
CREATE VIEW dbo.vw_CustomerOrderDetails AS
SELECT
    o.Order_ID,
    o.Order_Date,
    c.Customer_ID,
    c.First_Name,
    c.Last_Name,
    c.Email,
    c.Membership_Level,
    oi.Inventory_ID,
    inv.Quantity      AS Inventory_Stock,
    oi.Quantity       AS Order_Quantity,
    oi.Amount,
    oi.Tax,
    p.Product_ID,
    p.Product_Name,
    pc.Category_Name,
    p.Supplier_ID,
    s.Supplier_Name   AS Supplier_Name,
    pay.Payment_ID,
    pay.Method        AS Payment_Method,
    pay.Payment_Status,
    sh.Shipping_ID,
    sh.Cost           AS Shipping_Cost,
    sh.Shipped_On,
    sh.Expected_By,
    sh.Ship_Status,
    sh.Carrier,
    sh.Tracking_Number
FROM
    [Order] o
    JOIN Customer c
      ON o.Customer_ID = c.Customer_ID
    JOIN Order_Item oi
      ON oi.Order_ID = o.Order_ID
    JOIN Inventory inv
      ON inv.Inventory_ID = oi.Inventory_ID
    JOIN Product p
      ON p.Product_ID = inv.Product_ID
    LEFT JOIN Product_Category pc
      ON p.Category_ID = pc.Category_ID
    LEFT JOIN Supplier s
      ON p.Supplier_ID = s.Supplier_ID
    LEFT JOIN Payment pay
      ON pay.Order_ID = o.Order_ID
    LEFT JOIN Shipping sh
      ON sh.Order_ID = o.Order_ID
;
GO



-- Shows per customer order counts and spend, useful for segmentation & lifetime value.
CREATE VIEW dbo.vw_CustomerOrderSummary AS
SELECT
  c.Customer_ID,
  c.First_Name,
  c.Last_Name,
  COUNT(DISTINCT o.Order_ID)                AS Orders_Placed,
  SUM(oi.Quantity * oi.Amount)             AS Total_Spend,
  AVG(oi.Quantity * oi.Amount + oi.Tax)    AS Avg_Order_Value
FROM [Order] o
JOIN Customer c
  ON o.Customer_ID = c.Customer_ID
JOIN Order_Item oi
  ON oi.Order_ID = o.Order_ID
GROUP BY
  c.Customer_ID, c.First_Name, c.Last_Name;
GO



--  Provides a consolidated view of inventory stock levels, product details, category, and supplier information.
	-- Useful for reporting and tracking stock status across the catalog.
CREATE VIEW dbo.vw_InventoryOverview AS
SELECT
  inv.Inventory_ID,
  p.Product_ID,
  p.Product_Name,
  pc.Category_Name,
  s.Supplier_ID,
  s.Supplier_Name,
  inv.Quantity      AS Stock_On_Hand,
  inv.Unit_Price
FROM Inventory inv
JOIN Product p
  ON inv.Product_ID = p.Product_ID
LEFT JOIN Product_Category pc
  ON p.Category_ID = pc.Category_ID
LEFT JOIN Supplier s
  ON p.Supplier_ID = s.Supplier_ID;
GO



-- Shows open vs. closed POs, items per PO, and receipt status.
CREATE VIEW dbo.vw_PurchaseOrderDashboard AS
SELECT
  po.Purchase_Order_ID,
  po.Supplier_ID,
  sup.Supplier_Name,
  po.Order_Date       AS PO_Date,
  po.Purchase_Order_Status,
  COUNT(poi.Product_ID)         AS Line_Items,
  SUM(poi.Quantity)             AS Total_Quantity_Ordered
FROM Purchase_Order po
JOIN Supplier sup
  ON po.Supplier_ID = sup.Supplier_ID
LEFT JOIN Purchase_Order_Item poi
  ON poi.Purchase_Order_ID = po.Purchase_Order_ID
GROUP BY
  po.Purchase_Order_ID,
  po.Supplier_ID,
  sup.Supplier_Name,
  po.Order_Date,
  po.Purchase_Order_Status;
GO



-- Shows Aggregated sales metrics by product (total quantity sold, gross revenue, total tax).
CREATE VIEW dbo.vw_SalesByProduct AS
SELECT
  p.Product_ID,
  p.Product_Name,
  SUM(oi.Quantity)      AS Total_Units_Sold,
  SUM(oi.Amount)        AS Gross_Revenue,
  SUM(oi.Tax)           AS Total_Tax
FROM Order_Item oi
JOIN Inventory inv
  ON oi.Inventory_ID = inv.Inventory_ID
JOIN Product p
  ON inv.Product_ID = p.Product_ID
GROUP BY
  p.Product_ID, p.Product_Name;
GO



-- Shows fulfillment KPIs how long orders take to ship, on time vs. delayed.
CREATE VIEW dbo.vw_ShippingPerformance AS
SELECT
  sh.Shipping_ID,
  sh.Order_ID,
  DATEDIFF(day, sh.Created_At, sh.Shipped_On) AS Days_To_Ship,
  DATEDIFF(day, sh.Shipped_On, sh.Expected_By) AS Expected_Transit_Days,
  CASE
    WHEN sh.Ship_Status = 'Delivered'
         AND sh.Expected_By >= sh.Shipped_On THEN 'On Time'
    WHEN sh.Ship_Status = 'Delivered' THEN 'Late'
    ELSE sh.Ship_Status
  END AS Delivery_Performance,
  sh.Carrier
FROM Shipping sh;
GO



-- View: SupplierOrderDetails
CREATE VIEW dbo.vw_SupplierOrderDetails AS
SELECT
    po.Purchase_Order_ID,
    po.Order_Date       AS PO_Date,
    po.Purchase_Order_Status,
    sup.Supplier_ID,
    sup.Supplier_Name,
    sup.Contact_Name,
    sup.Contact_Email,
    sup.Contact_Phone,
    poi.Product_ID,
    p.Product_Name,
    pc.Category_Name,
    poi.Quantity       AS Quantity_Ordered
FROM
    Purchase_Order po
    JOIN Supplier sup
      ON po.Supplier_ID = sup.Supplier_ID
    JOIN Purchase_Order_Item poi
      ON poi.Purchase_Order_ID = po.Purchase_Order_ID
    JOIN Product p
      ON p.Product_ID = poi.Product_ID
    LEFT JOIN Product_Category pc
      ON p.Category_ID = pc.Category_ID
;
GO
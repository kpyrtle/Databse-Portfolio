-- Run one by one on local machines

-- 1. Enforce uniqueness and speed lookups on Customer email
CREATE UNIQUE NONCLUSTERED INDEX IX_Customer_Email
  ON Customer (Email);

-- 2. Support joining orders back to customers
CREATE NONCLUSTERED INDEX IX_Order_CustomerID
  ON [Order] (Customer_ID);

-- 3. Range queries on order date (like sales by period)
CREATE NONCLUSTERED INDEX IX_Order_OrderDate
  ON [Order] (Order_Date);

-- 4. Fast retrieval of all items in an order
CREATE NONCLUSTERED INDEX IX_OrderItem_OrderID
  ON Order_Item (Order_ID)
  INCLUDE (Inventory_ID, Quantity, Amount, Tax);

-- 5. Lookups from inventory to product
CREATE NONCLUSTERED INDEX IX_Inventory_ProductID
  ON Inventory (Product_ID)
  INCLUDE (Quantity, Unit_Price);

-- 6. Query products by category/supplier
CREATE NONCLUSTERED INDEX IX_Product_CategoryID
  ON [Product] (Category_ID);
CREATE NONCLUSTERED INDEX IX_Product_SupplierID
  ON [Product] (Supplier_ID);

-- 7. Speed up payment lookups per order
CREATE NONCLUSTERED INDEX IX_Payment_OrderID
  ON Payment (Order_ID)
  INCLUDE (Method, Payment_Status);

-- 8. Shipping performance queries
CREATE NONCLUSTERED INDEX IX_Shipping_OrderID
  ON Shipping (Order_ID)
  INCLUDE (Ship_Status, Shipped_On, Expected_By);
CREATE NONCLUSTERED INDEX IX_Shipping_ShipStatus
  ON Shipping (Ship_Status)
  INCLUDE (Order_ID, Carrier);

-- 9. Customer addresses by customer
CREATE NONCLUSTERED INDEX IX_CustomerAddress_CustomerID
  ON Customer_Address (Customer_ID);

-- 10. Shopping?cart lookups
CREATE NONCLUSTERED INDEX IX_ShoppingCart_CustomerID
  ON Shopping_Cart (Customer_ID);
CREATE NONCLUSTERED INDEX IX_CartItem_CartID
  ON Shopping_Cart_Item (Cart_ID)
  INCLUDE (Inventory_ID, Quantity);

-- 11. Fast lookup of discounts
CREATE NONCLUSTERED INDEX IX_Discount_ProductID
  ON Discount (Product_ID)
  INCLUDE (Amount, Start_Date, End_Date);
CREATE NONCLUSTERED INDEX IX_Discount_OrderID
  ON Discount (Order_ID)
  INCLUDE (Amount, Start_Date, End_Date);

-- 12. Purchase?order lookups
CREATE NONCLUSTERED INDEX IX_PurchaseOrder_SupplierID
  ON Purchase_Order (Supplier_ID);
CREATE NONCLUSTERED INDEX IX_POItem_PurchaseOrderID
  ON Purchase_Order_Item (Purchase_Order_ID)
  INCLUDE (Product_ID, Quantity);

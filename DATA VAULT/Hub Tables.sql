CREATE TABLE Hub_Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_HashKey VARBINARY(64) UNIQUE NOT NULL,
    Load_Date DATETIME DEFAULT GETDATE()
);

CREATE TABLE Hub_Shipments (
    Shipment_ID INT PRIMARY KEY,
    Shipment_HashKey VARBINARY(64) UNIQUE NOT NULL,
    Load_Date DATETIME DEFAULT GETDATE()
);

CREATE TABLE Link_Customer_Shipment (
    Customer_HashKey VARBINARY(64),
    Shipment_HashKey VARBINARY(64),
    Link_HashKey VARBINARY(64) PRIMARY KEY,
    Load_Date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (Customer_HashKey) REFERENCES Hub_Customers(Customer_HashKey),
    FOREIGN KEY (Shipment_HashKey) REFERENCES Hub_Shipments(Shipment_HashKey)
);

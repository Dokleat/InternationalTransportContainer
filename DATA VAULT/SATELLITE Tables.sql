CREATE TABLE Sat_Customers (
    Customer_HashKey VARBINARY(64),
    Name VARCHAR(255),
    Email VARCHAR(255),
    Address TEXT,
    Phone VARCHAR(50),
    Effective_Date DATETIME DEFAULT GETDATE(),
    Expiry_Date DATETIME NULL,
    Load_Date DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (Customer_HashKey) REFERENCES Hub_Customers(Customer_HashKey)
);

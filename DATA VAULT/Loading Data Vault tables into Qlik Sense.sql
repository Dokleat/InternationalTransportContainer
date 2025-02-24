HubCustomers:
LOAD 
    Customer_ID,
    Customer_HashKey,
    Load_Date;
SQL SELECT * FROM Hub_Customers;

SatCustomers:
LOAD 
    Customer_HashKey AS Customer_HashKey_Sat,  
    Name,
    Email,
    Address,
    Phone,
    Effective_Date,
    Expiry_Date;
SQL SELECT * FROM Sat_Customers;

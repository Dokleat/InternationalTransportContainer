
CREATE DATABASE InternationalTransportContainer;
USE InternationalTransportContainer;


CREATE TABLE customers (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Address TEXT NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    Phone VARCHAR(50) UNIQUE NOT NULL
);


CREATE TABLE ports (
    Port_ID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Country VARCHAR(100) NOT NULL,
    Address TEXT NOT NULL,
    Branch VARCHAR(255),
    Capacity INT
);


CREATE TABLE employees (
    Employee_ID INT PRIMARY KEY,
    First_Name VARCHAR(100) NOT NULL,
    Last_Name VARCHAR(100) NOT NULL,
    Position VARCHAR(255),
    Branch_ID INT,
    Hire_Date DATE,
    FOREIGN KEY (Branch_ID) REFERENCES ports(Port_ID)
);


CREATE TABLE routes (
    Route_ID INT PRIMARY KEY,
    Departure_Port INT,
    Arrival_Port INT,
    Departure_Time TIME,
    Arrival_Time TIME,
    Distance_Km INT,
    FOREIGN KEY (Departure_Port) REFERENCES ports(Port_ID),
    FOREIGN KEY (Arrival_Port) REFERENCES ports(Port_ID)
);


CREATE TABLE shipments (
    Shipment_ID INT PRIMARY KEY,
    Customer_ID INT,
    Departure_Port INT,
    Arrival_Port INT,
    Departure_Date DATE,
    Arrival_Date DATE,
    Cost DECIMAL(10,2),
    Status VARCHAR(50) CHECK (Status IN ('In Transit', 'Delivered', 'Pending')),
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Departure_Port) REFERENCES ports(Port_ID),
    FOREIGN KEY (Arrival_Port) REFERENCES ports(Port_ID)
);


CREATE TABLE invoices (
    Invoice_ID INT PRIMARY KEY,
    Customer_ID INT,
    Shipment_ID INT,
    Total_Amount DECIMAL(10,2),
    Issue_Date DATE,
    Payment_Date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES customers(Customer_ID),
    FOREIGN KEY (Shipment_ID) REFERENCES shipments(Shipment_ID)
);


CREATE TABLE containers (
    Container_ID INT PRIMARY KEY,
    Capacity INT,
    Weight DECIMAL(10,2),
    Type VARCHAR(50),
    Status VARCHAR(50) CHECK (Status IN ('Empty', 'Full', 'In Use'))
);


CREATE TABLE goods (
    Goods_ID INT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Quantity INT,
    Weight DECIMAL(10,2),
    Container_ID INT,
    FOREIGN KEY (Container_ID) REFERENCES containers(Container_ID)
);
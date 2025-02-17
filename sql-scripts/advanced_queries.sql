-- Top 10 Customers by Total Shipment Value

SELECT 
    c.Customer_ID, 
    c.Name, 
    COUNT(s.Shipment_ID) AS Total_Shipments, 
    SUM(s.Cost) AS Total_Shipment_Value
FROM shipments s
JOIN customers c ON s.Customer_ID = c.Customer_ID
GROUP BY c.Customer_ID, c.Name
ORDER BY Total_Shipment_Value DESC
LIMIT 10;

-- Shipment Delivery Performance - Average Transit Time Per Route

SELECT 
    r.Route_ID,
    p1.Name AS Departure_Port, 
    p2.Name AS Arrival_Port, 
    COUNT(s.Shipment_ID) AS Total_Shipments,
    AVG(DATEDIFF(s.Arrival_Date, s.Departure_Date)) AS Avg_Transit_Days
FROM shipments s
JOIN ports p1 ON s.Departure_Port = p1.Port_ID
JOIN ports p2 ON s.Arrival_Port = p2.Port_ID
JOIN routes r ON s.Departure_Port = r.Departure_Port AND s.Arrival_Port = r.Arrival_Port
GROUP BY r.Route_ID, Departure_Port, Arrival_Port
ORDER BY Avg_Transit_Days ASC;

-- Unpaid Invoices & Overdue Payments

SELECT 
    i.Invoice_ID, 
    c.Name AS Customer_Name, 
    i.Total_Amount, 
    i.Issue_Date, 
    i.Payment_Date, 
    DATEDIFF(CURDATE(), i.Payment_Date) AS Days_Overdue
FROM invoices i
JOIN customers c ON i.Customer_ID = c.Customer_ID
WHERE i.Payment_Date < CURDATE()
ORDER BY Days_Overdue DESC;

-- Container Utilization - Empty vs. Full Containers

SELECT 
    Status, 
    COUNT(Container_ID) AS Total_Containers,
    ROUND(COUNT(Container_ID) * 100.0 / (SELECT COUNT(*) FROM containers), 2) AS Percentage
FROM containers
GROUP BY Status;

-- Port Efficiency - Number of Shipments Handled per Port

SELECT 
    p.Name AS Port_Name, 
    COUNT(s.Shipment_ID) AS Shipments_Handled
FROM shipments s
JOIN ports p ON s.Departure_Port = p.Port_ID OR s.Arrival_Port = p.Port_ID
GROUP BY p.Name
ORDER BY Shipments_Handled DESC;

-- Employee Distribution Across Ports

SELECT 
    p.Name AS Port_Name, 
    COUNT(e.Employee_ID) AS Employee_Count
FROM employees e
JOIN ports p ON e.Branch_ID = p.Port_ID
GROUP BY p.Name
ORDER BY Employee_Count DESC;

-- Most Frequent Shipment Routes

SELECT 
    p1.Name AS Departure_Port, 
    p2.Name AS Arrival_Port, 
    COUNT(s.Shipment_ID) AS Shipment_Count
FROM shipments s
JOIN ports p1 ON s.Departure_Port = p1.Port_ID
JOIN ports p2 ON s.Arrival_Port = p2.Port_ID
GROUP BY p1.Name, p2.Name
ORDER BY Shipment_Count DESC
LIMIT 10;

-- Total Weight of Goods Transported by Each Container

SELECT 
    c.Container_ID, 
    c.Type AS Container_Type, 
    COUNT(g.Goods_ID) AS Total_Goods, 
    SUM(g.Weight * g.Quantity) AS Total_Weight
FROM goods g
JOIN containers c ON g.Container_ID = c.Container_ID
GROUP BY c.Container_ID, c.Type
ORDER BY Total_Weight DESC;

-- SELECT 
    c.Container_ID, 
    c.Type AS Container_Type, 
    COUNT(g.Goods_ID) AS Total_Goods, 
    SUM(g.Weight * g.Quantity) AS Total_Weight
FROM goods g
JOIN containers c ON g.Container_ID = c.Container_ID
GROUP BY c.Container_ID, c.Type
ORDER BY Total_Weight DESC;

-- Financial Overview - Monthly Revenue Analysis

SELECT 
    YEAR(Issue_Date) AS Year, 
    MONTH(Issue_Date) AS Month, 
    SUM(Total_Amount) AS Monthly_Revenue
FROM invoices
GROUP BY Year, Month
ORDER BY Year DESC, Month DESC;

-- Shipments at Risk - Longest Transit Times

SELECT 
    s.Shipment_ID, 
    c.Name AS Customer_Name, 
    p1.Name AS Departure_Port, 
    p2.Name AS Arrival_Port, 
    s.Departure_Date, 
    s.Arrival_Date, 
    DATEDIFF(s.Arrival_Date, s.Departure_Date) AS Actual_Transit_Days
FROM shipments s
JOIN customers c ON s.Customer_ID = c.Customer_ID
JOIN ports p1 ON s.Departure_Port = p1.Port_ID
JOIN ports p2 ON s.Arrival_Port = p2.Port_ID
WHERE DATEDIFF(s.Arrival_Date, s.Departure_Date) > (SELECT AVG(DATEDIFF(Arrival_Date, Departure_Date)) FROM shipments)
ORDER BY Actual_Transit_Days DESC;

-- Time Series Analysis - Moving Average for Revenue Trends

WITH MonthlyRevenue AS (
    SELECT 
        YEAR(Issue_Date) AS Year, 
        MONTH(Issue_Date) AS Month, 
        SUM(Total_Amount) AS Monthly_Revenue
    FROM invoices
    GROUP BY YEAR(Issue_Date), MONTH(Issue_Date)
)
SELECT 
    Year, 
    Month, 
    Monthly_Revenue,
    AVG(Monthly_Revenue) OVER (ORDER BY Year, Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Moving_Avg_3_Months
FROM MonthlyRevenue
ORDER BY Year DESC, Month DESC;

-- Predicting Future Shipment Volume (Linear Forecasting)

WITH ShipmentTrends AS (
    SELECT 
        YEAR(Departure_Date) AS Year, 
        MONTH(Departure_Date) AS Month, 
        COUNT(Shipment_ID) AS Total_Shipments
    FROM shipments
    GROUP BY YEAR(Departure_Date), MONTH(Departure_Date)
)
SELECT 
    Year, 
    Month, 
    Total_Shipments,
    -- Regression coefficients
    REGR_SLOPE(Total_Shipments, Year * 12 + Month) OVER () AS Slope,
    REGR_INTERCEPT(Total_Shipments, Year * 12 + Month) OVER () AS Intercept,
    -- Predicted Shipments for next month
    (REGR_SLOPE(Total_Shipments, Year * 12 + Month) OVER () * ((YEAR(GETDATE()) * 12 + MONTH(GETDATE())) + 1) 
     + REGR_INTERCEPT(Total_Shipments, Year * 12 + Month) OVER ()) AS Predicted_Next_Month
FROM ShipmentTrends
ORDER BY Year DESC, Month DESC;

-- Identifying Anomalies in Shipment Cost (Outlier Detection)

WITH CostStats AS (
    SELECT 
        AVG(Cost) AS Avg_Cost, 
        STDEV(Cost) AS StdDev_Cost
    FROM shipments
)
SELECT 
    s.Shipment_ID, 
    c.Name AS Customer_Name, 
    s.Departure_Date, 
    s.Arrival_Date, 
    s.Cost,
    (s.Cost - cs.Avg_Cost) / cs.StdDev_Cost AS Z_Score
FROM shipments s
JOIN customers c ON s.Customer_ID = c.Customer_ID
CROSS JOIN CostStats cs
WHERE ABS((s.Cost - cs.Avg_Cost) / cs.StdDev_Cost) > 2
ORDER BY Z_Score DESC;

-- Cluster Analysis for Customer Segmentation (K-Means in SQL)

WITH CustomerStats AS (
    SELECT 
        c.Customer_ID, 
        c.Name, 
        COUNT(s.Shipment_ID) AS Total_Shipments, 
        AVG(i.Total_Amount) AS Avg_Invoice_Amount
    FROM customers c
    LEFT JOIN shipments s ON c.Customer_ID = s.Customer_ID
    LEFT JOIN invoices i ON c.Customer_ID = i.Customer_ID
    GROUP BY c.Customer_ID, c.Name
)
SELECT 
    Customer_ID, 
    Name, 
    Total_Shipments, 
    Avg_Invoice_Amount,
    NTILE(3) OVER (ORDER BY Total_Shipments DESC) AS Customer_Cluster
FROM CustomerStats;

-- Supply Chain Bottlenecks - Identifying Delayed Shipments

WITH TransitStats AS (
    SELECT AVG(DATEDIFF(DAY, Departure_Date, Arrival_Date)) AS Avg_Transit_Time
    FROM shipments
)
SELECT 
    s.Shipment_ID, 
    c.Name AS Customer_Name, 
    p1.Name AS Departure_Port, 
    p2.Name AS Arrival_Port, 
    s.Departure_Date, 
    s.Arrival_Date, 
    DATEDIFF(DAY, s.Departure_Date, s.Arrival_Date) AS Actual_Transit_Days,
    ts.Avg_Transit_Time
FROM shipments s
JOIN customers c ON s.Customer_ID = c.Customer_ID
JOIN ports p1 ON s.Departure_Port = p1.Port_ID
JOIN ports p2 ON s.Arrival_Port = p2.Port_ID
CROSS JOIN TransitStats ts
WHERE DATEDIFF(DAY, s.Departure_Date, s.Arrival_Date) > ts.Avg_Transit_Time * 1.5
ORDER BY Actual_Transit_Days DESC;

-- Predicting Future Revenue (Advanced Machine Learning in SQL Server)

EXEC sp_execute_external_script  
@language = N'Python',  
@script = N'  
import pandas as pd  
from statsmodels.tsa.holtwinters import ExponentialSmoothing  

df = pd.DataFrame(InputData)  
model = ExponentialSmoothing(df["Total_Amount"], trend="add", seasonal="add", seasonal_periods=12).fit()  
df["Forecast"] = model.forecast(3)  

OutputDataSet = df
',  
@input_data_1 = N'SELECT YEAR(Issue_Date) AS Year, MONTH(Issue_Date) AS Month, SUM(Total_Amount) AS Total_Amount FROM invoices GROUP BY YEAR(Issue_Date), MONTH(Issue_Date)',
@output_data_1_name = N'OutputDataSet';
                  ---- ANALYZING SALES DATA ----
		---- ALL queries written by me ---

--- What are the top 20 most profitable product categories ? ---

CREATE VIEW 
dbo.Vtopcategory AS
SELECT TOP 20 Category, SUM(Profit) AS TotalProfit
FROM dbo.Superstore
GROUP BY Category;

SELECT *
FROM dbo.Vtopcategory;

--- Is it possible to get a list of every order placed on Tuesdays ? ---

SELECT City, Order_Date, DATENAME(WEEKDAY,Order_Date) AS NameOfDay
FROM dbo.Superstore
WHERE DATENAME(WEEKDAY,Order_Date)='Tuesday';

---Could you please provide us with a list of all the cities in which our items are sold, together with their total profit? A "profit or loss" classification system for the cities would be very beneficial. ---

WITH CTE_RevenueStatus (Cities, TotalProfit, Status) AS (
SELECT City,ROUND(SUM(Profit),2) AS TotalProfit,
CASE WHEN SUM(Profit) < 0 THEN 'Loss'
     WHEN SUM(Profit) > 0 THEN 'Profit'
END AS RevenueStatus
FROM dbo.Superstore
GROUP BY City)
SELECT * 
FROM CTE_RevenueStatus
ORDER BY TotalProfit DESC;

---Would you kindly give us a list of the Top 10 customers who have made the most purchases? ---

SELECT TOP 10 Top_Customers, Total_Sales
FROM (SELECT Customer_Name AS Top_Customers, 
      SUM(Sales) AS Total_Sales 
	  FROM dbo.Superstore 
	  WHERE Sales > 500
	  GROUP BY Customer_Name, Sales) ChampionsTable
ORDER BY Total_Sales DESC;


--- Could you kindly check the delivery date for Sean Miller for an order that was placed on this date, "2017-07-09"? ---

SELECT Customer_Name,Order_Date, DATEADD(dd, 10, Ship_Date) AS DeliveryDate
FROM dbo.Superstore
WHERE Customer_Name = 'Sean Miller' AND Order_Date = '2017-07-09';


---Kindly create a stored procedure with all of the cities' sales data so we won't have to write queries each time?

CREATE PROCEDURE Cities_Data (
                 @City VARCHAR (50),
				 @LosDataCount INT OUTPUT )
AS
BEGIN
SELECT *
FROM dbo.Superstore
WHERE City = @City 

SELECT @LosDataCount = @@ROWCOUNT
END;

DECLARE @Count INT;

EXEC Cities_Data
     @City='Los Angeles',
	 @LosDataCount = @Count OUTPUT;

SELECT @Count AS 'Data Count';

---- Create a stored procedure with the overall earnings for every city and segment ---

CREATE PROCEDURE Segment_Data (
                @City VARCHAR(50),
				@Segment VARCHAR(50),
				@Profit DEC(10,2) OUTPUT)
AS
BEGIN
SELECT City, Segment, ROUND(SUM(Profit),2) AS Profit_Sum
FROM dbo.Superstore
WHERE City=@City AND
      Segment=@Segment
GROUP BY City, Segment;

SELECT @Profit = SUM(Profit)
FROM dbo.Superstore
WHERE City=@City AND
      Segment=@Segment
END;

DECLARE @SumProfit INT;

EXEC Segment_Data
     @City='Los Angeles',
	 @Segment='Consumer',
	 @Profit=@SumProfit OUTPUT

SELECT @SumProfit AS 'Total Profit';


--- Rank every customer from the same city according to their highest sales? ---

SELECT Customer_ID, Customer_Name,City, SUM(Sales) AS Total_Sales,
        RANK()  OVER(PARTITION BY City ORDER BY SUM(Sales) DESC) AS Customer_Rank
FROM dbo.Superstore
GROUP BY Customer_ID, Customer_Name,City,Sales;

--- 

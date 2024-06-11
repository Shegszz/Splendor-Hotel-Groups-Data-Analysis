------SPLENDOR HOTEL GROUPS DATA EDA(TWITTER DATA)

----CONVERTING THE DATE COLUMNS FROM DATETIME TO DATE FORMAT AND ADDING THE RESULTING COLUMNS TO THE DATA
SELECT [Booking Date], CONVERT(Date, [Booking Date]), [Arrival Date], CONVERT(Date, [Arrival Date]), [Status Update]
, CONVERT(Date, [Status Update])
FROM TwitterData..Data$;

ALTER TABLE TwitterData..Data$
ADD BookingDateConverted Date;

UPDATE TwitterData..Data$
SET BookingDateConverted = CONVERT(Date,[Booking Date]);


ALTER TABLE Data$
ADD ArrivalDateConverted Date;

UPDATE Data$
SET ArrivalDateConverted = CONVERT(Date,[Arrival Date]);


ALTER TABLE Data$
ADD StatusUpdateConverted Date;


UPDATE Data$
SET StatusUpdateConverted = CONVERT(Date,[Status Update]);

----ANALYSIS

----BOOKING PATTERN TREND OVER TIME
---The Data 
SELECT *
FROM TwitterData..Data$
ORDER BY BookingDateConverted;

---Total Bookings
SELECT COUNT([Booking ID]) AS [Total Bookings]
FROM TwitterData..Data$

---Total Bookings for each Month
SELECT DATENAME(M, BookingDateConverted) AS [Booking Month], COUNT([Booking ID]) AS [Total Bookings]
FROM TwitterData..Data$
GROUP BY DATENAME(M, BookingDateConverted)
ORDER BY [Total Bookings] DESC;

---Total Bookings for each Year
SELECT Year(BookingDateConverted) AS [Booking Year], COUNT([Booking ID]) AS [Total Bookings]
FROM TwitterData..Data$
GROUP BY Year(BookingDateConverted)
ORDER BY [Total Bookings] DESC;

---Booking trend over time with Rolling Count
SELECT YEAR(BookingDateConverted) AS [Booking Year], DATENAME(M, BookingDateConverted) AS [Booking Month], COUNT([Booking ID]) AS [Bookings Count],
SUM(COUNT([Booking ID])) OVER (PARTITION BY YEAR(BookingDateConverted) ORDER BY YEAR(BookingDateConverted), DATENAME(M, BookingDateConverted)) AS [Rolling Total Bookings]
FROM TwitterData..Data$
GROUP BY YEAR(BookingDateConverted), DATENAME(M, BookingDateConverted)
ORDER BY [Booking Year], [Booking Month];

---SUCCESSFUL BOOKINGS FOR EACH YEAR AND MONTH RESPECTIVELY:
--Successful Bookings Trend Over Time with Rolling Count
SELECT YEAR(BookingDateConverted) AS [Booking Year], DATENAME(M, BookingDateConverted) AS [Booking Month], COUNT([Booking ID]) AS [Successful Bookings Count],
SUM(COUNT([Booking ID])) OVER (PARTITION BY  YEAR(BookingDateConverted) ORDER BY YEAR(BookingDateConverted), DATENAME(M, BookingDateConverted)) AS [Rolling Total of Successful Bookings]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 0
GROUP BY YEAR(BookingDateConverted), DATENAME(M, BookingDateConverted)
ORDER BY [Booking Year], [Booking Month];

--Successful Bookings for each Month
SELECT DATENAME(M, BookingDateConverted) AS [Booking Month], COUNT([Booking ID]) AS [Successful Bookings]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 0
GROUP BY DATENAME(M, BookingDateConverted)
ORDER BY [Successful Bookings] DESC;

---Total Bookings across Distribution Channel
SELECT [Distribution Channel] , COUNT([Booking ID]) AS [Total Bookings],ROUND((SUM([Booking ID]) / (SELECT SUM([Booking ID])
FROM TwitterData..Data$)), 3) * 100 AS  [Booking Percentage(%)]
FROM TwitterData..Data$
GROUP BY [Distribution Channel]
ORDER BY [Total Bookings] DESC;

---Total Bookings across Customer Type
SELECT [Customer Type] , COUNT([Booking ID]) AS [Total Bookings]
FROM TwitterData..Data$
GROUP BY [Customer Type]
ORDER BY [Total Bookings] DESC;

---Cancelled Bookings over time
SELECT YEAR(BookingDateConverted) AS [Booking Year], COUNT([Booking ID]) AS [Cancelled Bookings]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = '1'
GROUP BY YEAR(BookingDateConverted)
ORDER BY [Cancelled Bookings] DESC;

---Average Lead Time across Distribution Channels
SELECT [Distribution Channel], ROUND(AVG([Lead Time]), 1) AS [Avg Lead Time]
FROM TwitterData..Data$
GROUP BY [Distribution Channel]
ORDER BY [Avg Lead Time] DESC;

---Average Lead Time across Customer Type
SELECT [Customer Type], ROUND(AVG([Lead Time]), 0) AS [Avg Lead Time]
FROM TwitterData..Data$
GROUP BY [Customer Type]
ORDER BY [Avg Lead Time] DESC;


-----CUSTOMER BEHAVIOR ANALYSIS

---Contribution of distribution channels to bookings and ADR differences
SELECT [Distribution Channel], COUNT([Booking ID]) [Bookings Count], ROUND(AVG([Avg Daily Rate]), 2) AS [Avg ADR($)]
FROM TwitterData..Data$
GROUP BY [Distribution Channel]
ORDER BY [Bookings Count] DESC;

---Patterns in Guest distribution by Country and impact on Revenue
SELECT  Country, COUNT([Booking ID]) AS [Guests Count], SUM(Revenue) AS [Total Revenue($)]
FROM TwitterData..Data$
GROUP BY Country
ORDER BY [Total Revenue($)] DESC;


----CANCELLATION ANALYSIS

---Factors correlated with cancellations and prediction based on variables
SELECT [Customer Type],
 ROUND(SUM([Revenue Loss]), 0) AS [Revenue loss($)]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 1
GROUP BY [Customer Type]
ORDER BY [Revenue loss($)]


---Revenue loss comparison across customer segments and channels
SELECT [Customer Type], [Distribution Channel], SUM([Revenue Loss]) AS [Total Revenue Loss($)]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 1
GROUP BY [Customer Type], [Distribution Channel]
ORDER BY [Total Revenue Loss($)];


----REVENUE OPTIMIZATION

---Best Performing Country by Revenue
SELECT  Country, SUM(Revenue) AS [Revenue($)], (SUM(Revenue) / (SELECT SUM(Revenue)
FROM TwitterData..Data$)) * 100 AS  [Revenue Percentage(%)]
FROM TwitterData..Data$
GROUP BY Country
ORDER BY [Revenue($)] DESC;

---Overall Revenue trend over time and significant contributors:
--Revenue/DAY
SELECT DATENAME(DW, BookingDateConverted) AS [Day], SUM(Revenue) AS [Revenue($)]
FROM TwitterData..Data$
GROUP BY DATENAME(DW, BookingDateConverted)
ORDER BY [Revenue($)] DESC;

--Revenue/MONTH
SELECT DATENAME(M, BookingDateConverted) AS [Month], SUM(Revenue) AS [Revenue($)]
FROM TwitterData..Data$
GROUP BY DATENAME(M, BookingDateConverted)
ORDER BY [Revenue($)] DESC;

--Revenue/YEAR
SELECT YEAR(BookingDateConverted) AS [Year], SUM(Revenue) AS [Revenue($)]
FROM TwitterData..Data$
GROUP BY YEAR(BookingDateConverted)
ORDER BY [Revenue($)] DESC;

---Total Revenue by Customer type
SELECT [Customer Type], SUM(Revenue) AS [Total Revenue($)]
FROM TwitterData..Data$ 
GROUP BY [Customer Type]
ORDER BY [Total Revenue($)] DESC;

---Total Revenue by Distribution Channel
SELECT [Distribution Channel], SUM(Revenue) AS [Total Revenue($)]
FROM TwitterData..Data$ 
GROUP BY [Distribution Channel]
ORDER BY [Total Revenue($)] DESC;


----GEOGRAPHICAL ANALYSIS

---Distribution of Guests and Revenue across Countries
SELECT Country, COUNT([Booking ID]) AS [Bookings Count], SUM(Revenue) AS [Total Revenue($)]
FROM TwitterData..Data$
GROUP BY  Country
ORDER BY [Bookings Count] DESC;

---Average stay of Guests across Country of origin
SELECT Country, AVG(Nights) AS [Average Night Spent], AVG([Cancelled (0/1)]) AS [Avg Cancellation Rate]
FROM TwitterData..Data$
GROUP BY Country
ORDER BY [Average Night Spent] DESC;


----OPERATIONAL EFFICIENCY

---Average Night spent by Guests
SELECT AVG(Nights) AS [Avg Length Of Stay]
FROM TwitterData..Data$;

---Patterns across Check-Out days
SELECT DATENAME(DW, StatusUpdateConverted) AS [Check-Out Day], AVG(Nights) AS [Avg Length Of Stay], COUNT([Booking ID]) AS [Check-Out Count]
FROM TwitterData..Data$
WHERE Status = 'Check-Out'
GROUP BY DATENAME(DW, StatusUpdateConverted)
ORDER BY [Check-Out Count] DESC, [Avg Length Of Stay] DESC;

---Average Length of stay/Booking Channel
SELECT [Distribution Channel], AVG(Nights) AS [Average Length Of Stay]
FROM TwitterData..Data$
GROUP BY [Distribution Channel]
ORDER BY  [Average Length Of Stay] DESC;

---Average Length of stay/Customer Type
SELECT [Customer Type], AVG(Nights) AS [Average Length Of Stay]
FROM TwitterData..Data$
--WHERE Status = 'Check-Out'
GROUP BY [Customer Type]
ORDER BY  [Average Length Of Stay] DESC;

---Guests Status
SELECT [Status], COUNT(Guests) AS [Total Guests]
FROM TwitterData..Data$
GROUP BY [Status];


----IMPACTS OF DEPOSIT TYPES
---On Cancellation and Revenue
SELECT [Deposit Type], COUNT([Cancelled (0/1)]) AS [Cancelled Bookings], AVG([Revenue]) AS [Average Revenue($)],
	(CASE WHEN [Deposit Type] IN ('Non Refundable','Refundable' )THEN 'With Deposits' ELSE 'Without Deposits' END) AS [Deposit-Type], (SUM([Cancelled (0/1)]) / (SELECT SUM([Cancelled (0/1)])
FROM TwitterData..Data$)) * 100 AS  [Cancellation Rate(%)]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 1 
GROUP BY [Deposit Type]
ORDER BY [Cancelled Bookings] DESC;


----TIME-TO-EVENT ANALYSIS
SELECT Country, ROUND(AVG([Lead Time]), 2) AS [Avg Lead Time], ROUND(SUM(Revenue), 2) AS [Revenue($)]
FROM TwitterData..Data$
WHERE [Cancelled (0/1)] = 1
GROUP BY Country
ORDER BY [Avg Lead Time] DESC;


----COMPARISON OF ONLINE AND OFFLINE TRAVEL AGENTS

---Revenue comparison between online and offline agents over time
SELECT YEAR(BookingDateConverted) AS [Booking Year], DATENAME(M, BookingDateConverted) AS [Booking Month], 
       SUM(CASE WHEN [Distribution Channel] = 'Online Travel Agent' THEN Revenue ELSE 0 END) AS [Online Revenue($)],
       SUM(CASE WHEN [Distribution Channel] = 'Offline Travel Agent' THEN Revenue ELSE 0 END) AS [Offline Revenue($)]
FROM TwitterData..Data$
GROUP BY YEAR(BookingDateConverted), DATENAME(M, BookingDateConverted)
ORDER BY [Booking Year], [Booking Month];

---Revenue contribution and cancellation rates comparison
SELECT [Distribution Channel], SUM(Revenue) AS [Total Revenue($)], ROUND(AVG([Cancelled (0/1)]), 2) AS [Avg Cancellation Rate]
FROM TwitterData..Data$
--WHERE [Distribution Channel] IN ('Online Travel Agent', 'Offline Travel Agent')
GROUP BY [Distribution Channel]
ORDER BY [Total Revenue($)] DESC;

-- Chinook Music Store: Sales Analysis
-- Tool: DB Browser for SQLite
-- Database: Chinook_Sqlite.sqlite (github.com/lerocha/chinook-database)
-- Data: sample music store sales, 2009-2013
-- Author: Paulina Kur

-- Q1: Top 5 countries by revenue
SELECT BillingCountry, SUM(Total) AS TotalRevenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalRevenue DESC
LIMIT 5;
-- Finding: The USA brings in the most revenue (523.06). Brazil is 4th (190.10).

-- Q2: Revenue per year
SELECT strftime('%Y', InvoiceDate) AS Year, SUM(Total) AS TotalRevenue
FROM Invoice
GROUP BY Year
ORDER BY Year;
-- Finding: Revenue is steady at 449 to 481 per year, 2,328.60 in total, with no clear growth.

-- Q3: Top 10 customers by total spent
SELECT c.FirstName, c.LastName, c.Country, SUM(i.Total) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY TotalSpent DESC
LIMIT 10;
-- Finding: Spending is very even. The top customer spent 49.62 and the 10th spent 42.62.

-- Q4: Top 5 genres by revenue
SELECT g.Name AS Genre, SUM(il.UnitPrice * il.Quantity) AS Revenue
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId
ORDER BY Revenue DESC
LIMIT 5;
-- Finding: Rock earns the most (826.65), about a third of all revenue.

-- Q5: Top 10 best-selling tracks
SELECT t.Name AS Track, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId
ORDER BY UnitsSold DESC
LIMIT 10;
-- Finding: No track sold more than 2 units, and 256 tracks are tied at 2, so there are no true bestsellers.

-- Check: max quantity per invoice line (result: 1)
SELECT MAX(Quantity)
FROM InvoiceLine;

-- Check: tracks with exactly 2 units sold (result: 256 rows)
SELECT t.Name, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId
HAVING SUM(il.Quantity) = 2;

-- Q6: Average invoice value
SELECT ROUND(AVG(Total), 2) AS AvgInvoice, COUNT(*) AS Invoices
FROM Invoice;
-- Finding: The average invoice is 5.65 across 412 invoices.

-- Q7: Customers with the fewest invoices
SELECT c.FirstName, c.LastName, COUNT(i.InvoiceId) AS Invoices
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId
ORDER BY Invoices ASC
LIMIT 5;
-- Finding: The customer with the fewest invoices still has 6, so purchases are spread evenly across customers.

-- Q8: Revenue by support rep
SELECT e.FirstName, e.LastName, SUM(i.Total) AS Revenue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId
ORDER BY Revenue DESC;
-- Finding: Three support reps cover all customers. Jane Peacock leads (833.04), and the three totals add up to 2,328.60.

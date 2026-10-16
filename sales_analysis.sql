-- Chinook Music Store: Sales Analysis
-- Tool: DB Browser for SQLite
-- Database: Chinook_Sqlite.sqlite (github.com/lerocha/chinook-database)
-- Data: sample music store sales, 2009-2013
-- Author: Paulina Kur
--
-- Structure: Part A = 8 business questions, Part B = validation checks.
-- Run each query separately (select it, then press Ctrl+Return in DB Browser).


-- ==========================================================
-- PART A: BUSINESS QUESTIONS
-- ==========================================================

-- Q1: Which 5 countries bring in the most revenue?
-- Also shows customers per country, so we can tell whether a country leads
-- because it has more customers or because each customer spends more.
SELECT BillingCountry,
       ROUND(SUM(Total), 2) AS TotalRevenue,
       COUNT(DISTINCT CustomerId) AS Customers,
       ROUND(SUM(Total) / COUNT(DISTINCT CustomerId), 2) AS RevenuePerCustomer,
       ROUND(SUM(Total) * 100.0 / (SELECT SUM(Total) FROM Invoice), 1) AS PctOfTotal
FROM Invoice
GROUP BY BillingCountry
ORDER BY TotalRevenue DESC
LIMIT 5;
-- Finding: The USA brings in the most revenue (523.06). Brazil is 4th (190.10).
-- See the Customers and RevenuePerCustomer columns for the explanation.


-- Q2: How much revenue came in each year?
SELECT strftime('%Y', InvoiceDate) AS Year,
       ROUND(SUM(Total), 2) AS TotalRevenue,
       COUNT(*) AS Invoices
FROM Invoice
GROUP BY Year
ORDER BY Year;
-- Finding: Revenue is steady at 449 to 481 per year, 2,328.60 in total, with no clear growth.


-- Q3: Who are the top 10 customers by total spent?
SELECT c.FirstName, c.LastName, c.Country, ROUND(SUM(i.Total), 2) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName, c.Country
ORDER BY TotalSpent DESC, c.CustomerId
LIMIT 10;
-- Finding: The top customer spent 49.62 and the 10th spent 42.62.
-- Whether this means "even" spending is tested in check B4.


-- Q4: Which 5 genres earn the most?
SELECT g.Name AS Genre,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS Revenue,
       ROUND(SUM(il.UnitPrice * il.Quantity) * 100.0
             / (SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine), 1) AS PctOfTotal
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY Revenue DESC
LIMIT 5;
-- Finding: Rock earns the most (826.65), 35.5% of total revenue.


-- Q5: What are the 10 best-selling tracks?
SELECT t.Name AS Track, SUM(il.Quantity) AS UnitsSold
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY UnitsSold DESC, t.Name
LIMIT 10;
-- Finding: No track sold more than 2 units, so the top 10 is an arbitrary
-- cut of a large tie. The tie is measured in checks B5 and B6.


-- Q6: What is the average invoice value?
SELECT ROUND(AVG(Total), 2) AS AvgInvoice, COUNT(*) AS Invoices
FROM Invoice;
-- Finding: The average invoice is 5.65 across 412 invoices.


-- Q7: Which customers have the fewest invoices?
SELECT c.FirstName, c.LastName, COUNT(i.InvoiceId) AS Invoices
FROM Customer c
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY Invoices ASC, c.CustomerId
LIMIT 5;
-- Finding: The lowest count is 6 invoices.
-- Whether purchases are spread evenly is tested in check B4.


-- Q8: How much revenue does each support rep's customer group bring in?
SELECT e.FirstName, e.LastName, ROUND(SUM(i.Total), 2) AS Revenue
FROM Employee e
JOIN Customer c ON e.EmployeeId = c.SupportRepId
JOIN Invoice i ON c.CustomerId = i.CustomerId
GROUP BY e.EmployeeId, e.FirstName, e.LastName
ORDER BY Revenue DESC;
-- Finding: Three support reps cover all customers. Jane Peacock leads (833.04).


-- ==========================================================
-- PART B: VALIDATION CHECKS
-- ==========================================================

-- B1: Do the two revenue sources agree?
-- Q4 sums InvoiceLine, the other queries sum Invoice.Total. Both should match.
SELECT ROUND((SELECT SUM(Total) FROM Invoice), 2) AS InvoiceTotal,
       ROUND((SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine), 2) AS InvoiceLineTotal;
-- Expected: both 2,328.60.


-- B2: Do the country totals (Q1) add up to the overall revenue?
SELECT ROUND(SUM(CountryRevenue), 2) AS SumOfCountries
FROM (SELECT SUM(Total) AS CountryRevenue FROM Invoice GROUP BY BillingCountry);
-- Expected: 2,328.60.


-- B3: Do the yearly totals (Q2) and support rep totals (Q8) add up too?
SELECT ROUND(SUM(YearRevenue), 2) AS SumOfYears
FROM (SELECT SUM(Total) AS YearRevenue FROM Invoice GROUP BY strftime('%Y', InvoiceDate));

SELECT COUNT(*) AS CustomersWithoutRep FROM Customer WHERE SupportRepId IS NULL;
-- Expected: SumOfYears = 2,328.60, CustomersWithoutRep = 0
-- (so Q8 covers every customer and its three totals add up to 2,328.60).


-- B4: Are purchases spread evenly across customers? (tests Q3 and Q7)
-- Invoices per customer: lowest, highest, average.
SELECT MIN(InvoiceCount) AS MinInvoices,
       MAX(InvoiceCount) AS MaxInvoices,
       ROUND(AVG(InvoiceCount), 1) AS AvgInvoices
FROM (SELECT COUNT(*) AS InvoiceCount FROM Invoice GROUP BY CustomerId);

-- Share of total revenue from the top 10 customers.
SELECT ROUND(SUM(TotalSpent), 2) AS Top10Revenue,
       ROUND(SUM(TotalSpent) * 100.0 / (SELECT SUM(Total) FROM Invoice), 1) AS Top10PctOfTotal,
       (SELECT COUNT(*) FROM Customer) AS AllCustomers
FROM (SELECT SUM(Total) AS TotalSpent
      FROM Invoice
      GROUP BY CustomerId
      ORDER BY TotalSpent DESC
      LIMIT 10);
-- How to read it: if the top 10 customers make up only a little more than
-- 10 / AllCustomers of revenue, spending is close to even.


-- B5: Units sold per track, grouped (replaces the old MAX(Quantity) check).
-- First step (inner query): total units per track. Second step: count tracks per total.
SELECT UnitsSold, COUNT(*) AS Tracks
FROM (SELECT TrackId, SUM(Quantity) AS UnitsSold
      FROM InvoiceLine
      GROUP BY TrackId)
GROUP BY UnitsSold
ORDER BY UnitsSold DESC;
-- Shows the highest units sold by any track and how many tracks share each value.
-- Old check: it only found the largest quantity on a single invoice line,
-- which does not measure units sold per track.


-- B6: Tracks that never sold.
SELECT COUNT(*) AS NeverSoldTracks
FROM Track
WHERE TrackId NOT IN (SELECT TrackId FROM InvoiceLine);

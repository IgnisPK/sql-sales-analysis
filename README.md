# sql-sales-analysis
Chinook Sales Analysis (SQL): answered 8 business questions with joins, GROUP BY and aggregate functions; validated results with cross-checks.

## Dataset

- **Chinook sample database** (SQLite), a free sample database of a music store: customers, invoices, tracks, genres and support staff. Source: [lerocha/chinook-database](https://github.com/lerocha/chinook-database).
- Sales period: 2009-2013. 412 invoices, 2,328.60 in total revenue.
- Tool: DB Browser for SQLite.

## Files

- `chinook_sales_analysis.sql`: all queries, each with a comment describing the question and the finding.

## Questions and findings

| # | Question | Finding |
|---|----------|---------|
| 1 | Which 5 countries bring in the most revenue? | The USA is first (523.06). Brazil is 4th (190.10). |
| 2 | How much revenue came in each year? | Steady at 449 to 481 per year, with no clear growth. |
| 3 | Who are the top 10 customers by total spent? | The top 10 spent between 42.62 and 49.62 each, a narrow range. The top customer is about 2% of total revenue (49.62 of 2,328.60), so no single customer dominates. |
| 4 | Which 5 genres earn the most? | Rock is first (826.65), about a third of all revenue. |
| 5 | What are the 10 best-selling tracks? | No track sold more than 2 units, and 256 tracks tied at 2, so there are no true bestsellers. |
| 6 | What is the average invoice value? | 5.65 across 412 invoices. |
| 7 | Which customers have the fewest invoices? | The lowest is 6 invoices, so every customer made at least 6 purchases. |
| 8 | How much revenue does each support rep's customer group bring in? | Three reps cover all customers. Jane Peacock leads (833.04). |

## Checks I ran

- **Q1:** my first version returned single invoice values instead of country totals. I fixed it with `SUM()` and `GROUP BY BillingCountry`.
- **Q5:** the top 10 were all tied, so I checked `MAX(Quantity)` (it is 1) and counted tracks with exactly 2 units sold (256). The result is reported as a tie, not as a ranking.
- **Q2 and Q8:** both add up to the same total revenue of 2,328.60, which matches the overall figure.

## SQL used

`SELECT`, `JOIN` (up to 3 tables), `GROUP BY`, `HAVING`, `ORDER BY`, `LIMIT`, `SUM`, `AVG`, `COUNT`, `MAX`, `ROUND`, `strftime`, table aliases.

## Notes

This project is part of my data analyst portfolio and was created to practice SQL on a sample music store database.

The goal was to answer basic business questions with clear queries and to check that the results make sense.

Feedback is welcome.

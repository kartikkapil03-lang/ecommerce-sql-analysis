# SQL Validation Report — 8 October 2026

## Scope and execution environment

- Executed **all 11 SELECT/CTE queries** in `ecommerce_analysis.sql` against the four supplied CSV datasets loaded into an in-memory SQLite database.
- Registered `STR_TO_DATE()` and `DATE_FORMAT()` functions to reproduce the two MySQL date operations used by the script.
- All 11 statements **executed without errors in this compatible test environment**.
- **Native MySQL 8.0 execution has not been performed.** This test checks the queries' logical execution and results, but cannot certify every MySQL-specific behavior or configuration.

## Dataset and integrity checks

| Check | Result |
|---|---|
| Customers | 100 records |
| Orders | 200 records |
| Order details | 519 records |
| Products | 8 records |
| Sum of order totals | 19,783,000 |
| Sum of quantity × detail price | 19,783,000 |
| Orphan detail order references | 0 |
| Orphan order customer references | 0 |
| Orphan detail product references | 0 |
| Duplicate order IDs | 0 |
| Order date range | 2023-03-06 to 2024-02-24 |

## Query-level execution results

| # | Analysis | Execution | Rows |
|---|---|---|---:|
| 1 | Customers by market | Pass | 10 |
| 2 | Customer order frequency, including no orders | Pass | 8 |
| 3 | Category customer reach | Pass | 3 |
| 4 | Product revenue and units | Pass | 8 |
| 5 | Products averaging approximately two units per order line | Pass | 2 |
| 6 | Monthly sales, AOV and MoM changes | Pass | 12 |
| 7 | First observed buyers per month | Pass | 12 |
| 8 | Product penetration below 40% | Pass | 2 |
| 9 | Sales frequency by product | Pass | 8 |
| 10 | Highest-revenue months | Pass | 3 |
| 11 | Repeat-order distribution by market | Pass | 10 |

## Checked outputs

- Largest customer locations: Delhi (16), Chennai (15).
- Electronics category reached 79 distinct customers.
- Top product by number of distinct orders containing the product: Product 7 (63 orders, 151 units).
- Highest-revenue month: September 2023 (2,927,000).
- Source coverage ends on February 24, 2024; do not interpret February as a complete period.

## Remaining native MySQL check

1. Create four tables in MySQL 8.0+ with the types described in `docs/data_dictionary.md`.
2. Import the CSVs and check row counts.
3. Execute `ecommerce_analysis.sql` without modification.
4. Verify query result counts and key metrics above.

This report avoids claiming that native MySQL validation has already happened.

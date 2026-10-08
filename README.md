# E-Commerce Customer, Sales & Product Performance Analysis

**Portfolio case study | MySQL 8.0+ | Customer analytics • Sales trends • Product reach**

## Business objective
Understand where customers are concentrated, how frequently they shop, which products and categories reach buyers, how revenue and average order value change, and what the observed patterns suggest for retention, merchandising and operational planning.

## Data and model
Four related CSV tables: `customers` (**100 rows**), `orders` (**200 rows**), `order_details` (**519 rows**) and `products` (**8 rows**). Order records span **6 March 2023 to 24 February 2024**. Data is a case-study dataset, not production company data.

`customers.customer_id` → `orders.customer_id`; `orders.order_id` → `order_details.order_id`; `products.product_id` → `order_details.product_id`.

**Data validation performed:** checked primary-key uniqueness, missing values and referential integrity; verified that `orders.total_amount` equals summed `quantity × price_per_unit` for all 200 orders. The date values use **DD-MM-YY**, parsed in SQL with `STR_TO_DATE(order_date, '%d-%m-%y')`.

## SQL techniques
Multi-table joins, `LEFT JOIN`, `COUNT(DISTINCT)`, aggregations, CTEs, conditional aggregation, `LAG()` for month-on-month comparison, date parsing, and KPI construction. All analysis queries are read-only.

## Key findings from the supplied data
- **Customer concentration:** Delhi (**16 customers**), Chennai (**15**) and Jaipur (**11**) are the largest registered customer markets. This measures customer counts, *not* city revenue.
- **Engagement:** **84 of 100** registered customers placed orders; **26** had exactly one order and **58** had two or more. **16** placed none in this dataset.
- **Product reach:** Electronics was bought by **79 distinct customers**, ahead of Wearable Tech (**61**) and Photography (**45**). These audiences overlap.
- **Top product by order-line frequency:** Product ID **7** appears on **78 order lines**. This is a sales-frequency measure, **not inventory turnover**.
- **Sales volatility:** September 2023 had the highest recorded revenue (**2,927,000 monetary units**); month-to-month results vary. **February 2024 is partial**, so its apparent decline must not be treated as evidence of falling underlying demand.
- **AOV:** December 2023's average order value was approximately **132,095** in the dataset's monetary units, up from November's ~95,917. No currency label is assumed for the data.
- **First observed purchases:** monthly additions vary and later months contain fewer first-time buyers; this does *not* establish that marketing campaigns failed.

## Business recommendations
1. Assess repeat-purchase opportunities among occasional shoppers; verify retention with cohorts and customer tenure before drawing conclusions.
2. Monitor high-frequency products for replenishment review, but use stock-on-hand and inventory turnover data before committing stock decisions.
3. Investigate why lower-penetration products have low reach (pricing, category interest, visibility), ideally with campaign and traffic data.
4. Monitor monthly revenue, AOV and order counts together; compare full-month periods for reliable growth interpretation.
5. Evaluate geographic markets using revenue and cohort metrics as well as registered customer counts.

## Limitations
- Date coverage starts in March 2023 and ends mid/late February 2024; first and last periods are incomplete.
- No marketing spend, impressions, traffic, campaign attribution, stock levels or cost-of-goods data.
- Product reach uses all 100 registered customers as denominator; results change if using only active buyers.
- Descriptive analysis identifies relationships and areas for investigation, not proven causal mechanisms.
- Original classroom assignment and raw SQL exercise are *not* presented as production-tested code.

## SQL execution validation

All **11 queries executed successfully** against the supplied CSVs in a local SQL test environment (SQLite with registered MySQL-compatible date functions). Native MySQL 8.0 execution remains pending; see [`docs/sql_validation.md`](docs/sql_validation.md) for precise scope, results, and checks.

## Repository structure
```
ecommerce-sql-analysis/
├── README.md
├── ecommerce_analysis.sql
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   ├── order_details.csv
│   └── products.csv
└── docs/
    ├── data_dictionary.md
    ├── insights.md
    └── sql_validation.md
```

## Running the queries
Create four MySQL tables from the column schemas in `docs/data_dictionary.md`, import the matching CSV files, then run `ecommerce_analysis.sql` in a MySQL 8.0+ database. `order_date` can remain text in the imported staging table because queries explicitly parse it using `%d-%m-%y`.

**Suggested next extension:** Build a Power BI report covering revenue and AOV, customer frequency, city reach and category/product performance.

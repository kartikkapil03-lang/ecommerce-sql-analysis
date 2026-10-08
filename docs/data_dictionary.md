# Data dictionary and MySQL import

| Table | CSV fields | Recommended MySQL types | Key |
|---|---|---|---|
| customers | customer_id, name, location | INT, VARCHAR(255), VARCHAR(100) | customer_id PK |
| orders | order_id, order_date, customer_id, total_amount | INT, VARCHAR(8), INT, DECIMAL(14,2) | order_id PK; customer_id FK |
| order_details | order_id, product_id, quantity, price_per_unit | INT, INT, INT, DECIMAL(12,2) | order_id and product_id link to parent tables; source has no explicit line ID |
| products | product_id, name, category, price | INT, VARCHAR(255), VARCHAR(100), DECIMAL(12,2) | product_id PK |

**Date handling:** `order_date` uses `DD-MM-YY` format in the source CSV and should be parsed using `STR_TO_DATE(order_date, '%d-%m-%y')`; importing the field directly as `DATE` without conversion can fail. The name and category fields are text; order-level amounts are numeric.

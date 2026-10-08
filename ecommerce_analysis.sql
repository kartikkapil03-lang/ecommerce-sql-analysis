-- E-Commerce Customer, Sales & Product Performance Analysis
-- MySQL 8.0+ | Source dates are DD-MM-YY (e.g., 27-09-23)
-- Read-only queries: nothing here alters the source data.
-- Note: order amounts have been reconciled against quantity * price_per_unit.

-- 1. Market concentration: customer base by city (not sales by city).
SELECT location, COUNT(*) AS customers
FROM customers
GROUP BY location
ORDER BY customers DESC, location
LIMIT 10;

-- 2. Order frequency: customers with zero orders are included.
WITH customer_orders AS (
 SELECT c.customer_id, COUNT(o.order_id) AS order_count
 FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
 GROUP BY c.customer_id
)
SELECT order_count, COUNT(*) AS customer_count
FROM customer_orders
GROUP BY order_count ORDER BY order_count;

-- 3. Category customer reach. Percent denominator = all registered customers.
SELECT p.category, COUNT(DISTINCT o.customer_id) AS unique_buyers,
 ROUND(100.0 * COUNT(DISTINCT o.customer_id) /
       NULLIF((SELECT COUNT(*) FROM customers),0),2) AS customer_reach_pct
FROM products p
JOIN order_details d ON p.product_id=d.product_id
JOIN orders o ON d.order_id=o.order_id
GROUP BY p.category ORDER BY unique_buyers DESC;

-- 4. Revenue and purchase units by product (selling price from transaction detail).
SELECT p.product_id, p.name, p.category,
 COUNT(*) AS order_line_count, COUNT(DISTINCT d.order_id) AS order_count,
 SUM(d.quantity) AS units_sold,
 SUM(d.quantity*d.price_per_unit) AS revenue
FROM products p JOIN order_details d ON p.product_id=d.product_id
GROUP BY p.product_id,p.name,p.category ORDER BY revenue DESC;

-- 5. Products with average units per order-line approximately 2.
-- AVG uses order LINE as denominator, not distinct orders across products.
SELECT p.product_id,p.name,ROUND(AVG(d.quantity),2) AS avg_units_per_line,
 SUM(d.quantity*d.price_per_unit) AS revenue
FROM products p JOIN order_details d ON d.product_id=p.product_id
GROUP BY p.product_id,p.name
HAVING ABS(AVG(d.quantity)-2)<0.005
ORDER BY revenue DESC;

-- 6. Monthly sales, order count, average order value and MoM changes.
WITH monthly AS (
 SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%d-%m-%y'),'%Y-%m') AS month,
 SUM(total_amount) AS sales, COUNT(*) AS orders,
 ROUND(AVG(total_amount),2) AS aov
 FROM orders
 GROUP BY DATE_FORMAT(STR_TO_DATE(order_date,'%d-%m-%y'),'%Y-%m')
), previous AS (
 SELECT *,LAG(sales) OVER(ORDER BY month) AS prior_sales,
 LAG(aov) OVER(ORDER BY month) AS prior_aov
 FROM monthly
)
SELECT month,sales,orders,aov,prior_sales,
 ROUND(100.0*(sales-prior_sales)/NULLIF(prior_sales,0),2) AS mom_sales_pct,
 ROUND(aov-prior_aov,2) AS mom_aov_absolute_change,
 ROUND(100.0*(aov-prior_aov)/NULLIF(prior_aov,0),2) AS mom_aov_pct
FROM previous ORDER BY month;

-- 7. Monthly first-time buyers, using each customer's MINIMUM order date.
-- This measures first OBSERVED purchase, not necessarily sign-up or campaign success.
WITH first_purchase AS (
 SELECT customer_id,MIN(STR_TO_DATE(order_date,'%d-%m-%y')) AS first_order_date
 FROM orders GROUP BY customer_id
)
SELECT DATE_FORMAT(first_order_date,'%Y-%m') AS first_order_month,
 COUNT(*) AS first_time_buyers
FROM first_purchase
GROUP BY DATE_FORMAT(first_order_date,'%Y-%m')
ORDER BY first_order_month;

-- 8. Product customer penetration, INCLUDING products without orders.
WITH product_buyers AS (
 SELECT p.product_id,p.name,p.category,COUNT(DISTINCT o.customer_id) AS buyers
 FROM products p
 LEFT JOIN order_details d ON p.product_id=d.product_id
 LEFT JOIN orders o ON d.order_id=o.order_id
 GROUP BY p.product_id,p.name,p.category
)
SELECT *,ROUND(100.0*buyers/NULLIF((SELECT COUNT(*) FROM customers),0),2) AS penetration_pct
FROM product_buyers
WHERE 100.0*buyers/NULLIF((SELECT COUNT(*) FROM customers),0)<40
ORDER BY buyers,product_id;

-- 9. Product sales frequency (NOT inventory turnover, which requires stock data).
SELECT p.product_id,p.name,COUNT(DISTINCT d.order_id) AS orders_with_product,
 SUM(d.quantity) AS units_sold
FROM products p JOIN order_details d ON p.product_id=d.product_id
GROUP BY p.product_id,p.name
ORDER BY orders_with_product DESC,units_sold DESC;

-- 10. Peak months by recorded revenue; partial months need caution.
SELECT DATE_FORMAT(STR_TO_DATE(order_date,'%d-%m-%y'),'%Y-%m') AS month,
 COUNT(*) AS order_count,SUM(total_amount) AS sales
FROM orders
GROUP BY DATE_FORMAT(STR_TO_DATE(order_date,'%d-%m-%y'),'%Y-%m')
ORDER BY sales DESC LIMIT 3;

-- 11. Customer repeat-order distribution by market.
WITH customer_orders AS (
 SELECT c.customer_id,c.location,COUNT(o.order_id) AS orders_placed
 FROM customers c LEFT JOIN orders o ON o.customer_id=c.customer_id
 GROUP BY c.customer_id,c.location
)
SELECT location,COUNT(*) AS registered_customers,
 SUM(orders_placed=0) AS no_order_customers,
 SUM(orders_placed=1) AS single_order_customers,
 SUM(orders_placed>=2) AS repeat_customers
FROM customer_orders GROUP BY location ORDER BY registered_customers DESC;

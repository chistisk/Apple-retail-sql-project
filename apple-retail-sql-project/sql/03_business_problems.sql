-- =========================================================
-- Apple Retail Sales SQL Project — Business Problems
-- 20 questions, easy -> advanced, with solution queries.
-- =========================================================
USE apple_retail;

-- ---------------------------------------------------------
-- EASY
-- ---------------------------------------------------------

-- Q1. How many Apple stores do we have per country?
SELECT country, COUNT(*) AS total_stores
FROM stores
GROUP BY country
ORDER BY total_stores DESC;

-- Q2. What is the total number of units sold by each store?
SELECT s.store_id, s.store_name, SUM(sa.quantity) AS total_units_sold
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
GROUP BY s.store_id, s.store_name
ORDER BY total_units_sold DESC;

-- Q3. How many sales occurred in December 2023?
SELECT COUNT(*) AS sales_in_dec_2023
FROM sales
WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31';

-- Q4. What is the average price of products in each category?
SELECT c.category_name, ROUND(AVG(p.price), 2) AS avg_price
FROM products p
JOIN category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_price DESC;

-- Q5. List stores located in India.
SELECT store_id, store_name, city
FROM stores
WHERE country = 'India';

-- ---------------------------------------------------------
-- MEDIUM
-- ---------------------------------------------------------

-- Q6. How many warranty claims were filed in 2023?
SELECT COUNT(*) AS claims_2023
FROM warranty
WHERE YEAR(claim_date) = 2023;

-- Q7. Which store had the highest total revenue in 2023?
SELECT s.store_id, s.store_name, ROUND(SUM(sa.quantity * p.price), 2) AS revenue_2023
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
JOIN products p ON sa.product_id = p.product_id
WHERE YEAR(sa.sale_date) = 2023
GROUP BY s.store_id, s.store_name
ORDER BY revenue_2023 DESC
LIMIT 1;

-- Q8. How many unique products were sold in the last 12 months (relative to the most recent sale)?
SELECT COUNT(DISTINCT product_id) AS unique_products_last_12mo
FROM sales
WHERE sale_date >= (SELECT DATE_SUB(MAX(sale_date), INTERVAL 12 MONTH) FROM sales);

-- Q9. What percentage of total warranty claims are marked "Warranty Void"?
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN repair_status = 'Warranty Void' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS pct_warranty_void
FROM warranty;

-- Q10. List the 5 stores with no warranty claims at all.
SELECT s.store_id, s.store_name
FROM stores s
WHERE NOT EXISTS (
    SELECT 1
    FROM sales sa
    JOIN warranty w ON w.sale_id = sa.sale_id
    WHERE sa.store_id = s.store_id
)
LIMIT 5;

-- Q11. What's the correlation between product price range and warranty-claim rate?
-- (bucket products into price tiers, then compute claim rate per tier)
SELECT
    CASE
        WHEN p.price < 200 THEN 'Budget (<$200)'
        WHEN p.price BETWEEN 200 AND 799 THEN 'Mid ($200-$799)'
        ELSE 'Premium ($800+)'
    END AS price_tier,
    COUNT(DISTINCT sa.sale_id) AS total_sales,
    COUNT(DISTINCT w.claim_id) AS total_claims,
    ROUND(100.0 * COUNT(DISTINCT w.claim_id) / COUNT(DISTINCT sa.sale_id), 2) AS claim_rate_pct
FROM sales sa
JOIN products p ON sa.product_id = p.product_id
LEFT JOIN warranty w ON w.sale_id = sa.sale_id
GROUP BY price_tier
ORDER BY claim_rate_pct DESC;

-- ---------------------------------------------------------
-- ADVANCED (window functions / CTEs)
-- ---------------------------------------------------------

-- Q12. Rank stores by total revenue within each country.
WITH store_revenue AS (
    SELECT s.store_id, s.store_name, s.country,
           SUM(sa.quantity * p.price) AS revenue
    FROM sales sa
    JOIN stores s ON sa.store_id = s.store_id
    JOIN products p ON sa.product_id = p.product_id
    GROUP BY s.store_id, s.store_name, s.country
)
SELECT *,
       RANK() OVER (PARTITION BY country ORDER BY revenue DESC) AS rank_in_country
FROM store_revenue
ORDER BY country, rank_in_country;

-- Q13. Year-over-year revenue growth, overall.
WITH yearly AS (
    SELECT YEAR(sa.sale_date) AS yr, SUM(sa.quantity * p.price) AS revenue
    FROM sales sa
    JOIN products p ON sa.product_id = p.product_id
    GROUP BY YEAR(sa.sale_date)
)
SELECT yr, revenue,
       LAG(revenue) OVER (ORDER BY yr) AS prev_year_revenue,
       ROUND(
           100.0 * (revenue - LAG(revenue) OVER (ORDER BY yr))
           / LAG(revenue) OVER (ORDER BY yr), 2
       ) AS yoy_growth_pct
FROM yearly
ORDER BY yr;

-- Q14. Running (cumulative) monthly revenue for 2024.
WITH monthly AS (
    SELECT DATE_FORMAT(sa.sale_date, '%Y-%m') AS month,
           SUM(sa.quantity * p.price) AS revenue
    FROM sales sa
    JOIN products p ON sa.product_id = p.product_id
    WHERE YEAR(sa.sale_date) = 2024
    GROUP BY DATE_FORMAT(sa.sale_date, '%Y-%m')
)
SELECT month, revenue,
       SUM(revenue) OVER (ORDER BY month) AS running_total
FROM monthly
ORDER BY month;

-- Q15. For each product category, find the best-selling product by units.
WITH product_units AS (
    SELECT p.category_id, p.product_id, p.product_name,
           SUM(sa.quantity) AS units_sold,
           ROW_NUMBER() OVER (PARTITION BY p.category_id ORDER BY SUM(sa.quantity) DESC) AS rn
    FROM sales sa
    JOIN products p ON sa.product_id = p.product_id
    GROUP BY p.category_id, p.product_id, p.product_name
)
SELECT c.category_name, pu.product_name, pu.units_sold
FROM product_units pu
JOIN category c ON c.category_id = pu.category_id
WHERE pu.rn = 1
ORDER BY pu.units_sold DESC;

-- Q16. Average days between a sale and its warranty claim, by category.
SELECT c.category_name,
       ROUND(AVG(DATEDIFF(w.claim_date, sa.sale_date)), 1) AS avg_days_to_claim
FROM warranty w
JOIN sales sa ON w.sale_id = sa.sale_id
JOIN products p ON sa.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_days_to_claim;

-- Q17. Products that have never had a warranty claim (candidate "most reliable" list).
SELECT p.product_id, p.product_name
FROM products p
WHERE NOT EXISTS (
    SELECT 1 FROM sales sa
    JOIN warranty w ON w.sale_id = sa.sale_id
    WHERE sa.product_id = p.product_id
);

-- Q18. Month-over-month new-vs-repeat store performance:
-- classify each store-month as "growing" or "declining" vs the prior month.
WITH store_monthly AS (
    SELECT store_id, DATE_FORMAT(sale_date, '%Y-%m') AS month,
           SUM(quantity) AS units
    FROM sales
    GROUP BY store_id, DATE_FORMAT(sale_date, '%Y-%m')
),
with_prev AS (
    SELECT store_id, month, units,
           LAG(units) OVER (PARTITION BY store_id ORDER BY month) AS prev_units
    FROM store_monthly
)
SELECT store_id, month, units, prev_units,
       CASE
           WHEN prev_units IS NULL THEN 'No prior data'
           WHEN units > prev_units THEN 'Growing'
           WHEN units < prev_units THEN 'Declining'
           ELSE 'Flat'
       END AS trend
FROM with_prev
ORDER BY store_id, month;

-- Q19. Top 3 countries by warranty-claim rate (claims per 100 sales).
SELECT s.country,
       COUNT(DISTINCT sa.sale_id) AS total_sales,
       COUNT(DISTINCT w.claim_id) AS total_claims,
       ROUND(100.0 * COUNT(DISTINCT w.claim_id) / COUNT(DISTINCT sa.sale_id), 2) AS claims_per_100_sales
FROM sales sa
JOIN stores s ON sa.store_id = s.store_id
LEFT JOIN warranty w ON w.sale_id = sa.sale_id
GROUP BY s.country
ORDER BY claims_per_100_sales DESC
LIMIT 3;

-- Q20. Products launched in the last 2 years (relative to latest sale date) and their revenue-to-date.
SELECT p.product_name, p.launch_date,
       ROUND(SUM(sa.quantity * p.price), 2) AS revenue_to_date
FROM products p
JOIN sales sa ON sa.product_id = p.product_id
WHERE p.launch_date >= (SELECT DATE_SUB(MAX(sale_date), INTERVAL 2 YEAR) FROM sales)
GROUP BY p.product_id, p.product_name, p.launch_date
ORDER BY revenue_to_date DESC;

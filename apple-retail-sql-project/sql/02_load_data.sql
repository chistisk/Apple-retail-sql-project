-- =========================================================
-- Apple Retail Sales SQL Project — Load Data
-- Run 01_schema.sql first.
--
-- NOTE: Update the file paths below to wherever you place the
-- CSVs on the machine running the MySQL server, and make sure
-- --secure-file-priv / local_infile settings allow it. If your
-- server has local_infile disabled, run:
--   SET GLOBAL local_infile = 1;
-- and connect with --local-infile=1 on the client.
-- =========================================================

USE apple_retail;

LOAD DATA LOCAL INFILE 'data/category.csv'
INTO TABLE category
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category_id, launch_date, price);

LOAD DATA LOCAL INFILE 'data/sales.csv'
INTO TABLE sales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(sale_id, sale_date, store_id, product_id, quantity);

LOAD DATA LOCAL INFILE 'data/warranty.csv'
INTO TABLE warranty
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(claim_id, claim_date, sale_id, repair_status);

-- Quick sanity checks
SELECT 'category' AS tbl, COUNT(*) AS rows FROM category
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'sales', COUNT(*) FROM sales
UNION ALL SELECT 'warranty', COUNT(*) FROM warranty;

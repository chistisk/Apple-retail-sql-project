-- =========================================================
-- Apple Retail Sales SQL Project — Schema
-- Engine: MySQL 8+
-- =========================================================

DROP DATABASE IF EXISTS apple_retail;
CREATE DATABASE apple_retail;
USE apple_retail;

CREATE TABLE category (
    category_id     INT PRIMARY KEY,
    category_name   VARCHAR(50) NOT NULL
);

CREATE TABLE stores (
    store_id        INT PRIMARY KEY,
    store_name      VARCHAR(100) NOT NULL,
    city            VARCHAR(100) NOT NULL,
    country         VARCHAR(100) NOT NULL
);

CREATE TABLE products (
    product_id      INT PRIMARY KEY,
    product_name    VARCHAR(100) NOT NULL,
    category_id     INT,
    launch_date     DATE,
    price           DECIMAL(10,2),
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE sales (
    sale_id         INT PRIMARY KEY,
    sale_date       DATE NOT NULL,
    store_id        INT,
    product_id      INT,
    quantity        INT,
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE warranty (
    claim_id        INT PRIMARY KEY,
    claim_date      DATE NOT NULL,
    sale_id         INT,
    repair_status   VARCHAR(30),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id)
);

-- Helpful indexes for the analytical queries in 03_business_problems.sql
CREATE INDEX idx_sales_date ON sales(sale_date);
CREATE INDEX idx_sales_store ON sales(store_id);
CREATE INDEX idx_sales_product ON sales(product_id);
CREATE INDEX idx_warranty_sale ON warranty(sale_id);
CREATE INDEX idx_warranty_date ON warranty(claim_date);

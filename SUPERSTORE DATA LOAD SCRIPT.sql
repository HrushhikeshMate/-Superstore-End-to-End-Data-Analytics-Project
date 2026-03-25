-- SUPERSTORE DATA LOAD SCRIPT

-- STEP 1: Create a staging table (flat, mirrors the CSV exactly)

DROP TABLE IF EXISTS staging_superstore;

CREATE TABLE staging_superstore (
    order_id      VARCHAR(20),
    order_date    VARCHAR(20),
    ship_date     VARCHAR(20),
    ship_mode     VARCHAR(50),
    customer_id   VARCHAR(20),
    customer_name VARCHAR(150),
    segment       VARCHAR(50),
    country       VARCHAR(100),
    city          VARCHAR(100),
    state         VARCHAR(100),
    postal_code   VARCHAR(10),
    region        VARCHAR(50),
    product_id    VARCHAR(30),
    category      VARCHAR(50),
    sub_category  VARCHAR(50),
    product_name  VARCHAR(300),
    sales         NUMERIC(12,4),
    quantity      INTEGER,
    discount      NUMERIC(5,4),
    profit        NUMERIC(12,4),
    days_to_ship  INTEGER,
    is_loss       VARCHAR(10),
    high_discount VARCHAR(10)
);

-- STEP 2: Load CSV into staging table


COPY staging_superstore 
FROM 'C:/Users/HRUSHI/Desktop/PROJECTS/Sample_Superstore_Cleaned.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');


-- STEP 3: Validate staging data before loading

SELECT COUNT(*) AS staging_rows FROM staging_superstore;

-- Null checks on critical columns
SELECT
    SUM(CASE WHEN order_id     IS NULL THEN 1 ELSE 0 END) AS null_order_id,
    SUM(CASE WHEN customer_id  IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
    SUM(CASE WHEN product_id   IS NULL THEN 1 ELSE 0 END) AS null_product_id,
    SUM(CASE WHEN sales        IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN profit       IS NULL THEN 1 ELSE 0 END) AS null_profit
FROM staging_superstore;

-- Date format check
SELECT order_date, ship_date
FROM staging_superstore
WHERE order_date !~ '^\d{4}-\d{2}-\d{2}$'
   OR (ship_date IS NOT NULL AND ship_date !~ '^\d{4}-\d{2}-\d{2}$')
LIMIT 10;


-- STEP 4: Load dimension tables (de-duplicate from staging)
-- 4a. Geography
INSERT INTO geography (postal_code, city, state, region, country)
SELECT DISTINCT
    postal_code,
    city,
    state,
    region,
    country
FROM staging_superstore
ON CONFLICT (postal_code, city, state) DO NOTHING;

select * from geography;

-- 4b. Customers
INSERT INTO customers (customer_id, customer_name, segment)
SELECT DISTINCT ON (customer_id)
    customer_id,
    customer_name,
    segment
FROM staging_superstore
ORDER BY customer_id
ON CONFLICT (customer_id) DO NOTHING;

-- 4c. Products
INSERT INTO products (product_id, product_name, category, sub_category)
SELECT DISTINCT ON (product_id)
    product_id,
    product_name,
    category,
    sub_category
FROM staging_superstore
ORDER BY product_id
ON CONFLICT (product_id) DO NOTHING;


-- STEP 5: Load orders (fact header)

INSERT INTO orders (order_id, order_date, ship_date, ship_mode, customer_id, geo_id)
SELECT DISTINCT ON (s.order_id)
    s.order_id,
    s.order_date::DATE,
    NULLIF(s.ship_date, '')::DATE,
    s.ship_mode,
    s.customer_id,
    g.geo_id
FROM staging_superstore s
JOIN geography g
    ON  g.postal_code = s.postal_code
    AND g.city        = s.city
    AND g.state       = s.state
ORDER BY s.order_id
ON CONFLICT (order_id) DO NOTHING;

-- STEP 6: Load order_items (fact detail)

INSERT INTO order_items (order_id, product_id, sales, quantity, discount,
                         profit, days_to_ship, is_loss, high_discount)
SELECT
    s.order_id,
    s.product_id,
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.days_to_ship,
    (LOWER(s.is_loss)      = 'true')::BOOLEAN,
    (LOWER(s.high_discount) = 'true')::BOOLEAN
FROM staging_superstore s;

---- STEP 7: Post-load validation checks

-- Row counts per table
SELECT 'geography'   AS tbl, COUNT(*) FROM geography   UNION ALL
SELECT 'customers',           COUNT(*) FROM customers   UNION ALL
SELECT 'products',            COUNT(*) FROM products    UNION ALL
SELECT 'orders',              COUNT(*) FROM orders      UNION ALL
SELECT 'order_items',         COUNT(*) FROM order_items;

-- Sales/profit totals should match staging
SELECT
    ROUND(SUM(sales)::NUMERIC,  2) AS total_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS total_profit
FROM order_items;

SELECT
    ROUND(SUM(sales)::NUMERIC,  2) AS staging_sales,
    ROUND(SUM(profit)::NUMERIC, 2) AS staging_profit
FROM staging_superstore;


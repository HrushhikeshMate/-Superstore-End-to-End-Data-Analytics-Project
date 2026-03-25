--SUPERSTORE DATABASE SCHEMA

-- DROP TABLE if rebuilding
drop table if exists order_items cascade;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS geography CASCADE;

-- 1. GEOGRAPHY (Dimensions)

create table geography (
	geo_id 		serial 	primary key,
	postal_code VARCHAR(10)  not null,
	city 		VARCHAR(100) not null,
	state        VARCHAR(100) NOT NULL,
    region        VARCHAR(50)  NOT NULL,
    country       VARCHAR(100) NOT NULL DEFAULT 'United States',
    UNIQUE (postal_code, city, state)
);

-- 2. CUSTOMERS (Dimension)
CREATE TABLE customers (
    customer_id   VARCHAR(20)  PRIMARY KEY,   
    customer_name VARCHAR(150) NOT NULL,
    segment       VARCHAR(50)  NOT NULL        -- Consumer / Corporate / Home Office
);

-- 3. PRODUCTS (Dimension)
CREATE TABLE products (
    product_id    VARCHAR(30)  PRIMARY KEY,   
    product_name  VARCHAR(300) NOT NULL,
    category      VARCHAR(50)  NOT NULL,
    sub_category  VARCHAR(50)  NOT NULL
);


-- 4. ORDERS (Fact header)

CREATE TABLE orders (
    order_id      VARCHAR(20)  PRIMARY KEY,   
    order_date    DATE         NOT NULL,
    ship_date     DATE,
    ship_mode     VARCHAR(50),
    customer_id   VARCHAR(20)  NOT NULL REFERENCES customers(customer_id),
    geo_id        INTEGER      NOT NULL REFERENCES geography(geo_id)
);

-- 5. ORDER_ITEMS (Fact detail — one row per order+product)

CREATE TABLE order_items (
    item_id       SERIAL       PRIMARY KEY,
    order_id      VARCHAR(20)  NOT NULL REFERENCES orders(order_id),
    product_id    VARCHAR(30)  NOT NULL REFERENCES products(product_id),
    sales         NUMERIC(12,4) NOT NULL,
    quantity      INTEGER       NOT NULL,
    discount      NUMERIC(5,4)  NOT NULL DEFAULT 0,
    profit        NUMERIC(12,4) NOT NULL,
    days_to_ship  INTEGER,
    is_loss       BOOLEAN       NOT NULL DEFAULT FALSE,
    high_discount BOOLEAN       NOT NULL DEFAULT FALSE
);


-- INDEXES (Performance)

-- Orders: filter by date range (most common)
CREATE INDEX idx_orders_order_date   ON orders(order_date);
CREATE INDEX idx_orders_customer_id  ON orders(customer_id);
CREATE INDEX idx_orders_geo_id       ON orders(geo_id);

-- Order items: joins and aggregations
CREATE INDEX idx_items_order_id      ON order_items(order_id);
CREATE INDEX idx_items_product_id    ON order_items(product_id);
CREATE INDEX idx_items_is_loss       ON order_items(is_loss);
CREATE INDEX idx_items_high_discount ON order_items(high_discount);

-- Products: category filtering
CREATE INDEX idx_products_category   ON products(category);
CREATE INDEX idx_products_sub_cat    ON products(sub_category);

-- Geography: region/state filtering
CREATE INDEX idx_geo_region          ON geography(region);
CREATE INDEX idx_geo_state           ON geography(state);

-- Composite: order date + region for time-series by region
CREATE INDEX idx_orders_date_geo     ON orders(order_date, geo_id);

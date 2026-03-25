-- SUPERSTORE ANALYTICS QUERIES

-- SECTION 1: SALES PERFORMANCE
-- 1.1 Total Sales, Profit, Orders, and Profit Margin by Year
SELECT
    EXTRACT(YEAR FROM o.order_date)      AS year,
    COUNT(DISTINCT o.order_id)            AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS profit_margin_pct
FROM orders o
JOIN order_items oi USING (order_id)
GROUP BY 1
ORDER BY 1;

-- 1.2 Monthly Sales Trend (all years)
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')      AS month,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS monthly_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS monthly_profit
FROM orders o
JOIN order_items oi USING (order_id)
GROUP BY 1
ORDER BY 1;

-- 1.3 Sales by Region
SELECT
    g.region,
    COUNT(DISTINCT o.order_id)            AS orders,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS margin_pct
FROM orders o
JOIN order_items oi USING (order_id)
JOIN geography g ON o.geo_id = g.geo_id
GROUP BY 1
ORDER BY total_sales DESC;

-- 1.4 Sales by Customer Segment
SELECT
    c.segment,
    COUNT(DISTINCT o.order_id)            AS orders,
    COUNT(DISTINCT o.customer_id)         AS unique_customers,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND(AVG(oi.sales)::NUMERIC,  2)     AS avg_order_value
FROM orders o
JOIN order_items oi USING (order_id)
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY total_sales DESC;


-- SECTION 2: PRODUCT ANALYTICS

-- 2.1 Sales and Profit by Category and Sub-Category
SELECT
    p.category,
    p.sub_category,
    COUNT(DISTINCT o.order_id)            AS orders,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales), 0) * 100)::NUMERIC, 2) AS margin_pct
FROM order_items oi
JOIN orders o USING (order_id)
JOIN products p ON oi.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, total_sales DESC;

-- 2.2 Top 10 Most Profitable Products
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    SUM(oi.quantity)                      AS units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
ORDER BY total_profit DESC
LIMIT 10;

-- 2.3 Top 10 Loss-Making Products
SELECT
    p.product_name,
    p.category,
    p.sub_category,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    COUNT(*) FILTER (WHERE oi.is_loss)    AS loss_transactions
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category, p.sub_category
ORDER BY total_profit ASC
LIMIT 10;

-- 2.4 Impact of Discounting on Profit
SELECT
    CASE
        WHEN oi.discount = 0           THEN '0% (No Discount)'
        WHEN oi.discount <= 0.10       THEN '1-10%'
        WHEN oi.discount <= 0.20       THEN '11-20%'
        WHEN oi.discount <= 0.30       THEN '21-30%'
        WHEN oi.discount <= 0.50       THEN '31-50%'
        ELSE '50%+'
    END AS discount_band,
    COUNT(*)                               AS transactions,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    ROUND(AVG(oi.profit)::NUMERIC, 2)     AS avg_profit_per_item,
    ROUND((SUM(oi.profit) / NULLIF(SUM(oi.sales),0) * 100)::NUMERIC, 2) AS margin_pct
FROM order_items oi
GROUP BY 1
ORDER BY 1;

-- SECTION 3: CUSTOMER ANALYTICS

-- 3.1 Top 20 Customers by Revenue
SELECT
    c.customer_id,
    c.customer_name,
    c.segment,
    COUNT(DISTINCT o.order_id)            AS total_orders,
    ROUND(SUM(oi.sales)::NUMERIC,  2)     AS total_revenue,
    ROUND(SUM(oi.profit)::NUMERIC, 2)     AS total_profit,
    MIN(o.order_date)                     AS first_order,
    MAX(o.order_date)                     AS last_order
FROM orders o
JOIN order_items oi USING (order_id)
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name, c.segment
ORDER BY total_revenue DESC
LIMIT 20;

-- 3.2 Customer Repeat Purchase Rate
SELECT
    order_count_bucket,
    COUNT(*) AS customers,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_customers
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS order_count,
        CASE
            WHEN COUNT(DISTINCT order_id) = 1 THEN '1 order'
            WHEN COUNT(DISTINCT order_id) BETWEEN 2 AND 4 THEN '2-4 orders'
            WHEN COUNT(DISTINCT order_id) BETWEEN 5 AND 9 THEN '5-9 orders'
            ELSE '10+ orders'
        END AS order_count_bucket
    FROM orders
    GROUP BY customer_id
) sub
GROUP BY order_count_bucket
ORDER BY MIN(order_count_bucket);

-- 3.3 RFM (Recency, Frequency, Monetary) Summary

WITH rfm_base AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)                         AS last_order_date,
        COUNT(DISTINCT o.order_id)                AS frequency,
        ROUND(SUM(oi.sales)::NUMERIC, 2)          AS monetary
    FROM orders o
    JOIN order_items oi USING (order_id)
    GROUP BY o.customer_id
),
max_date AS (SELECT MAX(last_order_date) AS latest FROM rfm_base)
SELECT
    r.customer_id,
    c.customer_name,
    c.segment,
    (SELECT latest FROM max_date) - r.last_order_date AS days_since_last_order,
    r.frequency,
    r.monetary,
    NTILE(4) OVER (ORDER BY (SELECT latest FROM max_date) - r.last_order_date ASC)  AS recency_score,
    NTILE(4) OVER (ORDER BY r.frequency   DESC)  AS frequency_score,
    NTILE(4) OVER (ORDER BY r.monetary    DESC)  AS monetary_score
FROM rfm_base r
JOIN customers c ON r.customer_id = c.customer_id
ORDER BY monetary DESC;


-- SECTION 4: SHIPPING & OPERATIONS

-- 4.1 Average Days to Ship by Ship Mode
SELECT
    o.ship_mode,
    COUNT(*)                              AS shipments,
    ROUND(AVG(oi.days_to_ship)::NUMERIC, 2) AS avg_days_to_ship,
    MIN(oi.days_to_ship)                  AS min_days,
    MAX(oi.days_to_ship)                  AS max_days
FROM orders o
JOIN order_items oi USING (order_id)
WHERE oi.days_to_ship IS NOT NULL
GROUP BY 1
ORDER BY avg_days_to_ship;

-- 4.2 Shipping Performance by Region
SELECT
    g.region,
    o.ship_mode,
    ROUND(AVG(oi.days_to_ship)::NUMERIC, 2) AS avg_days_to_ship,
    COUNT(*)                              AS shipments
FROM orders o
JOIN order_items oi USING (order_id)
JOIN geography g ON o.geo_id = g.geo_id
WHERE oi.days_to_ship IS NOT NULL
GROUP BY 1, 2
ORDER BY 1, avg_days_to_ship;

-- SECTION 5: GEOGRAPHIC ANALYTICS

-- 5.1 Top 10 States by Sales
SELECT
    g.state,
    g.region,
    ROUND(SUM(oi.sales)::NUMERIC,  2)    AS total_sales,
    ROUND(SUM(oi.profit)::NUMERIC, 2)    AS total_profit,
    COUNT(DISTINCT o.order_id)           AS orders
FROM orders o
JOIN order_items oi USING (order_id)
JOIN geography g ON o.geo_id = g.geo_id
GROUP BY g.state, g.region
ORDER BY total_sales DESC
LIMIT 10;

-- 5.2 Bottom 10 States by Profit (loss hotspots)
SELECT
    g.state,
    g.region,
    ROUND(SUM(oi.profit)::NUMERIC, 2)    AS total_profit,
    COUNT(*) FILTER (WHERE oi.is_loss)   AS loss_transactions
FROM orders o
JOIN order_items oi USING (order_id)
JOIN geography g ON o.geo_id = g.geo_id
GROUP BY g.state, g.region
ORDER BY total_profit ASC
LIMIT 10;


-- SECTION 6: WINDOW FUNCTIONS & ADVANCED ANALYTICS

-- 6.1 Running total of sales by month (YTD)
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')  AS month,
    ROUND(SUM(oi.sales)::NUMERIC, 2)  AS monthly_sales,
    ROUND(SUM(SUM(oi.sales)) OVER (
        PARTITION BY EXTRACT(YEAR FROM o.order_date)
        ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')
    )::NUMERIC, 2)                    AS ytd_sales
FROM orders o
JOIN order_items oi USING (order_id)
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM'), EXTRACT(YEAR FROM o.order_date)
ORDER BY month;

-- 6.2 Month-over-Month sales growth %
WITH monthly AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM')    AS month,
        ROUND(SUM(oi.sales)::NUMERIC, 2)    AS monthly_sales
    FROM orders o
    JOIN order_items oi USING (order_id)
    GROUP BY 1
)
SELECT
    month,
    monthly_sales,
    LAG(monthly_sales) OVER (ORDER BY month)  AS prev_month_sales,
    ROUND(
        (monthly_sales - LAG(monthly_sales) OVER (ORDER BY month))
        / NULLIF(LAG(monthly_sales) OVER (ORDER BY month), 0) * 100
    , 2) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- 6.3 Rank products within each category by profit
SELECT
    p.category,
    p.sub_category,
    p.product_name,
    ROUND(SUM(oi.profit)::NUMERIC, 2)  AS total_profit,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY SUM(oi.profit) DESC
    ) AS rank_in_category
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category, p.sub_category, p.product_id, p.product_name
ORDER BY p.category, rank_in_category;
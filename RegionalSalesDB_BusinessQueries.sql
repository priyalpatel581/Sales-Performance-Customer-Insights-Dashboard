-- 1. Monthly & Quarterly Sales Trends
-- Monthly Sales Trends
SELECT 
    YEAR(occurred_at) AS sales_year,       
    MONTH(occurred_at) AS sales_month,     
    SUM(total_amt_usd) AS total_revenue    
FROM orders
GROUP BY YEAR(occurred_at), MONTH(occurred_at)
ORDER BY sales_year;

-- Quarterly Sales Trends
SELECT 
    YEAR(occurred_at) AS sales_year,        -- Example: 2024
    QUARTER(occurred_at) AS sales_quarter,  -- Example: 1 = Jan–Mar
    SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY YEAR(occurred_at), QUARTER(occurred_at)
ORDER BY sales_year, sales_quarter;

-- 2. Which Regions Generate the Highest Revenue?
CREATE VIEW revenue_by_region AS
SELECT 
    r.name AS region,
    SUM(o.total_amt_usd) AS total_revenue
FROM orders o
JOIN accounts a ON o.account_id = a.id
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
GROUP BY r.name 
ORDER BY total_revenue DESC;

SELECT * FROM revenue_by_region;


-- 3. Who are the top-performing sales reps?
SELECT 
    s.name AS sales_rep,
    r.name AS region,
    SUM(o.total_amt_usd) AS revenue
FROM orders o
JOIN accounts a ON o.account_id = a.id
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
GROUP BY s.id, s.name, r.name
ORDER BY revenue DESC;

-- 4. Who are the top 10 customers by revenue?
WITH ranked_customers AS (
    SELECT 
        a.name AS customer,
        SUM(o.total_amt_usd) AS revenue,
        RANK() OVER (ORDER BY SUM(o.total_amt_usd) DESC) AS customer_rank
    FROM orders o
    JOIN accounts a ON o.account_id = a.id
    GROUP BY a.id, a.name
)
SELECT customer, revenue
FROM ranked_customers
WHERE customer_rank <= 10;

-- 5. What is the Average Order Value (AOV) and Customer Lifetime Value (CLV)?
-- AOV
SELECT 
    (SUM(total_amt_usd) / COUNT(*)) AS avg_order_value
FROM orders;

-- CLV per customer
SELECT 
    a.name AS customer,
    (SUM(o.total_amt_usd) / COUNT(o.id)) * COUNT(o.id) AS clv
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.id, a.name;

-- 6. How does web engagement impact actual sales?
SELECT 
    w.channel_name,                                
    COUNT(DISTINCT w.account_id) AS engaged_customers,  -- Customers with web events
    COUNT(DISTINCT o.account_id) AS customers_with_orders, -- Customers who later ordered
    ROUND(
        (COUNT(DISTINCT o.account_id) * 100.0 / COUNT(DISTINCT w.account_id)), 2
    ) AS conversion_rate_percent                   -- Conversion % (Orders ÷ Web Events)
FROM web_events w
LEFT JOIN orders o 
    ON w.account_id = o.account_id
GROUP BY w.channel_name
ORDER BY conversion_rate_percent DESC;

-- 7. Are there seasonal patterns or risks in revenue?
SELECT 
    MONTHNAME(occurred_at) AS month_name,    
    SUM(total_amt_usd) AS total_revenue
FROM orders
GROUP BY MONTH(occurred_at), MONTHNAME(occurred_at)
ORDER BY MONTH(occurred_at);

-- 8. Which customers are at risk of churn?
WITH last_orders AS (
    SELECT 
        a.id AS customer_id,
        a.name AS customer_name,
        MAX(o.occurred_at) AS last_order_date
    FROM accounts a
    LEFT JOIN orders o ON a.id = o.account_id
    GROUP BY a.id, a.name
)
SELECT 
    customer_id,
    customer_name,
    last_order_date,
    CASE 
        WHEN last_order_date IS NULL THEN 'No Orders Ever'
        WHEN last_order_date < DATE_SUB(CURDATE(), INTERVAL 6 MONTH) THEN 'Inactive > 6 Months'
        ELSE 'Active'
    END AS churn_status
FROM last_orders
ORDER BY churn_status;






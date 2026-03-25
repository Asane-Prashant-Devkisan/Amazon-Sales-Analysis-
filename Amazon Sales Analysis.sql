CREATE DATABASE customer_behavior;
use customer_behavior;
select * from amazon_sales;

select count(order_id) from amazon_sales;

-- Basic Queries 

-- 1. VIEW FIRST 10 ROWS OF THE TABLE
SELECT * FROM amazon_sales 
LIMIT 10;

-- 2. COUNT TOTAL NUMBER OF ORDERS
SELECT COUNT(Order_ID) AS total_orders 
FROM amazon_sales;

-- 3. GET ALL UNIQUE ORDER STATUSES
SELECT DISTINCT Status 
FROM amazon_sales;

-- 4. TOTAL REVENUE FROM ALL ORDERS
SELECT ROUND(SUM(Amount), 2) AS total_revenue 
FROM amazon_sales;

-- 5. COUNT ORDERS PER STATUS
SELECT Status, COUNT(Order_ID) AS order_count 
FROM amazon_sales 
GROUP BY Status;

-- 6. ALL ORDERS FROM A SPECIFIC STATE (e.g. Maharashtra)
SELECT Order_ID, Order_Date, Category, Amount, Status 
FROM amazon_sales 
WHERE Ship_State = 'Maharashtra';

-- 7. ORDERS SORTED BY AMOUNT (HIGHEST FIRST)
SELECT Order_ID, Category, Amount, Status 
FROM amazon_sales 
ORDER BY Amount DESC 
LIMIT 10;

-- 8. COUNT OF ORDERS BY CATEGORY
SELECT Category, COUNT(Order_ID) AS total_orders 
FROM amazon_sales 
GROUP BY Category 
ORDER BY total_orders DESC;

-- 9. AVERAGE ORDER VALUE
SELECT ROUND(AVG(Amount), 2) AS avg_order_value 
FROM amazon_sales;

-- 10. FIND ALL CANCELLED ORDERS
SELECT Order_ID, Order_Date, Category, Amount, Ship_State 
FROM amazon_sales 
WHERE Status = 'Cancelled';

-- Advanced Queries

-- 1. TOTAL REVENUE, ORDERS & AVG ORDER VALUE BY YEAR & QUARTER
SELECT 
    Year, Quarter,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_order_value
FROM amazon_sales
WHERE Status != 'Cancelled'
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

-- 2. TOP 10 BEST-SELLING CATEGORIES BY REVENUE
SELECT 
    Category,
    COUNT(Order_ID) AS total_orders,
    SUM(Qty) AS total_units_sold,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_price
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY Category
ORDER BY total_revenue DESC
LIMIT 10;


-- 3. ORDER STATUS BREAKDOWN (FULFILLMENT RATE)
SELECT 
    Status,
    COUNT(Order_ID) AS order_count,
    ROUND(COUNT(Order_ID) * 100.0 / SUM(COUNT(Order_ID)) OVER (), 2) AS percentage
FROM amazon_sales
GROUP BY Status
ORDER BY order_count DESC;

-- 4. REVENUE BY STATE (TOP 15 STATES)
SELECT 
    Ship_State,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_order_value
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY Ship_State
ORDER BY total_revenue DESC
LIMIT 15;

-- 5. MONTHLY SALES TREND (REVENUE & ORDERS OVER TIME)
SELECT 
    Year,
    Month_Num,
    Month,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS monthly_revenue,
    ROUND(SUM(Amount) - LAG(SUM(Amount)) OVER (ORDER BY Year, Month_Num), 2) AS revenue_change
FROM amazon_sales
WHERE Status != 'Cancelled'
GROUP BY Year, Month_Num, Month
ORDER BY Year, Month_Num;

-- 6. B2B vs B2C COMPARISON
SELECT 
    CASE WHEN B2B = 1 THEN 'B2B' ELSE 'B2C' END AS customer_type,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_order_value,
    ROUND(SUM(Amount) * 100.0 / SUM(SUM(Amount)) OVER (), 2) AS revenue_share_pct
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY B2B;

-- 7. PROMOTION IMPACT ON SALES
SELECT 
    CASE WHEN Is_Promotion = 1 THEN 'Promoted' ELSE 'Non-Promoted' END AS promotion_type,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_order_value,
    ROUND(AVG(Qty), 2) AS avg_qty_per_order
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY Is_Promotion;

-- 8. SHIPPING SERVICE LEVEL vs CANCELLATION RATE
SELECT 
    Ship_Service_Level,
    COUNT(Order_ID) AS total_orders,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) AS returned,
    ROUND(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(Order_ID), 2) AS cancellation_rate_pct
FROM amazon_sales
GROUP BY Ship_Service_Level
ORDER BY total_orders DESC;

-- 9. TOP 10 PRODUCTS (SKU) BY UNITS SOLD
SELECT 
    SKU,
    Category,
    Style,
    Size,
    SUM(Qty) AS total_units_sold,
    COUNT(DISTINCT Order_ID) AS distinct_orders,
    ROUND(SUM(Amount), 2) AS total_revenue
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY SKU, Category, Style, Size
ORDER BY total_units_sold DESC
LIMIT 10;

-- 10. WEEKEND vs WEEKDAY SALES PERFORMANCE
SELECT 
    CASE WHEN Is_Weekend = 'True' THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    Day_of_Week,
    COUNT(Order_ID) AS total_orders,
    ROUND(SUM(Amount), 2) AS total_revenue,
    ROUND(AVG(Amount), 2) AS avg_order_value
FROM amazon_sales
WHERE Status = 'Shipped'
GROUP BY Is_Weekend, Day_of_Week
ORDER BY 
    CASE WHEN Is_Weekend = 'True' THEN 1 ELSE 0 END,
    FIELD(Day_of_Week, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');


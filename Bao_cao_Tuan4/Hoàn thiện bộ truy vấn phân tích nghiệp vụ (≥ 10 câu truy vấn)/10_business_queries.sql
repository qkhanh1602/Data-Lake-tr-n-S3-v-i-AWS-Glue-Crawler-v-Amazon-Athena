-- ====================================================================
-- BỘ 10 TRUY VẤN PHÂN TÍCH KINH DOANH TRÊN DATA LAKE (AMAZON ATHENA)
-- Database: daily_datalake_db | Table: sales_parquet
-- ====================================================================

-- 1. Tổng quan quy mô: Tổng doanh thu, tổng lượng hàng bán và tổng số đơn hàng
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(quantity) AS total_items_sold,
    SUM(quantity * unit_price) AS total_revenue_vnd
FROM sales_parquet;

-- 2. Phân tích doanh thu và sản lượng bán theo từng ngày (Partition Analysis)
SELECT 
    year, month, day,
    COUNT(order_id) AS daily_orders,
    SUM(quantity) AS daily_items_sold,
    SUM(quantity * unit_price) AS daily_revenue_vnd
FROM sales_parquet
GROUP BY year, month, day
ORDER BY year, month, day;

-- 3. Top 5 sản phẩm mang lại doanh thu cao nhất toàn hệ thống
SELECT 
    product,
    category,
    SUM(quantity) AS total_quantity_sold,
    SUM(quantity * unit_price) AS total_product_revenue
FROM sales_parquet
GROUP BY product, category
ORDER BY total_product_revenue DESC
LIMIT 5;

-- 4. Top sản phẩm bán chạy nhất theo số lượng (Volume Leader)
SELECT 
    product,
    category,
    SUM(quantity) AS units_sold
FROM sales_parquet
GROUP BY product, category
ORDER BY units_sold DESC
LIMIT 5;

-- 5. Cơ cấu và tỷ trọng doanh thu theo từng danh mục hàng hóa (Category Breakdown)
SELECT 
    category,
    COUNT(order_id) AS total_orders,
    SUM(quantity * unit_price) AS category_revenue,
    ROUND(100.0 * SUM(quantity * unit_price) / (SELECT SUM(quantity * unit_price) FROM sales_parquet), 2) AS revenue_percentage
FROM sales_parquet
GROUP BY category
ORDER BY category_revenue DESC;

-- 6. Phân tích thị trường: Xếp hạng doanh thu và số đơn hàng theo từng thành phố
SELECT 
    customer_city,
    COUNT(order_id) AS orders_count,
    SUM(quantity) AS items_purchased,
    SUM(quantity * unit_price) AS city_revenue
FROM sales_parquet
GROUP BY customer_city
ORDER BY city_revenue DESC;

-- 7. Giá trị đơn hàng trung bình (AOV - Average Order Value)
SELECT 
    ROUND(AVG(quantity * unit_price), 2) AS average_order_value_vnd,
    MIN(quantity * unit_price) AS min_order_value_vnd,
    MAX(quantity * unit_price) AS max_order_value_vnd
FROM sales_parquet;

-- 8. Lọc danh sách các đơn hàng có giá trị cao (High-value Orders >= 500,000 VND)
SELECT 
    order_id,
    order_time,
    customer_city,
    product,
    quantity,
    unit_price,
    (quantity * unit_price) AS order_total_vnd
FROM sales_parquet
WHERE (quantity * unit_price) >= 500000
ORDER BY order_total_vnd DESC;

-- 9. Thống kê sản phẩm chủ lực và doanh thu bình quân trên mỗi đơn hàng theo danh mục
SELECT 
    category,
    COUNT(order_id) AS total_orders,
    ROUND(AVG(unit_price), 2) AS avg_item_price,
    ROUND(AVG(quantity * unit_price), 2) AS avg_revenue_per_order
FROM sales_parquet
GROUP BY category
ORDER BY total_orders DESC;

-- 10. Phân tích ma trận chéo: Danh mục sản phẩm bán chạy nhất tại từng thành phố
SELECT 
    customer_city,
    category,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unit_price) AS total_spent
FROM sales_parquet
GROUP BY customer_city, category
ORDER BY customer_city, total_spent DESC;
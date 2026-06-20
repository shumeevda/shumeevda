-- Проверка объема данных
SELECT 'purchases' AS table_name, COUNT(*) FROM purchases
UNION ALL
SELECT 'events', COUNT(*) FROM events
UNION ALL
SELECT 'venues', COUNT(*) FROM venues
UNION ALL
SELECT 'city', COUNT(*) FROM city
UNION ALL
SELECT 'regions', COUNT(*) FROM regions;
-- Проверка уникальности идентификаторов

SELECT 
COUNT(order_id) AS total_orders,
COUNT(DISTINCT order_id) AS unique_orders
FROM purchases;
SELECT 
COUNT(event_id),
COUNT(DISTINCT event_id)
FROM events;

-- Проверка пропущенных значений
SELECT
COUNT(*) FILTER (WHERE revenue IS NULL) AS missing_revenue,
COUNT(*) FILTER (WHERE total IS NULL) AS missing_total,
COUNT(*) FILTER (WHERE device_type_canonical IS NULL) AS missing_device
FROM purchases;
-- Проверка категориальных данных
SELECT device_type_canonical, COUNT(*)
FROM purchases
GROUP BY device_type_canonical
ORDER BY COUNT(*) DESC;

-- Ответы на вопросы:

-- 1. 
SELECT COUNT(order_id),
       COUNT(DISTINCT order_id)
FROM purchases;
-- 2.
SELECT 
COUNT(*) AS orders,
COUNT(DISTINCT user_id) AS users
FROM purchases;
-- 3.
SELECT age_limit, COUNT(*)
FROM purchases
GROUP BY age_limit
ORDER BY COUNT(*) DESC;
-- 4.
SELECT COUNT(*) FILTER (WHERE tickets_count IS NULL)
FROM purchases;
-- 5.
SELECT e.event_type_main, COUNT(*)
FROM purchases p
JOIN events e USING(event_id)
GROUP BY e.event_type_main
ORDER BY COUNT(*) DESC;
-- 6.
SELECT device_type_canonical, COUNT(*)
FROM purchases
GROUP BY device_type_canonical
ORDER BY COUNT(*) DESC;
-- 7.
SELECT MIN(created_dt_msk),
       MAX(created_dt_msk)
FROM purchases;
-- 8.
SELECT DISTINCT currency_code
FROM purchases;
-- 9.
SELECT
currency_code,
MIN(revenue)  AS min_rev,
MAX(revenue)  AS max_rev,
AVG(revenue)  AS avg_rev,
STDDEV(revenue) AS std_rev,
COUNT(*) FILTER (WHERE revenue IS NULL) AS missing_rev
FROM purchases
GROUP BY currency_code;
-- 10.
SELECT DISTINCT service_name
FROM purchases
ORDER BY service_name;
-- 11.
SELECT 
service_name,
COUNT(*) AS orders_count
FROM purchases
GROUP BY service_name
ORDER BY orders_count DESC;
-- 12.
SELECT
COUNT(DISTINCT event_id),
COUNT(DISTINCT event_name_code)
FROM events;
-- 13.

SELECT COUNT(DISTINCT city_id) FROM city;
SELECT COUNT(DISTINCT region_id) FROM regions;
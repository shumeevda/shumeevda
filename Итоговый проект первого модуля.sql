--Задание №1
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH 
limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
info AS (
    SELECT
        a.id,
        c.city,
        t.type,
        a.days_exposition,
        a.last_price,
        f.total_area,
        f.rooms,
        f.balcony,
        f.floor,
        a.last_price / f.total_area AS price_m2 -- цена за м²
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON a.id = f.id
    JOIN real_estate.city c ON f.city_id = c.city_id
    JOIN real_estate.type t ON f.type_id = t.type_id
    WHERE t.type = 'город'												-- оставляем только квартиры в городах
			AND a.first_day_exposition >= DATE '2015-01-01'				-- ограничиваем анализ полными годами
			AND a.first_day_exposition < DATE '2019-01-01'
			AND a.id IN (SELECT * FROM filtered_id)
),
category AS (
    SELECT																-- категоризация объявлений по длительности
        *,
        CASE
	        WHEN days_exposition IS NULL THEN 'неизвестно'
            WHEN days_exposition <= 30 THEN 'до месяца'
            WHEN days_exposition <= 90 THEN 'до трёх месяцев'
            WHEN days_exposition <= 180 THEN 'до полугода'
            ELSE 'более полугода'
        END AS category
    FROM info
)
SELECT
	CASE
        WHEN city = 'Санкт-Петербург' THEN 'Санкт-Петербург'			-- распределяем данные по региону
        ELSE 'Ленинградская область'
    END AS region,
    category,
    COUNT(*) AS count,
    ROUND(AVG(price_m2)::numeric,2) AS avg_price_m2,
    ROUND(AVG(total_area)::numeric,2) AS avg_area,
    ROUND(AVG(rooms)::numeric,2) AS avg_rooms,
    ROUND(AVG(balcony)::numeric,2) AS avg_balconies,
    ROUND(AVG(floor)::numeric,2) AS avg_floor
FROM category
GROUP BY region, category
ORDER BY region, category;

-- Задание №2
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH 
limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Найдём id объявлений, которые не содержат выбросы:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
),
filtered AS (
	SELECT
		a.id,
		(a.first_day_exposition::date) AS begin_date,
		(a.first_day_exposition::date + (a.days_exposition * INTERVAL '1 day'))::date AS comleted_date, -- дата снятия объявления = дата публикации + длительность в днях
		a.last_price,
		f.total_area
	FROM real_estate.advertisement a
	JOIN real_estate.flats f USING (id)
	JOIN real_estate.type t ON f.type_id = t.type_id
	WHERE t.type = 'город'																-- оставляем только квартиры в городах
		AND a.first_day_exposition >= DATE '2015-01-01'									-- ограничиваем анализ полными годами
		AND a.first_day_exposition < DATE '2019-01-01'
		AND a.id IN (SELECT * FROM filtered_id)
),
begin_stats AS (
	SELECT
		EXTRACT(MONTH FROM begin_date)::int AS month, 							     	-- достаём месяц публикации
		COUNT(*) AS begin_count,													    -- сколько объявлений опубликовано в этом месяце
		AVG(last_price::numeric / total_area) AS avg_price_m2_begin,		    	    -- средняя цена за кв.м. среди опубликованных 
		AVG(total_area) AS avg_area_begin											    -- средняя площадь квартир, выставленных в этом месяце
	FROM filtered
	GROUP BY EXTRACT(MONTH FROM begin_date)::int										-- группируем по номеру месяца публикации
),
comleted_stats AS (
	SELECT
		EXTRACT(MONTH FROM comleted_date)::int AS month, 								-- достаём месяц публикации
		COUNT(*) AS comleted_count, 													-- сколько объявлений снято в этом месяце
		AVG(last_price::numeric / total_area) AS avg_price_m2_comleted, 		    	-- средняя цена за кв.м. среди снятых
		AVG(total_area) AS avg_area_comleted											-- средняя площадь квартир, снятых в этом месяце.
	FROM filtered
	GROUP BY EXTRACT(MONTH FROM comleted_date)::int									    -- группируем по номеру месяца публикации
) 
SELECT
	b.month,
	to_char(to_date(b.month::text,'MM'),'TMMonth') AS month_name, 						-- выводим название месяца
	b.begin_count, 
	ROUND(b.avg_price_m2_begin::numeric,2) AS avg_price_m2_begin,
	ROUND(b.avg_area_begin::numeric,2) AS avg_area_begin,
	c.comleted_count,
	ROUND(c.avg_price_m2_comleted::numeric,2) AS avg_price_m2_comleted,
	ROUND(c.avg_area_comleted::numeric,2) AS avg_area_comleted
FROM begin_stats b
LEFT JOIN comleted_stats c USING (month)
ORDER BY b.month;


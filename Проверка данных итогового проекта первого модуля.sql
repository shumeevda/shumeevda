WITH price_meter AS (
					SELECT 
						a.last_price / f.total_area  AS price_meter
					FROM real_estate.flats f 
					LEFT JOIN real_estate.advertisement a USING(id))
SELECT 
	MIN(price_meter),
	MAX(price_meter),
	AVG(price_meter),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY price_meter )
FROM price_meter;

SELECT 
	MIN(total_area),
	MAX(total_area),
	AVG(total_area ),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY total_area),
	percentile_cont(0.99) WITHIN GROUP (ORDER BY total_area),
	MIN(rooms),
	MAX(rooms),
	AVG(rooms),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY rooms),
	percentile_cont(0.99) WITHIN GROUP (ORDER BY rooms),
	MIN(ceiling_height),
	MAX(ceiling_height),
	AVG(ceiling_height),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY ceiling_height),
	percentile_cont(0.99) WITHIN GROUP (ORDER BY ceiling_height),
	MIN(floor),
	MAX(floor),
	AVG(floor),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY floor),
	percentile_cont(0.99) WITHIN GROUP (ORDER BY floor),
	MIN(balcony),
	MAX(balcony),
	AVG(balcony),
	percentile_cont(0.5) WITHIN GROUP (ORDER BY balcony),
	percentile_cont(0.99) WITHIN GROUP (ORDER BY balcony)
FROM real_estate.flats



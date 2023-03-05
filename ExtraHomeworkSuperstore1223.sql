--extra solo HW
--Question 1- which region saw the most returned items? for what reasons?
--tables: regions and returns
--columns region grouped return count, return reasons

SELECT reg.region, count(ret.order_id)
FROM orders as ord
JOIN regions as reg
USING(region_id)
RIGHT JOIN returns as ret
USING(order_id)
GROUP BY reg.region
;
 --below answers the second part of the question
SELECT reg.region, ret.reason_returned
FROM orders as ord
JOIN regions as reg
USING(region_id)
RIGHT JOIN returns as ret
USING(order_id)
;

--Question 2 - what product was returned most often?
-- tables, product, returns, orders

SELECT p.product_name,count(r.order_id)
FROM orders as o
JOIN returns as r
USING(order_id)
JOIN products as p
USING(product_id)
GROUP BY p.product_name
;

--Question 3 - which of the top vendors saw the most returns

SELECT Vendor_Name, count(r.order_id)
	CASE
		WHEN p.product_name ilike '%3M%' THEN '3M'
		WHEN p.product_name ilike '%Apple%' THEN 'Apple'
		WHEN p.product_name ilike '%Avery%' THEN 'Avery'
		WHEN p.product_name ilike '%Cisco%' THEN 'Cisco'
		WHEN p.product_name ilike '%Epson%' THEN 'Epson'
		WHEN p.product_name ilike '%Hewlett Packard%' or p.product_name ilike '%HP%' THEN 'HP'
		WHEN p.product_name ilike '%Logitech%' THEN 'Logitech'
		WHEN p.product_name ilike '%Panasonic%' THEN 'Panasonic'
		WHEN p.product_name ilike '%Samsung%' THEN 'Samsung'
		WHEN p.product_name ilike '%Xerox%' THEN 'Xerox'
		ELSE 'Error'
	END AS Vendor_Name
FROM orders as o
JOIN returns as r
USING(order_id)
JOIN products as p
USING(product_id)
GROUP BY Vendor_Name
;
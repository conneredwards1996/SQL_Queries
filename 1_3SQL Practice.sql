-- orders to returns

SELECT o.product_id, r.reason_returned
FROM orders as o
	right JOIN returns as r
	Using(order_id)
WHERE r.reason_returned ilike 'Not Given'
;

-- columns for output
	--number of sales
--tables needed:
	--orders in main, secondary is returns
-- any filtering required?
	--return_reason is not null
--sorting plan for output
	--rank largest to smallest (desc) by count of order_id

SELECT reg.salesperson, count(o.order_id) as sale_totals
FROM orders as o
left JOIN returns as r
USING(order_id)
left JOIN regions as reg
USING(region_id)
WHERE r.reason_returned is null
GROUP BY reg.salesperson
ORDER BY sale_totals desc
;


--returned 15 rows
-- largest value is 58734
-- it seems possible, not necessarily - total adds up to about 355k total order Ids out of I belive 990K
--tried inverting the query and using "is not null" but the numbers still don't add up to 990K

--to double check the oppositive. andverify my answer to previous problem
SELECT reg.salesperson, count(o.order_id) as sale_totals
FROM orders as o
left JOIN returns as r
USING(order_id)
JOIN regions as reg
USING(region_id)
WHERE r.reason_returned is not null
GROUP BY reg.salesperson
ORDER BY sale_totals desc
;


--all product_ids, discount per item (where shipping is in std mode)
-- Pid, discount, quantity
	--per quantity discount
	
-- output == PID discount per item(qty/discount)

SELECT product_id, round(quantity/nullif(discount,0) ,2) as discount_per_item --rounds the # to 2 digits of spec
From orders
Where ship_mode ilike 'standard class'
;

--same query with CASE

SELECT product_id, 
--round(quantity/nullif(discount,0) ,2) as discount_per_item --rounds the # to 2 digits of spec
	CASE
		WHEN discount = 0 then null
		when discount > 0 then round(quantity/discount,2)
	end as discount_per_item
From orders
Where ship_mode ilike 'standard class'
;

--coalesce

select order_id, product_id, sales,
	coalesce(postal_code:: text, region_id:: text) as postcode_coalesced
from orders;

-- all of the info we can get on customers who made orders in 2020

SELECT *
FROM orders as o
left JOIN returns as ret USING(order_id)
left JOIN regions as reg USING(region_id)
left JOIN products as prod USING(product_id)
left JOIN customers as cust USING(customer_id)
WHERE date_part('year', o.order_date) = 2020
ORDER BY o.order_date
;


-- SOLO EXERCISES JOINS AND NULLS (SUPERSTORE DATA)

--Question 1
--orders made by customers in the consumer segment
	--try connecting the keys with 'USING'
	--limit to 1000 rows

--segment comes from customer
--joined to order
--joined by customer id

SELECT ord.order_id, cust.segment, ord.order_date
FROM orders as ord
JOIN customers as cust
USING(customer_id)
WHERE cust.segment ilike 'Consumer'
ORDER BY ord.order_date
LIMIT 1000;


--Question 2

--return order id and phot frame product category

--where is that?
SELECT *
FROM orders as ord
JOIN products as prod
USING(product_id)
WHERE prod.product_name ilike '%photo frame%';
--LIMIT 1000;
--answer is 7018

--Question 3
--photo frame products not sold?
--product_id with 'photo frame' in product_name not in orders table

SELECT prod.product_id, prod.product_name, order_id, order_date
FROM  products as prod
left JOIN  orders as ord
USING(product_id)
WHERE order_id is null and prod.product_name ilike '%photo frame%'
LIMIT 1000;

--Question 4
--which unique products were sold in France?
--group by instead of distinct
--products, regions, orders

SELECT ord.product_id as unique_product, count(ord.order_id)
FROM orders as ord
JOIN products as prod
USING(product_id)
JOIN regions as reg
USING(region_id)
WHERE reg.country ilike 'France'
GROUP BY unique_product
;

--answer is 9401

--Question 5
--recycled products sold in the US? looking for product_id where country = US
--products, regions - need orders to join


SELECT ord.product_id, count(ord.order_id)
FROM orders as ord
JOIN products as prod
USING(product_id)
JOIN regions as reg
USING(region_id)

WHERE reg.country_code ilike 'US' and prod.product_name ilike '%recycled%'
GROUP BY ord.product_id
LIMIT 1000;
--answer is 403

--Question 6
--products sold in canada that are not photo frames
SELECT distinct ord.product_id -- what I'm returning
FROM orders as ord
left JOIN products as prod
USING(product_id)
left JOIN regions as reg
USING(region_id)
WHERE reg.country ilike '%canada' and prod.product_name not like '%Photo Frame%' -- have to cap Photo Frame
GROUP BY ord.product_id -- group by the type of product, in this case product id and name
;
-- I got 4632

--Question 7
--any products that were not sold?
--products and orders
--product_id does not show up in orders tab
--when products is merged to orders, order_id is null

SELECT prod.product_id, prod.product_name, order_id, order_date
FROM  products as prod
left JOIN  orders as ord
USING(product_id)
WHERE order_id is null
LIMIT 1000;
--should do this using an except

SELECT product_id from products
EXCEPT
SELECT product_id from orders;
-- returns the same one answer, in much less code and thinking


--Question 8
--orders from countries outside of sales regions? 
--ie, were there any orders with sales region of null?
--join regions to orders on region_id

SELECT region_id FROM orders
EXCEPT
SELECT region_id FROM regions;

--this answer is incorrect, because it returns 0 - the answer is one null value, as shown by the above code
SELECT ord.order_id, reg.region_id
FROM orders as ord
JOIN regions as reg
USING(region_id)
WHERE reg.region_id is null
LIMIT 1000;


--- subqueries

--insights on increase in avg monthly sales over time
--sales for every month (non-aggregated)
--month as a number, sales amount

select
from orders
group by


--group exercise

Select purchase_frequency, sum(sum_sales):: money as total_sales
From
	(select customer_id, sum(sales) as sum_sales,
		case 
			when count(distinct order_id) >= 1000 then 'Supplier'
			when count(distinct order_id) >= 100 then 'Frequent'
			else 'Other'
			end as Purchase_Frequency
	from orders
	group by customer_id) as frequency_table
group by purchase_frequency
order by 2 desc
;	



--consider customer and report

-- how many orders contained products that had a cost to consumer of over 500$
-- 


Select product_id
From orders
Where product_id in
	(SELECT product_id
	FROM products
	WHERE product_cost_to_consumer::int > 500)
;


--answer to option 2
Select product_id
From orders
Where product_id not in
	(SELECT product_id
	FROM products
	WHERE product_cost_to_consumer::int <= 500)
;

-- how many orders have more profit than the average product_cost_to_consumer?

select count(order_id) qty_over_avg_pctc
from orders
where profit >
	(select avg(product_cost_to_consumer)
	from products)
;


--practice homework

-- 1 has the sales org grown over the years?
--has the list of salespersons grown over the years
--need orders and regions
--salespersons who are attached to a sale from year 1 vs sales persons attached to a sale from year n



SELECT DISTINCT SALESPERSON
FROM ORDERS
JOIN REGIONS
USING(region_id)
WHERE SALESPERSON not in
		(SELECT DISTINCT SALESPERSON
			FROM ORDERS
			JOIN REGIONS USING(REGION_ID)
			WHERE DATE_PART('year', ORDERS.ORDER_DATE)::int = 2016)
;


select date_part('year', order_month) as year,
		avg(monthly_sales)::money as avg_monthly_sales
from (select date_trunc('month', order_date)::date as order_month,
	 avg(sales) as monthly_sales
	 from orders
	 group by 1
) as t1
group by 1

-- 2 on avg, what percent of salespeople make a sale each month?
--using orders, regions tables
--list of salespeople that made a sale, then compare percentage


--avg(count(salesperson))
--where they made a sale
--group by month

select date_part('month', order_date)::int as Order_Month, count(distinct salesperson) as number_sales_reps
from orders
left join regions
using(region_id)
where salesperson in(select distinct salesperson
	from orders
	left join regions
	using(region_id)
	where salesperson is not null
)
group by Order_Month
order by number_sales_reps desc
;


--says that on avg, every sales rep makes a sale each month


--3 what percent of all sales in the US were returned in 2020?
--orders and returns
--count returned orders - merge and reason_returned not null where year is 2020
--count of returned orders in 2020 / count of total orders in 2020

select order_id
from orders as o
join returns as ret
using(order_id)
join regions as reg
using(region_id)
where ret.reason_returned is not null and date_part('year', o.order_date) = 2020 
	and reg.country_code ilike 'US'
--189 orders were returned




select sum(bin.binary_return)::int, count(bin.binary_return)::int
from orders as ord
join (select order_id,
	case
	when order_id in(select order_id
			from orders as o
			join returns as ret
			using(order_id)
			join regions as reg
			using(region_id)
			where ret.reason_returned is not null and date_part('year', o.order_date) = 2020
	 			and reg.country_code ilike 'US')
		then 1
		Else 0
		end as binary_return
from orders) as bin
using(order_id)
join regions as reg
using(region_id)
where reg.country_code ilike 'US';

--189/210,073 for us


select product_name
from products
limit 100;

select substring(product_name, 0, (strpos(product_name, ',')))
from products limit 100;
-- use 0 as the starting position

select substring(Product_id, 0 , strpos(product_id, '-')) as cat,
	substring(product_id, 5, strpos(product_id, '-') -1) as sub_cat
from orders
limit 100;
--gives us the beggining of the product id



-- upper, length(), 
--postgres doc


-- to return
--category name in all caps, length of the new name,
--first 5 car of PID without hyphens or blank spaces


--combine sub_category and product-name
--where length under 100
--return length


SELECT upper(category), CONCAT(sub_category, product_name) as new_name, 
	length(CONCAT(sub_category, product_name)) as name_length,
	substring(translate(product_id,'-',''), 0, 6) as FivecharPID
FROM products
WHERE length(CONCAT(sub_category, product_name)) < 100
ORDER BY length(CONCAT(sub_category, product_name)) desc
LIMIT 1
;

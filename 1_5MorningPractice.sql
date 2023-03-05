-- Morning Review / Practice
-- Date Manipulation with Sales Reporting

/* Q1: What will be the difference in the results between
the following two lines of code. You can test them against the
GA superstore database. */

DATE_PART('month', order_date)::numeric 

EXTRACT(month from order_date) 


Select DATE_PART('month', order_date)::numeric 
from orders
;

select EXTRACT(month from order_date) 
from orders
;

--date_part results in a numeric field, extract results in a field type of 'double precision'


/* Q2:  If you wished to have the Month Names (like, December) 
in output where the data table only a had date stamp (timestamp or full date)
what are some options that come to mind?  */


select to_char(order_date, 'Month')
from orders
;

SELECT 
  to_char(current_timestamp, 'mon') AS "mon",
  to_char(current_timestamp, 'Mon') AS "Mon",
  to_char(current_timestamp, 'MON') AS "MON",
  to_char(current_timestamp, 'MONTH') AS "MONTH",
  to_char(current_timestamp, 'Month') AS "Month";
  
/*Q3: Write a query that returns Superstore sales 
summed AND separated by year (column 1) and month (separate column), 
showing the numeric month number (column 2) alongside the month name (column 3).
Format the summed sales as currency (column 4). 
Sort in chronological order. */
--to return: year, numeric month, month name, sum of sales as currency

SELECT to_char(order_date, 'YYYY'), to_char(order_date, 'MM'), to_char(order_date, 'Month'), sum(sales)::money as Sum_sales
FROM orders
GROUP BY to_char(order_date, 'YYYY'), to_char(order_date, 'MM'), to_char(order_date, 'Month')
;


/* Q4: Sales Management has requested a report that shows the 
Average Sales by Quarter. They've specifically requested that
the calculation of average monthly sales be used. You will need 
to create a temporary table or subquery that calculates the 
monthly averages before calculating the quarterly average.
This method creates an average less influenced by daily highs and lows.
*/
--create a subquery to determine month average sales

SELECT avg(monthly_sales)::money as Qtr_Avg,
	CASE
	WHEN Month_num in('01', '02', '03') then 'Q1'
	WHEN Month_num in('04','05', '06') then 'Q2'
	WHEN Month_num in('07','08','09') then 'Q3'
	Else 'Q4'
	End as Quarter,
	Year
FROM
	(SELECT to_char(order_date, 'MM') as Month_num, to_char(order_date, 'YYYY') as Year, avg(sales) as Monthly_sales
	FROM orders
	GROUP BY 1, 2) as monthly_avg_sales
Group by quarter, Year
order by Qtr_Avg desc
;

/* Q5: Sales Execs are now asking for a "Discrete" view of the
quarterly sales, that is a consolidation of all the years.
What do you need to change about the last query to provide 
those results? Present the output showing most to least
sales volume. */

SELECT avg(monthly_sales)::money as Qtr_Avg,
	CASE
	WHEN Month_num in('01', '02', '03') then 'Q1'
	WHEN Month_num in('04','05', '06') then 'Q2'
	WHEN Month_num in('07','08','09') then 'Q3'
	Else 'Q4'
	End as Quarter
FROM
	(SELECT to_char(order_date, 'MM') as Month_num,avg(sales) as Monthly_sales
	FROM orders
	GROUP BY to_char(order_date, 'MM')) as monthly_avg_sales
Group by quarter
order by Qtr_Avg desc
;

/* Q6: VERACITY CHALLENGE QUESTION -- What potential flaw needs to be
removed from the new report showing the Discrete Avg Sales Compilation? */


-- Write a query to adjust for the incomplete data so that all
-- quarters are weighted evenly.

SELECT avg(monthly_sales)::money as Qtr_Avg,
	CASE
	WHEN Month_num in('01', '02', '03') then 'Q1'
	WHEN Month_num in('04','05', '06') then 'Q2'
	WHEN Month_num in('07','08','09') then 'Q3'
	Else 'Q4'
	End as Quarter
FROM
	(SELECT to_char(order_date, 'MM') as Month_num, to_char(order_date, 'YYYY') as Year,avg(sales) as Monthly_sales
	FROM orders
	GROUP BY 1,2) as monthly_avg_sales
WHERE year in('2016','2017','2018','2019')
Group by quarter
order by Qtr_Avg desc
;
--Q1 $252, Q3 $246, Q4 $243, Q1 $236



/* Q6: Identify which quarter trend results in the most and least sales revenue over time.  */

--answer: Q2
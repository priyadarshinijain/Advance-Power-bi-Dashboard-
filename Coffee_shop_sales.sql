SELECT 
    *
FROM
    coffee_shop.coffee_shop_sales;
UPDATE coffee_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

alter table coffee_shop_sales
modify column transaction_date	date;

UPDATE coffee_shop_sales 
SET 
    transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

alter table coffee_shop_sales
modify column transaction_time	time;

alter table coffee_shop_sales
change column ï»¿transaction_id transaction_id int;

SELECT 
    CONCAT((ROUND(SUM(unit_price * transaction_qty))) / 1000,
            'K') AS Total_sales
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 5; 

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales,
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- month sales difference
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- division by previous month sales
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- converting it into percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
SELECT count(transaction_id) as Total_orders
FROM
    coffee_shop_sales
WHERE
    MONTH(transaction_date) = 3;

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_id )) AS total_orders,
    (count(transaction_id) - LAG(count(transaction_id), 1)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(count(transaction_id), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage 
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);
    
select sum(transaction_qty) as Total_Quantity_Sold
from coffee_shop_sales
where 
month(transaction_date)= 5;
    
SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);

select 
concat(round(sum(unit_price * transaction_qty )/1000,1), 'K') as Total_sales,
concat(round(sum( transaction_qty)/1000,1), 'K') as Total_Qty_Sold,
concat(round(count(transaction_id)/1000,1), 'K') as Total_Orders
from coffee_shop_sales
where transaction_date = "2023-05-18";

select 
case when dayofweek ( transaction_date) in (1,7) then 'weekends' 
else 'weekdays'
end as day_type,
concat(round(sum(unit_price * transaction_qty)/1000,1), 'K') as Total_sales 
from coffee_shop_sales
where month  (transaction_date) = 5 
group by 
case when dayofweek ( transaction_date) in (1,7) then 'weekends' 
else 'weekdays'
end;

select 
	store_location, 
	concat(round(SUM(unit_price * transaction_qty)/1000,1), 'K' )as Total_sales 
from coffee_shop_sales
where month(transaction_date) = 5 
group by store_location
order by SUM(unit_price * transaction_qty) desc;

select 
	concat(round(avg(total_sales)/1000,1), 'K') as Avg_sales
from 
	( 
    select sum(unit_price * transaction_qty) as total_sales 
    from coffee_shop_sales 
    where month(transaction_date)= 5
    group by transaction_date
    ) as Internal_query ;
    
select 
	day(transaction_date) as day_of_month,
    sum(unit_price * transaction_qty) as total_sales
from coffee_shop_sales
where month (transaction_date) = 5
group by day(transaction_date)
order by day(transaction_date);

SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_shop_sales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;

-- sales by product category 
select 
		product_category,
        concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_category 
order by sum(unit_price * transaction_qty) desc;

-- top 10 prodcuts by sale 
select 
		product_type,
        concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5
group by product_type 
order by sum(unit_price * transaction_qty) desc
limit 10;

-- sales analysis by days and hours 
select 
	 concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales,
    sum( transaction_qty) as Total_qty_sold,
    count(*)
from coffee_shop_sales
where month(transaction_date) = 5 -- month
and dayofweek (transaction_date) = 2 -- day
and hour(transaction_time) = 8; -- hour

select 
hour(transaction_time),
concat(round(sum(unit_price * transaction_qty)/1000,1),'K') as total_sales
from coffee_shop_sales
where month(transaction_date) = 5 
group by hour(transaction_time) 
order by hour(transaction_time);

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;

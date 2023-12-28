A. Roll Metrics 
B. Driver and Cutsomer Experience
C. Ingredient optimisation
D. Pricing nd Ratings

A. Roll Mterics
1. how many rolls were ordered?
select count(roll_id) from customer_orders;

# count(roll_id)
14

2. how many unique customer orders were made?

select count(distinct customer_id) from customer_orders;
# count(distinct customer_id)
5
 
3. how many sucessful orders were delivered by each driver?
select driver_id, count(distinct order_id) from driver_order  where cancellation not in ('Cancellation', 'Customer Cancellation')group by driver_id;

# driver_id, count(distinct order_id)
1, 3
2, 1
3, 1

4. how many of each type of roll was delivered? 
# this is a data clening step tro make data processable
select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order; 
 
 complete querry
 select roll_id, count(roll_id) from
 customer_orders where order_id in (
 select order_id from
( select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order) AS a
where order_cancel_details= 'nc')
group by roll_id;

# roll_id, count(roll_id)
1, 9
2, 3

5. how many veg and non veg rolls were orderd by each customer?
select a.*, b.roll_name from
(
select customer_id, roll_id,count(roll_id) as cnt
from customer_orders
group by customer_id, roll_id) AS a inner join rolls AS b on a.roll_id=b.roll_id;
# customer_id, roll_id, cnt, roll_name
101, 1, 2, Non Veg Roll
102, 1, 2, Non Veg Roll
103, 1, 3, Non Veg Roll
104, 1, 3, Non Veg Roll
102, 2, 1, Veg Roll
103, 2, 1, Veg Roll
101, 2, 1, Veg Roll
105, 2, 1, Veg Roll

6.what is the maximum number of rolls delivered in a single order?
# total orders that are delivered
select * from customer_orders where order_id in (
select order_id from
(select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order) AS a
where order_cancel_details= 'nc') 
complete querry-
select * from 
( 
select *, rank() over (order by cnt DESC) AS rnk from
(select order_id, count(roll_id) AS cnt from
(select * from customer_orders where order_id in (
select order_id from
(select *, case when cancellation in ('Cancellation', 'Customer Cancellation') then 'c' else 'nc' end as order_cancel_details from driver_order) AS a
where order_cancel_details= 'nc')) AS b
group by order_id)AS c) AS d where rnk=1;

# order_id, cnt, rnk
4, 3, 1

7. for each cutomer, how many deliverd rolls had at least 1 change and how many had no change?
here change means add on or toppings extra
#creating temp table to store clean data of customer table
WITH temp_customer_orders AS
(
    SELECT
        order_id,
        customer_id,
        roll_id,
        CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' ELSE not_include_items END AS new_not_include_items,
        CASE WHEN extra_items_included IS NULL OR extra_items_included = '' OR extra_items_included = 'NaN' OR extra_items_included = 'NULL' THEN '0' ELSE extra_items_included END AS extra_items_included,
        order_date
    FROM
        customer_orders
)
SELECT * FROM temp_customer_orders;

# order_id, customer_id, roll_id, new_not_include_items, extra_items_included, order_date
1, 101, 1, 0, 0, 2021-01-01 18:05:02
2, 101, 1, 0, 0, 2021-01-01 19:00:52
3, 102, 1, 0, 0, 2021-01-02 23:51:23
3, 102, 2, 0, 0, 2021-01-02 23:51:23
4, 103, 1, 4, 0, 2021-01-04 13:23:46
4, 103, 1, 4, 0, 2021-01-04 13:23:46
4, 103, 2, 4, 0, 2021-01-04 13:23:46
5, 104, 1, 0, 1, 2021-01-08 21:00:29
6, 101, 2, 0, 0, 2021-01-08 21:03:13
7, 105, 2, 0, 1, 2021-01-08 21:20:29
8, 102, 1, 0, 0, 2021-01-09 23:54:33
9, 103, 1, 4, 1,5, 2021-01-10 11:22:59
10, 104, 1, 0, 0, 2021-01-11 18:34:49
10, 104, 1, 2,6, 1,4, 2021-01-11 18:34:49


# driver table cleaning 
with temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation)as 
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then 0 else 1 end as new_cancellation
from driver_order
)
select *from temp_driver_order;
# order_id, driver_id, pickup_time, distance, duration, cancellation
1, 1, 2021-01-01 18:15:34, 20km, 32 minutes, 1
2, 1, 2021-01-01 19:10:54, 20km, 27 minutes, 1
3, 1, 2021-01-03 00:12:37, 13.4km, 20 mins, 1
4, 2, 2021-01-04 13:53:03, 23.4, 40, 1
5, 3, 2021-01-08 21:10:57, 10, 15, 1
6, 3, , , , 0
7, 2, 2020-01-08 21:30:45, 25km, 25mins, 1
8, 2, 2020-01-10 00:15:02, 23.4 km, 15 minute, 1
9, 2, , , , 0
10, 1, 2020-01-11 18:50:20, 10km, 10minutes, 1

querry answer- 
WITH temp_customer_orders AS
(
    SELECT
        order_id,
        customer_id,
        roll_id,
        CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' ELSE not_include_items END AS not_include_items,
        CASE WHEN extra_items_included IS NULL OR extra_items_included = '' OR extra_items_included = 'NaN' OR extra_items_included = 'NULL' THEN '0' ELSE extra_items_included END AS extra_items_included,
        order_date
    FROM
        customer_orders
),

 temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation)as 
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then 0 else 1 end as new_cancellation
from driver_order
)
select customer_id,chg_no_chg,count(order_id) as at_least_1_change from 
(
SELECT *, case when not_include_items='0' and extra_items_included='0' then 'no change' else 'change' end chg_no_chg 
FROM temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation!=0)) as a
group by customer_id, chg_no_chg;

# customer_id, chg_no_chg, at_least_1_change
101, no change, 2
102, no change, 3
103, change, 3
104, change, 2
105, change, 1
104, no change, 1

8. how many rolls were delivered that had bot exclusions and extras?
WITH temp_customer_orders AS
(
    SELECT
        order_id,
        customer_id,
        roll_id,
        CASE WHEN not_include_items IS NULL OR not_include_items = '' THEN '0' ELSE not_include_items END AS not_include_items,
        CASE WHEN extra_items_included IS NULL OR extra_items_included = '' OR extra_items_included = 'NaN' OR extra_items_included = 'NULL' THEN '0' ELSE extra_items_included END AS extra_items_included,
        order_date
    FROM
        customer_orders
),

 temp_driver_order(order_id, driver_id, pickup_time, distance, duration, new_cancellation)as 
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('Cancellation', 'Customer Cancellation') then 0 else 1 end as new_cancellation
from driver_order
)
select chg_no_chg, count(chg_no_chg)from 
(SELECT *, case when not_include_items!='0' and extra_items_included!='0' then 'both inc exc' else 'either 1 inc or exc' end chg_no_chg 
FROM temp_customer_orders where order_id in (
select order_id from temp_driver_order where new_cancellation!=0))AS a
group by chg_no_chg;

# chg_no_chg, count(chg_no_chg)
both inc exc, 1
either 1 inc or exc, 11

9. what is the total no of rolls ordered for each hour a day?

SELECT hours_bucket, COUNT(hours_bucket)
FROM (
    SELECT *,
           CONCAT(CAST(HOUR(order_date) AS CHAR), '-', CAST(HOUR(order_date) + 1 AS CHAR)) AS hours_bucket
    FROM customer_orders
) AS a
GROUP BY hours_bucket;


# hours_bucket, COUNT(hours_bucket)
18-19, 3
19-20, 1
23-24, 3
13-14, 3
21-22, 3
11-12, 1

10. what was the number of orders for each day of the week?
select dow, count(distinct order_id) from 
(select *, dayname(order_date) dow from customer_orders) as a
group by dow;

# dow, count(distinct order_id)
Friday, 5
Monday, 2
Saturday, 2
Sunday, 1

B. driver and cutomer experince 

1. what was the avg time in minutes it took for each driver to arrive at the fasoos HQ to pickup the order ?
# order placed time - pickup time
 select driver_id , sum(diff)/count(order_id) avg_min from 
 (select * from 
 (select *, row_number() over (partition by order_id order by diff) AS rnk from
 (select a.order_id, a.customer_id, a.roll_id, a.not_include_items, a.extra_items_included , a.order_date, b.driver_id, b.pickup_time , b.distance, b.duration, b.cancellation, TIMESTAMPDIFF(MINUTE, a.order_date, b.pickup_time) diff
 from customer_orders AS a inner join driver_order  AS b on a.order_id= b.order_id
 where b.pickup_time is not null) AS a ) AS b where rnk=1) AS c
 group by driver_id;

# driver_id, avg_min
1, -131745.7500- 14 mins
2, -351339.6667 - 20 mins
3, 10.0000


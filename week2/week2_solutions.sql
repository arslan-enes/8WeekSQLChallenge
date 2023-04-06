-- CLEANING CUSTOMER ORDERS DATA

update customer_orders co 
set extras = NULL
where extras in ('null', '')

update customer_orders co 
set exclusions  = NULL
where exclusions in ('null', '')

update runner_orders ro
set cancellation = NULL
where cancellation in ('null', '')


-- SECTION A

-- How many pizzas were ordered?

select count(*) 
from customer_orders co

-- How many unique customer orders were made?

select count(distinct customer_id)
from customer_orders co 

-- How many successful orders were delivered by each runner?
select ro.runner_id, count(*) from customer_orders co 
join runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null 
group by ro.runner_id 

-- How many of each type of pizza was delivered?

select pizza_name, "count" as "Delivery Count" 
from (	select pizza_id, count(*)  from customer_orders co 
		join runner_orders ro on ro.order_id = co.order_id
		where ro.cancellation is null 
		group by pizza_id) as grouped
join pizza_names pn on pn.pizza_id = grouped.pizza_id

-- How many Vegetarian and Meatlovers were ordered by each customer?

select customer_id, pizza_name, "count" as "order_count" 
from (
	select co.customer_id , co.pizza_id, count(*) from customer_orders co 
	join runner_orders ro on ro.order_id = co.order_id
	group by co.customer_id, co.pizza_id) as grouped  
join pizza_names pn on pn.pizza_id = grouped.pizza_id
order by customer_id

-- What was the maximum number of pizzas delivered in a single order?
select max("count") as "maximum number of pizzas delivered in a single order"
from( 	
	select co.order_id ,count(pizza_id)  from customer_orders co 
	group by co.order_id ) as X

-- For each customer, how many delivered pizzas had at least 1 change 
-- and how many had no changes?

select co.customer_id,
case 
	when co.exclusions is not null or co.extras is not null
	then 'CHANGED_PIZZA'
	else 'UNCHANGED PIZZA'
end as "PIZZA DELIVERY", count(pizza_id) 
from customer_orders co 
join runner_orders ro on ro.order_id = co.order_id
where ro.cancellation is null
group by customer_id,
case 
	when co.exclusions is not null or co.extras is not null
	then 'CHANGED_PIZZA'
	else 'UNCHANGED PIZZA'
end 
order by co.customer_id 

-- How many pizzas were delivered that had both exclusions and extras?

select count(pizza_id) "had both exclusions and extras" from customer_orders co 
join runner_orders ro on ro.order_id = co.order_id
where 
	ro.cancellation is null 
	and co.exclusions is not null 
	and co.extras is not null  

-- What was the total volume of pizzas ordered for each hour of the day?
	
select *
from (select extract(hour from co.order_time) as "Hour of the Day", 
			 count(*) as "Order Count"
      from customer_orders co 
      group by extract(hour from co.order_time)
     ) t
order by "Hour of the Day" 

-- What was the volume of orders for each day of the week?

select *
from (select extract(isodow from co.order_time) as "Day of the Week", 
			 count(*) as "Order Count"
      from customer_orders co 
      group by extract(isodow from co.order_time)
     ) t
order by "Day of the Week"
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

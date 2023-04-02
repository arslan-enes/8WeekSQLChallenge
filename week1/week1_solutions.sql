-- views

create view sale_menu_join as
select m.product_id, s.order_date, s.customer_id, m.product_name, m.price
from dannys_diner.sales s 
join dannys_diner.menu m
on s.product_id = m.product_id

--What is the total amount each customer spent at the restaurant?

select customer_id, sum(price) total_price 
from sale_menu_join group by customer_id
order by total_price desc

--How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) total_day
from sale_menu_join
group by customer_id
order by total_day desc

--What was the first item from the menu purchased by each customer?

select X.customer_id, X.first_occurence,  product_name from sale_menu_join smj
inner join (SELECT customer_id, MIN(order_date) as first_occurence
			FROM sale_menu_join
			GROUP BY customer_id) X
on X.first_occurence = smj.order_date and X.customer_id = smj.customer_id

--What is the most purchased item on the menu and how many times was it purchased by all customers?

select product_name, count(*) total_purchase
from sale_menu_join
group by product_name
order by total_purchase desc
limit 1

--Which item was the most popular for each customer?



--Which item was purchased first by the customer after they became a member?

select smj.customer_id, order_date, product_name from 
	(select m.customer_id, min(order_date) first_date from sale_menu_join smj
	join dannys_diner.members m
	on smj.customer_id = m.customer_id
	where order_date > join_date
	group by m.customer_id)
as first_date_after_member
join sale_menu_join smj
on smj.customer_id = first_date_after_member.customer_id
and smj.order_date = first_date_after_member.first_date

--Which item was purchased just before the customer became a member?

select smj.customer_id, order_date, product_name from 
	(select m.customer_id, max(order_date) first_date from sale_menu_join smj
	join dannys_diner.members m
	on smj.customer_id = m.customer_id
	where join_date > order_date
	group by m.customer_id)
as first_date_after_member
join sale_menu_join smj
on smj.customer_id = first_date_after_member.customer_id
and smj.order_date = first_date_after_member.first_date

--What is the total items and amount spent for each member before they became a member?

select customer_id, count(price) as "Total Amount", sum(price) as "Total Price" from (
	select smj.customer_id, price from sale_menu_join smj
	left join dannys_diner.members m
	on smj.customer_id = m.customer_id
	where order_date < join_date or join_date is null
) as X
group by customer_id
order by customer_id

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- how many points would each customer have?

select customer_id,sum(
		case when product_id = 1 then price*2
			 else price end) as points
from sale_menu_join 
group by customer_id
order by points desc

-- In the first week after a customer joins the program (including their join date) 
-- they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

select smj.customer_id, sum(   
	   case when order_date - join_date < 7 and 0 <= order_date - join_date
	   		then price*2
	   		when product_id = 1 then price*2
	   		else price end) as points
from sale_menu_join smj
left join dannys_diner.members m 
on m.customer_id = smj.customer_id
where (smj.customer_id in ('A','B')) and (order_date < '2021-02-01') 
group by smj.customer_id


-- BONUS --

-- Join All The Things

-- The following questions are related creating basic data tables that
-- Danny and his team can use to quickly derive insights without
-- needing to join the underlying tables using SQL.


create view join_all as
select 	smj.customer_id,
		order_date,
		product_name,
		price,
		case when order_date >= join_date then 'Y'
		else 'N' end as "member"
from sale_menu_join smj
left join dannys_diner.members m
on smj.customer_id = m.customer_id
order by customer_id, order_date

select * from join_all

-- Rank All The Things

-- Danny also requires further information about the ranking of customer products,
-- but he purposely does not need the ranking for non-member purchases
-- so he expects null ranking values for the records when
-- customers are not yet part of the loyalty program.

select 	*,
		case  
        when member = 'Y'
		then rank() over(
            partition by case when ja.member = 'Y' then 1 else 2 end, customer_id
            order by order_date) 
      end as Ranking
from join_all ja
order by customer_id, order_date





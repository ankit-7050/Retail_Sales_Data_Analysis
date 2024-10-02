
------------ Retail Sales Data Analysis --------------

select * from orders;

--  Basic SQL Questions

-- Q1. Retrieve all records of orders that used 'Second Class' as the ship mode.

select * from orders
where ship_mode = 'Second Class' and region = 'South'

-- Q2. Select distinct states where orders were placed.
select distinct(state),
round(sum(sale_price*quantity)::numeric,2) as revenue
from orders
group by state
order by revenue desc

-- Q3. Find the total number of orders in the dataset.
select count(order_id) as total_order
from orders;

-- Q4. Retrieve all orders where the discount applied 
         -- was greater than 10%.
select * from orders
where discount >10

-- Q5. List all orders placed in 'California'.

select * from orders
where state = 'California';

-- Q6. Get the total quantity of products ordered across all orders.

select sum(quantity) as total_quantity
from orders;

-- Q7. Retrieve the minimum, maximum, and average profit from the orders.

select round(min(profit)::numeric,2) as min_profit,
		round(max(profit)::numeric,2) as max_profit,
		round(avg(profit)::numeric,2) as avg_profit
from orders

-- Q8. List the unique categories of products ordered.

select distinct(category), round(sum(sale_price*quantity)::numeric,2) as revenue
from orders
group by category
order by revenue desc

-- Q9. Find the total number of orders for each region.

select count(order_id) as total_order, region
from orders
group by region

-- Q10. Retrieve all orders placed in '2023'.

select * from orders
where extract(year from order_date) = '2023'



-- Q1. Find top 10 highest revenue genetating products. ----- 

select product_id, sum(sale_price) as sales
from orders
group by product_id
order by sales desc
limit 10;
 
--  Q2. find top 5 highest selling products in each region -----

with cte as(
select region, product_id, sum(sale_price) as total_sales
from orders
group by region, product_id)
select * from(
select *,
row_number() over(partition by region order by total_sales) as rn
from cte) A
where rn<=5;


-- Q3. Find month over month growth comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023 ----

with cte as(
select  extract (year from order_date) as order_year,
extract (month from order_date) as order_month,
sum(sale_price) as sales
from orders
group by order_year, order_month
--order by order_year, order_month
	)
select order_month,
sum(case when order_year = 2022 then sales else 0 end) as year_2022,
sum(case when order_year = 2023 then sales else 0 end) as year_2023
from cte
group by order_month
order by order_month;


--Q4. for each category which month had highest sales

with cte as(
select category, to_char(order_date,'yyyyMM') as order_year_month,
sum(sale_price) as sales
from orders
group by category,order_year_month
--order by order_year_month
)
select * from(
select *,
row_number() over(partition by category order by sales desc) as rn
from cte
) a
where rn=1


-- Q5. Which sub_category had highest growth by profit in 2023 compare to 2022

with cte as(
select  sub_category, extract (year from order_date) as order_year,
sum(sale_price) as sales
from orders
group by sub_category, order_year
--order by order_year, order_month
	),
cte2 as (
select sub_category,
sum(case when order_year = 2022 then sales else 0 end) as year_2022,
sum(case when order_year = 2023 then sales else 0 end) as year_2023
from cte
group by sub_category
)
select *,
(year_2023-year_2022)*100/year_2022 as highest_growth
from cte2
order by highest_growth desc
limit 1


-- Intermediate SQL Questions


-- 1. Find the total sales (sale_price) for each state.

select state, round(sum(sale_price)::numeric,2) as total_sales
from orders
group by state
order by total_sales desc

-- 2. Retrieve the top 5 states with the highest number of orders.

select state, count(order_id) as total_orders
from orders
group by state
order by total_orders desc
limit 5

-- 3. Find the average sale price for each product category.

select category, round(avg(sale_price)::numeric,2) as avg_sale_price
from orders
group by category
order by avg_sale_price desc

-- 4. Calculate the total profit for orders placed in the 'Consumer' segment.

select segment, round(sum(profit)::numeric,2) as total_profit
from orders
where segment = 'Consumer'
group by segment

-- 5. Get the average discount applied to orders in the 'Furniture' category.

select category, round(avg(discount)::numeric,2) as avg_discount
from orders
where category = 'Furniture'
group by category

-- 6. Retrieve all orders where the profit is negative (i.e., a loss).

select order_id, (round(profit::numeric,2)) as profit
from orders
where profit < 0;

-- 7. List the top 3 products (by product_id) that generated the most profit.

select product_id, sum(profit) as total_profit
from orders
group by product_id
order by total_profit desc
limit 3

-- 8. Get the number of orders placed in each year.

select count(order_id) as total_order,
		extract(year from order_date) as year
from orders
group by year

-- 9. Find the product category that has the highest total sales.

select category, count(quantity) as highest_sales
from orders
group by category
order by highest_sales desc
limit 1

-- 10. List the top 5 cities with the highest sales revenue.

select city, round((sale_price * quantity)::numeric,2) as revenue
from orders
group by city, revenue
order by revenue desc
limit 5


-- Hard SQL Questions

-- 1. Retrieve the top 5 states with the highest total profit and display their corresponding total sales.
	
	select state, round(sum(profit)::numeric,2) as total_profit,
			round(sum(sale_price)::numeric,2) as total_sales
	from orders
	group by state
	order by total_profit desc, total_sales desc
	
-- 2. Find the top 5 months with the highest sales revenue in the dataset.
	
	select extract(year from order_date) as year,
			extract(month from order_date) as month,
			round((sale_price * quantity)::numeric,2) as revenue
	from orders
	group by month, revenue, year
	order by revenue desc
	limit 5;

-- 3. Calculate the cumulative profit for each state, ordered by total profit in descending order.

WITH state_profits AS (
    SELECT state,
        ROUND(SUM(profit)::numeric, 2) AS total_profit
    FROM orders
    GROUP BY state
)
SELECT 
    state, total_profit,
    ROUND(SUM(total_profit) OVER (ORDER BY total_profit DESC), 2) AS cumulative_profit
FROM state_profits
ORDER BY total_profit DESC;


-- 4. Write a query that displays the difference between the maximum and minimum sale prices for each category.

select category, max(sale_price) as max_sale_price,
			min(sale_price) as min_sale_price,
		max(sale_price) - min(sale_price) as diff_sale_price
from orders
group by category
order by diff_sale_price

-- 5. List the top 3 cities with the highest average profit per order.

SELECT 
    city, 
    ROUND(AVG(profit)::numeric, 2) AS avg_profit_per_order
FROM 
    orders
GROUP BY 
    city
ORDER BY 
    avg_profit_per_order DESC
LIMIT 3;

-- 6. Find the top 5 subcategories that have the highest total sales but with a discount greater than 15%.

select sub_category, round(sum(sale_price)::numeric,2) as total_sales
from orders
where discount >15
group by sub_category
order by total_sales desc
limit 5

-- 7. Calculate the percentage contribution of each category to the total sales.

select category, 
round((sum(sale_price)/(select sum(sale_price) from orders)*100)::numeric,2) as percentage_cont
from orders
group by category
order by percentage_cont desc

-- 8. Retrieve the top 5 products that had the highest quantity sold in the 'West' region.

select product_id, sum(quantity) as quantity_sold
from orders
where region = 'West'
group by product_id
order by quantity_sold desc
limit 5

-- 9. Find the month that generated the highest total profit and list the top 3 states in that month.

WITH month_profits AS (
    SELECT
		extract(month from order_date) as order_month,
        round(SUM(profit)::numeric,2) AS total_profit
    FROM orders
    GROUP BY order_month
    ORDER BY total_profit DESC
    LIMIT 1
)

SELECT 
    state,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM orders
WHERE 
extract(month from order_date) = (SELECT order_month FROM month_profits)
GROUP BY state
ORDER BY total_profit DESC
LIMIT 3;

		
-- 10. Determine the product category and subcategory with the highest profit-to-sales ratio.

SELECT 
    category,
    sub_category,
    ROUND((SUM(profit) / SUM(sale_price))::numeric,4) AS profit_to_sales_ratio
FROM 
    orders
GROUP BY 
    category, 
    sub_category
ORDER BY 
    profit_to_sales_ratio DESC
LIMIT 1;















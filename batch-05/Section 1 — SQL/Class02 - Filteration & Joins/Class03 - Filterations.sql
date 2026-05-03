SELECT *
FROM production.products
WHERE list_price > 1000 AND (brand_id = 1 
	OR brand_id = 2);

-- 2999.99 2599.99 1199.99 2799.99
select *
from production.products
where list_price = 2999.99 or  
 list_price = 2599.99 or  
 list_price = 1199.99 or  
 list_price = 2799.99;

 -- IN 
select *
from production.products
where list_price IN (2999.99, 2599.99, 1199.99, 2799.99)


select *
from production.products
where list_price NOT IN (2999.99, 2599.99, 1199.99, 2799.99)

-- Between 
select *
from production.products
where list_price BETWEEN 1199.99 AND 2999.99;

SELECT * FROM sales.orders
where order_date between '20160101' and '20160131';

select *
from production.products
where list_price NOT BETWEEN 1199.99 AND 2999.99;

-- Alias
-- column & tables 
select product_name as prd_name
from production.products;

-- Customer Full Name 
--Ayan Hussain -- AyanHussain (Need to add a space)

select first_name + ' ' + last_name as full_name
from sales.customers

-- like
-- logical operator that check or matches with specified string/text
-- used with wild cards % _ ^ []

-- % - represent multiple characters 
select customer_id, first_name, last_name from sales.customers
where first_name like 'A%'
order by first_name;

select customer_id, first_name, last_name from sales.customers
where first_name like '%a'
order by first_name;

select customer_id, first_name, last_name from sales.customers
where first_name like '%g%'
order by first_name;

select customer_id, first_name, last_name from sales.customers
where last_name like 't%s' ;

-- _ single character
-- 2nd letter a

select customer_id, first_name, last_name from sales.customers
where first_name like '_a%'
order by first_name;

-- first letter must not be 'a'

select customer_id, first_name, last_name from sales.customers
where first_name Not like 'a%'
order by first_name;

-- Waqas 
-- like 'q%' '%q'   '%q%'
-- like 'w%s'


-- Joins 

create schema hr;
go

create table hr.candidates(
	id int primary key identity,
	fullname varchar(100) not null);

create table hr.employees(
	id int primary key identity,
	fullname varchar(100) not null);


insert into 
	hr.candidates(fullname)
values
	('Saad'),
	('Mohsin'),
	('Owais'),
	('Haseeb')

insert into 
	hr.employees(fullname)
values
	('Haseeb'),
	('Saad'),
	('Bilal'),
	('Adnan')

select * from hr.candidates;
select * from hr.employees;

-- Syntax 
-- SELECT * FROM TABLE_1
-- INNER JOIN TABLE_2 
--		ON TABLE_1.COLUMN = TABLE_2.COLUMN

SELECT c.fullname FROM hr.candidates c
INNER JOIN hr.employees  e
	ON c.fullname = e.fullname

SELECT c.id as candid_id, e.id as emp_id, c.fullname FROM hr.candidates c
INNER JOIN hr.employees  e
	ON c.fullname = e.fullname

SELECT c.id as candid_id, e.id as emp_id, c.fullname FROM hr.candidates c
INNER JOIN hr.employees  e
	ON e.fullname = c.fullname;

-- product_name, list_price, category_id 
-- production.products 
-- order by product_name desc

SELECT 
	product_name, 
	list_price, 
	products.category_id,
	category_name
FROM
	production.products
INNER JOIN production.categories
	ON products.category_id = categories.category_id
order by 
	product_name desc;


 -- CUSTOMER FULL NAME, ORDER STATUS, ORDER_DATE 

 
select c.first_name + ' ' + c.last_name as full_name,
	o.order_status,
	o.order_date
from sales.customers C
INNER JOIN SALES.ORDERS O
	ON c.customer_id =o.customer_id

SELECT 
	p.product_name, 
	p.list_price, 
	p.category_id,
	c.category_name,
	b.brand_name
FROM
	production.products p
INNER JOIN production.categories c
	ON p.category_id = c.category_id
INNER JOIN production.brands b
	on p.brand_id = b.brand_id
order by 
	product_name desc;
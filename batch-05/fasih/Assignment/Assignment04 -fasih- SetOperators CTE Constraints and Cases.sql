-- ============================================================
--   ASSIGNMENT 04 — SET OPERATORS, CTEs, CONSTRAINTS & CASES
--   Database  : BikeStores
--   Topics    : UNION / UNION ALL / INTERSECT / EXCEPT
--               CTEs (Single & Multiple)
--               Constraints (PK, FK, NOT NULL, UNIQUE, CHECK)
--               CASE Expressions
-- ============================================================


-- ============================================================
--  SECTION A — SET OPERATORS
-- ============================================================

-- Q1.
-- The marketing team wants a single contact list of everyone in the system
-- — both staff members and customers.
-- Build a unified list showing full name and email for all of them.
-- Make sure no one is accidentally listed twice.

	select first_name || ' ' || last_name as full_name, email
	from sales.customers
	union
	select first_name || ' ' || last_name as full_name, email
	from sales.staffs;



-- Q2.
-- The logistics team wants to know which states have BOTH
-- a store location AND customers living there.
-- Find those states.

	select state
	from sales.stores
	intersect
	select state
	from sales.customers;



-- Q3.
-- Management wants to identify stores that received zero orders
-- in the year 2018.
-- Find the store_ids that appear in sales.stores but did NOT
-- receive any orders in 2018.

	select store_id
	from sales.stores
	except
	select distinct store_id
	from sales.orders
	where YEAR(order_date) = 2018;
	


-- ============================================================
--  SECTION B — CTEs
-- ============================================================

-- Q4.
-- The pricing team wants to flag overpriced products.
-- For each category, find all products whose list_price is
-- higher than the average list_price of their own category.
-- Show category_id, product_name, list_price, and the category average.

	with category_avg as (
		select category_id,Avg(list_price) as avg_price
	from production.products p
	group by category_id
	)
	select p.category_id, p.product_name, p.list_price, c.avg_price as category_avg 
	from production.products p
	join category_avg c on p.category_id = c.category_id
	where p.list_price > c.avg_price
	order by p.category_id, p.list_price desc;


-- Q5.
-- HR wants to reward the hardest-working staff member.
-- Find all staff members whose order count is higher than
-- the average order count across all staff.
-- Show staff_id and their order_count.

	with staff_order_counts as (
	select staff_id, count(*) as order_count
	from sales.orders
	group by staff_id
	 ),
	Avg_order_count as (
		select Avg(order_count * 1.0) as avg_count
		from staff_order_counts
	)
	select soc.staff_id, soc.order_count
	from staff_order_counts soc
	cross join Avg_order_count aoc
	where soc.order_count > aoc.avg_count;

-- Q6.
-- The finance team needs a yearly performance report per store.
-- For each store and each year, calculate total revenue.
-- Then find only the years where a store's revenue
-- exceeded $1,000,000.
-- Show store_id, year, and total_revenue.

   with yearly_revenue as (
	select store_id, YEAR(order_date) as order_year, 
	sum(quantity * list_price * (1 - discount)) as total_revenue
	from sales.orders o
	join sales.order_items oi 
	on o.order_id = oi.order_id
	group by store_id, YEAR(order_date)
	)
	select store_id, order_year, total_revenue
	from yearly_revenue
	where total_revenue > 1000000
	order by store_id, order_year;


-- ============================================================
--  SECTION C — CONSTRAINTS (DDL)
-- ============================================================

-- Q7.
-- The business wants to launch a customer loyalty program.
-- Below is the table structure. Your job is to add the correct constraints:
--   - Each card must have a unique card number (not auto-generated).
--   - The card must be linked to a valid customer in sales.customers.
--   - Points balance cannot be negative.
--   - Tier must be one of: 'Bronze', 'Silver', or 'Gold'.
--   - Join date is required and cannot be empty.
--   - If a customer is deleted, their loyalty card record should also be deleted.
--
-- Starter table (add your constraints here):
--
-- CREATE TABLE sales.loyalty_cards (
--     card_number   INT,
--     customer_id   INT,
--     points        INT,
--     tier          VARCHAR(10),
--     join_date     DATE
-- );
--
-- Once the table is created, run these inserts to verify your constraints work:
--
-- INSERT INTO sales.loyalty_cards VALUES (1001, 1,  500,  'Gold',   '2024-01-15');
-- INSERT INTO sales.loyalty_cards VALUES (1002, 2,  150,  'Silver', '2024-03-22');
-- INSERT INTO sales.loyalty_cards VALUES (1003, 3,  0,    'Bronze', '2024-06-01');
--
-- Also try these to confirm your constraints REJECT bad data:
-- INSERT INTO sales.loyalty_cards VALUES (1001, 4,  100,  'Gold',   '2024-07-01'); -- duplicate card_number
-- INSERT INTO sales.loyalty_cards VALUES (1004, 1,  -50,  'Silver', '2024-08-01'); -- negative points
-- INSERT INTO sales.loyalty_cards VALUES (1005, 5,  200,  'Diamond','2024-09-01'); -- invalid tier
	 
	CREATE TABLE sales.loyalty_cards (
    card_number INT PRIMARY KEY UNIQUE,
    customer_id INT NOT NULL,
    points INT CHECK (points >= 0),
    tier VARCHAR(10) CHECK (tier IN ('Bronze', 'Silver', 'Gold')),
    join_date DATE NOT NULL,

    CONSTRAINT fk_loyalty_customer
        FOREIGN KEY (customer_id)
        REFERENCES sales.customers(customer_id)
   );



-- Q8.
-- The operations team realized that some orders in the database have
-- a shipped_date that is earlier than the order_date, which is impossible.
-- Add a rule to the table below that prevents this from happening.
-- Then try inserting a valid row and an invalid row to confirm it works.
--
-- Run this setup first:
--
-- CREATE TABLE test_orders (
--     order_id      INT PRIMARY KEY,
--     order_date    DATE NOT NULL,
--     shipped_date  DATE
-- );
--
-- INSERT INTO test_orders VALUES (1, '2024-01-10', '2024-01-13');
-- INSERT INTO test_orders VALUES (2, '2024-02-05', '2024-02-07');
-- INSERT INTO test_orders VALUES (3, '2024-03-01', NULL);
--
-- Now add the constraint using ALTER TABLE (do not recreate the table).
-- After adding it, test with:
-- INSERT INTO test_orders VALUES (4, '2024-04-10', '2024-04-08'); -- should FAIL
-- INSERT INTO test_orders VALUES (5, '2024-04-10', '2024-04-15'); -- should PASS

	CREATE TABLE test_orders (
    order_id INT PRIMARY KEY,
    order_date DATE NOT NULL,
    shipped_date DATE,

    CONSTRAINT chk_shipped_date
    CHECK (
        shipped_date IS NULL
        OR shipped_date >= order_date
    )
);

-- ============================================================
--  SECTION D — CASE EXPRESSIONS
-- ============================================================

-- Q9.
-- The sales team wants to see how quickly each order was shipped.
-- Using the difference between shipped_date and order_date:
--   - 'Fast'     — shipped within 2 days
--   - 'Normal'   — shipped in 3 to 5 days
--   - 'Delayed'  — shipped after 5 days
--   - 'Pending'  — not yet shipped (shipped_date is NULL)
-- Show order_id, order_date, shipped_date, and shipping_speed.

SELECT
    order_id,
    order_date,
    shipped_date,
    CASE
        WHEN shipped_date IS NULL THEN 'Pending'
        WHEN DATEDIFF(DAY, order_date, shipped_date) <= 2 THEN 'Fast'
        WHEN DATEDIFF(DAY, order_date, shipped_date) BETWEEN 3 AND 5 THEN 'Normal'
        ELSE 'Delayed'
    END AS shipping_speed
FROM sales.orders;
 

-- Q10.
-- The warehouse team wants to label stock levels for each product per store.
-- Using production.stocks:
--   - 'Out of Stock'  — quantity = 0
--   - 'Low Stock'     — quantity between 1 and 10
--   - 'Sufficient'    — quantity between 11 and 50
--   - 'Well Stocked'  — quantity above 50
-- Show store_id, product_id, quantity, and stock_status.
-- Sort by store_id, then quantity ascending.

select
	store_id,
	product_id,
	quantity,
	CASE
		WHEN quantity = 0 THEN 'Out of Stock'
		WHEN quantity BETWEEN 1 AND 10 THEN 'Low Stock'
		WHEN quantity BETWEEN 11 AND 50 THEN 'Sufficient'
		ELSE 'Well Stocked'
	END AS stock_status
	from production.stocks
	order by store_id, quantity asc;


-- ============================================================
--  END OF ASSIGNMENT 04
-- ============================================================
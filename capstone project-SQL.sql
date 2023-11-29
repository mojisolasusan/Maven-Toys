
SELECT * FROM inventory

SElECT * FROM sales

SELECT * FROM stores 

SELECT * FROM products

CREATE VIEW combined_all AS(
SELECT
	p.product_id,
	p.product_name,
	p.product_category,
	p.product_cost,
	p.product_price,
	i.stock_on_hand,
	s.sales_id,
	s.date,
	s.store_id,
	s.units,
	st.store_name,
	st.store_city,
	st.store_location,
	st.store_open_date,
	(s.units * p.product_price) AS profit
FROM
	products AS p
JOIN
	sales AS s ON s.product_id = p.product_id
JOIN
	stores AS st ON st.store_id = s.store_id
JOIN
	inventory AS i ON i.store_id= st.store_id AND i.product_id = p.product_id)
	
 --1.a Which product categories drive the biggest profits?	
 
SELECT
	product_category,
	SUM(profit) AS total_profit
FROM
	combined_all
GROUP BY product_category
ORDER BY total_profit DESC
LIMIT 1;

--1.b  Is this the same across store locations?

SELECT
	store_location,
	product_category,
	SUM(profit) AS total_profit,
	ROW_NUMBER() OVER(PARTITION BY product_category ORDER BY SUM(profit)) AS ranking
FROM
	combined_all
GROUP BY product_category,store_location

--2.How much money is tied up in inventory at the toy stores?

CREATE VIEW store_inventory AS(
SELECT
	store_location,
	store_name,
	store_city,
	store_open_date,
  	store_id,
  	stock_on_hand,
  	product_id,
  	product_category,
 	product_name,
  	product_cost,
  	product_price,
	SUM(product_cost * stock_on_hand) AS Working_capital
FROM
	combined_all
GROUP BY store_location, 
	store_name,
	store_city,
	store_open_date,
	store_id,
	stock_on_hand,
  	product_id,
  	product_category,
 	product_name,
  	product_cost,
  	product_price);

---TOTAL holding cost accross store loactions and store name.
SELECT
	store_location,
	store_name,
	SUM(Working_capital) AS holding_cost
FROM
	store_inventory
GROUP BY
	store_location, store_name;
	
--TOTAL HOLDING_COST
SELECT
	SUM(Working_capital) AS holding_cost
FROM
	store_inventory;
	
--2.b How long will it last?

-- firstly,find the total units of each product_id sold per day
--secondly, the count of days and do the average of units by the sum of units
-- lastly,find how long each product will last from the result above.

SELECT
	product_id,
	product_name,
	store_id,
	store_name,
	COUNT(TO_CHAR(date, 'day'))AS total_days,
	SUM(units) as total_units,
	AVG(units) as average_units,
	stock_on_hand,
	(stock_on_hand/ AVG(units) ) AS lasting_period
FROM
	combined_all
GROUP BY 
	product_id,product_name,store_id,store_name,stock_on_hand;
	
--3. Are sales being lost with out-of-stock products at certain locations?

SELECT
	stock_on_hand,
	store_location,
	product_name,
	product_price,
	COUNT(TO_CHAR(date, 'day'))AS total_days,
	SUM(units) as total_units,
	AVG(units) as average_units,
	(AVG(units) * product_price) AS sales_lost
FROM combined_all
WHERE stock_on_hand = 0	
GROUP BY stock_on_hand,
	store_location,
	product_name,
	product_price;
	
-- OR to get sales_lost accross each location
select
	store_location,
	SUM(sales_lost) AS total_sales_lost
FROM(SELECT
	stock_on_hand,
	store_location,
	product_name,
	product_price,
	COUNT(TO_CHAR(date, 'day'))AS total_days,
	SUM(units) as total_units,
	AVG(units) as average_units,
	(AVG(units) * product_price) AS sales_lost
FROM combined_all
WHERE stock_on_hand = 0	
GROUP BY stock_on_hand,
	store_location,
	product_name,
	product_price)sales_lost_table
GROUP BY store_location;

--OR total_sales_lost

select
	SUM(sales_lost) AS total_sales_lost
FROM(SELECT
	stock_on_hand,
	store_location,
	product_name,
	product_price,
	COUNT(TO_CHAR(date, 'day'))AS total_days,
	SUM(units) as total_units,
	AVG(units) as average_units,
	(AVG(units) * product_price) AS sales_lost
FROM combined_all
WHERE stock_on_hand = 0	
GROUP BY stock_on_hand,
	store_location,
	product_name,
	product_price)sales_lost_table;

	
	
	
	
	
	
	
	
	
	
	
	
	


















	


	






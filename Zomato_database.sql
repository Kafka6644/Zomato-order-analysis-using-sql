SELECT DATABASE() zomato_schema;
USE zomato_schema;
			-- Q.1 Find the customers who have never ordered

SELECT name FROM zomato_users WHERE user_id NOT IN (SELECT user_id FROM zomato_orders);

			-- Q.2 Find average price of food

SELECT f.f_name, AVG(price) AS price_avg
FROM zomato_menu m
JOIN zomato_food f
ON m.f_id = f.f_id
GROUP BY f.f_name;

			-- Q.3 Find top restaurants in terms of orders in June
            

SELECT r.r_name, COUNT(*) AS num_orders
FROM zomato_orders o
JOIN zomato_restaurants r
ON o.r_id = r.r_id
WHERE MONTHNAME(date) = 'June'
GROUP BY r.r_name
ORDER BY num_orders DESC LIMIT 1;


			-- Q.4  Show all orders with order details for a particular customer in a particular date range

SELECT o.order_id, r.r_name, f.f_name
FROM zomato_orders o
JOIN zomato_restaurants r
ON r.r_id = o.r_id
JOIN zomato_order_details od
ON o.order_id = od.order_id
JOIN zomato_food f
ON f.f_id = od.f_id
WHERE user_id = (SELECT user_id FROM zomato_users WHERE name = 'Ankit')
AND date > '2022-06-10' AND date < '2022-07-10';


			-- Q.5 Month over month revenue growth of zomato
            
SELECT month, ((revenue - lag_revenue)/lag_revenue) * 100 AS m_o_m_sales FROM 

	(
		WITH sales AS 
		(
			SELECT MONTHNAME(date) as month, SUM(amount) AS revenue
			FROM zomato_orders
			GROUP BY month)
		SELECT month, revenue, LAG(revenue,1) OVER(ORDER BY revenue) AS lag_revenue FROM sales
			) s;
            
            
            
			-- Q.6 Fetch Customer & their favorite food
            
WITH data AS (
		SELECT o.user_id, od.f_id, COUNT(*) AS num_orders
		FROM zomato_orders o
		JOIN zomato_order_details od
		ON o.order_id = od.order_id
		GROUP BY o.user_id, od.f_id
)
SELECT u.name, f.f_name, d1.num_orders FROM
data d1
JOIN zomato_users u
ON u.user_id = d1.user_id
JOIN zomato_food F
ON f.f_id = d1.f_id
WHERE d1.num_orders =
		(SELECT MAX(num_orders)
		 FROM data d2
		 WHERE d2.user_id = d1.user_id);
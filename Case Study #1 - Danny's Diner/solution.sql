-- What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) as total_amount
FROM sales as s
INNER JOIN menu as m
ON S.product_id = M.product_id
GROUP BY S.customer_id;

-- How many days has each customer visited the restaurant?
SELECT s.customer_id, COUNT( DISTINCT s.order_date) as visits
FROM sales as s
GROUP by s.customer_id;

-- What was the first item from the menu purchased by each customer?
WITH order_number as (
	SELECT s.customer_id, m.product_name, 
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as order_no
	FROM sales as s
	INNER JOIN menu as m
	ON s.product_id = m.product_id
)
SELECT customer_id, product_name
FROM order_number
WHERE order_no = 1;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name, COUNT(m.product_name) as times_purchased
FROM sales as s
INNER JOIN menu as m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY times_purchased DESC
LIMIt 1;

-- Which item was the most popular for each customer?
-- Which item was purchased first by the customer after they became a member?
-- Which item was purchased just before the customer became a member?
-- What is the total items and amount spent for each member before they became a member?
-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
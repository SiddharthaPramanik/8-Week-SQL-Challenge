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
WITH purchase_freq As (
	SELECT s.customer_id, m.product_name, COUNT(m.product_name) as times_purchased,
	RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(m.product_name) DESC) as purchase_freq_rank
	FROM sales as s
	INNER JOIN menu as m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
    )
SELECT customer_id, product_name, times_purchased
FROM purchase_freq
WHERE purchase_freq_rank = 1;

-- Which item was purchased first by the customer after they became a member?
SELECT customer_id, product_name
FROM 
(
	SELECT s.customer_id, me.product_name,
	RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as order_no
	FROM sales as s 
	INNER JOIN members as mb 
	ON s.customer_id = mb.customer_id
	INNER JOIN menu as me
	ON s.product_id = me.product_id
	WHERE s.order_date >= mb.join_date
    ) as relevant_data
WHERE order_no = 1;

-- Which item was purchased just before the customer became a member?
SELECT customer_id, product_name
FROM 
(
	SELECT s.customer_id, me.product_name,
	RANk() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) as order_no
	FROM sales as s 
	INNER JOIN members as mb 
	ON s.customer_id = mb.customer_id
	INNER JOIN menu as me
	ON s.product_id = me.product_id
	WHERE s.order_date < mb.join_date
    ) as relevant_data
WHERE order_no = 1;

-- What is the total items and amount spent for each member before they became a member?
SELECT s.customer_id, COUNT(me.product_name) as number_of_items, SUM(me.price) as amount
FROM sales as s 
INNER JOIN members as mb 
ON s.customer_id = mb.customer_id
INNER JOIN menu as me
ON s.product_id = me.product_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT s.customer_id, SUM(p.point) as points
FROM sales as s
INNER JOIN (
	SELECT me.product_id,
    CASE
    WHEN me.product_id = 1 THEN me.price * 20
    ELSE me.price * 10
    END as point
    FROM menu as me
) as p
ON s.product_id = p.product_id
GROUP BY s.customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
SELECT s.customer_id, SUM(
	CASE
		WHEN s.order_date >= mb.join_date
		AND s.order_date < ADDDATE(mb.join_date, INTERVAL 7 DAY )
		THEN me.price * 20
		ELSE
			CASE
				WHEN me.product_id = 1 THEN me.price * 20
				ELSE me.price * 10
			END
	END
) as new_points
FROM sales as s
LEFT JOIN members as mb
ON s.customer_id = mb.customer_id
INNER JOIN menu as me
on me.product_id = s.product_id
GROUP BY s.customer_id;

-- BONUS QUESTIONS

-- Join All The Things
SELECT s.customer_id, s.order_date, me.product_name, me.price,
CASE
	WHEN s.order_date >= mb.join_date THEN 'Y'
    ELSE 'N'
END as member
FROM sales as s
LEFT JOIN members as mb
ON s.customer_id = mb.customer_id
INNER JOIN menu as me
on s.product_id = me.product_id;

-- Rank All The Things

WITH dataset as (
	SELECT s.customer_id, s.order_date, me.product_name, me.price,
	CASE
		WHEN s.order_date >= mb.join_date THEN 'Y'
		ELSE 'N'
	END as member
	FROM sales as s
	LEFT JOIN members as mb
	ON s.customer_id = mb.customer_id
	INNER JOIN menu as me
	on s.product_id = me.product_id
)
SELECT *,
CASE
	WHEN member='Y' THEN RANK() OVER(
					PARTITION BY customer_id, member ORDER BY order_date
                    )
END as ranking
FROM dataset;
CREATE DATABASE IF NOT EXISTS Walmart;

CREATE TABLE sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11, 9),
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2, 1)
);

-- --------------------------------------------------------------------------------------- --
-- ---------------------------- Feature Engineering -------------------------------------- --

-- time of day

SELECT time,
(CASE WHEN  `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
      WHEN `time` BETWEEN "12:00:00" AND "16:00:00" THEN "Afternoon"
      ELSE "Evening"
  END) AS time_of_date
FROM Walmart.sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (CASE 
      WHEN  `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
      WHEN `time` BETWEEN "12:00:00" AND "16:00:00" THEN "Afternoon"
      ELSE "Evening"
  END);
  
  
  -- day_name
  SELECT date, DAYNAME(date)
  FROM sales;
  
  ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
  UPDATE sales
  SET day_name = DAYNAME(date);
  
  -- month_name

  SELECT date, MONTHNAME(date)
  FROM sales;
  
  ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);
  UPDATE sales
  SET month_name = MONTHNAME(date);
  
  -- --------------------------------------------------------------------------------------- 
  -- --------------------------------------Generic------------------------------------------
  
  -- How many unique cities does the data have
  
  SELECT DISTINCT city
  FROM sales;
  
  SELECT DISTINCT branch
  FROM sales;
  
  -- Which city has which branch
  
  SELECT DISTINCT city, branch
  FROM sales;
  
-- -----------------------------------------------------------------------------------------
-- ---------------------------- Product ----------------------------------------------------
-- -----------------------------------------------------------------------------------------

-- How many unique product lines does the data have? -- 6

SELECT COUNT(DISTINCT product_line)
FROM sales;

-- What is the most selling product line
SELECT payment_method, COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line
SELECT product_line, COUNT(product_line) AS pd
FROM sales
GROUP BY product_line
ORDER BY pd DESC;

-- What is the total reveneu by month -- 
SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?  -- January
SELECT month_name AS month, SUM(cogs)AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue? -- Food and beverages
SELECT product_line, SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue? --Naypyitaw
SELECT
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city 
ORDER BY total_revenue DESC;

-- What product line had the largest VAT?
SELECT product_line, AVG(VAT) as VAT
FROM sales
GROUP BY product_line
ORDER BY VAT DESC;

-- Which branch sold more products than average product sold? --Yet to find way to find the answer
SELECT branch, SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender
SELECT gender, product_line, COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
-- Need to work on this again
SELECT 
	product_line, AVG(quantity) AS avg_qnty, AVG(avg_qnty) AS avg_avg_qnty
FROM sales
GROUP BY product_line;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;


SELECT AVG(quantity) as avg_qty
FROM sales;

-- Add new column with CASE statement
SELECT 
  product_line,
  quantity,
  CASE 
    WHEN quantity > (SELECT avg_qty FROM (SELECT AVG(quantity) as avg_qty FROM sales) tmp) 
        THEN 'Good'  
    ELSE 'Bad'
  END AS rating
FROM sales;


-- ------------------------------------------------------------------------------------------
-- ---------------------------------- Sales -------------------------------------------------

-- Number of sales made in each time of the day per weekday 
-- Evenings experience most sales, the stores are 

SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'Monday'
GROUP BY time_of_day
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT customer_type, SUM(total) AS total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Which city has the largest tax/VAT percent?

SELECT city, AVG(VAT)
FROM sales
GROUP BY city
ORDER BY AVG(VAT) DESC;

-- Which customer type pays the most in VAT?

SELECT customer_type, AVG(VAT)
FROM sales
GROUP BY customer_type
ORDER BY AVG(VAT) DESC;


-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT(payment_method)
FROM sales;

-- What is the most common customer type?
SELECT customer_type, count(customer_type)
FROM sales
GROUP BY customer_type
ORDER BY customer_type DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*) AS cstm_cnt
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT COUNT(*), gender
FROM sales
GROUP BY gender;

-- What is the gender distribution per branch?

SELECT gender, COUNT(*) as gender_cnt
FROM sales
WHERE branch = 'B'
GROUP BY gender;

-- Which time of the day do customers give most ratings?

SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?

SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'B'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?

SELECT day_name, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;








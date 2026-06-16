
#E-COMMERCE _SQL PROJECT
#DATABASE_CREATION_
create database e_commerce;
use e_commerce;

#TABLES
create table customers ( customer_id varchar(10),
customer_unique_id varchar(100),
customer_zip_code_prefix bigint,
customer_city varchar(100),
customer_state char(2));

CREATE TABLE orders(order_id VARCHAR(100),
customer_id VARCHAR(100),
order_status VARCHAR(20),
order_purchase_timestamp VARCHAR(50),
order_approved_at VARCHAR(50),
order_delivered_carrier_date VARCHAR(50),
order_delivered_customer_date VARCHAR(50),
order_estimated_delivery_date VARCHAR(50));

create table order_items (order_id varchar(100),
order_item_id int,product_id varchar(100),
seller_id varchar(100),shipping_limit_date datetime,
price decimal(10,3),freight_value decimal(6,4));


CREATE TABLE order_payments(order_id VARCHAR(100),
payment_sequential INT,payment_type VARCHAR(15),
payment_installments INT,payment_value DECIMAL(10,2));

CREATE TABLE order_reviews(review_id VARCHAR(100),
order_id VARCHAR(100),review_score INT,
review_comment_title VARCHAR(255),
review_comment_message TEXT,
review_creation_date VARCHAR(50),
review_answer_timestamp VARCHAR(50));

CREATE TABLE products(product_id VARCHAR(100),
product_category_name VARCHAR(255),
product_name_lenght VARCHAR(20),product_description_lenght VARCHAR(20),
product_photos_qty VARCHAR(20),product_weight_g VARCHAR(20),
product_length_cm VARCHAR(20),product_height_cm VARCHAR(20),product_width_cm VARCHAR(20));


CREATE TABLE geolocation(
geolocation_zip_code_prefix BIGINT,
geolocation_lat VARCHAR(30),
geolocation_lng VARCHAR(30),
geolocation_city VARCHAR(100),
geolocation_state CHAR(2)
);

#total customers 1
select count(distinct  customer_unique_id) as total_customers from customers;

#total orders 2
select count(order_id)as total_orders from orders; 

#total revenue 3
select sum(price+freight_value) as total_revenue from order_items;

#avg order values  4
#select avg(payment_value) as average_order_value from order_payments;
SELECT 
    SUM(payment_value) / COUNT(DISTINCT order_id) AS avg_order_value
FROM order_payments;

#most used payment_method 5 
select payment_type,count(payment_type) as count from order_payments
 group by payment_type order by count desc; 

# top 10 customers states by order count 6 
select c.customer_state,count(o.order_id) as total_orders from orders o join customers c on o.customer_id = c.customer_id
 group by c.customer_state order by total_orders desc limit 10;

#top 10 customers city by order count  7
select c.customer_city , count(o.order_id) as total_orders from orders o 
join customers c on o.customer_id=c.customer_id group by c.customer_city order by total_orders desc limit 10;


# total product 8
select count(*) as total_products from products; 

# top 10 product categories by product count 9
select product_category_name,count(*) as product_count from products 
group by product_category_name order by product_count desc limit 10;

#highest -revenue genarted product category 10
select p.product_category_name,sum(o.price) as revenue from order_items o
 join products p on  p.product_id = o.product_id group by p.product_category_name order by revenue 
desc limit 1;

#Average payment installments 11 
select avg(payment_installments) from order_payments;

#Average review score 12 
select avg(review_score) as average_review from order_reviews;

#State-wise revenue distribution  13  
select c.customer_state,sum(o.price) as revenue from order_items o join 
 orders oo on o.order_id=oo.order_id join customers c on oo.customer_id=c.customer_id group by customer_state order by revenue desc ;

#review_score distribution 14 
select review_score , count(*) as count from order_reviews group by review_score order by review_score;

#highest rated categories  15  
select p.product_category_name,avg(orr.review_score) as avg_rating from order_reviews orr join orders o on orr.order_id=o.order_id 
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id=p.product_id
group by p.product_category_name order by avg_rating desc limit 10; 

#lowest rated categories 16
select p.product_category_name,avg(orr.review_score) as avg_rating from order_reviews orr join orders o on orr.order_id=o.order_id 
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id=p.product_id
group by p.product_category_name order by avg_rating asc limit 10;

#monthly orders
select date_format(order_purchase_timestamp,'%y-%m') as month , 
count(order_id) as total_orders from orders group by month order by month;

#monthly revenue
 select date_format(o.order_purchase_timestamp,'%y-%m') as month,sum(op.payment_value) as total_revenue 
 from orders o join order_payments op on o.order_id=op.order_id group by month order by month;
 
 #yearwise growth
 select year(order_purchase_timestamp) as year , count(order_id) as total_orders from orders group by year order by year;

#single payment vs installment payments

SELECT 
    CASE 
        WHEN payment_installments = 1 THEN 'Single'
        ELSE 'Installments'
    END AS payment_type,
    COUNT(*) AS total
FROM order_payments
GROUP BY 
    CASE 
        WHEN payment_installments = 1 THEN 'Single'
        ELSE 'Installments'
    END;


#top cities by revenue

#SELECT c.customer_city, SUM(oi.price + oi.freight_value) AS revenue FROM customers c JOIN orders o ON c.customer_id = o.customer_id
#JOIN order_items oi ON o.order_id = oi.order_id GROUP BY c.customer_city ORDER BY revenue DESC LIMIT 10;

SELECT c.customer_city,SUM(oi.total_amount) AS revenue FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN (SELECT order_id,SUM(price + freight_value) AS total_amount FROM order_items GROUP BY order_id) oi 
ON o.order_id = oi.order_id GROUP BY c.customer_city ORDER BY revenue DESC LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------------------------

#1. Customer Analysis 
#Top 10 customers by spending 
select o.customer_id ,sum(oi.price + oi.freight_value) as total_spend from orders o 
join order_items oi on o.order_id=oi.order_id group by o.customer_id order by total_spend desc limit 10;

#Repeat Customers
#select customer_id , count(order_id) as total_orders from orders group by customer_id having count(order_id)>1;

select c.customer_unique_id , count(order_id) as total_orders from customers c
 join orders o on c.customer_id=o.customer_id group by c.customer_unique_id having count(order_id)>1;

#Customers with Multiple Orders (count)
SELECT 
    COUNT(*) AS repeat_customer_count
FROM (
    select c.customer_unique_id , count(order_id) as total_orders from customers c 
    join orders o on c.customer_id=o.customer_id group by c.customer_unique_id having count(order_id)>1
) t;

#customers distribution
select customer_state , count(customer_id) as total_customers
 from customers group by customer_state order by total_customers desc ;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#2 SALES ANALYSIS
# Monthly Sales Trend
select date_format(o.order_purchase_timestamp,'%Y-%m') as month , sum(oi.price + oi.freight_value)
 as revenue from orders o join order_items oi on o.order_id=oi.order_id group by month order by month;

#yearly sales trends
select year(o.order_purchase_timestamp) as year , sum(oi.price + oi.freight_value) as revenue
 from orders o join order_items oi on o.order_id=oi.order_id group by year order by year;


#Average Order Value (AOV)
#select sum(oi.price+ +oi .freight_value)/ count(distinct (o.order_id)) as avrege_order_value from orders o join order_items oi on o.order_id =oi.order_id; 
SELECT AVG(order_total) AS average_order_value
FROM (
    SELECT 
        o.order_id,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    GROUP BY o.order_id
) t;

SELECT COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'canceled';

SELECT COUNT(DISTINCT order_id) AS returned_orders
FROM orders
WHERE LOWER(order_status) IN ('canceled','unavailable');

SELECT 
    ROUND(
        COUNT(CASE WHEN LOWER(order_status) = 'delivered' THEN 1 END) * 100.0 
        / COUNT(*), 
    2) AS success_rate
FROM orders;


#Revenue by Category
select p.product_category_name ,sum(oi.price + oi.freight_value) as revenue from order_items oi 
join products p on oi.product_id=p.product_id group by p.product_category_name order by revenue desc;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#3 product analysis
#Top Selling Categories
select p.product_category_name,count(oi.order_id) as total_sales  from order_items oi
 join products p on oi.product_id=p.product_id group by p.product_category_name order by total_sales desc limit 10;

#Low Performing Categories
select p.product_category_name,count(oi.order_id) as total_sales  from order_items oi 
join products p on oi.product_id=p.product_id group by p.product_category_name order by total_sales asc limit 10;

#Category Contribution %
select p.product_category_name ,sum(oi.price + oi.freight_value) as revenue,
 100 * sum(oi.price + oi.freight_value) / sum(sum(oi.price + oi.freight_value)) over() as contribution_pct 
 from order_items oi join products p on oi.product_id=p.product_id group by p.product_category_name order by revenue desc;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#4 REVIEW ANALYSIS
# Average Review Score
select avg(review_score) as average_review from order_reviews;

#Rating Distribution
select review_score , count(*) as total_reviews from order_reviews group by review_score order by review_score;

#Categories with Highest Ratings
select p.product_category_name,avg(orr.review_score) as avg_rating from order_reviews orr join orders o on orr.order_id=o.order_id 
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id=p.product_id
group by p.product_category_name order by avg_rating desc limit 10; 

#Categories with lowest Ratings
select p.product_category_name,avg(orr.review_score) as avg_rating from order_reviews orr join orders o on orr.order_id=o.order_id 
join order_items oi on o.order_id=oi.order_id
join products p on oi.product_id=p.product_id
group by p.product_category_name order by avg_rating asc limit 10;


#5 DELIVERY ANALYSIS
#Average Delivery Days
select (avg(datediff(order_delivered_customer_date,order_purchase_timestamp))) as avg_delivery_days from orders where order_delivered_customer_date  is not null;

#fastest delivery states
select c.customer_state,(avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)))
 as avg_delivery_days from orders o join customers c on o.customer_id=c.customer_id where order_delivered_customer_date  is not null 
 group by customer_state order by avg_delivery_days asc limit 5;

#Slowest Delivery States
select c.customer_state,(avg(datediff(o.order_delivered_customer_date,o.order_purchase_timestamp)))
 as avg_delivery_days from orders o join customers c on o.customer_id=c.customer_id where order_delivered_customer_date  is not null
 group by customer_state order by avg_delivery_days desc limit 5;

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#customer life value
#SELECT c.customer_unique_id,SUM(oi.price + oi.freight_value) AS lifetime_value FROM customers c JOIN orders o ON c.customer_id = o.customer_id
#JOIN order_items oi ON o.order_id = oi.order_id GROUP BY c.customer_unique_id ORDER BY lifetime_value DESC; 

SELECT c.customer_unique_id,SUM(oi.total_amount) AS lifetime_value FROM customers c JOIN orders o ON c.customer_id = o.customer_id
JOIN (SELECT order_id, SUM(price + freight_value) AS total_amount FROM order_items GROUP BY order_id) oi ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id ORDER BY lifetime_value DESC;


#cancellation rate
SELECT  order_status, COUNT(*) AS total_orders  FROM orders GROUP BY order_status;

#total orders
SELECT count(distinct order_id) from orders;

#total revenue
select sum(price+freight_value) from order_items;

#total customers
select count(customer_unique_id) from customers;
SELECT COUNT(DISTINCT customer_unique_id) FROM customers;


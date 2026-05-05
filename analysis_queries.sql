-- =============================================
-- 📚 ONLINE BOOKSTORE SQL PROJECT (POSTGRESQL)
-- =============================================

-- 1. DATABASE SETUP

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    genre VARCHAR(50),
    published_year INT,
    price NUMERIC(10,2),
    stock INT
);

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50),
    country VARCHAR(100)
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    book_id INT REFERENCES books(book_id),
    order_date DATE,
    quantity INT,
    total_amount NUMERIC(10,2)
);

-- =============================================
-- 2. DATA IMPORT (Use COPY in PostgreSQL)


 COPY books FROM 'D:/Online Book Store SQL Project/Books.csv' DELIMITER ',' CSV HEADER;
 COPY customers FROM 'D:/Online Book Store SQL Project/Customers.csv' DELIMITER ',' CSV HEADER;
 COPY orders FROM 'D:/Online Book Store SQL Project/Orders.csv' DELIMITER ',' CSV HEADER;

-- =============================================
-- 3. BASIC QUERIES

-- 1. Books in Fiction genre
SELECT *
FROM books
WHERE genre = 'Fiction';

-- 2. Books published after 1950
SELECT *
FROM books
WHERE published_year > 1950;

-- 3. Customers from Canada
SELECT *
FROM customers
WHERE country = 'Canada';

-- 4. Orders in November 2023
SELECT *
FROM orders
WHERE DATE_TRUNC('month', order_date) = '2023-11-01';

-- 5. Total stock available
SELECT SUM(stock) AS total_stock
FROM books;

-- 6. Most expensive book
SELECT *
FROM books
ORDER BY price DESC
LIMIT 1;

-- 7. Orders with quantity > 1
SELECT *
FROM orders
WHERE quantity > 1;

-- 8. Orders with amount > 20
SELECT *
FROM orders
WHERE total_amount > 20;

-- 9. All available genres
SELECT DISTINCT genre
FROM books;

-- 10. Book with lowest stock
SELECT *
FROM books
ORDER BY stock ASC
LIMIT 1;

-- 11. Total revenue
SELECT SUM(total_amount) AS total_revenue
FROM orders;

-- =============================================
-- 4. INTERMEDIATE ANALYSIS

-- 1. Total books sold per genre
SELECT 
    b.genre,
    SUM(o.quantity) AS total_books_sold
FROM orders o
JOIN books b ON o.book_id = b.book_id
GROUP BY b.genre
ORDER BY total_books_sold DESC;

-- 2. Average price (Fantasy)
SELECT AVG(price) AS avg_price
FROM books
WHERE genre = 'Fantasy';

-- 3. Customers with at least 2 orders
SELECT 
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) >= 2;

-- 4. Most frequently ordered books
SELECT 
    book_id,
    COUNT(order_id) AS order_count
FROM orders
GROUP BY book_id
ORDER BY order_count DESC;

-- 5. Top 3 expensive Fantasy books
SELECT *
FROM books
WHERE genre = 'Fantasy'
ORDER BY price DESC
LIMIT 3;

-- 6. Books sold per author
SELECT 
    b.author,
    SUM(o.quantity) AS total_sold
FROM books b
JOIN orders o ON b.book_id = o.book_id
GROUP BY b.author
ORDER BY total_sold DESC;

-- 7. Cities with high-value customers (>30 spend)
SELECT DISTINCT c.city
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.total_amount > 30;

-- 8. Top spending customer
SELECT 
    c.customer_id,
    c.name,
    SUM(o.total_amount) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC
LIMIT 1;

-- 9. Remaining stock after orders
SELECT 
    b.book_id,
    b.title,
    b.stock,
    COALESCE(SUM(o.quantity), 0) AS sold_quantity,
    b.stock - COALESCE(SUM(o.quantity), 0) AS remaining_stock
FROM books b
LEFT JOIN orders o ON b.book_id = o.book_id
GROUP BY b.book_id, b.title, b.stock
ORDER BY b.book_id;

-- =============================================
-- 5. ADVANCED ANALYSIS (ANALYST LEVEL)

-- 1. Top 5 best-selling books
SELECT 
    b.title,
    SUM(o.quantity) AS total_sold
FROM orders o
JOIN books b ON o.book_id = b.book_id
GROUP BY b.title
ORDER BY total_sold DESC
LIMIT 5;

-- 2. Monthly revenue trend
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_amount) AS revenue
FROM orders
GROUP BY month
ORDER BY month;

-- 3. Customer segmentation
SELECT 
    CASE 
        WHEN SUM(o.total_amount) > 500 THEN 'High Value'
        WHEN SUM(o.total_amount) BETWEEN 200 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment,
    COUNT(*) AS customer_count
FROM orders o
GROUP BY segment;

-- 4. Rank books by sales (Window Function)
SELECT 
    b.title,
    SUM(o.quantity) AS total_sold,
    RANK() OVER (ORDER BY SUM(o.quantity) DESC) AS rank
FROM orders o
JOIN books b ON o.book_id = b.book_id
GROUP BY b.title;

-- =============================================
-- 📌 END OF PROJECT
-- =============================================









CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,            
    phone_encrypted VARBINARY(255) NOT NULL,          
    city VARCHAR(50) NOT NULL,                      
    subcity_or_wereda VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(12, 2) NOT NULL CHECK (price >= 0),
    is_active TINYINT(1) DEFAULT 1,               
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    stock_level INT NOT NULL CHECK (stock_level >= 0), 
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE 
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status ENUM('placed', 'paid', 'shipped', 'delivered') NOT NULL DEFAULT 'placed',
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(12, 2) NOT NULL,
    UNIQUE KEY unique_order_product (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE, 
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT 
);

CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    method ENUM('Telebirr', 'Bank Transfer', 'Cash on Delivery') NOT NULL, 
    status ENUM('pending', 'completed', 'failed', 'refunded') NOT NULL DEFAULT 'pending',
    transaction_reference VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE RESTRICT
);

CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action_performed VARCHAR(255) NOT NULL,     
    ip_address VARCHAR(45) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
); 

CREATE INDEX idx_products_cat_price ON products(category_id, price); 
CREATE INDEX idx_orders_customer_date ON orders(customer_id, created_at DESC); 
CREATE INDEX idx_inventory_stock ON inventory(stock_level); 
CREATE FULLTEXT INDEX idx_products_title_search ON products(title, description); 

INSERT INTO categories (category_id, category_name) VALUES 
(1, 'Electronics'), (2, 'Fashion'), (3, 'Books'), (4, 'Home appliances'), (5, 'Vegetables and fruits');

INSERT INTO customers (customer_id, name, email, password_hash, phone_encrypted, city, subcity_or_wereda) VALUES 
(201, 'Liul Birhanu ', 'liul@gmail.com', SHA2('pass123', 256), AES_ENCRYPT('+251910124578', 'EthioKey2026!'), 'Addis Ababa', 'Bole'),
(202, 'Tirukelem Alemayehu', 'tirukelem@gmail.com', SHA2('pass456', 256), AES_ENCRYPT('+251956784231', 'EthioKey2026!'), 'Mizan Aman', '04 Kebele'), 
(203, 'Mudin Abilu', 'mudinabilu@gmail.com', SHA2('pass789', 256), AES_ENCRYPT('+251933764589', 'EthioKey2026!'), 'Hawassa', 'Tabor'),
(204, 'Mulualem Wubale', 'mulualem@gmail.com', SHA2('pass749', 256), AES_ENCRYPT('+251924096734', 'EthioKey2026!'), 'Bonga', '01 kebele'),
(205, 'Mekonnen Eshetu', 'mekonnen34@gmail.com', SHA2('pass271', 256), AES_ENCRYPT('+251935789043', 'EthioKey2026!'), 'Debre Birhan', 'Tebase');

INSERT INTO products (product_id, category_id, title, description, price) VALUES 
(1, 1, 'Laptop', 'High performance computing machine', 35000.00),
(2, 1, 'Phone', 'Flagship smartphone', 15000.00),
(3, 2, 'Shoes', 'Comfortable running gear', 1200.00),
(4, 2, 'Leather Jacket', 'Genuine Ethiopian sheep leather jacket', 7500.00),
(5, 3, 'Fikir Eske Mekabir', 'Classic Ethiopian Amharic Novel by Haddis Alemayehu', 150.00),
(6, 3, 'Advanced Database Systems', 'Academic reference book for computer science', 120.00),
(7, 4, 'Midea Refrigerator', 'Double door energy saving fridge', 48000.00),
(8, 4, 'Philips Smart TV 55\"', '4K Ultra HD LED Smart Television', 65000.00),
(9, 5, 'Fresh Organic Bananas (1kg)', 'Sweet local bananas from Arba Minch', 120.00), 
(10, 5, 'Red Onions (10kg Bag)', 'Freshly harvested local red onions', 950.00);

INSERT INTO inventory (product_id, stock_level) VALUES 
(1, 10), (2, 20), (3, 50), (4, 35), (5, 100), (6, 15), (7, 4), (8, 12), (9, 300), (10, 150);

INSERT INTO orders (order_id, customer_id, total_amount, status, shipping_address) VALUES 
(1, 201, 15000.00, 'delivered', 'Addis Ababa, Bole Wereda 03, H.No 402'),
(2, 202, 35000.00, 'placed', 'Mzan Aman, 04 Kebele, Near Aman cumpas'), 
(3, 203, 240.00, 'paid', 'Hawassa, Tabor Subcity'),
(4, 204, 48000.00, 'shipped', 'Bonga, 01 kebele'),
(5, 205, 1490.00, 'placed', 'Debre Birhan,Tebase sub sity, Kebele 02');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES 
(1, 2, 1, 15000.00),
(2, 1, 1, 35000.00),
(3, 6, 2, 120.00),  
(4, 7, 1, 48000.00), 
(5, 9, 2, 120.00),  
(5, 10, 1, 950.00), 
(5, 5, 2, 150.00);

INSERT INTO payments (order_id, method, status, transaction_reference) VALUES 
(1, 'Telebirr', 'completed', 'TXN-TB-99881'),
(2, 'Cash on Delivery', 'pending', NULL),
(3, 'Telebirr', 'completed', 'TXN-TB-554433'),
(4, 'Bank Transfer', 'completed', 'TXN-CBE-889911'),
(5, 'Telebirr', 'pending', 'TXN-TB-001122');

INSERT INTO audit_logs (user_id, action_performed, ip_address) VALUES 
(201, 'CUSTOMER_LOGIN_SUCCESS', '196.188.12.45'),
(201, 'ORDER_PLACEMENT_SUCCESS', '196.188.12.45'),
(203, 'PAYMENT_SUBMIT_TELEBIRR', '197.156.33.12'),
(NULL, 'FAILED_LOGIN_ATTEMPT', '213.55.85.99');

EXPLAIN SELECT product_id, title, price 
FROM products 
WHERE category_id = 1 
  AND price BETWEEN 1000 AND 20000 
  AND MATCH(title, description) AGAINST('Laptop' IN NATURAL LANGUAGE MODE);
  
SELECT p.product_id, p.title, SUM(oi.quantity) AS total_units_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.title
ORDER BY total_units_sold DESC
LIMIT 10;  

EXPLAIN SELECT order_id, total_amount, status, created_at 
FROM orders 
WHERE customer_id = 201 
ORDER BY created_at DESC;

SELECT 
    DATE_FORMAT(created_at, '%Y-%m') AS revenue_month,
    SUM(total_amount) AS total_revenue,
    COUNT(order_id) AS total_orders
FROM orders
WHERE status IN ('paid', 'shipped', 'delivered')
GROUP BY DATE_FORMAT(created_at, '%Y-%m');

SELECT p.product_id, p.title, i.stock_level
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE i.stock_level <= 10;

SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT stock_level FROM inventory WHERE product_id = 1 FOR UPDATE; 
UPDATE inventory 
SET stock_level = stock_level - 1 
WHERE product_id = 1 AND stock_level >= 1;

 INSERT INTO orders (customer_id, total_amount, status, shipping_address) 
VALUES (203, 35000.00, 'placed', 'Hawassa, Tabor Subcity');
COMMIT;

CREATE ROLE IF NOT EXISTS 'admin_role';
CREATE ROLE IF NOT EXISTS 'seller_role';
CREATE ROLE IF NOT EXISTS 'customer_role';

GRANT ALL PRIVILEGES ON ecommerce_db.* TO 'admin_role';

GRANT SELECT, INSERT, UPDATE, DELETE ON ecommerce_db.products TO 'seller_role';
GRANT SELECT, UPDATE ON ecommerce_db.inventory TO 'seller_role';
GRANT SELECT ON ecommerce_db.orders TO 'seller_role';

GRANT SELECT ON ecommerce_db.products TO 'customer_role';
GRANT SELECT ON ecommerce_db.categories TO 'customer_role';
GRANT INSERT, SELECT ON ecommerce_db.orders TO 'customer_role';
GRANT INSERT, SELECT ON ecommerce_db.order_items TO 'customer_role';

CREATE USER IF NOT EXISTS 'ethio_admin'@'localhost' IDENTIFIED BY 'Admin@Secure2018';
CREATE USER IF NOT EXISTS 'ethio_seller'@'localhost' IDENTIFIED BY 'Seller@Secure2018';

GRANT 'admin_role' TO 'ethio_admin'@'localhost';
GRANT 'seller_role' TO 'ethio_seller'@'localhost';

SET DEFAULT ROLE ALL TO 'ethio_admin'@'localhost', 'ethio_seller'@'localhost';

-- CREATE TABLE Scripts
CREATE SCHEMA CUSTOMER_RETENTION_ASSIGNMENT;
USE CUSTOMER_RETENTION_ASSIGNMENT;


CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    registration_date DATE DEFAULT (CURRENT_DATE),
    account_status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Customer_Addresses (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    address_type ENUM('shipping', 'billing', 'gift') NOT NULL,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_address_type (address_type)
);

CREATE TABLE Customer_Segments (
    segment_id INT AUTO_INCREMENT PRIMARY KEY,
    segment_name VARCHAR(50) NOT NULL UNIQUE,
    segment_description VARCHAR(255),
    criteria_definition TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL CHECK (total_amount >= 0),
    sales_channel ENUM('online', 'store') NOT NULL,
    order_status ENUM('pending', 'processing', 'completed', 'cancelled', 'returned') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE RESTRICT,
    INDEX idx_customer_id (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_order_status (order_status)
);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method ENUM('credit_card', 'debit_card', 'digital_wallet', 'cash', 'gift_card') NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'completed',
    transaction_reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_payment_date (payment_date)
);

CREATE TABLE Loyalty_Points_Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    transaction_type ENUM('earned', 'redeemed', 'expired', 'adjusted') NOT NULL,
    points_amount INT NOT NULL,
    transaction_date DATE NOT NULL,
    order_id INT,
    description VARCHAR(255),
    expiry_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE SET NULL,
    INDEX idx_customer_id (customer_id),
    INDEX idx_transaction_date (transaction_date),
    INDEX idx_transaction_type (transaction_type)
);

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    base_price DECIMAL(10,2) NOT NULL CHECK (base_price > 0),
    active_status BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_name (product_name),
    INDEX idx_active_status (active_status)
);

CREATE TABLE Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    category_description VARCHAR(255),
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id) ON DELETE SET NULL,
    INDEX idx_parent_category (parent_category_id)
);

CREATE TABLE Product_Reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    review_date DATE NOT NULL,
    helpful_count INT DEFAULT 0 CHECK (helpful_count >= 0),
    verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_product_id (product_id),
    INDEX idx_rating (rating),
    INDEX idx_review_date (review_date)
);




CREATE TABLE Loyalty_Programs (
    tier_id INT AUTO_INCREMENT PRIMARY KEY,
    tier_name VARCHAR(50) NOT NULL UNIQUE,
    points_threshold INT NOT NULL CHECK (points_threshold >= 0),
    discount_percentage DECIMAL(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    benefits_description VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Marketing_Campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(100) NOT NULL,
    campaign_type ENUM('email', 'social_media', 'in_store', 'sms', 'push_notification') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    target_segment VARCHAR(50),
    campaign_budget DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CHECK (end_date >= start_date),
    INDEX idx_start_date (start_date),
    INDEX idx_campaign_type (campaign_type)
); 

CREATE TABLE Support_Tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    issue_type VARCHAR(100) NOT NULL,
    priority ENUM('low', 'medium', 'high', 'urgent') DEFAULT 'medium',
    status ENUM('open', 'in_progress', 'resolved', 'closed') DEFAULT 'open',
    created_date DATE NOT NULL,
    resolution_date DATE,
    satisfaction_rating INT CHECK (satisfaction_rating BETWEEN 1 AND 5),
    ticket_description TEXT,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    INDEX idx_customer_id (customer_id),
    INDEX idx_status (status),
    INDEX idx_priority (priority),
    INDEX idx_created_date (created_date),
    CHECK (resolution_date IS NULL OR resolution_date >= created_date)
);

CREATE TABLE Order_Items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price_at_purchase DECIMAL(10,2) NOT NULL CHECK (unit_price_at_purchase >= 0),
    line_discount DECIMAL(10,2) DEFAULT 0 CHECK (line_discount >= 0),
    line_total DECIMAL(10,2) GENERATED ALWAYS AS ((quantity * unit_price_at_purchase) - line_discount) STORED,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE RESTRICT,
    UNIQUE KEY unique_order_product (order_id, product_id),
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id)
);

CREATE TABLE Product_Categories (
    product_id INT NOT NULL,
    category_id INT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    assigned_date DATE DEFAULT (CURRENT_DATE),
    PRIMARY KEY (product_id, category_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE,
    INDEX idx_category_id (category_id),
    INDEX idx_is_primary (is_primary)
);

CREATE TABLE Loyalty_Memberships (
    membership_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    tier_id INT NOT NULL,
    enrollment_date DATE NOT NULL,
    points_balance INT DEFAULT 0 CHECK (points_balance >= 0),
    tier_start_date DATE NOT NULL,
    tier_end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (tier_id) REFERENCES Loyalty_Programs(tier_id) ON DELETE RESTRICT,
    INDEX idx_customer_id (customer_id),
    INDEX idx_tier_id (tier_id),
    INDEX idx_is_active (is_active),
    CHECK (tier_end_date IS NULL OR tier_end_date >= tier_start_date)
);

CREATE TABLE Customer_Campaigns (
    customer_id INT NOT NULL,
    campaign_id INT NOT NULL,
    participation_date DATE NOT NULL,
    response_status ENUM('sent', 'opened', 'clicked', 'converted', 'unsubscribed') DEFAULT 'sent',
    response_date DATE,
    conversion_value DECIMAL(10,2),
    PRIMARY KEY (customer_id, campaign_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (campaign_id) REFERENCES Marketing_Campaigns(campaign_id) ON DELETE CASCADE,
    INDEX idx_campaign_id (campaign_id),
    INDEX idx_response_status (response_status),
    INDEX idx_participation_date (participation_date)
);

-- Sample Data Population
INSERT INTO Customers (full_name, email, phone, registration_date, account_status) VALUES
('Mariam Yusuf', 'mariam.yusuf@email.com', '555-0101', '2023-01-15', 'active'),
('Michael Chen', 'michael.chen@email.com', '555-0102', '2023-02-20', 'active'),
('Emily Rodriguez', 'emily.rodriguez@email.com', '555-0103', '2023-03-10', 'active'),
('James Williams', 'james.williams@email.com', '555-0104', '2023-04-05', 'active'),
('Amanda Brown', 'amanda.brown@email.com', '555-0105', '2023-05-12', 'inactive'),
('David Lee', 'david.lee@email.com', '555-0106', '2023-06-18', 'active'),
('Jessica Taylor', 'jessica.taylor@email.com', '555-0107', '2023-07-22', 'active'),
('Robert Martinez', 'robert.martinez@email.com', '555-0108', '2023-08-30', 'suspended'),
('Jennifer Davis', 'jennifer.davis@email.com', '555-0109', '2023-09-14', 'active'),
('Christopher Wilson', 'christopher.wilson@email.com', '555-0110', '2023-10-25', 'active');

INSERT INTO Customer_Addresses (customer_id, address_type, address_line1, address_line2, city, postal_code, country, is_default) VALUES
(1, 'shipping', '123 Main Street', 'Apt 4B', 'New York', '10001', 'USA', TRUE),
(1, 'billing', '123 Main Street', 'Apt 4B', 'New York', '10001', 'USA', TRUE),
(2, 'shipping', '456 Oak Avenue', NULL, 'Los Angeles', '90001', 'USA', TRUE),
(2, 'billing', '456 Oak Avenue', NULL, 'Los Angeles', '90001', 'USA', TRUE),
(3, 'shipping', '789 Pine Road', 'Suite 200', 'Chicago', '60601', 'USA', TRUE),
(3, 'billing', '321 Elm Street', NULL, 'Chicago', '60602', 'USA', FALSE),
(4, 'shipping', '147 Maple Drive', NULL, 'Houston', '77001', 'USA', TRUE),
(5, 'shipping', '258 Cedar Lane', 'Unit 12', 'Phoenix', '85001', 'USA', TRUE),
(6, 'shipping', '369 Birch Boulevard', NULL, 'Philadelphia', '19101', 'USA', TRUE),
(7, 'shipping', '741 Willow Way', NULL, 'San Antonio', '78201', 'USA', TRUE),
(8, 'shipping', '852 Ash Court', 'Building C', 'San Diego', '92101', 'USA', TRUE),
(9, 'shipping', '963 Spruce Street', NULL, 'Dallas', '75201', 'USA', TRUE),
(10, 'shipping', '159 Fir Avenue', NULL, 'San Jose', '95101', 'USA', TRUE);


INSERT INTO Customer_Segments (segment_name, segment_description, criteria_definition) VALUES
('High Value', 'Top spending customers with high lifetime value', 'Total purchases > $5000 AND active within 3 months'),
('At Risk', 'Previously active customers showing declining engagement', 'No purchase in 6+ months AND previous purchase frequency > 2/month'),
('New Customer', 'Recently registered customers', 'Registration date within last 90 days'),
('Repeat Buyer', 'Regular customers with consistent purchase patterns', 'Purchase frequency 2-4 times per month'),
('Dormant', 'Inactive customers requiring reactivation', 'No purchase in 12+ months'),
('Occasional Shopper', 'Infrequent but consistent buyers', 'Purchase frequency 1-2 times per quarter'),
('Loyal Advocate', 'High engagement with reviews and referrals', 'Multiple reviews AND referred customers'),
('Price Sensitive', 'Primarily responds to promotions', 'Most purchases during sale periods');


INSERT INTO Categories (category_name, category_description, parent_category_id) VALUES
('Electronics', 'Electronic devices and accessories', NULL),
('Mobile Phones', 'Smartphones and mobile devices', 1),
('Laptops', 'Laptop computers and accessories', 1),
('Audio', 'Headphones, speakers, and audio equipment', 1),
('Clothing', 'Apparel and fashion items', NULL),
('Home & Garden', 'Home improvement and garden supplies', NULL),
('Health & Wellness', 'Health and fitness products', NULL),
('Gaming', 'Video games and gaming accessories', NULL),
('Books', 'Physical and digital books', NULL),
('Sports', 'Sports equipment and athletic wear', NULL);

INSERT INTO Products (product_name, description, base_price, active_status) VALUES
('Wireless Bluetooth Headphones', 'Premium noise-canceling over-ear headphones with 30-hour battery life', 149.99, TRUE),
('Smartphone Pro X', 'Latest flagship smartphone with 256GB storage and advanced camera system', 999.99, TRUE),
('Laptop Ultra 15', '15-inch laptop with Intel i7 processor, 16GB RAM, 512GB SSD', 1299.99, TRUE),
('Fitness Tracker Band', 'Water-resistant fitness tracker with heart rate monitor and sleep tracking', 79.99, TRUE),
('Portable Bluetooth Speaker', 'Compact wireless speaker with 360-degree sound and 12-hour battery', 59.99, TRUE),
('Gaming Mouse Pro', 'High-precision gaming mouse with RGB lighting and programmable buttons', 49.99, TRUE),
('Laptop Backpack', 'Durable laptop backpack with multiple compartments and USB charging port', 39.99, TRUE),
('Wireless Charger Pad', 'Fast wireless charging pad compatible with all Qi-enabled devices', 24.99, TRUE),
('USB-C Hub Adapter', '7-in-1 USB-C hub with HDMI, USB 3.0, and SD card reader', 34.99, TRUE),
('Ergonomic Keyboard', 'Split ergonomic keyboard with mechanical switches and wrist rest', 89.99, TRUE);


INSERT INTO Product_Categories (product_id, category_id, is_primary) VALUES
(1, 4, TRUE), 
(1, 1, FALSE),  
(2, 2, TRUE),  
(2, 1, FALSE),  
(3, 3, TRUE),  
(3, 1, FALSE),  
(4, 7, TRUE),   
(4, 1, FALSE),  
(5, 4, TRUE),  
(6, 8, TRUE),   
(6, 1, FALSE),  
(7, 6, TRUE),   
(8, 1, TRUE),  
(9, 1, TRUE),  
(10, 1, TRUE);  




INSERT INTO Product_Reviews (customer_id, product_id, rating, review_text, review_date, helpful_count, verified_purchase) VALUES
(1, 1, 5, 'Excellent sound quality and comfortable for long listening sessions. Battery life is impressive!', '2023-02-20', 12, TRUE),
(2, 2, 4, 'Great phone with amazing camera, but battery could be better. Overall very satisfied.', '2023-03-15', 8, TRUE),
(3, 3, 5, 'Perfect laptop for work and productivity. Fast performance and beautiful display.', '2023-04-10', 15, TRUE),
(4, 4, 4, 'Good fitness tracker for the price. Accurate heart rate monitoring and easy to use app.', '2023-05-20', 6, TRUE),
(5, 5, 5, 'Amazing sound from such a small speaker! Great for outdoor activities.', '2023-06-15', 9, TRUE),
(1, 7, 5, 'Very durable backpack with great organization. Perfect for my laptop and accessories.', '2023-07-10', 4, TRUE),
(6, 1, 4, 'Good headphones but a bit tight at first. Sound quality is excellent though.', '2023-08-05', 3, TRUE),
(7, 6, 5, 'Best gaming mouse I have owned. Precision is incredible and customization options are great.', '2023-09-12', 7, TRUE);



INSERT INTO Loyalty_Programs (tier_name, points_threshold, discount_percentage, benefits_description) VALUES
('Bronze', 0, 5.00, 'Entry level: 5% discount on all purchases, birthday bonus points'),
('Silver', 1000, 10.00, 'Mid tier: 10% discount, free shipping on orders over $50, early access to sales'),
('Gold', 5000, 15.00, 'Premium: 15% discount, free shipping on all orders, priority customer support, exclusive products'),
('Platinum', 10000, 20.00, 'Elite: 20% discount, free express shipping, dedicated account manager, invitation-only events');



INSERT INTO Orders (customer_id, order_date, total_amount, sales_channel, order_status) VALUES
(1, '2023-02-15', 189.98, 'online', 'completed'),
(1, '2023-05-20', 1299.99, 'online', 'completed'),
(1, '2023-08-10', 84.98, 'store', 'completed'),
(2, '2023-03-10', 999.99, 'online', 'completed'),
(2, '2023-07-15', 149.99, 'store', 'completed'),
(3, '2023-04-05', 1299.99, 'online', 'completed'),
(3, '2023-09-20', 104.98, 'online', 'completed'),
(4, '2023-05-12', 79.99, 'online', 'completed'),
(4, '2023-10-05', 199.98, 'store', 'completed'),
(5, '2023-06-10', 59.99, 'online', 'completed'),
(6, '2023-07-18', 189.98, 'online', 'completed'),
(6, '2023-11-22', 1349.98, 'online', 'completed'),
(7, '2023-08-25', 49.99, 'store', 'completed'),
(7, '2023-12-01', 129.98, 'online', 'completed'),
(8, '2023-09-10', 999.99, 'online', 'returned'),
(9, '2023-10-15', 299.97, 'online', 'completed'),
(9, '2023-12-20', 174.98, 'store', 'completed'),
(10, '2023-11-05', 1439.97, 'online', 'completed');



INSERT INTO Order_Items (order_id, product_id, quantity, unit_price_at_purchase, line_discount) VALUES
(1, 1, 1, 149.99, 0.00),
(1, 7, 1, 39.99, 0.00),
(2, 3, 1, 1299.99, 0.00),
(3, 4, 1, 79.99, 0.00),
(3, 8, 2, 24.99, 5.00),
(4, 2, 1, 999.99, 0.00),
(5, 1, 1, 149.99, 0.00),
(6, 3, 1, 1299.99, 0.00),
(7, 5, 1, 59.99, 0.00),
(7, 9, 1, 34.99, 0.00),
(7, 8, 1, 24.99, 5.00),
(8, 4, 1, 79.99, 0.00),
(9, 1, 1, 149.99, 0.00),
(9, 6, 1, 49.99, 0.00),
(10, 5, 1, 59.99, 0.00),
(11, 1, 1, 149.99, 0.00),
(11, 7, 1, 39.99, 0.00),
(12, 3, 1, 1299.99, 0.00),
(12, 6, 1, 49.99, 0.00),
(13, 6, 1, 49.99, 0.00),
(14, 4, 1, 79.99, 0.00),
(14, 6, 1, 49.99, 0.00),
(15, 2, 1, 999.99, 0.00),
(16, 1, 2, 149.99, 0.00),
(17, 4, 1, 79.99, 0.00),
(17, 5, 1, 59.99, 10.00),
(17, 9, 1, 34.99, 0.00),
(18, 3, 1, 1299.99, 0.00),
(18, 1, 1, 149.99, 0.00),
(18, 8, 4, 24.99, 10.00);

INSERT INTO Payments (order_id, payment_method, payment_date, amount, payment_status, transaction_reference) VALUES
(1, 'credit_card', '2023-02-15', 189.98, 'completed', 'TXN-20230215-001'),
(2, 'credit_card', '2023-05-20', 1299.99, 'completed', 'TXN-20230520-002'),
(3, 'debit_card', '2023-08-10', 84.98, 'completed', 'TXN-20230810-003'),
(4, 'digital_wallet', '2023-03-10', 999.99, 'completed', 'TXN-20230310-004'),
(5, 'cash', '2023-07-15', 149.99, 'completed', 'TXN-20230715-005'),
(6, 'credit_card', '2023-04-05', 1299.99, 'completed', 'TXN-20230405-006'),
(7, 'credit_card', '2023-09-20', 104.98, 'completed', 'TXN-20230920-007'),
(8, 'digital_wallet', '2023-05-12', 79.99, 'completed', 'TXN-20230512-008'),
(9, 'credit_card', '2023-10-05', 199.98, 'completed', 'TXN-20231005-009'),
(10, 'debit_card', '2023-06-10', 59.99, 'completed', 'TXN-20230610-010'),
(11, 'credit_card', '2023-07-18', 189.98, 'completed', 'TXN-20230718-011'),
(12, 'credit_card', '2023-11-22', 1349.98, 'completed', 'TXN-20231122-012'),
(13, 'cash', '2023-08-25', 49.99, 'completed', 'TXN-20230825-013'),
(14, 'digital_wallet', '2023-12-01', 129.98, 'completed', 'TXN-20231201-014'),
(15, 'credit_card', '2023-09-10', 999.99, 'refunded', 'TXN-20230910-015'),
(16, 'credit_card', '2023-10-15', 299.97, 'completed', 'TXN-20231015-016'),
(17, 'debit_card', '2023-12-20', 174.98, 'completed', 'TXN-20231220-017'),
(18, 'credit_card', '2023-11-05', 1439.97, 'completed', 'TXN-20231105-018');


INSERT INTO Loyalty_Memberships (customer_id, tier_id, enrollment_date, points_balance, tier_start_date, tier_end_date, is_active) VALUES
(1, 3, '2023-02-15', 8500, '2023-08-15', NULL, TRUE),     
(2, 2, '2023-03-10', 2200, '2023-07-10', NULL, TRUE),     
(3, 3, '2023-04-05', 6800, '2023-09-05', NULL, TRUE),     
(4, 1, '2023-05-12', 550, '2023-05-12', NULL, TRUE),      
(5, 1, '2023-06-10', 300, '2023-06-10', NULL, FALSE),      
(6, 4, '2023-07-18', 12000, '2023-11-18', NULL, TRUE),     
(7, 1, '2023-08-25', 800, '2023-08-25', NULL, TRUE),       
(8, 2, '2023-09-10', 1500, '2023-09-10', NULL, FALSE),     
(9, 2, '2023-10-15', 2400, '2023-10-15', NULL, TRUE),      
(10, 3, '2023-11-05', 7200, '2023-11-05', NULL, TRUE);     

INSERT INTO Loyalty_Points_Transactions (customer_id, transaction_type, points_amount, transaction_date, order_id, description, expiry_date) VALUES
(1, 'earned', 190, '2023-02-15', 1, 'Points earned from order #1', '2024-02-15'),
(1, 'earned', 1300, '2023-05-20', 2, 'Points earned from order #2', '2024-05-20'),
(1, 'redeemed', -200, '2023-06-01', NULL, 'Redeemed for $20 discount', NULL),
(1, 'earned', 85, '2023-08-10', 3, 'Points earned from order #3', '2024-08-10'),
(2, 'earned', 1000, '2023-03-10', 4, 'Points earned from order #4', '2024-03-10'),
(2, 'earned', 150, '2023-07-15', 5, 'Points earned from order #5', '2024-07-15'),
(2, 'earned', 500, '2023-08-01', NULL, 'Bonus points for birthday', '2024-08-01'),
(3, 'earned', 1300, '2023-04-05', 6, 'Points earned from order #6', '2024-04-05'),
(3, 'earned', 105, '2023-09-20', 7, 'Points earned from order #7', '2024-09-20'),
(4, 'earned', 80, '2023-05-12', 8, 'Points earned from order #8', '2024-05-12'),
(4, 'earned', 200, '2023-10-05', 9, 'Points earned from order #9', '2024-10-05'),
(5, 'earned', 60, '2023-06-10', 10, 'Points earned from order #10', '2024-06-10'),
(6, 'earned', 190, '2023-07-18', 11, 'Points earned from order #11', '2024-07-18'),
(6, 'earned', 1350, '2023-11-22', 12, 'Points earned from order #12', '2024-11-22'),
(6, 'redeemed', -500, '2023-12-01', NULL, 'Redeemed for premium product access', NULL),
(7, 'earned', 50, '2023-08-25', 13, 'Points earned from order #13', '2024-08-25'),
(7, 'earned', 130, '2023-12-01', 14, 'Points earned from order #14', '2024-12-01'),
(9, 'earned', 300, '2023-10-15', 16, 'Points earned from order #16', '2024-10-15'),
(9, 'earned', 175, '2023-12-20', 17, 'Points earned from order #17', '2024-12-20'),
(10, 'earned', 1440, '2023-11-05', 18, 'Points earned from order #18', '2024-11-05');

INSERT INTO Marketing_Campaigns (campaign_name, campaign_type, start_date, end_date, target_segment, campaign_budget) VALUES
('Spring Sale 2023', 'email', '2023-03-01', '2023-03-31', 'All Customers', 5000.00),
('Summer Electronics Promotion', 'social_media', '2023-06-01', '2023-06-30', 'High Value', 8000.00),
('Back to School Campaign', 'email', '2023-08-01', '2023-08-31', 'New Customer', 6000.00),
('Holiday Gift Guide', 'email', '2023-11-15', '2023-12-24', 'All Customers', 10000.00),
('Loyalty Rewards Boost', 'push_notification', '2023-09-01', '2023-09-30', 'Repeat Buyer', 3000.00),
('Win-Back Campaign', 'email', '2023-10-01', '2023-10-31', 'At Risk', 4000.00),
('Flash Sale Weekend', 'sms', '2023-07-14', '2023-07-16', 'High Value', 2000.00),
('New Year New Tech', 'social_media', '2024-01-01', '2024-01-15', 'All Customers', 7000.00);

INSERT INTO Customer_Campaigns (customer_id, campaign_id, participation_date, response_status, response_date, conversion_value) VALUES
(1, 1, '2023-03-01', 'converted', '2023-03-05', 189.98),
(1, 2, '2023-06-01', 'clicked', '2023-06-03', NULL),
(1, 4, '2023-11-15', 'opened', '2023-11-16', NULL),
(2, 1, '2023-03-01', 'converted', '2023-03-10', 999.99),
(2, 2, '2023-06-01', 'opened', '2023-06-02', NULL),
(3, 1, '2023-03-01', 'converted', '2023-04-05', 1299.99),
(3, 3, '2023-08-01', 'clicked', '2023-08-05', NULL),
(4, 3, '2023-08-01', 'sent', NULL, NULL),
(4, 5, '2023-09-01', 'converted', '2023-10-05', 199.98),
(5, 6, '2023-10-01', 'opened', '2023-10-02', NULL),
(6, 2, '2023-06-01', 'converted', '2023-07-18', 189.98),
(6, 4, '2023-11-15', 'converted', '2023-11-22', 1349.98),
(7, 3, '2023-08-01', 'converted', '2023-08-25', 49.99),
(7, 4, '2023-11-15', 'converted', '2023-12-01', 129.98),
(8, 1, '2023-03-01', 'sent', NULL, NULL),
(9, 5, '2023-09-01', 'clicked', '2023-09-10', NULL),
(9, 4, '2023-11-15', 'converted', '2023-12-20', 174.98),
(10, 4, '2023-11-15', 'converted', '2023-11-05', 1439.97);

INSERT INTO Support_Tickets (customer_id, issue_type, priority, status, created_date, resolution_date, satisfaction_rating, ticket_description, resolution_notes) VALUES
(1, 'Product Question', 'low', 'closed', '2023-02-18', '2023-02-18', 5, 'Question about headphone battery life', 'Provided detailed battery specifications and usage tips'),
(2, 'Delivery Delay', 'high', 'closed', '2023-03-12', '2023-03-14', 4, 'Order not received on expected date', 'Tracked package, expedited delivery, issued partial refund'),
(3, 'Technical Support', 'medium', 'closed', '2023-04-10', '2023-04-11', 5, 'Laptop setup assistance needed', 'Provided remote setup support via video call'),
(4, 'Return Request', 'medium', 'closed', '2023-05-15', '2023-05-20', 3, 'Fitness tracker not syncing properly', 'Processed return, issued full refund'),
(5, 'Account Issue', 'low', 'closed', '2023-06-12', '2023-06-12', 4, 'Cannot access loyalty points', 'Reset account credentials, restored access'),
(6, 'Product Recommendation', 'low', 'closed', '2023-07-20', '2023-07-20', 5, 'Looking for laptop accessories', 'Recommended compatible products based on purchase history'),
(7, 'Billing Question', 'high', 'closed', '2023-08-28', '2023-08-28', 5, 'Charge appears twice on statement', 'Verified single charge, provided transaction details'),
(8, 'Return Request', 'urgent', 'closed', '2023-09-12', '2023-09-15', 2, 'Smartphone not as described', 'Processed return, issued refund, account suspended due to policy'),
(9, 'Product Question', 'low', 'closed', '2023-10-18', '2023-10-18', 5, 'Compatibility question for USB-C hub', 'Confirmed compatibility with customer laptop model'),
(10, 'Delivery Question', 'medium', 'closed', '2023-11-07', '2023-11-08', 5, 'Request for faster shipping method', 'Upgraded to express shipping at no additional cost');

-- First View
CREATE VIEW monthly_cohort_retention AS (
WITH COHORT AS
(SELECT customer_id, DATE_FORMAT(MIN(order_date), '%Y-%m') AS cohort_month from orders
GROUP BY customer_id),
ORDER_MONTH AS
(SELECT customer_id, DATE_FORMAT(order_date, '%Y-%m') AS order_month from orders),
ORDER_COHORT AS 
(SELECT C.cohort_month, O.order_month, 
COUNT(DISTINCT(C.customer_id)) AS num_customers 
FROM COHORT C 
LEFT JOIN ORDER_MONTH O
USING(customer_id)
GROUP BY C.cohort_month, O.order_month),
COHORT_SIZE AS
(SELECT cohort_month, COUNT(customer_id) AS size 
FROM cohort
GROUP BY cohort_month)
SELECT OC.cohort_month, 
OC.order_month, 
OC.num_customers,
ROUND(OC.num_customers / CS.size * 100, 2) AS retention_rate
FROM ORDER_COHORT AS OC
LEFT JOIN COHORT_SIZE AS CS
ON OC.cohort_month = CS.cohort_month
ORDER BY OC.cohort_month, OC.order_month);

SELECT * FROM monthly_cohort_retention;

-- Second View
CREATE VIEW customer_retention_metrics AS

WITH CUSTOMER_ORDERS AS (
SELECT C.customer_id, registration_date, COUNT(O.order_id) AS total_orders,
MIN(O.order_date) AS first_order,
MAX(O.order_date) AS last_order
FROM customers C
LEFT JOIN ORDERS O
USING (customer_id)
WHERE order_status = 'completed'
GROUP BY C.customer_id, registration_date
)
SELECT customer_id, registration_date, DATE_FORMAT(first_order, '%Y-%m') AS cohort_month,
total_orders, first_order, last_order,
DATEDIFF(CURRENT_DATE, last_order) AS days_difference,
CASE WHEN total_orders > 1 THEN 'Return Customer'
ELSE 'One-Time Customer' END AS purchase_type,
CASE WHEN last_order IS NULL THEN 'Never Purchased'
WHEN DATEDIFF(CURRENT_DATE, last_order) > 90 THEN 'Churned Customer'
ELSE 'Active' END AS Churn_status
FROM CUSTOMER_ORDERS;
SELECT * FROM customer_retention_metrics;


-- Advanced SQL Queries for Analytics

/*1. Identifying High-Value Repeat Customers using 
Multi-table JOINs, Aggregation, GROUP BY, HAVING*/

SELECT c.customer_id, c.full_name AS Name, 
count(order_id) AS total_orders,
COUNT(DISTINCT(p.payment_method)) AS payment_methods_used, 
SUM(total_amount) as total_revenue
FROM customers c
LEFT JOIN orders o
USING(customer_id)
LEFT JOIN payments p
USING(order_id)
WHERE order_status = 'completed'
AND p.payment_status = 'completed' 
GROUP BY c.customer_id, c.full_name
HAVING COUNT(DISTINCT(o.sales_channel)) >= 2 
AND COUNT(o.order_id) > 1
ORDER BY total_revenue DESC;

-- 2. Loyalty Program Impact on Retention

WITH Engagement_Status AS (
SELECT customer_id,
CASE WHEN 
MAX(CASE WHEN l.transaction_type='redeemed' THEN 1 ELSE 0 END) = 1 
THEN 'Loyalty Engaged' 
ELSE 'Non-Engaged' END AS 'engagement_status'
FROM loyalty_points_transactions l
LEFT JOIN customers 
USING (customer_id)
GROUP BY customer_id),

Purchase_Behavior AS (
SELECT c.customer_id, c.full_name, 
COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
USING(customer_id)
WHERE o.order_status = 'completed'
GROUP BY c.customer_id, c.full_name
HAVING (total_orders) > 1
),

Engagement_with_Orders AS (
SELECT customer_id, full_name, total_orders, engagement_status,
total_orders > 1 AS repeat_customer
FROM Purchase_Behavior 
JOIN Engagement_Status
USING (customer_id)
)
SELECT COUNT(customer_id) AS number_of_customer, AVG(total_orders) AS average_order, engagement_status
FROM Engagement_with_Orders
GROUP BY engagement_status;


-- 3. Identify customers who spent more than the average purchase amount for their loyalty tier.
SELECT customer.customer_id, 
customer.full_name, 
customer.tier_name,
order_sp.total_spend, 
loyalty.avgtier_spend
FROM
(SELECT c.customer_id, c.full_name, lp.tier_name
FROM customers c
INNER JOIN loyalty_memberships lm
USING (customer_id)
INNER JOIN loyalty_programs lp
USING (tier_id)) AS customer
JOIN
(SELECT customer_id, SUM(total_amount) AS total_spend
FROM orders
WHERE order_status = 'completed'
GROUP BY customer_id) AS order_sp
USING (customer_id)
JOIN
(SELECT tier_name, avg((total_spend)) as avgtier_spend
FROM (SELECT customer_id, tier_name, 
sum(total_amount) as total_spend
FROM customers
INNER JOIN loyalty_memberships lm
USING (customer_id)
INNER JOIN loyalty_programs
USING (tier_id)
INNER JOIN orders
USING (customer_id)
WHERE order_status = 'completed'
GROUP BY customer_id, tier_name) as customer_spend
GROUP BY tier_name
) AS loyalty
USING (tier_name)
WHERE total_spend > avgtier_spend;

-- 4. Rank customers by monthly spend within each loyalty tier to identify top performers.
SELECT customer_id, tier_name,
DATE_FORMAT(order_date, '%Y-%m') AS month,
SUM(total_amount) AS total_spend,
RANK() OVER (
PARTITION BY tier_id,  DATE_FORMAT(order_date, '%Y-%m') 
ORDER BY SUM(total_amount) DESC) AS ranker_in_tier
FROM orders
INNER JOIN loyalty_memberships
USING (customer_id)
INNER JOIN loyalty_programs
using(tier_id)
WHERE order_status = 'completed'
GROUP BY customer_id, tier_id, tier_name, DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- 5. Marketing Campaign Effectiveness
WITH campaign_participant AS (
SELECT customer_id, campaign_id, response_status 
FROM customer_campaigns),

customer_campaign_metrics AS (
SELECT cp.customer_id, cp.campaign_id, 
COUNT(CASE WHEN o.order_status = 'completed' THEN o.order_id END) AS total_orders,
SUM(CASE WHEN o.order_status = 'completed' THEN o.total_amount ELSE 0 END) AS total_spend,
AVG(CASE WHEN o.order_status = 'completed' THEN o.total_amount END) AS avg_order_value,
cp.response_status
FROM campaign_participant cp 
LEFT JOIN orders o
USING(customer_id)
WHERE o.order_status = 'completed'
GROUP BY cp.customer_id, cp.campaign_id, cp.response_status
),
campaign AS (
SELECT ccm.campaign_id, 
COUNT(DISTINCT(ccm.customer_id)) AS num_customers,
SUM(ccm.total_spend) AS campaign_revenue,
AVG(ccm.avg_order_value) AS avg_order_value_per_customer,
SUM(CASE WHEN response_status = 'converted' THEN 1 ELSE 0 END) AS responders,
campaign_type, campaign_name
FROM customer_campaign_metrics ccm
INNER JOIN marketing_campaigns mc
USING(campaign_id)
GROUP BY ccm.campaign_id, campaign_type, campaign_name
ORDER BY campaign_revenue DESC
)
SELECT * FROM campaign;

-- 6. Rank campaign channels by total revenue generated
SELECT mc.campaign_type, SUM(o.total_amount) AS total_revenue,
RANK() OVER (ORDER BY sum(o.total_amount) DESC)  AS revenue_rank
FROM orders o
INNER JOIN customer_campaigns cc
USING (customer_id)
INNER JOIN marketing_campaigns mc
USING (campaign_id)
WHERE order_status = 'completed'
GROUP BY mc.campaign_type
ORDER BY revenue_rank;

-- Stored Procedures and User-Defined Functions
-- Stored Procedures
DELIMITER $$
create procedure CRSE(IN input_customer_id INT, IN churn_threshold INT, IN at_risk_threshold INT)
begin
select customer_id, total_orders, days_difference, purchase_type,
CASE
WHEN days_difference <= churn_threshold THEN 'Active'
WHEN days_difference BETWEEN churn_threshold + 1 AND at_risk_threshold THEN 'At Risk'
ELSE 'Inactive' END 
AS retention_category
from customer_retention_metrics
WHERE customer_id = input_customer_id 
OR input_customer_id IS NULL;
END$$
DELIMITER ;

-- The Function: Customer Lifetime Value 
DELIMITER $$

CREATE FUNCTION CLV(input_customer_id INT)
RETURNS DOUBLE
DETERMINISTIC
BEGIN
    DECLARE total_spend DOUBLE;

    -- Sum all completed orders for the given active loyalty member
    SELECT IFNULL(SUM(o.total_amount), 0)
    INTO total_spend
    FROM orders o
    INNER JOIN loyalty_memberships lm
        ON o.customer_id = lm.customer_id
    WHERE o.customer_id = input_customer_id
      AND o.order_status = 'completed'
      AND lm.is_active = 1;

    RETURN total_spend;
END $$

DELIMITER ;

-- QUERY PERFORMANCE AND OPTIMIZATION
# EXPLAIN ANALYSIS -- 5. Marketing Campaign Effectiveness
EXPLAIN
WITH campaign_participant AS (
SELECT customer_id, campaign_id, response_status 
FROM customer_campaigns),
customer_campaign_metrics AS (
SELECT cp.customer_id, cp.campaign_id, 
COUNT(CASE WHEN o.order_status = 'completed' THEN o.order_id END) AS total_orders,
SUM(CASE WHEN o.order_status = 'completed' THEN o.total_amount ELSE 0 END) AS total_spend,
AVG(CASE WHEN o.order_status = 'completed' THEN o.total_amount END) AS avg_order_value,
cp.response_status
FROM campaign_participant cp 
LEFT JOIN orders o
USING(customer_id)
WHERE o.order_status = 'completed'
GROUP BY cp.customer_id, cp.campaign_id, cp.response_status
),
campaign AS (
SELECT ccm.campaign_id, 
COUNT(DISTINCT(ccm.customer_id)) AS num_customers,
SUM(ccm.total_spend) AS campaign_revenue,
AVG(ccm.avg_order_value) AS avg_order_value_per_customer,
SUM(CASE WHEN response_status = 'converted' THEN 1 ELSE 0 END) AS responders,
campaign_type, campaign_name
FROM customer_campaign_metrics ccm
INNER JOIN marketing_campaigns mc
USING(campaign_id)
GROUP BY ccm.campaign_id, campaign_type, campaign_name
ORDER BY campaign_revenue DESC
)
SELECT * FROM campaign;

--  Optimization Strategy 1: Strategic Indexing
CREATE INDEX idx_orders_customer_status_date 
ON orders(customer_id, order_status, order_date);
CREATE INDEX idx_customer_campaigns_composite 
ON customer_campaigns(customer_id, campaign_id, response_status);


-- Optimization Strategy 2: Query Rewriting

WITH customer_campaign_metrics AS (
SELECT cc.customer_id, cc.campaign_id, 
COUNT(o.order_id) AS total_orders,
SUM(o.total_amount) AS total_spend,
AVG(o.total_amount) AS avg_order_value,
cc.response_status
FROM customer_campaigns cc
LEFT JOIN orders o 
ON cc.customer_id = o.customer_id 
AND o.order_status = 'completed'  -- Filter moved to JOIN
GROUP BY cc.customer_id, cc.campaign_id, cc.response_status
),
campaign AS (
SELECT ccm.campaign_id, 
COUNT(ccm.customer_id) AS num_customers,  -- DISTINCT removed
SUM(ccm.total_spend) AS campaign_revenue,
AVG(ccm.avg_order_value) AS avg_order_value_per_customer,
SUM(CASE WHEN response_status = 'converted' THEN 1 ELSE 0 END) AS responders,
mc.campaign_type, mc.campaign_name
FROM customer_campaign_metrics ccm
INNER JOIN marketing_campaigns mc USING(campaign_id)
GROUP BY ccm.campaign_id, mc.campaign_type, mc.campaign_name
ORDER BY campaign_revenue DESC
)
SELECT * FROM campaign;


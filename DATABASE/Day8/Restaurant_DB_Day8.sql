-- ==========================================
-- 1. DATABASE SCHEMA
-- ==========================================
CREATE TABLE Ingredient (
    ing_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    stock_qty INT DEFAULT 0 
);

CREATE TABLE MenuItem (
    menu_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price INT NOT NULL 
);

CREATE TABLE Recipe (
    menu_id INT REFERENCES MenuItem(menu_id),
    ing_id INT REFERENCES Ingredient(ing_id),
    qty_needed INT NOT NULL, 
    PRIMARY KEY (menu_id, ing_id)
);

CREATE TABLE DiningTable (
    table_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'available' 
    CHECK (status IN ('available', 'reserved', 'occupied'))
);

CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    table_id INT REFERENCES DiningTable(table_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE Orders 
ADD COLUMN order_status VARCHAR(20) DEFAULT 'pending' 
CHECK (order_status IN ('pending', 'cooking', 'served', 'cancelled'));

CREATE TABLE OrderItem (
    order_id INT REFERENCES Orders(order_id),
    menu_id INT REFERENCES MenuItem(menu_id),
    qty INT NOT NULL,
    PRIMARY KEY (order_id, menu_id)
);

-- ==========================================
-- 2. SEED DATA
-- ==========================================
INSERT INTO Ingredient (name, stock_qty) VALUES 
('Dough', 10000), ('Cheese', 5000), ('Tomato', 5000);

select * from Ingredient

INSERT INTO MenuItem (name, price) VALUES ('Pizza', 12);

select * from MenuItem

INSERT INTO Recipe (menu_id, ing_id, qty_needed) VALUES 
(1, 1, 500), (1, 2, 200), (1, 3, 100);

SELECT 
    m.name AS "Menu Item", 
    i.name AS "Ingredient", 
    r.qty_needed AS "Qty"
FROM Recipe r
JOIN MenuItem m ON r.menu_id = m.menu_id
JOIN Ingredient i ON r.ing_id = i.ing_id
ORDER BY m.name;

INSERT INTO DiningTable (table_id, status) VALUES (1, 'available'), (2, 'available');

-- ==========================================
-- 3. LIVE OPERATION: ORDERING 2 PIZZAS
-- ==========================================

-- Check tables availabilty
select * from DiningTable

-- Customer arrives
UPDATE DiningTable SET status = 'occupied' WHERE table_id = 2;

-- Create order header
INSERT INTO Orders (table_id) VALUES (2);

-- Transaction for stock deduction and item addition
BEGIN;

    -- A. Stock Check (If results found, app should ROLLBACK)
    SELECT i.name, i.stock_qty, (r.qty_needed * 50) AS total_needed
    FROM Recipe r 
    JOIN Ingredient i ON r.ing_id = i.ing_id 
    WHERE r.menu_id = 1 AND (r.qty_needed * 50) > i.stock_qty;

    -- B. Add Items (Assuming Order ID 1 was generated)
    INSERT INTO OrderItem (order_id, menu_id, qty) VALUES (5, 1, 50);

    -- C. Auto-Deduction (Corrected Syntax)
    UPDATE Ingredient i
    SET stock_qty = i.stock_qty - (r.qty_needed * 50)
    FROM Recipe r
    WHERE i.ing_id = r.ing_id AND r.menu_id = 1;

COMMIT;
rollback;

-- ==========================================
-- 4. VIEWS & BILLING
-- ==========================================

-- Kitchen Monitor: Show all active food prep
SELECT 
    o.order_id, 
    o.table_id, 
    m.name AS item_name, 
    oi.qty,
    o.order_status
FROM Orders o
JOIN OrderItem oi ON o.order_id = oi.order_id
JOIN MenuItem m ON oi.menu_id = m.menu_id
WHERE o.order_status IN ('pending', 'cooking')
ORDER BY o.order_date ASC;

-- ORDER READY
UPDATE Orders SET order_status = 'served' WHERE order_id = 5;

-- Billing: How much to pay?
SELECT o.order_id, m.name, oi.qty, m.price, (oi.qty * m.price) AS subtotal
FROM Orders o
JOIN OrderItem oi ON o.order_id = oi.order_id
JOIN MenuItem m ON oi.menu_id = m.menu_id
WHERE o.table_id = 2;

-- Reset table for next guest
UPDATE DiningTable SET status = 'available' WHERE table_id = 2;

-- ORDERS DETAILS
SELECT 
    o.table_id,
    o.order_id,
    o.order_date::TIME AS "Time",
    STRING_AGG(CONCAT(m.name, ' (x', oi.qty, ')'), ', ') AS "Order Details",
    SUM(oi.qty * m.price) AS "Table Total",
    o.order_status AS "Status"
FROM Orders o
JOIN OrderItem oi ON o.order_id = oi.order_id
JOIN MenuItem m ON oi.menu_id = m.menu_id
WHERE DATE(o.order_date) = CURRENT_DATE
GROUP BY o.table_id, o.order_id, o.order_date, o.order_status
ORDER BY o.order_date DESC;

-- DAILY REPORT
SELECT 
    COUNT(DISTINCT o.order_id) AS "Total Orders Today",
    SUM(qty * price) AS "Total Revenue",
    ROUND(SUM(qty * price) / COUNT(DISTINCT o.order_id), 2) AS "Avg Ticket Size"
FROM Orders o
JOIN OrderItem oi ON o.order_id = oi.order_id
JOIN MenuItem m ON oi.menu_id = m.menu_id
WHERE o.order_status = 'served' 
  AND DATE(o.order_date) = CURRENT_DATE;
-- =================================================================================
-- 1. CLEAN RESET
-- =================================================================================
DROP TABLE IF EXISTS Review, Payment, FlightBooking, HotelBooking, Flight, Airline, Room, RoomType, Hotel, Users CASCADE;

-- =================================================================================
-- 2. CREATE TABLES
-- =================================================================================

CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    user_phone VARCHAR(20),
    user_password VARCHAR(255) NOT NULL,
    user_role VARCHAR(20) DEFAULT 'customer' CHECK (user_role IN ('customer', 'admin'))
);

CREATE TABLE Hotel (
    hotel_id SERIAL PRIMARY KEY,
    hotel_name VARCHAR(100) NOT NULL,
    hotel_location VARCHAR(100) NOT NULL,
    hotel_rating INT CHECK (hotel_rating BETWEEN 1 AND 5),
    hotel_description TEXT
);

CREATE TABLE RoomType (
    room_type_id SERIAL PRIMARY KEY,
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    room_type_name VARCHAR(50) NOT NULL,
    price_per_night INT NOT NULL,
    total_capacity INT NOT NULL CHECK (total_capacity >= 0) 
);

CREATE TABLE Room (
    room_id SERIAL PRIMARY KEY,
    room_type_id INT REFERENCES RoomType(room_type_id) ON DELETE CASCADE,
    room_number VARCHAR(10) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    UNIQUE(room_type_id, room_number)
);

CREATE TABLE Airline (
    airline_id SERIAL PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL
);

CREATE TABLE Flight (
    flight_id SERIAL PRIMARY KEY,
    airline_id INT REFERENCES Airline(airline_id) ON DELETE CASCADE,
    departure_city VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    flight_price INT NOT NULL,
    available_seats INT NOT NULL CHECK (available_seats >= 0) 
);

CREATE TABLE HotelBooking (
    hotel_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    room_id INT REFERENCES Room(room_id) ON DELETE CASCADE,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_cost INT NOT NULL,
    status VARCHAR(20) DEFAULT 'booked' CHECK (status IN ('booked', 'confirmed', 'cancelled'))
);

CREATE TABLE FlightBooking (
    flight_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    flight_id INT REFERENCES Flight(flight_id) ON DELETE CASCADE,
    seat_number VARCHAR(10),
    status VARCHAR(20) DEFAULT 'booked' CHECK (status IN ('booked', 'confirmed', 'cancelled'))
);

CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    amount INT NOT NULL,
    payment_method VARCHAR(50),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hotel_booking_id INT REFERENCES HotelBooking(hotel_booking_id) ON DELETE CASCADE,
    flight_booking_id INT REFERENCES FlightBooking(flight_booking_id) ON DELETE CASCADE
);

CREATE TABLE Review (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);

-- =================================================================================
-- 3. TRIGGERS & LOGIC
-- =================================================================================
CREATE OR REPLACE FUNCTION auto_calculate_booking_cost()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_cost := (NEW.check_out - NEW.check_in) * (
        SELECT rt.price_per_night FROM Room r 
        JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
        WHERE r.room_id = NEW.room_id
    );
    IF NEW.total_cost <= 0 THEN
        NEW.total_cost := (SELECT rt.price_per_night FROM Room r JOIN RoomType rt ON r.room_type_id = rt.room_type_id WHERE r.room_id = NEW.room_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_auto_cost ON HotelBooking;

CREATE TRIGGER trg_auto_cost BEFORE INSERT OR UPDATE OF check_in, check_out, room_id ON HotelBooking FOR EACH ROW EXECUTE FUNCTION auto_calculate_booking_cost();


CREATE OR REPLACE FUNCTION handle_payments()
RETURNS TRIGGER AS $$
DECLARE v_cost INT; v_paid INT;
BEGIN
    IF NEW.hotel_booking_id IS NOT NULL THEN
        SELECT total_cost INTO v_cost FROM HotelBooking WHERE hotel_booking_id = NEW.hotel_booking_id;
        SELECT SUM(amount) INTO v_paid FROM Payment WHERE hotel_booking_id = NEW.hotel_booking_id;
        IF v_paid >= v_cost THEN UPDATE HotelBooking SET status = 'confirmed' WHERE hotel_booking_id = NEW.hotel_booking_id; END IF;
    ELSIF NEW.flight_booking_id IS NOT NULL THEN
        SELECT f.flight_price INTO v_cost FROM Flight f JOIN FlightBooking fb ON f.flight_id = fb.flight_id WHERE fb.flight_booking_id = NEW.flight_booking_id;
        SELECT SUM(amount) INTO v_paid FROM Payment WHERE flight_booking_id = NEW.flight_booking_id;
        IF v_paid >= v_cost THEN UPDATE FlightBooking SET status = 'confirmed' WHERE flight_booking_id = NEW.flight_booking_id; END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pay AFTER INSERT ON Payment FOR EACH ROW EXECUTE FUNCTION handle_payments();

-- =================================================================================
-- 4. VIEW FOR BALANCE REPORTS
-- =================================================================================
DROP VIEW IF EXISTS BookingBalances;
CREATE OR REPLACE VIEW BookingBalances AS
-- Part 1: Hotel Balances
SELECT 
    'Hotel' AS Type, 
    hb.hotel_booking_id AS ID, 
    u.user_id,             
    u.user_name, 
    hb.total_cost AS Cost, 
    COALESCE(SUM(p.amount), 0) AS Paid, 
    (hb.total_cost - COALESCE(SUM(p.amount), 0)) AS Balance, 
    hb.status
FROM HotelBooking hb 
JOIN Users u ON hb.user_id = u.user_id 
LEFT JOIN Payment p ON hb.hotel_booking_id = p.hotel_booking_id
GROUP BY hb.hotel_booking_id, u.user_id, u.user_name, hb.total_cost, hb.status

UNION ALL

-- Part 2: Flight Balances
SELECT 
    'Flight' AS Type, 
    fb.flight_booking_id AS ID, 
    u.user_id,            
    u.user_name, 
    f.flight_price AS Cost, 
    COALESCE(SUM(p.amount), 0) AS Paid, 
    (f.flight_price - COALESCE(SUM(p.amount), 0)) AS Balance, 
    fb.status
FROM FlightBooking fb 
JOIN Users u ON fb.user_id = u.user_id 
JOIN Flight f ON fb.flight_id = f.flight_id 
LEFT JOIN Payment p ON fb.flight_booking_id = p.flight_booking_id
GROUP BY fb.flight_booking_id, u.user_id, u.user_name, f.flight_price, fb.status;

SELECT * FROM BookingBalances;

-- =================================================================================
-- 5. INSERTS
-- =================================================================================

INSERT INTO Users (user_name, user_email, user_phone, user_password, user_role) VALUES 
('Ahmed Ali', 'ahmed@gmail.com', '01116622221', 'pass1', 'customer'),
('Sara Smith', 'sara@yahoo.com', '01116622222', 'pass2', 'customer'),
('Kenji Tanaka', 'kenji@outlook.jp', '01116622223', 'pass3', 'customer'),
('Maria Garcia', 'maria@gmail.com', '01116622224', 'pass4', 'customer'),
('Admin Sam', 'sam@travel.com', '01116622225', 'admin_pass', 'admin');

INSERT INTO Hotel (hotel_name, hotel_location, hotel_rating, hotel_description) VALUES 
('Burj Al Arab', 'Dubai', 5, 'Luxury'),
('The Ritz', 'London', 5, 'Classic'),
('Ibis Styles', 'Dubai', 3, 'Budget'),
('Park Hyatt', 'Tokyo', 5, 'Views'),
('Hotel Gran Via', 'Madrid', 4, 'Central');

INSERT INTO RoomType (hotel_id, room_type_name, price_per_night, total_capacity) VALUES 
(1, 'Royal Suite', 2000, 5), 
(2, 'Superior', 400, 10), 
(3, 'Economy', 100, 2),
(4, 'Zen Suite', 900, 4), 
(5, 'Family', 350, 6);

INSERT INTO Room (room_type_id, room_number) VALUES 
(1, '1001'), 
(2, '201'), 
(3, '305'), 
(4, '701'), 
(5, '501');

INSERT INTO Airline (airline_name) VALUES 
('Emirates'), 
('British Airways'), 
('Japan Airlines'), 
('Qatar Airways'), 
('EgyptAir');

INSERT INTO Flight (airline_id, departure_city, arrival_city, departure_time, arrival_time, flight_price, available_seats) VALUES 
(1, 'Dubai', 'London', '2026-06-01 08:00', '2026-06-01 13:00', 800, 100),
(3, 'Tokyo', 'Dubai', '2026-06-15 09:00', '2026-06-15 15:00', 1100, 50),
(5, 'Cairo', 'Dubai', '2026-06-20 02:00', '2026-06-20 06:00', 350, 80),
(2, 'London', 'Paris', '2026-07-01 10:00', '2026-07-01 11:30', 200, 40),
(4, 'Dubai', 'Cairo', '2026-08-01 12:00', '2026-08-01 16:00', 400, 90);

INSERT INTO HotelBooking (user_id, room_id, check_in, check_out, total_cost, status) VALUES 
(1, 1, '2026-06-01', '2026-06-03', 0, 'booked'),
(2, 2, '2026-06-10', '2026-06-12', 0, 'booked'),
(3, 3, '2026-06-05', '2026-06-06', 0, 'booked'),
(4, 4, '2026-07-15', '2026-07-16', 0, 'booked'),
(5, 5, '2026-08-01', '2026-08-03', 0, 'booked');

INSERT INTO FlightBooking (user_id, flight_id, seat_number, status) VALUES 
(1, 1, '12A', 'booked'), 
(2, 2, '05C', 'booked'), 
(3, 3, '10F', 'booked'), 
(4, 4, '01B', 'booked'), 
(5, 5, '14D', 'booked');


INSERT INTO Payment (amount, payment_method, hotel_booking_id) VALUES 
(2000, 'Cash', 1), (2000, 'Credit Card', 1), 
(100, 'PayPal', 2),                          
(100, 'Debit Card', 3),                      
(450, 'Cash', 4), (450, 'Credit Card', 4);    

INSERT INTO Payment (amount, payment_method, flight_booking_id) VALUES 
(800, 'Credit Card', 1), (1100, 'PayPal', 2); 

INSERT INTO Review (user_id, hotel_id, rating, comment) VALUES 
(1, 1, 5, 'Perfect'), 
(2, 2, 4, 'Good'), 
(4, 4, 3, 'Average'), 
(3, 3, 5, 'Cheap!'), 
(5, 5, 2, 'Old');

-- =================================================================================
-- 6. Queries & Reports
-- =================================================================================
-- =================================================================================
-- Customer Queries
-- =================================================================================
-- 7.1.1 Hotels and Rooms List
SELECT h.hotel_name, h.hotel_location, rt.room_type_name, rt.price_per_night, rt.total_capacity as availible_rooms
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id;

-- 7.1.2 Search for Hotels By location
SELECT hotel_name, hotel_rating, hotel_description 
FROM Hotel 
WHERE hotel_location ILIKE '%Dubai%';

-- 7.1.3 Filter by Specific Room Type
SELECT h.hotel_name, rt.price_per_night, rt.total_capacity
FROM RoomType rt
JOIN Hotel h ON rt.hotel_id = h.hotel_id
WHERE rt.room_type_name = 'Royal Suite';

-- 7.1.4 Cheapest Hotel in a Specific City
SELECT h.hotel_name, h.hotel_location, MIN(rt.price_per_night) as starting_price
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
WHERE h.hotel_location = 'Dubai'
GROUP BY h.hotel_name, h.hotel_location
ORDER BY starting_price ASC
LIMIT 3;

-- 7.2.1 Find Available Flights by Destination
SELECT a.airline_name, f.departure_time, f.flight_price, f.available_seats
FROM Flight f
JOIN Airline a ON f.airline_id = a.airline_id
WHERE f.arrival_city = 'London' AND f.available_seats > 0;

-- 7.2.2 Flights Cheaper than $500
SELECT departure_city, arrival_city, flight_price 
FROM Flight 
WHERE flight_price < 500 
ORDER BY flight_price ASC;

-- 7.2.3 Search for flight by date range
SELECT 
    f.flight_id,
    a.airline_name,
    f.departure_city,
    f.arrival_city,
    f.departure_time,
    f.flight_price
FROM Flight f
JOIN Airline a ON f.airline_id = a.airline_id
WHERE f.departure_time BETWEEN '2026-06-01' AND '2026-06-30'
ORDER BY f.departure_time ASC;

-- Customer's Review History
SELECT h.hotel_name,u.user_name, r.rating, r.comment, r.review_date
FROM Review r
JOIN Hotel h ON r.hotel_id = h.hotel_id
JOIN Users u ON r.user_id = u.user_id

-- =================================================================================
-- Admin Reports
-- =================================================================================
-- A.1. Total Revenue per Hotel
SELECT h.hotel_name, SUM(p.amount) as total_earned , h.hotel_location
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
JOIN Payment p ON hb.hotel_booking_id = p.hotel_booking_id
GROUP BY h.hotel_name,hotel_location
ORDER BY total_earned DESC;

-- A.2. Low Inventory Alert (Rooms)
SELECT hotel_name, room_type_name, total_capacity
FROM Hotel h JOIN RoomType rt ON h.hotel_id = rt.hotel_id
WHERE total_capacity < 10;

-- A.3. Flights Report
SELECT 
    f.flight_id, 
    f.arrival_city, 
    f.available_seats,
    (SELECT COUNT(*) FROM FlightBooking fb WHERE fb.flight_id = f.flight_id) AS seats_sold
FROM Flight f;

-- A.4. Most Popular Hotel
SELECT h.hotel_name, COUNT(hb.hotel_booking_id) as booking_count
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
GROUP BY h.hotel_name
ORDER BY booking_count DESC;

-- A.5. Customers with highest spending
SELECT user_name, SUM(Paid) as total_owed
FROM BookingBalances
GROUP BY user_name
HAVING SUM(Paid) > 0
ORDER BY total_owed DESC;

-- A.6. Airline Performance Report
SELECT a.airline_name, SUM(f.flight_price) as revenue_generated
FROM Airline a
JOIN Flight f ON a.airline_id = f.airline_id
JOIN FlightBooking fb ON f.flight_id = fb.flight_id
JOIN Payment p ON fb.flight_booking_id = p.flight_booking_id
GROUP BY a.airline_name
ORDER BY revenue_generated DESC;

-- A.7. Monthly Revenue
SELECT TO_CHAR(payment_date, 'YYYY-MM') AS month, SUM(amount) AS monthly_income
FROM Payment
GROUP BY month
ORDER BY month DESC;

-- A.8. Top Rated Hotels
SELECT h.hotel_name, round(AVG(r.rating),0) as avg_rating
FROM Hotel h
JOIN Review r ON h.hotel_id = r.hotel_id
GROUP BY h.hotel_name
HAVING AVG(r.rating) >= 4;

-- A.9. Payment Report (Today)
SELECT payment_method, SUM(amount) 
FROM Payment 
WHERE payment_date::DATE = CURRENT_DATE
GROUP BY payment_method;

-- =================================================================================
-- 7. Full Customer Experience Hotel & Flight Booking
-- =================================================================================
INSERT INTO Users (user_name, user_email, user_phone, user_password, user_role) VALUES 
('Hady', 'hady@gmail.com', '01116622228', 'pass8', 'customer');

Select user_id,user_name
From Users
Where user_password = 'pass8'

-- 1. Customer Book Hotel
BEGIN;
    INSERT INTO HotelBooking (user_id, room_id, check_in, check_out, total_cost, status)
    SELECT 6, 1, '2026-06-05', '2026-06-07', 0, 'booked'
    FROM Room WHERE room_id = 1 AND is_available = TRUE;

    UPDATE Room SET is_available = FALSE WHERE room_id = 1;
    UPDATE RoomType SET total_capacity = total_capacity - 1 WHERE room_type_id = 1;
COMMIT;

-- 2. Customer Book Flight
BEGIN;
    INSERT INTO FlightBooking (user_id, flight_id, seat_number, status)
    SELECT 6, 1, '15B', 'booked'
    FROM Flight WHERE flight_id = 1 AND available_seats > 0;

    UPDATE Flight SET available_seats = available_seats - 1 WHERE flight_id = 1;
COMMIT;

-- 3. Hotel Booking Details
SELECT ID as Booking_ID, user_name, Cost, Paid, Balance, status
FROM BookingBalances 
WHERE Type = 'Hotel' AND user_name = 'Hady';

-- 4. Flight Booking Details
SELECT ID as Booking_ID, user_name, Cost, Paid, Balance, status
FROM BookingBalances 
WHERE Type = 'Flight' AND user_name = 'Hady';

-- 5. Hotel Payment
BEGIN;
    INSERT INTO Payment (amount, payment_method, hotel_booking_id) 
    VALUES (4000, 'Credit Card', (SELECT hotel_booking_id FROM HotelBooking WHERE user_id = 6 ORDER BY 1 DESC LIMIT 1));
COMMIT;

-- 6. Flight Payment
BEGIN;
    INSERT INTO Payment (amount, payment_method, flight_booking_id) 
    VALUES (50, 'Cash', (SELECT flight_booking_id FROM FlightBooking WHERE user_id = 3 ORDER BY 1 DESC LIMIT 1));
COMMIT;

-- 7. Update Flight Seat
UPDATE FlightBooking SET seat_number = '01A' 
WHERE user_id = 6 AND status = 'booked';

SELECT * FROM FlightBooking WHERE user_id = 6;

-- 8. Update Hotel Dates
UPDATE HotelBooking SET check_out = '2026-06-08' 
WHERE user_id = 6 AND status = 'booked';

SELECT * FROM HotelBooking WHERE user_id = 6;

-- 9. Deleting Hotel Booking
BEGIN;
    UPDATE Room SET is_available = TRUE WHERE room_id = (SELECT room_id FROM HotelBooking WHERE hotel_booking_id = 5);
    UPDATE RoomType SET total_capacity = total_capacity + 1 WHERE room_type_id = 1;
    DELETE FROM HotelBooking WHERE hotel_booking_id = 5 AND status = 'booked';
COMMIT;

-- 10. Deleteing Flight Booking
BEGIN;
    UPDATE Flight SET available_seats = available_seats + 1 WHERE flight_id = 1;
    DELETE FROM FlightBooking WHERE flight_booking_id = 6 AND status = 'booked';
COMMIT;

-- 11. Full Report
SELECT * FROM BookingBalances;

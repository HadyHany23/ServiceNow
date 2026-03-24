-- =================================================================================
-- 1. CLEAR DATABASE (The "Nuclear" Option)
-- =================================================================================
DROP TABLE IF EXISTS Review CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS FlightBooking CASCADE;
DROP TABLE IF EXISTS HotelBooking CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS Airline CASCADE;
DROP TABLE IF EXISTS Room CASCADE;
DROP TABLE IF EXISTS RoomType CASCADE;
DROP TABLE IF EXISTS Hotel CASCADE;
DROP TABLE IF EXISTS Users CASCADE;

-- =================================================================================
-- 2. CREATE TABLES (With Updated Logic)
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

-- THE NEW ROOM TYPE TABLE
CREATE TABLE RoomType (
    room_type_id SERIAL PRIMARY KEY,
    hotel_id INT REFERENCES Hotel(hotel_id) ON DELETE CASCADE,
    room_type_name VARCHAR(50) NOT NULL,
    price_per_night INT NOT NULL,
    total_capacity INT NOT NULL
);

-- THE NEW PHYSICAL ROOM TABLE
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
    available_seats INT NOT NULL
);

CREATE TABLE HotelBooking (
    hotel_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    room_id INT REFERENCES Room(room_id) ON DELETE CASCADE,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_cost INT NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled'))
);

CREATE TABLE FlightBooking (
    flight_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
    flight_id INT REFERENCES Flight(flight_id) ON DELETE CASCADE,
    seat_number VARCHAR(10),
    status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled'))
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
-- 3. UPDATED COST TRIGGER
-- =================================================================================

CREATE OR REPLACE FUNCTION auto_calculate_booking_cost()
RETURNS TRIGGER AS $$
BEGIN
    NEW.total_cost := (NEW.check_out - NEW.check_in) * (
        SELECT rt.price_per_night 
        FROM Room r 
        JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
        WHERE r.room_id = NEW.room_id
    );
    
    IF NEW.total_cost = 0 THEN
        NEW.total_cost := (
            SELECT rt.price_per_night 
            FROM Room r 
            JOIN RoomType rt ON r.room_type_id = rt.room_type_id 
            WHERE r.room_id = NEW.room_id
        );
    END IF;

    IF NEW.check_out < NEW.check_in THEN
        RAISE EXCEPTION 'Check-out date cannot be before check-in date';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_cost
BEFORE INSERT ON HotelBooking
FOR EACH ROW
EXECUTE FUNCTION auto_calculate_booking_cost();

-- =================================================================================
-- 4. INSERT REFRESHED DATA 
-- =================================================================================

TRUNCATE TABLE Review, Payment, FlightBooking, HotelBooking, Flight, Airline, Room, RoomType, Hotel, Users RESTART IDENTITY CASCADE;

-- 1. Users 
INSERT INTO Users (user_name, user_email, user_phone, user_password, user_role) VALUES 
('Ahmed Ali', 'ahmed@gmail.com', '01116622221', 'pass1', 'customer'),
('Sara Smith', 'sara@yahoo.com', '01116622222', 'pass2', 'customer'),
('Kenji Tanaka', 'kenji@outlook.jp', '01116622223', 'pass3', 'customer'),
('Maria Garcia', 'maria@gmail.com', '01116622224', 'pass4', 'customer'),
('Admin Sam', 'sam@travel.com', '01116622225', 'admin_pass', 'admin'),
('John Doe', 'john.doe@gmail.com', '01223344556', 'pass6', 'customer'),
('Elena Petrova', 'elena@yandex.ru', '01556677889', 'pass7', 'customer');

-- 2. Hotels 
INSERT INTO Hotel (hotel_name, hotel_location, hotel_rating, hotel_description) VALUES 
('Burj Al Arab', 'Dubai', 5, 'World most luxurious hotel'),
('The Ritz', 'London', 5, 'Classic British elegance'),
('Ibis Styles', 'Dubai', 3, 'Modern budget stay'),
('Park Hyatt', 'Tokyo', 5, 'Stunning city views'),
('Hotel Gran Via', 'Madrid', 4, 'Heart of the city'),
('Cairo Marriott', 'Cairo', 5, 'Historic palace hotel');

-- 3. Room Types 
INSERT INTO RoomType (hotel_id, room_type_name, price_per_night, total_capacity) VALUES 
(1, 'Royal Suite', 2000, 5), (1, 'Deluxe', 800, 10),
(2, 'Superior', 400, 15), (2, 'Standard', 250, 20),
(3, 'Economy', 100, 30), (3, 'Studio', 180, 10),
(4, 'Zen Suite', 900, 8), (5, 'Family Room', 350, 12),
(6, 'Nile View', 500, 20);

-- 4. Physical Rooms
INSERT INTO Room (room_type_id, room_number) VALUES 
(1, '1001'), (1, '1002'), (2, '201'), (2, '202'), (2, '203'), 
(3, '305'), (3, '306'), (4, '410'), (4, '411'),              
(5, '501'), (5, '502'), (5, '503'), (6, '601'),          
(7, '701'), (8, '801'), (9, '901'), (9, '902');          

-- 5. Airlines
INSERT INTO Airline (airline_name) VALUES 
('Emirates'), ('British Airways'), ('Japan Airlines'), ('Qatar Airways'), ('EgyptAir');

-- 6. Flights 
INSERT INTO Flight (airline_id, departure_city, arrival_city, departure_time, arrival_time, flight_price, available_seats) VALUES 
(1, 'Dubai', 'London', '2026-06-01 08:00:00', '2026-06-01 13:00:00', 800, 150),
(1, 'Dubai', 'Tokyo', '2026-06-05 22:00:00', '2026-06-06 10:00:00', 1200, 200),
(2, 'London', 'Madrid', '2026-06-10 14:00:00', '2026-06-10 16:30:00', 150, 80),
(3, 'Tokyo', 'Dubai', '2026-06-15 09:00:00', '2026-06-15 15:00:00', 1100, 120),
(5, 'Cairo', 'Dubai', '2026-06-20 02:00:00', '2026-06-20 06:30:00', 350, 100),
(4, 'Dubai', 'Cairo', '2026-06-25 10:00:00', '2026-06-25 14:00:00', 400, 50);

-- 7. Hotel Bookings 
INSERT INTO HotelBooking (user_id, room_id, check_in, check_out, total_cost, status) VALUES 
(1, 1, '2026-06-01', '2026-06-03', 0, 'confirmed'),
(2, 6, '2026-06-10', '2026-06-12', 0, 'confirmed'),
(3, 14, '2026-06-06', '2026-06-07', 0, 'cancelled'),
(4, 15, '2026-06-15', '2026-06-20', 0, 'confirmed'),
(6, 16, '2026-06-21', '2026-06-23', 0, 'confirmed'),
(7, 3, '2026-06-05', '2026-06-10', 0, 'confirmed');

-- 8. Flight Bookings
INSERT INTO FlightBooking (user_id, flight_id, seat_number, status) VALUES 
(1, 1, '12A', 'confirmed'),
(2, 3, '05C', 'confirmed'),
(3, 2, '22K', 'cancelled'),
(4, 5, '01A', 'confirmed'),
(6, 6, '14F', 'confirmed'),
(7, 2, '10B', 'confirmed');

-- 9. Payments
INSERT INTO Payment (amount, payment_method, hotel_booking_id, flight_booking_id) VALUES 
(4000, 'Credit Card', 1, NULL),
(800, 'PayPal', 2, NULL),
(800, 'Credit Card', NULL, 1),
(150, 'Debit Card', NULL, 2),
(350, 'Cash', NULL, 4); 

-- 10. Reviews
INSERT INTO Review (user_id, hotel_id, rating, comment) VALUES 
(1, 1, 5, 'Incredible service!'),
(2, 2, 4, 'Very classic.'),
(4, 5, 2, 'Too noisy.'),
(6, 6, 5, 'Beautiful Nile view.'),
(7, 1, 4, 'Expensive but worth it.');

-- =================================================================================
-- 5. Queries & Reports
-- =================================================================================

-- 1. Search Available Rooms by Location
SELECT h.hotel_name, rt.room_type_name, rt.price_per_night, r.room_number
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
WHERE h.hotel_location = 'Dubai' AND r.is_available = TRUE;

-- 2. Cheapest Flights Report
SELECT a.airline_name AS Airline, f.departure_city, f.arrival_city, f.flight_price
FROM Flight f
JOIN Airline a ON f.airline_id = a.airline_id
ORDER BY f.flight_price ASC
LIMIT 3;

-- 3. Top Revenue Hotels (Based on Confirmed Bookings)
SELECT h.hotel_name, SUM(hb.total_cost) AS total_revenue
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
WHERE hb.status = 'confirmed'
GROUP BY h.hotel_name
ORDER BY total_revenue DESC;

-- 4. Flight Occupancy Rate
SELECT f.flight_id, f.departure_city, f.arrival_city, 
       COUNT(fb.flight_booking_id) AS tickets_sold,
       f.available_seats AS capacity
FROM Flight f
LEFT JOIN FlightBooking fb ON f.flight_id = fb.flight_id AND fb.status = 'confirmed'
GROUP BY f.flight_id, f.departure_city, f.arrival_city, f.available_seats
ORDER BY tickets_sold DESC;

-- 5. Hotel Ratings Summary
SELECT h.hotel_name, ROUND(AVG(rev.rating), 2) AS avg_user_rating, COUNT(rev.review_id) AS total_reviews
FROM Hotel h
LEFT JOIN Review rev ON h.hotel_id = rev.hotel_id
GROUP BY h.hotel_name;

-- 6. Monthly Revenue Trend
SELECT TO_CHAR(payment_date, 'YYYY-MM') AS month, SUM(amount) AS monthly_income
FROM Payment
GROUP BY month
ORDER BY month DESC;

-- 7. Booking Cancellation Analysis
SELECT status, COUNT(*) AS count
FROM HotelBooking
GROUP BY status;

-- 8. Most Popular Travel Routes
SELECT f.departure_city, f.arrival_city, COUNT(fb.flight_booking_id) AS total_bookings
FROM Flight f
JOIN FlightBooking fb ON f.flight_id = fb.flight_id
WHERE fb.status = 'confirmed'
GROUP BY f.departure_city, f.arrival_city
ORDER BY total_bookings DESC;

-- 9. Report Unpaid Hotel Bookings
SELECT u.user_name, h.hotel_name, hb.total_cost, hb.status
FROM HotelBooking hb
JOIN Users u ON hb.user_id = u.user_id
JOIN Room r ON hb.room_id = r.room_id
JOIN RoomType rt ON r.room_type_id = rt.room_type_id
JOIN Hotel h ON rt.hotel_id = h.hotel_id
LEFT JOIN Payment p ON hb.hotel_booking_id = p.hotel_booking_id
WHERE p.payment_id IS NULL AND hb.status = 'confirmed';

-- 10. Report Unpaid Flight Bookings
SELECT u.user_name, f.departure_city, f.arrival_city, f.flight_price
FROM FlightBooking fb
JOIN Users u ON fb.user_id = u.user_id
JOIN Flight f ON fb.flight_id = f.flight_id
LEFT JOIN Payment p ON fb.flight_booking_id = p.flight_booking_id
WHERE p.payment_id IS NULL AND fb.status = 'confirmed';

-- 11. Search Available Flights (Time Window)
SELECT a.airline_name, f.departure_time, f.arrival_time, f.flight_price
FROM Flight f
JOIN Airline a ON f.airline_id = a.airline_id
WHERE f.departure_city = 'Dubai' 
  AND f.arrival_city = 'Tokyo' 
  AND f.departure_time BETWEEN '2026-06-01 00:00:00' AND '2026-06-30 23:59:59'
  AND f.available_seats > 0;

-- 12. Full Hotel/Room Inventory List
SELECT h.hotel_name, h.hotel_location, rt.room_type_name, rt.price_per_night, r.room_number, r.is_available
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
ORDER BY h.hotel_name, rt.price_per_night DESC;

-- 13. Filter Hotels by Rating
SELECT hotel_name, hotel_location, hotel_rating
FROM Hotel
WHERE hotel_rating >= 4
ORDER BY hotel_rating DESC;

-- 14. Customer Lifetime Value (Top Spenders)
SELECT u.user_name, SUM(p.amount) AS total_contribution
FROM Users u
JOIN Payment p ON (u.user_id = (SELECT user_id FROM HotelBooking WHERE hotel_booking_id = p.hotel_booking_id) 
                OR u.user_id = (SELECT user_id FROM FlightBooking WHERE flight_booking_id = p.flight_booking_id))
GROUP BY u.user_name
ORDER BY total_contribution DESC;

-- 15. Room Type Popularity (Which category sells most?)
SELECT rt.room_type_name, COUNT(hb.hotel_booking_id) AS total_bookings
FROM RoomType rt
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
WHERE hb.status = 'confirmed'
GROUP BY rt.room_type_name
ORDER BY total_bookings DESC;

-- 16. Revenue Leakage (Value of Cancelled Bookings)
SELECT 'Hotel' AS Type, SUM(total_cost) AS lost_revenue 
FROM HotelBooking WHERE status = 'cancelled'
UNION ALL
SELECT 'Flight' AS Type, SUM(f.flight_price) 
FROM FlightBooking fb JOIN Flight f ON fb.flight_id = f.flight_id 
WHERE fb.status = 'cancelled';

-- 17. Daily Departure Schedule (Operational Report)
SELECT departure_time::DATE AS flight_date, COUNT(*) AS flight_count
FROM Flight
GROUP BY flight_date
ORDER BY flight_date;

-- 18. Average Length of Stay by Hotel
SELECT h.hotel_name, ROUND(AVG(check_out - check_in), 1) AS avg_nights
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
WHERE hb.status = 'confirmed'
GROUP BY h.hotel_name;

-- 19. Payment Method Distribution (Accounting Report)
SELECT payment_method, COUNT(*) AS usage_count, SUM(amount) AS total_collected
FROM Payment
GROUP BY payment_method;

-- 20. Busy Hotels (Occupancy Count)
SELECT h.hotel_name, COUNT(r.room_id) AS total_rooms_booked
FROM Hotel h
JOIN RoomType rt ON h.hotel_id = rt.hotel_id
JOIN Room r ON rt.room_type_id = r.room_type_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
WHERE hb.status = 'confirmed'
GROUP BY h.hotel_name;


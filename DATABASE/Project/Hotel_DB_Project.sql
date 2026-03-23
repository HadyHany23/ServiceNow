-- Create tables =================================================================================
-- 1. User Management
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    user_email VARCHAR(100) UNIQUE NOT NULL,
    user_phone VARCHAR(20), -- Added phone as requested
    user_password VARCHAR(255) NOT NULL,
    user_role VARCHAR(20) DEFAULT 'customer' CHECK (user_role IN ('customer', 'admin'))
);

Select * From Users

-- 2. Hotel Management (Base Information)
CREATE TABLE Hotel (
    hotel_id SERIAL PRIMARY KEY,
    hotel_name VARCHAR(100) NOT NULL,
    hotel_location VARCHAR(100) NOT NULL,
    hotel_rating INT CHECK (hotel_rating BETWEEN 1 AND 5),
    hotel_description TEXT
);

Select * From Hotel

-- 3. Room Management (Linked to Hotels)
CREATE TABLE Room (
    room_id SERIAL PRIMARY KEY,
    hotel_id INT REFERENCES Hotel(hotel_id),
    room_type VARCHAR(50) NOT NULL,
    price_per_night INT NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

Select * From Room

-- 4. Airline Management
CREATE TABLE Airline (
    airline_id SERIAL PRIMARY KEY,
    airline_name VARCHAR(100) NOT NULL
);

Select * From Airline

-- 5. Flight Management (Linked to Airlines)
CREATE TABLE Flight (
    flight_id SERIAL PRIMARY KEY,
    airline_id INT REFERENCES Airline(airline_id),
    departure_city VARCHAR(100) NOT NULL,
    arrival_city VARCHAR(100) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    flight_price INT NOT NULL,
    available_seats INT NOT NULL
);

Select * From Flight

-- 6. Hotel Booking (Updated ID name)
CREATE TABLE HotelBooking (
    hotel_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    room_id INT REFERENCES Room(room_id),
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    total_cost INT NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled'))
);

Select * From HotelBooking

-- 7. Flight Booking (Updated ID name)
CREATE TABLE FlightBooking (
    flight_booking_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    flight_id INT REFERENCES Flight(flight_id),
    seat_number VARCHAR(10),
    status VARCHAR(20) DEFAULT 'confirmed' CHECK (status IN ('confirmed', 'cancelled'))
);

Select * From FlightBooking

-- 8. Payment System (Linked to both types of bookings)
CREATE TABLE Payment (
    payment_id SERIAL PRIMARY KEY,
    amount INT NOT NULL,
    payment_method VARCHAR(50),
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hotel_booking_id INT REFERENCES HotelBooking(hotel_booking_id),
    flight_booking_id INT REFERENCES FlightBooking(flight_booking_id)
);

Select * From Payment

-- 9. Reviews & Ratings
CREATE TABLE Review (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    hotel_id INT REFERENCES Hotel(hotel_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATE DEFAULT CURRENT_DATE
);

Select * From Review

-- Functions =================================================================================

CREATE OR REPLACE FUNCTION auto_calculate_booking_cost()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Calculate cost: (Days Difference) * (Price from Room Table)
    NEW.total_cost := (NEW.check_out - NEW.check_in) * (SELECT price_per_night FROM Room WHERE room_id = NEW.room_id);
    
    -- 2. Safety: If they check in/out same day, charge for 1 night
    IF NEW.total_cost = 0 THEN
        NEW.total_cost := (SELECT price_per_night FROM Room WHERE room_id = NEW.room_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auto_cost
BEFORE INSERT ON HotelBooking
FOR EACH ROW
EXECUTE FUNCTION auto_calculate_booking_cost();

-- Insert =================================================================================

-- 1. Users (Customers and Admins)
INSERT INTO Users (user_name, user_email, user_phone, user_password, user_role) VALUES 
('Ahmed Ali', 'ahmed@gmail.com', '01116622221', 'pass1', 'customer'),
('Sara Smith', 'sara@yahoo.com', '01116622222', 'pass2', 'customer'),
('Kenji Tanaka', 'kenji@outlook.jp', '01116622223', 'pass3', 'customer'),
('Maria Garcia', 'maria@gmail.com', '01116622224', 'pass4', 'customer'),
('Admin Sam', 'sam@travel.com', '01116622225', 'admin_pass', 'admin');

-- 2. Hotels (Global Locations)
INSERT INTO Hotel (hotel_name, hotel_location, hotel_rating, hotel_description) VALUES 
('Burj Al Arab', 'Dubai', 5, 'World most luxurious hotel'),
('The Ritz', 'London', 5, 'Classic British elegance'),
('Ibis Styles', 'Dubai', 3, 'Modern budget stay'),
('Park Hyatt', 'Tokyo', 5, 'Stunning city views'),
('Hotel Gran Via', 'Madrid', 4, 'Heart of the city');

-- 3. Rooms (Different Types & Prices)
INSERT INTO Room (hotel_id, room_type, price_per_night, is_available) VALUES 
(1, 'Royal Suite', 2000, TRUE), (1, 'Deluxe', 800, TRUE),
(2, 'Superior', 400, TRUE), (2, 'Standard', 250, TRUE),
(3, 'Economy', 100, TRUE), (3, 'Double', 150, TRUE),
(4, 'Executive', 600, TRUE), (5, 'Family Room', 300, TRUE);

-- 4. Airlines
INSERT INTO Airline (airline_name) VALUES 
('Emirates'), ('British Airways'), ('Japan Airlines'), ('Qatar Airways'), ('EgyptAir');

-- 5. Flights (Various Routes & Prices)
INSERT INTO Flight (airline_id, departure_city, arrival_city, departure_time, arrival_time, flight_price, available_seats) VALUES 
(1, 'Dubai', 'London', '2026-06-01 08:00:00', '2026-06-01 13:00:00', 800, 150),
(1, 'Dubai', 'Tokyo', '2026-06-05 22:00:00', '2026-06-06 10:00:00', 1200, 200),
(2, 'London', 'Madrid', '2026-06-10 14:00:00', '2026-06-10 16:30:00', 150, 80),
(3, 'Tokyo', 'Dubai', '2026-06-15 09:00:00', '2026-06-15 15:00:00', 1100, 120),
(5, 'Cairo', 'Dubai', '2026-06-20 02:00:00', '2026-06-20 06:30:00', 350, 100);

-- TRUNCATE TABLE HotelBooking CASCADE;

-- 6. Hotel Bookings (Mixed Statuses)
INSERT INTO HotelBooking (user_id, room_id, check_in, check_out, total_cost, status) VALUES 
(1, 1, '2026-06-01', '2026-06-03', 0, 'confirmed'), -- 2 nights * 2000 = 4000
(2, 3, '2026-06-10', '2026-06-12', 0, 'confirmed'), -- 2 nights * 400 = 800
(3, 7, '2026-06-06', '2026-06-07', 0, 'cancelled'), -- 1 night * 600 = 600
(4, 8, '2026-06-15', '2026-06-20', 0, 'confirmed'), -- 5 nights * 300 = 1500
(1, 5, '2026-07-01', '2026-07-05', 0, 'confirmed'); -- 4 nights * 100 = 400

SELECT * FROM HotelBooking;

-- 7. Flight Bookings
INSERT INTO FlightBooking (user_id, flight_id, seat_number, status) VALUES 
(1, 1, '12A', 'confirmed'),
(2, 3, '05C', 'confirmed'),
(3, 2, '22K', 'cancelled'),
(4, 5, '01A', 'confirmed'),
(1, 2, '10B', 'confirmed');

-- 8. Payments (Linked to Bookings)
INSERT INTO Payment (amount, payment_method, hotel_booking_id, flight_booking_id) VALUES 
(4000, 'Credit Card', 1, NULL),
(800, 'PayPal', 2, NULL),
(800, 'Credit Card', NULL, 1),
(150, 'Debit Card', NULL, 2),
(1100, 'Credit Card', NULL, 5);

-- 9. Reviews
INSERT INTO Review (user_id, hotel_id, rating, comment) VALUES 
(1, 1, 5, 'Incredible service and view!'),
(2, 2, 4, 'Very classic, loved the tea.'),
(4, 5, 3, 'Good location but very noisy rooms.'),
(3, 4, 5, 'Pure luxury in Tokyo.');

-- Queries =================================================================================

-- 1- Search Available Rooms by Location
SELECT h.hotel_name, r.room_type, r.price_per_night
FROM Hotel h
JOIN Room r ON h.hotel_id = r.hotel_id
WHERE h.hotel_location = 'Dubai' AND r.is_available = TRUE;

-- 2- Cheapest Flights Report
SELECT a.airline_name AS Airline, f.departure_city, f.arrival_city, f.flight_price
FROM Flight f
JOIN Airline a ON f.airline_id = a.airline_id
ORDER BY f.flight_price ASC
LIMIT 3;

-- 3- Top Revenue Hotels
SELECT h.hotel_name, SUM(hb.total_cost) AS total_revenue
FROM Hotel h
JOIN Room r ON h.hotel_id = r.hotel_id
JOIN HotelBooking hb ON r.room_id = hb.room_id
WHERE hb.status = 'confirmed'
GROUP BY h.hotel_name
ORDER BY total_revenue DESC;

-- 4- Flight Occupancy Rate
SELECT f.flight_id, f.departure_city, f.arrival_city, 
       (COUNT(fb.flight_booking_id)) AS tickets_sold,
       f.available_seats AS capacity
FROM Flight f
LEFT JOIN FlightBooking fb ON f.flight_id = fb.flight_id
GROUP BY f.flight_id
ORDER BY tickets_sold DESC;

-- 5- Hotel Ratings Summary
SELECT h.hotel_name, ROUND(AVG(rev.rating), 2) AS avg_user_rating, COUNT(rev.review_id) AS total_reviews
FROM Hotel h
LEFT JOIN Review rev ON h.hotel_id = rev.hotel_id
GROUP BY h.hotel_name;

-- 6- Monthly Revenue Trend
SELECT TO_CHAR(payment_date, 'YYYY-MM') AS month, SUM(amount) AS monthly_income
FROM Payment
GROUP BY month
ORDER BY month DESC;

-- 7- Booking Cancellation Analysis
SELECT status, COUNT(*) AS count
FROM HotelBooking
GROUP BY status;

-- 8- Most Popular Travel Routes
SELECT departure_city, arrival_city, COUNT(*) AS total_bookings
FROM Flight f
JOIN FlightBooking fb ON f.flight_id = fb.flight_id
GROUP BY departure_city, arrival_city
ORDER BY total_bookings DESC;

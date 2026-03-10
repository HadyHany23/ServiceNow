--CREATE TABLES
CREATE TABLE Doctors (
doctor_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
middle_name VARCHAR(50),
last_name VARCHAR(50),
specialization TEXT,
qualification TEXT

);

CREATE TABLE Patients (
patient_id SERIAL PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
dob Date,
locality TEXT,
city VARCHAR(50),
doctor_id INT REFERENCES Doctors(doctor_id) ON DELETE CASCADE ON UPDATE CASCADE

);

CREATE TABLE Medicines (
code SERIAL PRIMARY KEY,
medicine_name VARCHAR(50),
price NUMERIC(10,2),
quantity INTEGER

);

CREATE TABLE patient_medicine  (
bill_id  SERIAL PRIMARY KEY,
patient_id INTEGER,
medicine_code INTEGER,
quantity INTEGER,
bill_date Date,
FOREIGN KEY (patient_id) REFERENCES Patients(patient_id),
FOREIGN KEY (medicine_code) REFERENCES Medicines(code)
);

-- INSERT
INSERT INTO Doctors (first_name, middle_name, last_name, specialization, qualification)
VALUES 
('Gregory', 'John', 'House', 'Diagnostic Medicine', 'MD, Board Certified'),
('Stephen', 'Vincent', 'Strange', 'Neurosurgery', 'MD, PhD'),
('Dana', 'Katherine', 'Scully', 'Forensic Pathology', 'MD, Forensic Specialist');

INSERT INTO Patients (first_name, last_name, dob, locality, city, doctor_id)
VALUES 
('Peter', 'Parker', '2001-08-10', 'Queens', 'New York', 2), -- Dr. Strange
('Wilson', 'Wilson', '1969-10-23', 'Princeton', 'New Jersey', 1), -- Dr. House
('Fox', 'Mulder', '1961-10-13', 'Arlington', 'Virginia', 3), -- Dr. Scully
('Jean', 'Grey', '1985-05-15', 'Westchester', 'New York', 2), -- Dr. Strange
('John', 'Watson', '1972-07-07', 'Baker St', 'London', 1); -- Dr. House

INSERT INTO Medicines (medicine_name, price, quantity)
VALUES 
('Amoxicillin', 15.50, 100),
('Ibuprofen', 8.99, 250),
('Vicodin', 45.00, 50),
('Lisinopril', 12.75, 120),
('Metformin', 20.00, 80);

INSERT INTO patient_medicine (patient_id, medicine_code, quantity, bill_date)
VALUES 
(1, 2, 1, '2026-03-10'), -- Peter Parker bought Ibuprofen
(2, 3, 2, '2026-03-10'), -- Wilson Wilson bought Vicodin
(3, 1, 1, '2026-03-11'), -- Fox Mulder bought Amoxicillin
(4, 4, 3, '2026-03-12'), -- Jean Grey bought Lisinopril
(5, 5, 1, '2026-03-12'); -- John Watson bought Metformin

-- UPDATE & ALTER
UPDATE Medicines SET price = 50.00 WHERE medicine_name = 'Vicodin';
UPDATE Patients SET doctor_id = 1 WHERE patient_id = 1;
ALTER TABLE Doctors ADD COLUMN phone_number VARCHAR(15);
ALTER TABLE Patients ADD COLUMN email VARCHAR(100) UNIQUE;
ALTER TABLE medicines ADD CONSTRAINT price CHECK (price >= 0);
SELECT first_name, last_name, doctor_id FROM Patients WHERE doctor_id = 1;
UPDATE Doctors SET doctor_id = 99 WHERE doctor_id = 1;
SELECT first_name, last_name, doctor_id FROM Patients;
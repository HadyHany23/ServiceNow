
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
    dob DATE,
    locality TEXT,
    city VARCHAR(50)
);

CREATE TABLE Doctor_Patient (
    doctor_id INTEGER REFERENCES Doctors(doctor_id) ON DELETE CASCADE ON UPDATE CASCADE,
    patient_id INTEGER REFERENCES Patients(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (doctor_id, patient_id)
);

CREATE TABLE Medicines (
    code SERIAL PRIMARY KEY,
    medicine_name VARCHAR(50),
    price NUMERIC(10,2) CHECK (price >= 0),
    quantity INTEGER
);

CREATE TABLE Patient_Medicine (
    bill_id SERIAL PRIMARY KEY,
    patient_id INTEGER REFERENCES Patients(patient_id) ON DELETE CASCADE,
    medicine_code INTEGER REFERENCES Medicines(code) ON DELETE CASCADE,
    quantity INTEGER,
    bill_date DATE DEFAULT CURRENT_DATE
);

--Insert Doctors
INSERT INTO Doctors (Doctor_id, Specialization, Qualification, first_name, middle_name, last_name)
VALUES
(1, 'Cardiology', 'MD', 'Ahmed', 'Ali', 'Hassan'),
(2, 'Neurology', 'PhD', 'Mona', 'Mohamed', 'Fahmy'),
(3, 'Orthopedics', 'MBBS', 'Khaled', NULL, 'Saeed'),
(4, 'Pediatrics', 'MD', 'Sara', 'Ahmed', 'Nabil'),
(5, 'Dermatology', 'MD', 'Omar', 'Hassan', 'Farouk');

Select * From Doctors;

-- Insert Patients
INSERT INTO Patients (Patient_id, DOB, locality, city)
VALUES
(101, '1990-05-12', 'Heliopolis', 'Cairo'),
(102, '1985-11-23', 'Zamalek', 'Cairo'),
(103, '2000-01-30', 'Nasr City', 'Cairo'),
(104, '2010-07-15', 'Maadi', 'Cairo'),
(105, '1975-09-10', 'Dokki', 'Giza');

UPDATE Patients SET first_name = 'Ahmed', last_name = 'Ali' WHERE patient_id = 101;
UPDATE Patients SET first_name = 'Sara', last_name = 'Mounir' WHERE patient_id = 102;
UPDATE Patients SET first_name = 'Khaled', last_name = 'Hassan' WHERE patient_id = 103;
UPDATE Patients SET first_name = 'Mona', last_name = 'Zaki' WHERE patient_id = 104;
UPDATE Patients SET first_name = 'Youssef', last_name = 'Adel' WHERE patient_id = 105;

Select * From Patients;

-- Insert Medicines
INSERT INTO Medicines (code, medicine_name, price, quantity)
VALUES
(101, 'Amoxicillin', 150.50, 20),
(102, 'Panadol Extra', 75.00, 50),
(103, 'Lipitor', 300.25, 10),
(104, 'Metformin', 120.00, 30),
(105, 'Aspirin', 50.75, 100);

Select * From Medicines;

-- Insert DR_Patient
INSERT INTO Doctor_Patient (doctor_id, patient_id)
VALUES
(1, 101),
(1, 102),
(2, 103), 
(3, 104), 
(4, 105),
(2, 101); 

Select * From Doctor_Patient;

-- Insert patient_Medicine
INSERT INTO Patient_Medicine (patient_id, medicine_code, quantity)
VALUES
(101, 101, 2),
(101, 102, 1),
(102, 103, 1),
(103, 102, 3),
(104, 104, 2),
(105, 105, 5);

Select * From Patient_Medicine;

-- Select
-- 1)
DELETE FROM Patients WHERE patient_id = 5;
-- 2)
ALTER TABLE Doctors ADD COLUMN salary NUMERIC;
UPDATE Doctors SET salary = 15000 WHERE doctor_id = 1; 
UPDATE Doctors SET salary = 11000 WHERE doctor_id = 2;
UPDATE Doctors SET salary = 13000 WHERE specialization = 'Cardiology' AND doctor_id != 1;
SELECT *
FROM Doctors
WHERE specialization = 'Cardiology' 
  AND salary > 12000;
Select * From Doctors;
-- 3)
SELECT *
FROM Patients
WHERE first_name ILIKE 'M%' ;

Select * From Patients;
-- 4)
SELECT *
FROM Doctors
WHERE salary BETWEEN 10000 AND 20000;
-- 5)
SELECT * FROM Doctors WHERE specialization IN ('Cardiology','Dermatology');
-- 6)
SELECT * FROM Doctors WHERE specialization NOT IN ('Neurology');
-- 7)
ALTER TABLE Patients ADD COLUMN phone VARCHAR(20);
SELECT *
FROM Patients
WHERE phone IS NULL;
-- 8)
SELECT 
    first_name, 
    last_name, 
    salary,
    CASE 
        WHEN salary > 14000 THEN 'High Salary'
        ELSE 'Normal Salary'
    END AS salary_status
FROM Doctors;
-- 9)

-- 10)
CREATE TABLE high_salary_doctors AS
SELECT * FROM Doctors
WHERE salary > 14000;
Select * from high_salary_doctors;
-- 11)
SELECT *
FROM Doctors d
WHERE EXISTS (
    SELECT 1 
    FROM Doctor_Patient dp 
    WHERE dp.doctor_id = d.doctor_id
);
-- 12)
UPDATE Doctors SET salary = 20000 WHERE doctor_id = 3; 
SELECT first_name, last_name, specialization, salary
FROM Doctors
WHERE salary > ANY (
    SELECT salary 
    FROM Doctors 
    WHERE specialization = 'Cardiology'
);
Select * From Doctors;
-- 13)
SELECT * FROM Patients 
WHERE first_name SIMILAR TO '(A|M)%';
-- 14)
SELECT DISTINCT specialization
FROM Doctors;
-- 15)
SELECT 
    first_name, 
    last_name, 
    AGE(dob) AS full_age,
    EXTRACT(YEAR FROM AGE(dob)) AS age_years
FROM Patients;
-- 16)
SELECT 
    UPPER(first_name) AS loud_name,
    LOWER(first_name) AS quiet_name,
    INITCAP(LOWER(first_name)) AS proper_name
FROM Patients;
-- 17)
UPDATE Patients SET phone = 01115577773 WHERE patient_id = 101;
UPDATE Patients SET phone = 01115577774 WHERE patient_id = 102;
UPDATE Patients SET phone = 01115577775 WHERE patient_id = 103;
UPDATE Patients SET phone = 01115577776 WHERE patient_id = 104;
UPDATE Patients SET phone = 01115577778 WHERE patient_id = 105;
Select * From Patients;

SELECT 
    phone AS original,
    '|' || phone || '|' AS visual_check, 
    TRIM(phone) AS both_cleaned,
    LTRIM(phone) AS left_cleaned,
    RTRIM(phone) AS right_cleaned
FROM Patients;
-- 18)
SELECT 
    patient_id,
    CONCAT(first_name, ' ', last_name, ' - Phone: ', phone) AS contact_info
FROM Patients;
-- 19)
SELECT 
    first_name,
    SUBSTRING(first_name FROM 1 FOR 3) AS name_short,
    POSITION('a' IN LOWER(first_name)) AS pos_of_a
FROM Patients;
-- 20)
SELECT 
    first_name AS original,
    REPLACE(first_name, 'Ahmed', 'Ahmad') AS updated_name
FROM Doctors;
-- 21)
SELECT 
    first_name, 
    salary AS original_numeric,
    CAST(salary AS INTEGER) AS salary_int,
    salary::TEXT AS salary_text
FROM Doctors;

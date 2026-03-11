
CREATE TABLE Department (
dept_id SERIAL PRIMARY KEY,
name VARCHAR(50)

);

CREATE TABLE Employee (
emp_id SERIAL PRIMARY KEY,
name VARCHAR(50),
dept_id INT REFERENCES Department(dept_id) ON DELETE CASCADE

);

CREATE TABLE Employee1 (
emp_id SERIAL PRIMARY KEY,
name VARCHAR(50),
dept_id INT REFERENCES Department(dept_id) ON DELETE RESTRICT

);

CREATE TABLE Employee2 (
emp_id SERIAL PRIMARY KEY,
name VARCHAR(50),
dept_id INT REFERENCES Department(dept_id) ON DELETE SET NULL

);

INSERT INTO Department (name) 
VALUES 
('Engineering'),
('Marketing'),
('Design'),
('Human Resources');

INSERT INTO Employee (name, dept_id) 
VALUES 
('Alice Chen', 1),   -- Engineering
('Bob Roberts', 1),  -- Engineering
('Charlie Day', 2),  -- Marketing
('Dana Scully', 3),  -- Design
('Eddie Brock', 4);  -- Human Resources

INSERT INTO Employee1 (name, dept_id) 
VALUES 
('Alice Chen', 1),   -- Engineering
('Bob Roberts', 1),  -- Engineering
('Dana Scully', 3),  -- Design
('Eddie Brock', 4);  -- Human Resources

INSERT INTO Employee2 (name, dept_id) 
VALUES 
('Alice Chen', 1),   -- Engineering
('Bob Roberts', 1),  -- Engineering
('Dana Scully', 3),  -- Design
('Eddie Brock', 4);  -- Human Resources

SELECT * FROM Department;
SELECT * FROM Employee2;

SELECT 
    e.emp_id, 
    e.name AS employee_name, 
    d.name AS department_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id;

DELETE FROM Department 
WHERE dept_id = 3;
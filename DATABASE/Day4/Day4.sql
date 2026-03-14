CREATE TABLE Department (
    dept_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Employee (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    dept_id INT REFERENCES Department(dept_id) ON DELETE CASCADE,
	salary NUMERIC
);

INSERT INTO Department (name) VALUES
('HR'),
('IT'),
('Finance'),
('Marketing'),
('Sales');

INSERT INTO Employee (name, dept_id, salary) VALUES
('Ahmed Ali', 1, 4500),
('Sara Mohamed', 1, 5200),
('Omar Hassan', 2, 8800),
('Mona Ibrahim', 2, 7100),
('Youssef Adel', 2, 3200),
('Nour Khaled', 3, 6000),
('Ali Mahmoud', 3, 4900),
('Fatma Samir', 3, 9500),
('Hassan Tarek', 4, 2800),
('Salma Hany', 4, 5500),
('Khaled Fathy', 4, 4200),
('Rania Mostafa', 5, 8100),
('Mahmoud Yasser', 5, 3900),
('Dina Ahmed', 5, 6700),
('Karim Nabil', 2, 5000),
('Heba Wael', 1, 4100),
('Amr Samy', 3, 7300),
('Laila Ashraf', 4, 8900),
('Mostafa Said', 5, 2200),
('Nada Gamal', 2, 4600),
('Test', 2, Null);



-- SELECT
-- COALESCE
SELECT name,
COALESCE(salary, 0) AS salary -- Substitute null values with 0
FROM Employee
WHERE name LIKE 'Test%';
-- COALESCE
SELECT salary,
COALESCE(name, 'No Name' )
FROM Employee;
-- ANY
SELECT name, salary
FROM Employee
WHERE salary > ANY (ARRAY[4000, 6000, 7000]);
-- COUNT
SELECT COUNT(*) AS total_employees
FROM employee;
-- Count & Where
SELECT COUNT (*)
FROM Employee
WHERE dept_id = 2;
-- Count & Distinct
SELECT COUNT (DISTINCT salary)
FROM Employee;
-- Count & Distinct
SELECT COUNT (DISTINCT name)
FROM Employee;
-- Sum
SELECT SUM(salary) AS total_salary
FROM employee;
-- Avg
SELECT AVG(salary) AS average_salary
FROM employee;
-- Min
SELECT MIN(salary) AS lowest_salary
FROM employee;
-- Max
SELECT MAX(salary) AS highest_salary
FROM employee;
-- Max Name
SELECT MAX(name) AS longest_asci
FROM employee;
-- Group
SELECT dept_id, AVG(salary) AS avg_salary
FROM employee
GROUP BY dept_id;
-- Having
SELECT dept_id,round(AVG(salary),2) 
FROM employee
GROUP BY dept_id
HAVING AVG(salary) > 5000;
-- Having
SELECT dept_id,
COUNT (*) AS total_emplyees
FROM Employee
GROUP BY dept_id
HAVING COUNT(*)>3;
-- Having
SELECT dept_id,
COUNT (Distinct name) AS total_emplyees
FROM Employee
GROUP BY dept_id
HAVING COUNT(Distinct name)>4;
-- Grouping sets
select * from Employee
SELECT 
    dept_id, 
    salary, 
    COUNT(*) AS total_employees
FROM Employee
GROUP BY GROUPING SETS (
    (dept_id),
    (salary),
    (dept_id, salary),
    ()
)
ORDER BY dept_id NULLS LAST, salary NULLS LAST;
-- Order BY
SELECT name, salary
FROM employee
ORDER BY salary DESC;
-- Order By
SELECT name, salary
FROM employee
ORDER BY salary ASC;
-- Multiple Order By
SELECT dept_id, name, dept_id, salary
FROM employee
ORDER BY dept_id ASC, salary DESC;
-- Order By Nulls
SELECT name, salary
FROM employee
ORDER BY salary ASC NULLS LAST;
-- Limit
SELECT name, salary
FROM employee
ORDER BY salary DESC
LIMIT 5;
-- Limit
SELECT emp_id, name, dept_id, salary
FROM Employee
ORDER BY emp_id
LIMIT 5;
-- Offset
SELECT name, salary
FROM employee
ORDER BY salary DESC
LIMIT 3 OFFSET 2;
-- Offset (Skip)
SELECT emp_id, name, dept_id, salary
FROM Employee
ORDER BY emp_id
OFFSET 5;
-- Limit & Offset
SELECT emp_id, name, dept_id, salary
FROM Employee
ORDER BY emp_id
LIMIT 3 OFFSET 5;
-- Filter
SELECT
COUNT(*) FILTER (WHERE salary >= 6000) AS high_salary,
COUNT(*) FILTER (WHERE salary < 6000) AS low_salary
FROM employee;
-- Filter
SELECT
COUNT (*) AS total_employees,
COUNT (*) FILTER (WHERE dept_id = 1) AS dept1_employees,
COUNT (*) FILTER (WHERE dept_id = 2) AS dept2_employees,
COUNT (*) FILTER (WHERE dept_id = 3) AS dept3_employees,
COUNT (*) FILTER (WHERE dept_id = 4) AS dept4_employees,
COUNT (*) FILTER (WHERE dept_id = 5) AS dept5_employees
FROM employee;
-- Concat_WS
SELECT CONCAT_WS(' - ', e.name, d.name) AS employee_department
FROM employee e
JOIN department d ON e.dept_id = d.dept_id;
-- Concat_ws (Concatunate with separator)
SELECT emp_id, name, CONCAT_WS(' - ', emp_id, name,salary) AS emp_info
FROM Employee
LIMIT 5;
-- Round
SELECT AVG(salary) AS avg_salary
FROM employee;
SELECT ROUND(AVG(salary), 2) AS avg_salary
FROM employee;
-- 
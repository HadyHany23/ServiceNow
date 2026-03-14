

-- Create Departments Table
CREATE TABLE Department (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    location VARCHAR(50)
);

INSERT INTO Department (dept_id, dept_name, location) VALUES
(1, 'IT', 'New York'),
(2, 'HR', 'London'),
(3, 'Finance', 'Tokyo'),
(4, 'Marketing', 'Paris'),
(5, 'Operations', 'Dubai');

-- Create Employees Table
CREATE TABLE Employee (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) CHECK (salary > 0),
    hire_date DATE,
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

INSERT INTO Employee (emp_id, emp_name, salary, hire_date, dept_id) VALUES
(101, 'Alice Johnson', 7500, '2022-01-15', 1),
(102, 'Bob Smith', 5000, '2021-03-20', 2),
(103, 'Charlie Brown', 9000, '2020-07-10', 1),
(104, 'David Lee', 3500, '2023-05-01', 3),
(105, 'Eva Green', 12000, '2019-11-25', 4),
(106, 'Frank White', 4000, '2022-08-12', NULL),
(107, 'Grace Kim', 6000, '2021-12-30', 5);

INSERT INTO Employee (emp_id, emp_name, salary, hire_date, dept_id) VALUES
(108, 'Ahmed Maged', 7500, '2022-01-15', NULL);

-- Create Projects Table
CREATE TABLE Project (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12, 2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

INSERT INTO Project (project_id, project_name, budget, dept_id) VALUES
(201, 'Project Alpha', 50000, 1),
(202, 'Project Beta', 75000, 2),
(203, 'Project Gamma', 100000, 1),
(204, 'Project Delta', 25000, 3),
(205, 'Project Epsilon', 80000, 4);

-- Create Works_on Table
CREATE TABLE Works_On (
    emp_id INT,
    project_id INT,
    hours NUMERIC(6, 2) CHECK (hours >= 0),
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id) REFERENCES Employee(emp_id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES Project(project_id) ON DELETE CASCADE
);

INSERT INTO Works_On (emp_id, project_id, hours) VALUES
(101, 201, 120),
(101, 202, 80),
(102, 203, 150),
(103, 201, 100),
(104, 204, 90),
(105, 205, 200),
(107, 202, 50);

Select * From Department;
Select * From Employee;
Select * From Project;
Select * From Works_On;

-- Select
-- Display all employees who work in the IT department
SELECT emp_name 
FROM Employee 
WHERE dept_id = (SELECT dept_id FROM Department WHERE dept_name = 'IT');
-- Display employees whose salary is BETWEEN 4000 AND 9000
SELECT emp_name, salary
FROM Employee
WHERE salary BETWEEN 4000 AND 9000;
-- Display employees whose name starts with 'A' using SIMILAR TO (PostgreSQL Regex Operators)
SELECT emp_name 
FROM Employee
WHERE emp_name SIMILAR TO 'A%';
-- Display employees who do NOT belong to any department
SELECT emp_id, emp_name, salary
FROM Employee
WHERE dept_id IS NULL;
-- Display employees who work in departments 1, 2, or 3 using IN
SELECT emp_id, emp_name, dept_id
FROM Employee
WHERE dept_id IN (1, 2, 3);
-- Display employee name and salary level using CASE WHEN
-- High if salary > 8000
-- Medium if salary BETWEEN 4000 AND 8000
-- Low if salary < 4000
SELECT 
    emp_name, 
    salary,
    CASE 
        WHEN salary > 8000 THEN 'High'
        WHEN salary BETWEEN 4000 AND 8000 THEN 'Medium'
        WHEN salary < 4000 THEN 'Low'
        ELSE 'Uncategorized'
    END AS salary_level
FROM Employee;
-- Display employees who are assigned to at least one project using EXISTS
SELECT emp_id, emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1 
    FROM Works_On w 
    WHERE w.emp_id = e.emp_id
);
-- Display employees whose salary is greater than ANY salary in department 2
SELECT emp_name, salary
FROM Employee
WHERE salary > ANY (
    SELECT salary 
    FROM Employee 
    WHERE dept_id = 2
);
-- Display the employee who has the HIGHEST salary using a subquery
SELECT emp_name, salary
FROM Employee
WHERE salary = (SELECT MAX(salary) FROM Employee);
-- Create a table called High_Salary_Employees and insert employees whose salary > 8000 using INSERT INTO … SELECT
CREATE TABLE High_Salary_Employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    salary NUMERIC(10, 2),
    dept_id INT
);
INSERT INTO High_Salary_Employees (emp_id, emp_name, salary, dept_id)
SELECT emp_id, emp_name, salary, dept_id
FROM Employee
WHERE salary > 8000;
Select * from High_Salary_Employees;
-- Delete employees who are NOT assigned to any project
DELETE FROM Employee
WHERE NOT EXISTS (
    SELECT 1 
    FROM Works_On 
    WHERE Works_On.emp_id = Employee.emp_id
);
Select * from Works_On;
Select * From Employee;
-- Display departments that do NOT have any employees using NOT EXISTS
INSERT INTO Department (dept_id, dept_name, location) 
VALUES (6, 'Sales', 'Berlin');
SELECT d.dept_id, d.dept_name
FROM Department d
WHERE NOT EXISTS (
    SELECT 1 
    FROM Employee e 
    WHERE e.dept_id = d.dept_id
);
-- Display all DISTINCT department locations
SELECT DISTINCT location
FROM Department;
-- Create a calculated column showing salary after 10% bonus
SELECT 
    emp_name, 
    salary AS current_salary,
    salary * 1.10 AS salary_with_bonus
FROM Employee;
-- Display employee names in UPPER, LOWER, and INITCAP formats
SELECT 
    emp_name,
    UPPER(emp_name) AS all_caps,
    LOWER(emp_name) AS all_lowercase,
    INITCAP(emp_name) AS capitalized_properly
FROM Employee;
-- Remove spaces from employee names using TRIM, LTRIM, and RTRIM
SELECT 
    emp_name,
    LTRIM(emp_name) AS left_trimmed,
    RTRIM(emp_name) AS right_trimmed,
    TRIM(emp_name) AS fully_trimmed
FROM Employee;
-- Concatenate first_name and last_name into a single column using CONCAT
SELECT 
    emp_name, 
    salary,
    CONCAT(emp_name, ' ', salary) AS full_name
FROM Employee;
-- Extract a substring of employee names using SUBSTRING
SELECT 
    emp_name,
    SUBSTRING(emp_name FROM 1 FOR 5) AS first_five_chars,
    SUBSTRING(emp_name FROM 1 FOR 1) AS first_initial
FROM Employee;
-- Find the POSITION of a character or substring in employee names using POSITION
SELECT 
    emp_name,
    POSITION(' ' IN emp_name) AS space_index,
    POSITION('e' IN emp_name) AS first_e_index
FROM Employee;
-- Replace a part of employee name using REPLACE
SELECT 
    emp_name,
    REPLACE(emp_name, 'Johnson', 'Smith') AS name_change,
    REPLACE(emp_name, ' ', '_') AS underscored_name
FROM Employee;
-- Change the data type of salary to INTEGER using CAST
SELECT 
    emp_name, 
    salary AS original_salary,
    CAST(salary AS INTEGER) AS integer_salary
FROM Employee;
-- Change the data type of salary to INTEGER using CAST
SELECT 
    emp_name, 
    salary::INTEGER AS integer_salary
FROM Employee;


-- New Assignment (Lab examples)
-- Display employee names with their department names
select emp_name,dept_name from employee e
left join department d on d.dept_id=e.dept_id
-- Count employees in each department (more than 1 employee)
select dept_name,count(emp_id)
from department d
left join employee e on d.dept_id=e.dept_id
group by dept_name having count(emp_id) >1
-- Top 3 highest paid employees with department names
select emp_name, salary,dept_name from employee e
inner join department d on d.dept_id=e.dept_id
order by salary desc
limit 3
-- Display all departments and the employees working in them, including departments that do not have employees.
select dept_name, emp_name from department d
Left join employee e on d.dept_id=e.dept_id


-- Assignment
-- Display all employees with their department names, including employees who do not belong to any department.
select emp_name,dept_name from employee e
Left join department d on d.dept_id=e.dept_id
-- Total hours worked on each project ordered by highest hours
select project_name,hours from Project p
Left join Works_On w on p.project_id=w.project_id
-- Average salary per department (avg > 6000)
select dept_name,Round(Avg(e.salary),2) from employee e
join department d on d.dept_id=e.dept_id
group by dept_name having Round(Avg(e.salary),2) >6000
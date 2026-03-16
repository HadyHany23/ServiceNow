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
(5, 'Operations', 'Dubai'),
(6, 'Administration', 'Dubai');

INSERT INTO Department (dept_id, dept_name, location) VALUES
(7, 'Sales', 'Cairo');

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

INSERT INTO Employee (emp_id, emp_name, salary, hire_date, dept_id) VALUES
(109, 'Sandy', 8500, '2022-01-17', 7);

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

INSERT INTO Project (project_id, project_name, budget, dept_id) VALUES
(206, 'Project Beta 2', 75000, 7);

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

CREATE TABLE tasks (
    task_id SERIAL PRIMARY KEY,
    task_name VARCHAR(100),
    status VARCHAR(20),
    priority VARCHAR(20),
    due_date DATE,
    emp_id INT
);

INSERT INTO tasks (task_name, status, priority, due_date, emp_id)
VALUES 
('Prepare report', 'Completed', 'High', '2026-03-20', 101),
('Fix system bug', 'In Progress', 'High', '2026-03-18', 102),
('Update database', 'Pending', 'Medium', '2026-03-25', 103),
('Design new feature', 'In Progress', 'High', '2026-03-22', 101),
('Test application', 'Completed', 'Low', '2026-03-19', 104),
('Write documentation', 'Pending', 'Medium', '2026-03-28', 102),
('Client meeting preparation', 'In Progress', 'High', '2026-03-17', 105),
('Code review', 'Completed', 'Medium', '2026-03-21', 103),
('Deploy update', 'Pending', 'High', '2026-03-26', 101),
('Security audit', 'Pending', 'High', '2026-03-30', 104);

INSERT INTO tasks (task_name, status, priority, due_date, emp_id)
VALUES 
('Prepare report 2', 'Completed', 'High', '2026-03-16', 109);

Select * From Department;
Select * From Employee;
Select * From Project;
Select * From Works_On;
Select * From tasks;

-- LAB ASSIGNMENT

-- Using the employee table, find the average salary per department, and then
-- display only the departments where the average salary is greater than 4000. Use
-- a CTE (WITH clause).
with high_earning as(select * from employee where salary>4000)
select dept_name, count(*) from high_earning
join department d on d.dept_id=high_earning.dept_id
group by dept_name

-- List employees who do not work in the 'IT' department. Use the EXCEPT clause.
select * from employee
select * from Department
SELECT emp_name FROM Employee
EXCEPT
SELECT e.emp_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'IT';

-- Find employees who are in both the 'Sales' and 'Marketing' projects (assuming works_on table). Use INTERSECT.
Select * from project

SELECT e.emp_name
FROM Employee e
JOIN Works_On w ON e.emp_id = w.emp_id
JOIN Project p ON w.project_id = p.project_id
WHERE p.project_name = 'Project Alpha'
INTERSECT
SELECT e.emp_name
FROM Employee e
JOIN Works_On w ON e.emp_id = w.emp_id
JOIN Project p ON w.project_id = p.project_id
WHERE p.project_name = 'Project Beta';

-- Update the salary of employee emp_id = 5 to 6000. Then update department of
-- emp_id = 5 to 3. If any error occurs, rollback the changes. Write the SQL
-- commands.

start transaction;
UPDATE Employee
SET salary = 6000
WHERE emp_id = 106;
UPDATE Employee
SET dept_id = 3
WHERE emp_id = 106;
COMMIT;

select * from employee

-- Show employees who work in the Sales department.
SELECT e.emp_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Sales';

-- Show employees who have tasks with priority 'High'.
select * from tasks
select * from employee

SELECT e.emp_name
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
WHERE t.priority = 'High';

-- Show employees who have tasks due today.
select * from tasks

SELECT e.emp_name
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
WHERE t.due_date = CURRENT_DATE;

-- Show employees who do not have any tasks with status 'Completed'
select * from tasks
select * from employee

SELECT e.emp_name
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
WHERE t.status != 'Completed';

-- HOMEWORK ASSIGNMENT

-- Show employees who have more than 2 tasks.
select * from tasks
select * from employee

SELECT 
    e.emp_name, 
    COUNT(t.task_id) AS task_count
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
GROUP BY e.emp_id, e.emp_name
HAVING COUNT(t.task_id) > 2;

-- Show tasks that have a due date later than the latest completed task.

SELECT 
    task_name, 
    due_date, 
    status
FROM tasks
WHERE due_date > (
    SELECT MAX(due_date) 
    FROM tasks 
    WHERE status = 'Completed'
);

-- Show employee names who are assigned High priority tasks.

SELECT DISTINCT 
    e.emp_name
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
WHERE t.priority = 'High';

-- Show employees who have at least one completed task.

SELECT DISTINCT 
    e.emp_name
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
WHERE t.status = 'Completed';

-- Show employees who have at least one completed task. (Different way)

SELECT 
    e.emp_name, 
    COUNT(*) FILTER (WHERE t.status = 'Completed') AS completed_count
FROM Employee e
JOIN tasks t ON e.emp_id = t.emp_id
GROUP BY e.emp_id, e.emp_name
HAVING COUNT(*) FILTER (WHERE t.status = 'Completed') > 0;



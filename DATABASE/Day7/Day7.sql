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
(107, 'Grace Kim', 6000, '2021-12-30', 5),
(108, 'Ahmed Maged', 7500, '2022-01-15', NULL);

INSERT INTO Employee (emp_id, emp_name, salary, hire_date, dept_id) VALUES
(109, 'Sandy', 7500, '2022-01-16', 4);

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


-- ROW NUMBER
select emp_name, salary, row_number() over(order by salary desc) as row_number
from employee

-- RANK (1,2,3,3,3,6,7,8,9)
select emp_name, salary, rank() over (order by salary desc) as rank
from employee

-- DENSE RANK (1,2,3,3,3,4,5,6,7)
select emp_name, salary, dense_rank() over (order by salary desc) as rank
from employee

-- NTILE
select emp_name, salary, ntile(3) over (order by salary desc) as salary_group
from employee

-- NTILE & WHERE
SELECT 
    d.dept_name, 
    e.emp_name, 
    e.salary, 
    NTILE(2) OVER (ORDER BY e.salary DESC) AS salary_group
FROM Employee e
JOIN Department d ON d.dept_id = e.dept_id
WHERE e.dept_id = 4;

-- LAG
select emp_name, salary, lag(salary) over (order by salary desc) as previous_salary
from employee

-- LAG & OFFSET
select emp_name, salary, lag(salary,3) over (order by salary desc) as previous_salary
from employee

-- LAG & OFFSET & DEFAULT
select emp_name, salary, lag(salary,3,0) over (order by salary desc) as previous_salary
from employee

-- LEAD
select emp_name, salary, lead(salary) over (order by salary desc) as post_salary
from employee

-- SUM (Running Total)
select emp_name, salary, sum(salary) over (order by salary desc) as running_total
from employee

-- SUM
select emp_name, salary, sum(salary) over () as total
from employee

-- AVG
select emp_name, salary, avg(salary) over () as avg
from employee

-- AVG (Running Average)
select emp_name, salary, avg(salary) over (order by salary desc) as running_avg
from employee



-- CREATE TABLES

CREATE TABLE students (
student_id SERIAL PRIMARY KEY,
student_name VARCHAR(50)
);

CREATE TABLE courses (
course_id SERIAL PRIMARY KEY,
course_name VARCHAR (50)
);

CREATE TABLE enrollments(
enrollment_id SERIAL PRIMARY KEY,
student_id INT,
course_id INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

ALTER TABLE enrollments ADD COLUMN score INT;

INSERT INTO students (student_name) VALUES
('Ali'), ('Sara'),('Omar'),('Ahmed');

INSERT INTO courses (course_name) VALUES
('Database'), ('JS'), ('HTML'),('Css');

INSERT INTO enrollments (student_id, course_id) VALUES
(1,1),(1,2),(2,1),(3,3);

UPDATE enrollments SET score = 75 WHERE student_id = 1 AND course_id = 1;
UPDATE enrollments SET score = 60 WHERE student_id = 1 AND course_id = 2;
UPDATE enrollments SET score = 75 WHERE student_id = 2 AND course_id = 1;
UPDATE enrollments SET score = 80 WHERE student_id = 3 AND course_id = 3;

CREATE TABLE parents (
id SERIAL PRIMARY KEY,
name TEXT NOT NULL
);

INSERT INTO parents (name) VALUES
('Ahmed Hassan'),
('Fatima Ali'),
('Mohamed Said'),
('Sara Ibrahim'),
('Omar Khaled');

CREATE TABLE student_parents(
student_id INT REFERENCES students(student_id) ON DELETE CASCADE,
parent_id INT REFERENCES parents(id) ON DELETE CASCADE,
PRIMARY KEY (student_id, parent_id)
);

INSERT INTO students (student_id, student_name) 
VALUES (5, 'Kareem');

INSERT INTO student_parents (student_id, parent_id) VALUES
(1,1),
(1,2),
(2,1),
(3,3),
(4,4),
(4,5),
(5,3);

-- ARRAY AGG
select array_agg(emp_name) as employee_names
from employee

-- ARRAY AGG & ORDER BY
select array_agg(emp_name order by salary) as employee_names
from employee

-- ARRAY AGG 
select array_agg(distinct dept_id) as department_id
from employee

-- ARRAY AGG 
SELECT 
    d.dept_name, 
    ARRAY_AGG(e.emp_name ORDER BY e.emp_name ASC) AS employee_list
FROM employee e
JOIN Department d ON d.dept_id = e.dept_id
GROUP BY d.dept_name; 

-- BOOL AND (ALL)
SELECT 
    d.dept_name, 
   bool_and(e.salary>4000) AS all_emp_above_4000
FROM employee e
JOIN Department d ON d.dept_id = e.dept_id
GROUP BY d.dept_name; 

-- BOOL OR (ANY)
select * from employee
SELECT 
    d.dept_name, 
   bool_or(e.salary>4000) AS any_emp_above_4000
FROM employee e
JOIN Department d ON d.dept_id = e.dept_id
GROUP BY d.dept_name; 

-- Rank Students by Score Within Each Course
select * from enrollments

select s.student_name, c.course_name,e.score,
rank() over ( partition by e.course_id order by e.score desc) as rank
from enrollments e
join students s on s.student_id=e.student_id
join courses c on c.course_id=e.course_id

-- PARTITIONING
select distinct s.student_name, count(sp.parent_id) over (partition by s.student_id )
from students s
join student_parents sp on s.student_id=sp.student_id

-- PARTITIONING
SELECT 
    s.student_name, 
    COUNT(p.id) AS parent_count, 
    ARRAY_AGG(p.name ORDER BY p.name) AS parent_names
FROM students s
JOIN student_parents sp ON s.student_id = sp.student_id
JOIN parents p ON sp.parent_id = p.id
GROUP BY s.student_id, s.student_name;

-- In database courses : Get Top Student Per Course-> Returns highest scoring student per course.
SELECT 
    course_name, 
    student_name, 
    score
FROM (
    SELECT 
        c.course_name, 
        s.student_name, 
        e.score,
        dense_RANK() OVER (PARTITION BY c.course_id ORDER BY e.score DESC) as student_rank
    FROM enrollments e
    JOIN students s ON e.student_id = s.student_id
    JOIN courses c ON e.course_id = c.course_id
) ranked_scores
WHERE student_rank = 1;

-- In database company : Return the highest paid employee in each department.
SELECT DISTINCT ON (d.dept_name)
    d.dept_name, 
    e.emp_name, 
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
ORDER BY d.dept_name, e.salary DESC;

-- In database company : Return the highest paid employee in each department. 
-- (Window functions)
SELECT 
    dept_name, 
    emp_name, 
    salary
FROM (
    SELECT 
        d.dept_name, 
        e.emp_name, 
        e.salary,
        dense_RANK() OVER (
            PARTITION BY d.dept_name 
            ORDER BY e.salary DESC
        ) as salary_rank
    FROM Employee e
    JOIN Department d ON e.dept_id = d.dept_id
) AS ranked_table
WHERE salary_rank = 1;

-- 
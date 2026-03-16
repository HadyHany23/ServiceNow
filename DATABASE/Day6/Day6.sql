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

INSERT INTO students (student_name) VALUES
('Ali'), ('Sara'),('Omar'),('Ahmed');

INSERT INTO courses (course_name) VALUES
('Database'), ('JS'), ('HTML'),('Css');

INSERT INTO enrollments (student_id, course_id) VALUES
(1,1),(1,2),(2,1),(3,3);

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

-- USING
select * from students
left join enrollments using(student_id)

-- UNION
select student_id from students
union
select student_id from enrollments

-- UNION ALL
select student_id from students
union all
select student_id from enrollments

-- INTERSECT
select student_id from students
intersect
select student_id from enrollments

-- EXCEPT
select student_id from students
EXCEPT
select student_id from enrollments


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


-- CTE (Common Table Expression)
with high_earning as (select * from employee where salary > 8000)
select dept_id,count(*)
from high_earning group by dept_id

-- CTE (Common Table Expression)
with high_earning as(select * from employee where salary>8000)
select dept_name, count(*) from high_earning
join department d on d.dept_id=high_earning.dept_id
group by dept_name

-- 2 WITH
with avg_salary as (select dept_id, avg(salary) as average_salary from employee group by dept_id),
top_salary as(select * from avg_salary where average_salary> 7000)
select dept_name,average_salary from top_salary t
join Department d on d.dept_id=t.dept_id

-- TRANSACTION
start transaction;
insert into employee(emp_name, salary,dept_id) values
('sandy',1000,1);
select * from Employee
commit;
-- ROLLBACK
rollback; -- Law 3amalna start transaction w ma3amalnash commit bn3mel rollback 3alashan ne2fel 2yy opened transaction

-- JSON
CREATE TABLE test_json (
data json)
select data->>'name' as name from public.test_json
insert into test_json values('{"name":"sandy","age":20}')
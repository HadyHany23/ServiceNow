--CREATE TABLES
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    salary NUMERIC(10, 2) CHECK (salary > 0),
    dept_id INT REFERENCES departments(dept_id),
    hire_date DATE,
	FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- INSERT
INSERT INTO departments (dept_name) VALUES ('Engineering'), ('Marketing'), ('Human Resources');

INSERT INTO employees (emp_name, salary, dept_id, hire_date) VALUES 
('Alice Smith', 75000.00, 1, '2023-01-15'),
('Bob Jones', 62000.00, 1, '2023-03-20'),
('Charlie Brown', 55000.00, 2, '2024-02-10'),
('Diana Prince', 80000.00, 2, '2022-11-05'),
('Edward Norton', 48000.00, 3, '2024-05-01');

INSERT INTO projects (project_name, dept_id) VALUES 
('Cloud Migration', 1),
('Ad Campaign 2026', 2),
('Employee Wellness', 3);

UPDATE employees SET salary = salary + 1000 WHERE emp_id = 1;

UPDATE employees SET dept_id = 2 WHERE emp_id = 2;

ALTER TABLE employees ADD COLUMN email VARCHAR(150) UNIQUE;

ALTER TABLE departments ADD COLUMN phone VARCHAR(20);

ALTER TABLE employees ALTER COLUMN salary SET NOT NULL;

SELECT emp_name, dept_id FROM employees WHERE dept_id = 1;

UPDATE departments SET dept_id = 101 WHERE dept_id = 1;

SELECT emp_name, dept_id FROM employees;
SELECT project_name, dept_id FROM projects;
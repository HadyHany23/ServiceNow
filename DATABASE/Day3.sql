CREATE TABLE Department (
    dept_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

CREATE TABLE Employee (
    emp_id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    dept_id INT REFERENCES Department(dept_id) ON DELETE CASCADE
);
ALTER TABLE Employee
ADD COLUMN salary NUMERIC;


INSERT INTO Department (name) VALUES
('HR'),
('IT'),
('Finance'),
('Marketing'),
('Sales');


INSERT INTO Employee (name, dept_id) VALUES
('Ahmed Ali', 1),
('Sara Mohamed', 1),
('Omar Hassan', 2),
('Mona Ibrahim', 2),
('Youssef Adel', 2),
('Nour Khaled', 3),
('Ali Mahmoud', 3),
('Fatma Samir', 3),
('Hassan Tarek', 4),
('Salma Hany', 4),
('Khaled Fathy', 4),
('Rania Mostafa', 5),
('Mahmoud Yasser', 5),
('Dina Ahmed', 5),
('Karim Nabil', 2),
('Heba Wael', 1),
('Amr Samy', 3),
('Laila Ashraf', 4),
('Mostafa Said', 5),
('Nada Gamal', 2);

UPDATE Employee
SET salary = 5000;

-- Case When
SELECT emp_id, name, dept_id,  -- Added a comma here
CASE 
    WHEN dept_id = 1 THEN 'HR' -- Use single quotes for text
    WHEN dept_id = 2 THEN 'IT'
    ELSE 'Other departments'
END AS dep_name
FROM Employee;

-- IN
SELECT * FROM Employee WHERE dept_id IN (1,3);

-- NOT IN
SELECT * FROM Employee WHERE dept_id NOT IN (1,3);

-- Between AS Text
SELECT *
FROM Employee
WHERE name BETWEEN 'A' AND 'F';

-- Not Between AS Text
SELECT *
FROM Employee
WHERE name NOT BETWEEN 'A' AND 'F';

-- Between as numeric
SELECT
FROM Employee
WHERE dept_id BETWEEN 3 AND 5;

-- LIKE :starts with (A Not a (Case-Sensetive))
SELECT *
FROM Employee
WHERE name LIKE 'A%' ;

-- ILIKE :starts with (ILIKE Case-Insensitive) 
SELECT *
FROM Employee
WHERE name ILIKE 'a%' ; -- Get all names starts with a or A

-- LIKE :starts with
SELECT *
FROM Employee
WHERE name LIKE '_a%' ; --second letter a ( _ acts as space)

--LIKE :Contains
SELECT *
FROM Employee
WHERE name LIKE '%me%' ; -- Get all names that containes 'me'

-- LIKE :Ends with
SELECT *
FROM Employee
WHERE name LIKE '%d'; -- when % comes first thats mean this will get all names ends with d

-- AND SELECT sevral conditions
SELECT *
FROM Employee
WHERE dept_id = 2
AND name LIKE 'M%'; 

-- OR SELECT sevral conditions
SELECT *
FROM Employee
WHERE dept_id = 2
OR name LIKE 'M%';

-- NOT SELECT sevral conditions
SELECT *
FROM Employee
WHERE NOT dept_id = 2

-- IS NULL
SELECT *
FROM Employee
WHERE dept_id IS NULL;

-- IS NOT NULL
SELECT *
FROM Employee
WHERE dept_id IS NOT NULL;

-- EXISTS
SELECT *
FROM Department d -- IF this Where Exists returns true the select * will works
WHERE EXISTS(
SELECT 1
FROM Employee e
WHERE e.dept_id = 1
);

-- EXISTS
SELECT d.dept_id, d.name
FROM Department d
WHERE EXISTS (
    SELECT 1 
    FROM Employee e 
    WHERE e.dept_id = d.dept_id
);

-- NOT EXISTS
SELECT d.name 
FROM Department d
WHERE NOT EXISTS (
    SELECT 1 
	FROM Employee e 
	WHERE e.dept_id = d.dept_id
);

-- Combined Example
SELECT 
    e.name AS employee_name, 
    e.dept_id, 
    d.name AS department_name, 
    e.salary
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id  -- This links the tables correctly
WHERE d.name IN ('IT', 'Finance')
  AND e.salary BETWEEN 5000 AND 12000
  AND e.name ILIKE 'a%';

-- Similar
SELECT name
FROM Employee
WHERE name SIMILAR TO '(A|M)%'; -- Returns all names starts with A OR M (Case-Sensetive)

-- Telda Regix (Case-Sensetive)
SELECT name
FROM employee
WHERE name ~ '^A'; -- Returns all names starts with A not a

-- Telda (Case-INsensetive)
SELECT name
FROM employee
WHERE name ~* '^a'; -- returns all names starts with A or a

-- Telda Regix (Case-Sensetive)
SELECT name
FROM employee
WHERE name !~ '^A'; -- returns all names doesn't start with A

-- Telda (Case-INsensetive)
SELECT name
FROM employee
WHERE name !~* '^a'; -- Retruns all names doesn't starts with A or a

-- Telda
SELECT name
FROM employee
WHERE name ~ 'd$'; -- Returns names with names ends with d not D

INSERT INTO Employee (name, dept_id) VALUES
('Ahmed', 1);

SELECT name
FROM employee
WHERE name ~ '^.{5}$'; -- Returns with names with 5 charachters

INSERT INTO Employee (name, dept_id) VALUES
('AAAA', 1);

SELECT name
FROM employee
WHERE name ~ '^A{4}$';

INSERT INTO Employee (name, dept_id) VALUES
('Reem', 1);

INSERT INTO Employee (name, dept_id,salary) VALUES
('Nada', 1,4000);

SELECT name
FROM employee
WHERE name ~ '^.{e,f}$';

SELECT name 
FROM employee 
WHERE name LIKE '_____'; -- Returns names with exactly 5 characters

SELECT name 
FROM employee 
WHERE LENGTH(name) = 5;

-- Contains n or s 
SELECT name
FROM employee
WHERE name ~ '[ns]';

-- Not start with A
SELECT name
FROM employee
WHERE name !~* '^A';

-- Select unique values
SELECT DISTINCT dept_id,salary
FROM employee;

UPDATE Employee
SET salary = 6000
WHERE name = 'Ahmed';

-- calculated column
SELECT
name,
salary,
salary * 1.10 AS salary_with_bonus
FROM employee;

-- upper & lower case
SELECT name,
UPPER(name) AS name_upper,
LOWER(name) AS name_lower
FROM employee;

-- length
SELECT name, LENGTH(name) AS name_length
FROM employee;

-- Substring
SELECT name,
SUBSTRING(name FROM 1 FOR 3) AS first_3_letters
FROM employee;

-- Concatunate
SELECT name,
CONCAT(name, ' works in ', dept_id) AS info
FROM employee;

-- Concatunate
SELECT name,name || ' works in department ' || dept_id AS info
FROM employee;

-- Replace
SELECT name,
REPLACE(name, 'a', '@') AS replaced_name
FROM employee;

-- Trim
SELECT ' Ahmed ' AS original,
TRIM(' ' FROM' Ahmed ') AS trimmed,
LTRIM('  Ahmed') AS left_trimmed,
RTRIM('Ahmed  ') AS right_trimmed;

-- position (one based & case sensetive)
SELECT name,
POSITION('a' IN name) AS first_a_position
FROM employee;

-- Casting
SELECT name, salary, salary::TEXT AS salary_text
FROM employee;

-- Casting
SELECT name, CAST(salary AS TEXT) AS salary_text
FROM employee;

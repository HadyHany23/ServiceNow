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


-- Inner & Left & Right JOIN

select student_name, course_name from students s
inner join enrollments e on e.student_id=s.student_id
inner join courses c on c.course_id=e.course_id

select student_name, course_name from students s
left join enrollments e on e.student_id=s.student_id
left join courses c on c.course_id=e.course_id

select student_name, course_name from students s
right join enrollments e on e.student_id=s.student_id
right join courses c on c.course_id=e.course_id

select course_name,student_name from courses c
left join enrollments e on c.course_id=e.course_id
left join students s on e.student_id=s.student_id

select student_name, count(e.course_id) as total_course from students s
left join enrollments e on e.student_id=s.student_id
group by student_name having count(e.course_id) > 0
order by total_course desc

-- FULL JOIN
select student_name, course_name from students s
full join enrollments e on e.student_id=s.student_id
full join courses c on c.course_id=e.course_id

-- CROSS JOIN
select student_name, course_name from students s
cross join courses

-- Create new table
CREATE TABLE employee (
employee_id SERIAL PRIMARY KEY,
employee_name VARCHAR(50),
manager_id int 
);

INSERT INTO employee (employee_id,employee_name,manager_id) VALUES
(1,'Ali',null), (2,'Sara',1),(3,'Omar',2),(4,'Ahmed',1);

-- SELF JOIN
select emp1.employee_name as emp_name, emp2.employee_name as manager_name
from public.employee emp1 -- employee
join public.employee emp2 -- manager
on emp1.manager_id=emp2.employee_id


-- NATURAL JOIN
select * from students natural join enrollments

-- NATURAL LEFT JOIN
select * from students natural left join enrollments

-- LATERAL JOIN
select student_name, course_name from students s
join lateral(
select course_id from enrollments e where e.student_id=s.student_id
) e on true
join courses c on c.course_id=e.course_id

-- SUB QUERY
select student_name, sub.total_course from students s
join (
select student_id, count(course_id) as total_course from enrollments group by student_id
) sub
on s.student_id=sub.student_id

-- SUB QUERY & HAVING
select student_name, sub.total_course from students s
join (
select student_id, count(course_id) as total_course from enrollments group by student_id
HAVING COUNT(course_id) > 1
) sub
on s.student_id=sub.student_id

--

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

-- MULTIPLE JOINS (Student name / Course name / parent name)
select student_name, course_name, parent_id, name
from students s
join enrollments e on e.student_id=s.student_id
join courses c on c.course_id=e.course_id
join student_parents sp on sp.student_id=s.student_id
join parents p on sp.parent_id=p.id

-- MULTIPLE JOINS (Parent name and student name)
SELECT
p.name AS parent_name,
s.student_name
FROM parents p
JOIN student_parents sp
ON p.id = sp.parent_id
JOIN students s
ON s.student_id = sp.student_id
ORDER BY parent_name;
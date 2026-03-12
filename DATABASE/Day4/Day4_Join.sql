-- Create Tables
CREATE TABLE students (
student_id SERIAL PRIMARY KEY,
student_name VARCHAR(50)
);
CREATE TABLE courses (
course_id SERIAL PRIMARY KEY,
course_name VARCHAR(50)
);
CREATE TABLE enrollments (
enrollment_id SERIAL PRIMARY KEY,
student_id INT,
course_id INT,
FOREIGN KEY (student_id) REFERENCES students(student_id),
FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Insert
INSERT INTO students (student_name) VALUES
('Ali'),('Sara'),('Omar'),('Ahmed');
 
INSERT INTO courses (course_name) VALUES
('Database'),('JS'),('HTML');
INSERT INTO courses (course_name) VALUES
('CSS');
 
INSERT INTO enrollments (student_id, course_id) VALUES
(1,1),(1,2),(2,1),(3,3);

Select * From students;
Select * From courses;
Select * From enrollments;

-- Select
-- Inner Join
SELECT s.student_name, c.course_name
FROM enrollments e
INNER JOIN students s
ON e.student_id = s.student_id
INNER JOIN courses c
ON e.course_id = c.course_id;
-- Left Join
SELECT s.student_name, c.course_name
FROM students s
LEFT JOIN enrollments e
ON s.student_id = e.student_id
LEFT JOIN courses c
ON e.course_id = c.course_id;
-- Lab examples
-- Inner Join
select student_name, course_name from students s
inner join enrollments e on e.student_id=s.student_id
inner join courses c on e.course_id=c.course_id
-- Left Join
select student_name, course_name from students s
left join enrollments e on e.student_id=s.student_id
left join courses c on e.course_id=c.course_id
-- Right Join
select student_name, course_name from students s
right join enrollments e on e.student_id=s.student_id
right join courses c on e.course_id=c.course_id
-- Left Join
select student_name, course_name from courses c
left join enrollments e on e.course_id=c.course_id
left join students s on s.student_id=e.student_id 
-- Group By & Join
select student_name , count(e.course_id) as course_count
from students s
left join enrollments e on s.student_id=e.student_id
group by student_name
-- Group students name
select student_name , count(e.course_id) as course_count
from students s
left join enrollments e on s.student_id=e.student_id
group by student_name having count(e.course_id) > 0
-- group by courses name
select course_name , count(e.student_id) as enrollment_students
from courses c
left join enrollments e on c.course_id=e.course_id
group by course_name
-- Group students name + Order
select student_name , count(e.course_id) as course_count
from students s
left join enrollments e on s.student_id=e.student_id
group by student_name having count(e.course_id) > 0
order by course_count desc
-- 
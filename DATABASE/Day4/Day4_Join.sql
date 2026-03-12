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
-- Right Join
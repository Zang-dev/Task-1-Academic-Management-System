-- File: task1_academic_mgmt_mysql.sql
DROP DATABASE IF EXISTS academic_mgmt;
CREATE DATABASE academic_mgmt;
USE academic_mgmt;

-- StudentInfo table
CREATE TABLE StudentInfo (
  STU_ID INT PRIMARY KEY AUTO_INCREMENT,
  STU_NAME VARCHAR(100) NOT NULL,
  DOB DATE NOT NULL,
  PHONE_NO VARCHAR(20),
  EMAIL_ID VARCHAR(150) UNIQUE,
  ADDRESS VARCHAR(255)
) ENGINE=InnoDB; -- InnoDB required for FK constraints[10][16]

-- CoursesInfo table
CREATE TABLE CoursesInfo (
  COURSE_ID INT PRIMARY KEY AUTO_INCREMENT,
  COURSE_NAME VARCHAR(150) NOT NULL,
  COURSE_INSTRUCTOR_NAME VARCHAR(100) NOT NULL
) ENGINE=InnoDB; -- Foreign keys supported in InnoDB[10][16]

-- EnrollmentInfo table
CREATE TABLE EnrollmentInfo (
  ENROLLMENT_ID INT PRIMARY KEY AUTO_INCREMENT,
  STU_ID INT NOT NULL,
  COURSE_ID INT NOT NULL,
  ENROLL_STATUS VARCHAR(20) NOT NULL,
  CONSTRAINT chk_enroll_status CHECK (ENROLL_STATUS IN ('Enrolled','Not Enrolled')), -- CHECK supported in MySQL >=8.0.16[17][11][14]
  CONSTRAINT fk_enroll_student FOREIGN KEY (STU_ID)
    REFERENCES StudentInfo(STU_ID)
    ON DELETE CASCADE
    ON UPDATE CASCADE, -- example referential actions[10]
  CONSTRAINT fk_enroll_course FOREIGN KEY (COURSE_ID)
    REFERENCES CoursesInfo(COURSE_ID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
) ENGINE=InnoDB; -- Indexes on FK created automatically if needed[10] 

INSERT INTO StudentInfo (STU_NAME, DOB, PHONE_NO, EMAIL_ID, ADDRESS) VALUES
('Alice Johnson', '2003-04-15', '555-1111', 'alice@example.com', '12 Oak St'),
('Bob Smith',     '2002-11-30', '555-2222', 'bob@example.com',   '34 Pine Ave'),
('Charlie Kim',   '2001-06-08', '555-3333', 'charlie@example.com','56 Maple Rd'),
('Diana Patel',   '2003-02-20', '555-4444', 'diana@example.com', '78 Cedar Ln'),
('Ethan Brown',   '2002-09-05', '555-5555', 'ethan@example.com', '90 Birch Dr');

INSERT INTO CoursesInfo (COURSE_NAME, COURSE_INSTRUCTOR_NAME) VALUES
('Database Systems', 'Dr. Green'),
('Operating Systems', 'Dr. White'),
('Algorithms', 'Dr. Black'),
('Data Structures', 'Dr. Gray');

-- Enrollments: include Enrolled and Not Enrolled for testing filters
INSERT INTO EnrollmentInfo (STU_ID, COURSE_ID, ENROLL_STATUS) VALUES
(1, 1, 'Enrolled'),
(1, 2, 'Enrolled'),
(2, 1, 'Not Enrolled'),
(2, 3, 'Enrolled'),
(3, 1, 'Enrolled'),
(3, 4, 'Enrolled'),
(4, 2, 'Enrolled'),
(4, 3, 'Not Enrolled'),
(5, 3, 'Enrolled');

SELECT
  s.STU_ID,
  s.STU_NAME,
  s.PHONE_NO,
  s.EMAIL_ID,
  e.ENROLL_STATUS,
  e.COURSE_ID
FROM StudentInfo s
LEFT JOIN EnrollmentInfo e
  ON s.STU_ID = e.STU_ID
ORDER BY s.STU_ID, e.COURSE_ID;

-- Example: courses for STU_ID = 1 and status Enrolled
SELECT
  c.COURSE_ID,
  c.COURSE_NAME,
  c.COURSE_INSTRUCTOR_NAME,
  e.ENROLL_STATUS
FROM EnrollmentInfo e
JOIN CoursesInfo c
  ON e.COURSE_ID = c.COURSE_ID
WHERE e.STU_ID = 1
  AND e.ENROLL_STATUS = 'Enrolled'
ORDER BY c.COURSE_NAME;

SELECT COURSE_ID, COURSE_NAME, COURSE_INSTRUCTOR_NAME
FROM CoursesInfo
ORDER BY COURSE_ID; 

-- By id
SELECT COURSE_ID, COURSE_NAME, COURSE_INSTRUCTOR_NAME
FROM CoursesInfo
WHERE COURSE_ID = 3;

-- Or by name
SELECT COURSE_ID, COURSE_NAME, COURSE_INSTRUCTOR_NAME
FROM CoursesInfo
WHERE COURSE_NAME = 'Algorithms';

SELECT COURSE_ID, COURSE_NAME, COURSE_INSTRUCTOR_NAME
FROM CoursesInfo
WHERE COURSE_ID IN (1,2,3,4)
ORDER BY COURSE_ID;


SELECT
  c.COURSE_ID,
  c.COURSE_NAME,
  COUNT(CASE WHEN e.ENROLL_STATUS = 'Enrolled' THEN 1 END) AS enrolled_count
FROM CoursesInfo c
LEFT JOIN EnrollmentInfo e
  ON c.COURSE_ID = e.COURSE_ID
GROUP BY c.COURSE_ID, c.COURSE_NAME
ORDER BY enrolled_count DESC, c.COURSE_ID;

-- Example: COURSE_ID = 1
SELECT
  s.STU_ID,
  s.STU_NAME,
  c.COURSE_ID,
  c.COURSE_NAME
FROM EnrollmentInfo e
JOIN StudentInfo s ON e.STU_ID = s.STU_ID
JOIN CoursesInfo c ON e.COURSE_ID = c.COURSE_ID
WHERE e.COURSE_ID = 1
  AND e.ENROLL_STATUS = 'Enrolled'
ORDER BY s.STU_NAME; 

SELECT
  c.COURSE_INSTRUCTOR_NAME,
  COUNT(CASE WHEN e.ENROLL_STATUS = 'Enrolled' THEN 1 END) AS enrolled_count
FROM CoursesInfo c
LEFT JOIN EnrollmentInfo e
  ON c.COURSE_ID = e.COURSE_ID
GROUP BY c.COURSE_INSTRUCTOR_NAME
ORDER BY enrolled_count DESC, c.COURSE_INSTRUCTOR_NAME; 

SELECT
  s.STU_ID,
  s.STU_NAME,
  COUNT(*) AS enrolled_courses
FROM EnrollmentInfo e
JOIN StudentInfo s ON e.STU_ID = s.STU_ID
WHERE e.ENROLL_STATUS = 'Enrolled'
GROUP BY s.STU_ID, s.STU_NAME
HAVING COUNT(*) >= 2
ORDER BY enrolled_courses DESC, s.STU_NAME; 

SELECT
  c.COURSE_ID,
  c.COURSE_NAME,
  COUNT(CASE WHEN e.ENROLL_STATUS = 'Enrolled' THEN 1 END) AS enrolled_count
FROM CoursesInfo c
LEFT JOIN EnrollmentInfo e
  ON c.COURSE_ID = e.COURSE_ID
GROUP BY c.COURSE_ID, c.COURSE_NAME
ORDER BY enrolled_count DESC, c.COURSE_NAME;





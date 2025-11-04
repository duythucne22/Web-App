-- Create the database (already created by docker-compose, but just in case)
CREATE DATABASE IF NOT EXISTS student_management;

USE student_management;

-- Drop table if exists (for clean setup)
DROP TABLE IF EXISTS students;

-- Create students table
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_code VARCHAR(10) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    major VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO students (student_code, full_name, email, major) VALUES
('SV001', 'John Smith', 'john.smith@email.com', 'Computer Science'),
('SV002', 'Emily Johnson', 'emily.j@email.com', 'Information Technology'),
('SV003', 'Michael Brown', 'michael.b@email.com', 'Software Engineering'),
('SV004', 'Sarah Davis', 'sarah.d@email.com', 'Data Science'),
('SV005', 'David Wilson', 'david.w@email.com', 'Computer Science');

-- Verify data
SELECT * FROM students;
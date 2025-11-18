-- Create the database (already created by docker-compose, but just in case)
CREATE DATABASE IF NOT EXISTS student_management;

USE student_management;

-- Drop existing tables if they exist
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS students;

-- Create students table
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_code VARCHAR(20) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    major VARCHAR(100),
    photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create users table
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- Insert sample users with PROPER hashed passwords
-- Run UserDAO.main() first to generate these hashes!
-- For now, using placeholder - YOU MUST REPLACE THESE
INSERT INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Admin User', 'admin'),
('john', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'John Doe', 'user'),
('jane', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Jane Smith', 'user');

-- Insert sample students
INSERT INTO students (student_code, full_name, email, major) VALUES
('SV001', 'Nguyen Van A', 'vana@example.com', 'Computer Science'),
('SV002', 'Tran Thi B', 'thib@example.com', 'Information Technology'),
('SV003', 'Le Van C', 'vanc@example.com', 'Software Engineering'),
('SV004', 'Pham Thi D', 'thid@example.com', 'Business Administration');

-- Verify data
SELECT 'Users:' as Table_Name;
SELECT * FROM users;

SELECT 'Students:' as Table_Name;
SELECT * FROM students;
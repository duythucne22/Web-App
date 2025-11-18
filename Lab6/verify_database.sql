-- Database Verification Script
-- Run this after docker-compose up to check if database is properly initialized

USE student_management;

-- Check if tables exist
SHOW TABLES;

-- Verify users table structure
DESCRIBE users;

-- Verify students table structure
DESCRIBE students;

-- Check user data
SELECT 'USERS TABLE:' as Info;
SELECT id, username, full_name, role, is_active, created_at FROM users;

-- Check student data
SELECT 'STUDENTS TABLE:' as Info;
SELECT * FROM students;

-- Test BCrypt password (should return 1 row if hash is correct)
SELECT 'PASSWORD VERIFICATION:' as Info;
SELECT username, 
       CASE 
           WHEN password LIKE '$2a$%' THEN 'BCrypt Hash Detected ✓'
           ELSE 'Plain Text (INSECURE) ✗'
       END as password_status
FROM users;

-- Count records
SELECT 'RECORD COUNTS:' as Info;
SELECT 
    (SELECT COUNT(*) FROM users) as total_users,
    (SELECT COUNT(*) FROM students) as total_students;

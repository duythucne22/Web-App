<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Get form parameters
    String studentCode = request.getParameter("student_code");
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Connect to database
        conn = DriverManager.getConnection(
            "jdbc:mysql://mysql:3306/student_management",
            "root",
            "password"
        );
        
        // Prepare SQL statement (using PreparedStatement to prevent SQL injection)
        String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        
        // Set parameters
        pstmt.setString(1, studentCode);
        pstmt.setString(2, fullName);
        pstmt.setString(3, email);
        pstmt.setString(4, major);
        
        // Execute update
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            // Success - redirect to list with success message
            response.sendRedirect("list_students.jsp?message=Student added successfully!");
        } else {
            // Failed - redirect with error message
            response.sendRedirect("list_students.jsp?error=Failed to add student!");
        }
        
    } catch (ClassNotFoundException e) {
        response.sendRedirect("list_students.jsp?error=JDBC Driver not found!");
        e.printStackTrace();
    } catch (SQLException e) {
        // Check if it's a duplicate key error
        if (e.getMessage().contains("Duplicate entry")) {
            response.sendRedirect("list_students.jsp?error=Student code already exists!");
        } else {
            response.sendRedirect("list_students.jsp?error=Database error: " + e.getMessage());
        }
        e.printStackTrace();
    } finally {
        // Close resources
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

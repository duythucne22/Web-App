<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Get student ID from parameter
    String idParam = request.getParameter("id");

    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid student ID!");
        return;
    }

    int studentId = Integer.parseInt(idParam);

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
        
        // Prepare SQL statement (DELETE with WHERE clause)
        String sql = "DELETE FROM students WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        
        // Set parameter
        pstmt.setInt(1, studentId);
        
        // Execute update
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            // Success
            response.sendRedirect("list_students.jsp?message=Student deleted successfully!");
        } else {
            // No rows affected
            response.sendRedirect("list_students.jsp?error=Student not found!");
        }
        
    } catch (ClassNotFoundException e) {
        response.sendRedirect("list_students.jsp?error=JDBC Driver not found!");
        e.printStackTrace();
    } catch (SQLException e) {
        response.sendRedirect("list_students.jsp?error=Database error: " + e.getMessage());
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

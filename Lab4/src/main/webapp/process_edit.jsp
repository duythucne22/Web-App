<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Get form parameters
    String idParam = request.getParameter("id");
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");

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
        
        // Prepare SQL statement (UPDATE with WHERE clause)
        String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        
        // Set parameters
        pstmt.setString(1, fullName);
        pstmt.setString(2, email);
        pstmt.setString(3, major);
        pstmt.setInt(4, studentId);
        
        // Execute update
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            // Success
            response.sendRedirect("list_students.jsp?message=Student updated successfully!");
        } else {
            // No rows affected
            response.sendRedirect("list_students.jsp?error=Student not found or no changes made!");
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

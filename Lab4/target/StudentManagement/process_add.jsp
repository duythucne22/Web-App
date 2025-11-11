<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%
    // ensure correct encoding before reading params
    request.setCharacterEncoding("UTF-8");

    // Get form parameters
    String studentCode = request.getParameter("student_code");
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");

    // normalize / trim inputs
    if (studentCode != null) studentCode = studentCode.trim().toUpperCase(); // upper-case to be forgiving
    if (fullName != null) fullName = fullName.trim();
    if (email != null) email = email.trim();
    if (major != null) major = major.trim();

    // --- Validation: student code pattern ---
    if (studentCode == null || !studentCode.matches("[A-Z]{2}[0-9]{3,}")) {
        try {
            String msg = URLEncoder.encode("Student code must be 2 uppercase letters followed by at least 3 digits","UTF-8");
            String redirect = "add_student.jsp?error=" + msg
                + "&student_code=" + URLEncoder.encode(studentCode==null?"":studentCode,"UTF-8")
                + "&full_name=" + URLEncoder.encode(fullName==null?"":fullName,"UTF-8")
                + "&email=" + URLEncoder.encode(email==null?"":email,"UTF-8")
                + "&major=" + URLEncoder.encode(major==null?"":major,"UTF-8");
            response.sendRedirect(redirect);
        } catch (java.io.UnsupportedEncodingException e) {
            response.sendRedirect("add_student.jsp?error=Invalid+student+code");
        }
        return;
    }

    // --- Validation: email format (optional field) ---
    if (email != null && !email.trim().isEmpty()) {
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)+\\.[A-Za-z]{2,}$")) {
            try {
                String msg = URLEncoder.encode("Invalid email format","UTF-8");
                String redirect = "add_student.jsp?error=" + msg
                    + "&student_code=" + URLEncoder.encode(studentCode,"UTF-8")
                    + "&full_name=" + URLEncoder.encode(fullName==null?"":fullName,"UTF-8")
                    + "&email=" + URLEncoder.encode(email,"UTF-8")
                    + "&major=" + URLEncoder.encode(major==null?"":major,"UTF-8");
                response.sendRedirect(redirect);
            } catch (java.io.UnsupportedEncodingException e) {
                response.sendRedirect("add_student.jsp?error=Invalid+email+format");
            }
            return;
        }
    }

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

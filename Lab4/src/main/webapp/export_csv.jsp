<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Set response type to CSV and prompt download
    response.setContentType("text/csv");
    response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

    // Write CSV header
    out.println("ID,Student Code,Full Name,Email,Major,Created At");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Connect to database
        conn = DriverManager.getConnection(
            "jdbc:mysql://mysql:3306/student_management",
            "root",
            "password"
        );
        
        // Query all students
        String sql = "SELECT * FROM students ORDER BY id DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();
        
        // Loop through students and write CSV rows
        while (rs.next()) {
            out.println(
                rs.getInt("id") + "," + 
                rs.getString("student_code") + "," +
                "\"" + rs.getString("full_name") + "\"," +  // Quotes for names with commas
                rs.getString("email") + "," +
                "\"" + rs.getString("major") + "\"," +      // Quotes for majors with commas
                rs.getTimestamp("created_at")
            );
        }
        
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%
    // Get selected student IDs (comma-separated or array)
    String[] ids = request.getParameterValues("ids");
    
    if (ids == null || ids.length == 0) {
        response.sendRedirect("list_students.jsp?error=No+students+selected");
        return;
    }
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(
            "jdbc:mysql://mysql:3306/student_management",
            "root",
            "password"
        );
        
        // Build SQL with placeholders for each ID
        StringBuilder sql = new StringBuilder("DELETE FROM students WHERE id IN (");
        for (int i = 0; i < ids.length; i++) {
            sql.append("?");
            if (i < ids.length - 1) {
                sql.append(",");
            }
        }
        sql.append(")");
        
        pstmt = conn.prepareStatement(sql.toString());
        
        // Set parameters
        for (int i = 0; i < ids.length; i++) {
            pstmt.setInt(i + 1, Integer.parseInt(ids[i]));
        }
        
        int deleted = pstmt.executeUpdate();
        
        response.sendRedirect("list_students.jsp?message=" + deleted + "+student(s)+deleted+successfully");
        
    } catch (ClassNotFoundException e) {
        response.sendRedirect("list_students.jsp?error=JDBC+Driver+not+found");
        e.printStackTrace();
    } catch (SQLException e) {
        response.sendRedirect("list_students.jsp?error=" + URLEncoder.encode("Database error: " + e.getMessage(), "UTF-8"));
        e.printStackTrace();
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.net.URLEncoder" %>
<%
    request.setCharacterEncoding("UTF-8");

    String idParam = request.getParameter("id");
    String studentCode = request.getParameter("student_code");
    String fullName = request.getParameter("full_name");
    String email = request.getParameter("email");
    String major = request.getParameter("major");

    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid+student+ID!");
        return;
    }

    // normalize
    if (studentCode != null) studentCode = studentCode.trim().toUpperCase();
    if (fullName != null) fullName = fullName.trim();
    if (email != null) email = email.trim();
    if (major != null) major = major.trim();

    // --- Validation: student code pattern (only if provided) ---
    if (studentCode != null && !studentCode.isEmpty()) {
        if (!studentCode.matches("[A-Z]{2}[0-9]{3,}")) {
            try {
                String msg = URLEncoder.encode("Student code must be 2 uppercase letters followed by at least 3 digits","UTF-8");
                String redirect = "edit_student.jsp?id=" + URLEncoder.encode(idParam,"UTF-8")
                    + "&error=" + msg
                    + "&student_code=" + URLEncoder.encode(studentCode,"UTF-8")
                    + "&full_name=" + URLEncoder.encode(fullName==null?"":fullName,"UTF-8")
                    + "&email=" + URLEncoder.encode(email==null?"":email,"UTF-8")
                    + "&major=" + URLEncoder.encode(major==null?"":major,"UTF-8");
                response.sendRedirect(redirect);
            } catch (java.io.UnsupportedEncodingException e) {
                response.sendRedirect("edit_student.jsp?id=" + idParam + "&error=Invalid+student+code");
            }
            return;
        }
    }

    // --- Validation: email format (optional) ---
    if (email != null && !email.isEmpty()) {
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)+\\.[A-Za-z]{2,}$")) {
            try {
                String msg = URLEncoder.encode("Invalid email format","UTF-8");
                String redirect = "edit_student.jsp?id=" + URLEncoder.encode(idParam,"UTF-8")
                    + "&error=" + msg
                    + "&student_code=" + URLEncoder.encode(studentCode==null?"":studentCode,"UTF-8")
                    + "&full_name=" + URLEncoder.encode(fullName==null?"":fullName,"UTF-8")
                    + "&email=" + URLEncoder.encode(email,"UTF-8")
                    + "&major=" + URLEncoder.encode(major==null?"":major,"UTF-8");
                response.sendRedirect(redirect);
            } catch (java.io.UnsupportedEncodingException e) {
                response.sendRedirect("edit_student.jsp?id=" + idParam + "&error=Invalid+email+format");
            }
            return;
        }
    }

    int studentId;
    try {
        studentId = Integer.parseInt(idParam.trim());
    } catch (NumberFormatException nfe) {
        response.sendRedirect("list_students.jsp?error=Invalid+student+ID");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://mysql:3306/student_management","root","password");

        // If studentCode provided, update it as well; otherwise update only name/email/major
        if (studentCode != null && !studentCode.isEmpty()) {
            String sql = "UPDATE students SET student_code = ?, full_name = ?, email = ?, major = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentCode);
            pstmt.setString(2, fullName);
            pstmt.setString(3, email);
            pstmt.setString(4, major);
            pstmt.setInt(5, studentId);
        } else {
            String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, fullName);
            pstmt.setString(2, email);
            pstmt.setString(3, major);
            pstmt.setInt(4, studentId);
        }

        int rows = pstmt.executeUpdate();
        if (rows > 0) {
            response.sendRedirect("list_students.jsp?message=Student updated successfully!");
        } else {
            response.sendRedirect("list_students.jsp?error=Student not found or no changes made!");
        }

    } catch (ClassNotFoundException e) {
        response.sendRedirect("list_students.jsp?error=JDBC+Driver+not+found!");
        e.printStackTrace();
    } catch (SQLException e) {
        if (e.getMessage().contains("Duplicate entry")) {
            response.sendRedirect("edit_student.jsp?id=" + studentId + "&error=Student+code+already+exists");
        } else {
            response.sendRedirect("edit_student.jsp?id=" + studentId + "&error=" + URLEncoder.encode(e.getMessage(),"UTF-8"));
        }
        e.printStackTrace();
    } finally {
        try { if (pstmt != null) pstmt.close(); if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>

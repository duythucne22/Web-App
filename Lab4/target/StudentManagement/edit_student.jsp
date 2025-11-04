<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Edit Student</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 0 auto;
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            color: #555;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-size: 14px;
        }
        input[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
        }
        input[type="text"]:focus,
        input[type="email"]:focus {
            outline: none;
            border-color: #2196F3;
        }
        .btn-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        .btn {
            flex: 1;
            padding: 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            text-decoration: none;
            text-align: center;
            display: inline-block;
        }
        .btn-submit {
            background-color: #2196F3;
            color: white;
        }
        .btn-submit:hover {
            background-color: #0b7dda;
        }
        .btn-cancel {
            background-color: #f44336;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #da190b;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            border: 1px solid #f5c6cb;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
<%
    String idParam = request.getParameter("id");
    
    if (idParam == null || idParam.trim().isEmpty()) {
        response.sendRedirect("list_students.jsp?error=Invalid student ID!");
        return;
    }
    
    int studentId = Integer.parseInt(idParam);
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    String studentCode = "";
    String fullName = "";
    String email = "";
    String major = "";
    boolean studentFound = false;
    
    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Connect to database
        conn = DriverManager.getConnection(
            "jdbc:mysql://mysql:3306/student_management",
            "root",
            "password"
        );
        
        // Prepare SQL statement
        String sql = "SELECT * FROM students WHERE id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, studentId);
        
        // Execute query
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            studentFound = true;
            studentCode = rs.getString("student_code");
            fullName = rs.getString("full_name");
            email = rs.getString("email");
            major = rs.getString("major");
        }
        
    } catch (Exception e) {
        out.println("<div class='container'><div class='error'>Error: " + e.getMessage() + "</div></div>");
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
    
    if (!studentFound) {
        response.sendRedirect("list_students.jsp?error=Student not found!");
        return;
    }
%>
    <div class="container">
        <h1>✏️ Edit Student</h1>
        
        <form action="process_edit.jsp" method="post">
            <input type="hidden" name="id" value="<%= studentId %>">
            
            <div class="form-group">
                <label for="student_code">Student Code: *</label>
                <input type="text" id="student_code" name="student_code" 
                       value="<%= studentCode %>" readonly>
                <small style="color: #666;">Student code cannot be changed</small>
            </div>

            <div class="form-group">
                <label for="full_name">Full Name: *</label>
                <input type="text" id="full_name" name="full_name" 
                       value="<%= fullName %>" required>
            </div>

            <div class="form-group">
                <label for="email">Email: *</label>
                <input type="email" id="email" name="email" 
                       value="<%= email %>" required>
            </div>

            <div class="form-group">
                <label for="major">Major: *</label>
                <input type="text" id="major" name="major" 
                       value="<%= major %>" required>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn btn-submit">💾 Update Student</button>
                <a href="list_students.jsp" class="btn btn-cancel">❌ Cancel</a>
            </div>
        </form>
    </div>
</body>
</html>

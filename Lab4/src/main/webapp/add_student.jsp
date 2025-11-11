<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Add New Student</title>
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
        input[type="text"]:focus,
        input[type="email"]:focus {
            outline: none;
            border-color: #4CAF50;
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
            background-color: #4CAF50;
            color: white;
        }
        .btn-submit:hover {
            background-color: #45a049;
        }
        .btn-cancel {
            background-color: #f44336;
            color: white;
        }
        .btn-cancel:hover {
            background-color: #da190b;
        }
        .message {
            padding: 10px;
            margin: 10px 0;
            border-radius: 4px;
        }
        .message.success {
            background-color: #e6ffed;
            color: #046b24;
            border-left: 4px solid #2ecc71;
        }
        .message.error {
            background-color: #ffecec;
            color: #8b0000;
            border-left: 4px solid #e74c3c;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>➕ Add New Student</h1>
        
        <%-- show error/success and prefill values from query params --%>
        <%
            String error = request.getParameter("error");
            String student_code_prefill = request.getParameter("student_code") != null ? request.getParameter("student_code") : "";
            String full_name_prefill = request.getParameter("full_name") != null ? request.getParameter("full_name") : "";
            String email_prefill = request.getParameter("email") != null ? request.getParameter("email") : "";
            String major_prefill = request.getParameter("major") != null ? request.getParameter("major") : "";
        %>

        <% if (error != null) { %>
            <div class="message error"><%= error %></div>
        <% } %>

        <form action="process_add.jsp" method="POST" onsubmit="return submitForm(this)">
            <div class="form-group">
                <label for="student_code">Student Code: *</label>
                <input type="text" id="student_code" name="student_code" 
                       value="<%= student_code_prefill %>"
                       placeholder="e.g., SV001" required>
            </div>

            <div class="form-group">
                <label for="full_name">Full Name: *</label>
                <input type="text" id="full_name" name="full_name" 
                       value="<%= full_name_prefill %>"
                       placeholder="e.g., John Smith" required>
            </div>

            <div class="form-group">
                <label for="email">Email: *</label>
                <input type="email" id="email" name="email" 
                       value="<%= email_prefill %>"
                       placeholder="e.g., john@email.com" required>
            </div>

            <div class="form-group">
                <label for="major">Major: *</label>
                <input type="text" id="major" name="major" 
                       value="<%= major_prefill %>"
                       placeholder="e.g., Computer Science" required>
            </div>

            <div class="btn-group">
                <button type="submit" class="btn btn-submit">💾 Save Student</button>
                <a href="list_students.jsp" class="btn btn-cancel">❌ Cancel</a>
            </div>
        </form>

        <script>
        function submitForm(form){ var btn=form.querySelector('button[type=submit]'); btn.disabled=true; btn.textContent='Processing...'; return true; }
        setTimeout(function(){ document.querySelectorAll('.message').forEach(m=>m.style.display='none'); }, 3000);
        </script>
    </div>
</body>
</html>

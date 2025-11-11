<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.regex.Pattern, java.net.URLEncoder" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin: 10px 0;
            background-color: #4CAF50;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .btn:hover {
            background-color: #45a049;
        }
        .edit-link {
            color: #2196F3;
            text-decoration: none;
        }
        .delete-link {
            color: #dc3545;
            text-decoration: none;
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
        /* Exercise 7.2c: Responsive table */
        .table-responsive {
            overflow-x: auto;
        }
        @media (max-width: 768px) {
            table {
                font-size: 12px;
            }
            th, td {
                padding: 5px;
            }
        }
        /* Pagination styling */
        .pagination {
            margin: 20px 0;
            text-align: center;
        }
        .pagination a, .pagination strong {
            display: inline-block;
            padding: 8px 12px;
            margin: 0 4px;
            text-decoration: none;
            border: 1px solid #ddd;
            border-radius: 4px;
            color: #333;
        }
        .pagination a:hover {
            background-color: #4CAF50;
            color: white;
        }
        .pagination strong {
            background-color: #4CAF50;
            color: white;
            border-color: #4CAF50;
        }
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>

    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            ✓ <%= request.getParameter("message") %>
        </div>
    <% } %>

    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            ✗ <%= request.getParameter("error") %>
        </div>
    <% } %>

    <!-- Search form (Exercise 5) -->
    <form action="list_students.jsp" method="GET" style="margin-bottom:12px;">
        <input type="text" name="keyword" placeholder="Search by name or code..."
               value="<%= (request.getParameter("keyword")!=null) ? request.getParameter("keyword") : "" %>">
        <button type="submit">Search</button>
        <a href="list_students.jsp">Clear</a>
    </form>

    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    <a href="export_csv.jsp" class="btn" style="background-color:#2196F3;">📥 Export to CSV</a>

    <!-- BONUS 3: Bulk Delete Form -->
    <form id="bulkDeleteForm" action="bulk_delete.jsp" method="POST" style="display:inline;">
        <button type="button" onclick="deleteSelected()" class="btn" style="background-color:#dc3545;">🗑️ Delete Selected</button>
    
    <!-- Exercise 7.2c: Responsive table wrapper -->
    <div class="table-responsive">
    <table>
        <thead>
<%
    // BONUS 2: Get sort parameters
    String sortBy = request.getParameter("sort");
    String order = request.getParameter("order");
    String keyword = request.getParameter("keyword");
    
    // Default sort
    if (sortBy == null) sortBy = "id";
    if (order == null) order = "desc";
    
    // Toggle order for current column
    String newOrder = order.equals("asc") ? "desc" : "asc";
    
    // Build URL parameters for sorting links
    String keywordParam = (keyword != null && !keyword.isEmpty()) ? "&keyword=" + URLEncoder.encode(keyword, "UTF-8") : "";
%>
            <tr>
                <th><input type="checkbox" id="selectAll" onclick="toggleSelectAll(this)"> All</th>
                <th><a href="list_students.jsp?sort=id&order=<%= newOrder %><%= keywordParam %>" style="color:white;text-decoration:none;">ID <%= sortBy.equals("id") ? (order.equals("asc") ? "↑" : "↓") : "" %></a></th>
                <th><a href="list_students.jsp?sort=student_code&order=<%= newOrder %><%= keywordParam %>" style="color:white;text-decoration:none;">Student Code <%= sortBy.equals("student_code") ? (order.equals("asc") ? "↑" : "↓") : "" %></a></th>
                <th><a href="list_students.jsp?sort=full_name&order=<%= newOrder %><%= keywordParam %>" style="color:white;text-decoration:none;">Full Name <%= sortBy.equals("full_name") ? (order.equals("asc") ? "↑" : "↓") : "" %></a></th>
                <th>Email</th>
                <th>Major</th>
                <th><a href="list_students.jsp?sort=created_at&order=<%= newOrder %><%= keywordParam %>" style="color:white;text-decoration:none;">Created At <%= sortBy.equals("created_at") ? (order.equals("asc") ? "↑" : "↓") : "" %></a></th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // Load MySQL JDBC Driver
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        // Connect to database (using mysql service name for Docker)
        conn = DriverManager.getConnection(
            "jdbc:mysql://mysql:3306/student_management",
            "root",
            "password"
        );

        // Exercise 7.1: Pagination - Get page number from URL (default = 1)
        String pageParam = request.getParameter("page");
        int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
        
        // Records per page
        int recordsPerPage = 10;
        
        // Calculate offset
        int offset = (currentPage - 1) * recordsPerPage;

        // Get keyword for search (already declared above)
        keyword = request.getParameter("keyword");
        
        // First, get total records for pagination
        int totalRecords = 0;
        String countSql;
        if (keyword != null && !keyword.trim().isEmpty()) {
            countSql = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
            pstmt = conn.prepareStatement(countSql);
            String like = "%" + keyword + "%";
            pstmt.setString(1, like);
            pstmt.setString(2, like);
        } else {
            countSql = "SELECT COUNT(*) FROM students";
            pstmt = conn.prepareStatement(countSql);
        }
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalRecords = rs.getInt(1);
        }
        rs.close();
        pstmt.close();
        
        // Calculate total pages
        int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

        // BONUS 2: Get sort parameters (re-read from request)
        sortBy = request.getParameter("sort");
        order = request.getParameter("order");
        if (sortBy == null) sortBy = "id";
        if (order == null) order = "desc";
        
        // Validate sortBy to prevent SQL injection
        String[] allowedColumns = {"id", "student_code", "full_name", "created_at"};
        boolean validSort = false;
        for (String col : allowedColumns) {
            if (col.equals(sortBy)) {
                validSort = true;
                break;
            }
        }
        if (!validSort) sortBy = "id";
        
        // Validate order
        if (!order.equals("asc") && !order.equals("desc")) {
            order = "desc";
        }

        // Now get the actual records with LIMIT, OFFSET, and ORDER BY
        String sql;
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            String like = "%" + keyword + "%";
            pstmt.setString(1, like);
            pstmt.setString(2, like);
            pstmt.setInt(3, recordsPerPage);
            pstmt.setInt(4, offset);
        } else {
            sql = "SELECT * FROM students ORDER BY " + sortBy + " " + order + " LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, recordsPerPage);
            pstmt.setInt(2, offset);
        }

        rs = pstmt.executeQuery();

        while (rs.next()) {
            int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            Timestamp createdAt = rs.getTimestamp("created_at");

            // Highlight matches if keyword provided
            String displayName = fullName;
            String displayCode = studentCode;
            if (keyword != null && !keyword.trim().isEmpty()) {
                try {
                    displayName = fullName.replaceAll("(?i)("+Pattern.quote(keyword)+")", "<mark>$1</mark>");
                    displayCode = studentCode.replaceAll("(?i)("+Pattern.quote(keyword)+")", "<mark>$1</mark>");
                } catch (Exception e) {
                    // if regex fails, fallback to original
                }
            }
%>
            <tr>
                <td><input type="checkbox" name="ids" value="<%= id %>" class="studentCheckbox"></td>
                <td><%= id %></td>
                <td><%= displayCode %></td>
                <td><%= displayName %></td>
                <td><%= email %></td>
                <td><%= major %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="edit-link">✏️ Edit</a> |
                    <a href="delete_student.jsp?id=<%= id %>" class="delete-link"
                       onclick="return confirm('Are you sure you want to delete this student?')">🗑️ Delete</a>
                </td>
            </tr>
<%
        }
%>
        </tbody>
    </table>
    </div>
    </form>

    <!-- Exercise 7.1: Pagination Links -->
    <% if (totalPages > 1) { 
        // Build pagination URL parameters
        String sortParam = (sortBy != null) ? "&sort=" + sortBy : "";
        String orderParam = (order != null) ? "&order=" + order : "";
        keywordParam = (keyword != null && !keyword.isEmpty()) ? "&keyword=" + URLEncoder.encode(keyword, "UTF-8") : "";
        String allParams = keywordParam + sortParam + orderParam;
    %>
    <div class="pagination">
        <% if (currentPage > 1) { %>
            <a href="list_students.jsp?page=<%= currentPage - 1 %><%= allParams %>">Previous</a>
        <% } %>
        
        <% for (int i = 1; i <= totalPages; i++) { %>
            <% if (i == currentPage) { %>
                <strong><%= i %></strong>
            <% } else { %>
                <a href="list_students.jsp?page=<%= i %><%= allParams %>"><%= i %></a>
            <% } %>
        <% } %>
        
        <% if (currentPage < totalPages) { %>
            <a href="list_students.jsp?page=<%= currentPage + 1 %><%= allParams %>">Next</a>
        <% } %>
    </div>
    <% } %>

<%
    } catch (ClassNotFoundException e) {
        out.println("<p style='color:red'>Error: JDBC Driver not found!</p>");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("<p style='color:red'>Database Error: " + e.getMessage() + "</p>");
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

    <!-- Exercise 7.2a: Auto-hide messages after 3 seconds -->
    <!-- Exercise 7.2b: Loading state for buttons -->
    <!-- BONUS 3: Bulk delete JavaScript -->
    <script>
    // Auto-hide success/error messages after 3 seconds
    setTimeout(function() {
        var messages = document.querySelectorAll('.message');
        messages.forEach(function(msg) {
            msg.style.display = 'none';
        });
    }, 3000);
    
    // BONUS 3: Toggle select all checkboxes
    function toggleSelectAll(selectAllCheckbox) {
        var checkboxes = document.querySelectorAll('.studentCheckbox');
        checkboxes.forEach(function(checkbox) {
            checkbox.checked = selectAllCheckbox.checked;
        });
    }
    
    // BONUS 3: Delete selected students
    function deleteSelected() {
        var checkboxes = document.querySelectorAll('.studentCheckbox:checked');
        if (checkboxes.length === 0) {
            alert('Please select at least one student to delete');
            return;
        }
        
        var count = checkboxes.length;
        if (confirm('Are you sure you want to delete ' + count + ' student(s)?')) {
            document.getElementById('bulkDeleteForm').submit();
        }
    }
    </script>
</body>
</html>

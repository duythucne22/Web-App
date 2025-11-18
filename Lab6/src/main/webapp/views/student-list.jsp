<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
        }
        .info {
            background-color: #d1ecf1;
            color: #0c5460;
        }
        .active-filters {
            background-color: #e9ecef;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .active-filters ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .active-filters li {
            display: inline-block;
            margin-right: 10px;
            padding: 5px 10px;
            background-color: #007bff;
            color: white;
            border-radius: 15px;
            font-size: 14px;
        }
        .active-filters .clear-filter {
            color: #ff6b6b;
            cursor: pointer;
            margin-left: 5px;
            font-weight: bold;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            border: none;
            cursor: pointer;
        }
        .btn:hover {
            background-color: #0069d9;
        }
        .btn-secondary {
            background-color: #6c757d;
        }
        .btn-secondary:hover {
            background-color: #5a6268;
        }
        .btn-success {
            background-color: #28a745;
        }
        .btn-success:hover {
            background-color: #218838;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }
        .filter-box {
            margin-bottom: 20px;
            padding: 15px;
            background-color: white;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            margin-right: 10px;
        }
        .sort-indicator {
            margin-left: 5px;
            font-size: 0.8em;
        }
        .pagination {
            margin: 20px 0;
            text-align: center;
        }
        .pagination a {
            padding: 8px 12px;
            margin: 0 4px;
            border: 1px solid #ddd;
            text-decoration: none;
            color: #007bff;
            border-radius: 4px;
        }
        .pagination a:hover {
            background-color: #f8f9fa;
        }
        .pagination strong {
            padding: 8px 12px;
            margin: 0 4px;
            background-color: #4CAF50;
            color: white;
            border: 1px solid #4CAF50;
            border-radius: 4px;
        }
        .pagination-info {
            text-align: center;
            margin-top: 10px;
            color: #6c757d;
        }
        .form-inline {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        .form-control {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            min-width: 200px;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h2>📚 Student Management System</h2>
        <div class="navbar-right">
            <div class="user-info">
                <span>Welcome, ${sessionScope.fullName}</span>
                <span class="role-badge role-${sessionScope.role}">
                    ${sessionScope.role}
                </span>
            </div>
            <a href="dashboard" class="btn-nav">Dashboard</a>
            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </div>
    
    <h1>📚 Student Management System (MVC)</h1>
    
    <c:if test="${not empty param.message}">
        <div class="message success">
            ${param.message}
        </div>
    </c:if>
    
    <c:if test="${not empty param.error}">
        <div class="message error">
            ${param.error}
        </div>
    </c:if>
    
    <a href="student?action=new" class="btn">➕ Add New Student</a>
    <a href="export" class="btn btn-success" style="margin-left: 10px;">📊 Export to Excel</a>

    <!-- Active Filters Display -->
    <c:if test="${not empty keyword or not empty selectedMajor or (sortBy != 'id' or order != 'desc')}">
        <div class="active-filters">
            <strong>Active Filters:</strong>
            <ul>
                <c:if test="${not empty keyword}">
                    <li>
                        Search: "${keyword}" 
                        <span class="clear-filter" onclick="clearFilter('keyword')">✕</span>
                    </li>
                </c:if>
                <c:if test="${not empty selectedMajor}">
                    <li>
                        Major: "${selectedMajor}" 
                        <span class="clear-filter" onclick="clearFilter('major')">✕</span>
                    </li>
                </c:if>
                <c:if test="${sortBy != 'id' or order != 'desc'}">
                    <li>
                        Sort: ${sortBy} ${order == 'asc' ? '▲' : '▼'}
                        <span class="clear-filter" onclick="clearFilter('sort')">✕</span>
                    </li>
                </c:if>
            </ul>
        </div>
    </c:if>

    <!-- Combined Search + Filter Form -->
    <div class="form-inline">
        <form action="student" method="GET" style="display: flex; gap: 10px; align-items: center;">
            <input type="hidden" name="action" value="list">
            
            <!-- Search field -->
            <input type="text" name="keyword" placeholder="Search by name/code/email..." 
                   value="${fn:escapeXml(keyword)}" class="form-control"
                   style="min-width: 250px;">
            
            <!-- Major filter -->
            <select name="major" class="form-control" style="min-width: 200px;">
                <option value="">All Majors</option>
                <option value="Computer Science" ${selectedMajor == 'Computer Science' ? 'selected' : ''}>
                    Computer Science
                </option>
                <option value="Information Technology" ${selectedMajor == 'Information Technology' ? 'selected' : ''}>
                    Information Technology
                </option>
                <option value="Software Engineering" ${selectedMajor == 'Software Engineering' ? 'selected' : ''}>
                    Software Engineering
                </option>
                <option value="Business Administration" ${selectedMajor == 'Business Administration' ? 'selected' : ''}>
                    Business Administration
                </option>
            </select>
            
            <!-- Sort options -->
            <select name="sortBy" class="form-control" style="min-width: 150px;">
                <option value="id" ${sortBy == 'id' ? 'selected' : ''}>ID</option>
                <option value="student_code" ${sortBy == 'student_code' ? 'selected' : ''}>Student Code</option>
                <option value="full_name" ${sortBy == 'full_name' ? 'selected' : ''}>Full Name</option>
                <option value="email" ${sortBy == 'email' ? 'selected' : ''}>Email</option>
                <option value="major" ${sortBy == 'major' ? 'selected' : ''}>Major</option>
            </select>
            
            <select name="order" class="form-control" style="min-width: 100px;">
                <option value="asc" ${order == 'asc' ? 'selected' : ''}>Ascending ▲</option>
                <option value="desc" ${order == 'desc' ? 'selected' : ''}>Descending ▼</option>
            </select>
            
            <button type="submit" class="btn" style="padding: 8px 15px;">Apply</button>
            <c:if test="${not empty keyword or not empty selectedMajor or sortBy != 'id' or order != 'desc'}">
                <a href="student?action=list" class="btn btn-secondary" style="padding: 8px 15px;">Clear All</a>
            </c:if>
        </form>
    </div>

    <table>
        <thead>
            <tr>
                <th>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=id&order=${sortBy == 'id' && order == 'asc' ? 'desc' : 'asc'}" style="color: white; text-decoration: none;">
                        ID
                        <c:if test="${sortBy == 'id'}">
                            <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                        </c:if>
                    </a>
                </th>
                <th>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=student_code&order=${sortBy == 'student_code' && order == 'asc' ? 'desc' : 'asc'}" style="color: white; text-decoration: none;">
                        Student Code
                        <c:if test="${sortBy == 'student_code'}">
                            <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                        </c:if>
                    </a>
                </th>
                <th>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=full_name&order=${sortBy == 'full_name' && order == 'asc' ? 'desc' : 'asc'}" style="color: white; text-decoration: none;">
                        Full Name
                        <c:if test="${sortBy == 'full_name'}">
                            <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                        </c:if>
                    </a>
                </th>
                <th>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=email&order=${sortBy == 'email' && order == 'asc' ? 'desc' : 'asc'}" style="color: white; text-decoration: none;">
                        Email
                        <c:if test="${sortBy == 'email'}">
                            <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                        </c:if>
                    </a>
                </th>
                <th>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=major&order=${sortBy == 'major' && order == 'asc' ? 'desc' : 'asc'}" style="color: white; text-decoration: none;">
                        Major
                        <c:if test="${sortBy == 'major'}">
                            <span class="sort-indicator">${order == 'asc' ? '▲' : '▼'}</span>
                        </c:if>
                    </a>
                </th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach var="student" items="${students}">
                <tr>
                    <td>${student.id}</td>
                    <td>${student.studentCode}</td>
                    <td>${student.fullName}</td>
                    <td>${student.email != null ? student.email : 'N/A'}</td>
                    <td>${student.major != null ? student.major : 'N/A'}</td>
                    <td>
                        <a href="student?action=edit&id=${student.id}" class="action-link">✏️ Edit</a>
                        <a href="student?action=delete&id=${student.id}" 
                           class="action-link delete-link"
                           onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                    </td>
                </tr>
            </c:forEach>
            
            <c:if test="${empty students}">
                <tr>
                    <td colspan="6" style="text-align: center;">
                        <c:choose>
                            <c:when test="${not empty keyword or not empty selectedMajor}">
                                No students found matching your criteria
                            </c:when>
                            <c:otherwise>
                                No students found.
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:if>
        </tbody>
    </table>

    <div class="pagination">
        <c:if test="${currentPage > 1}">
            <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=${sortBy}&order=${order}&page=${currentPage - 1}">&laquo; Previous</a>
        </c:if>
        
        <c:forEach begin="1" end="${totalPages}" var="i">
            <c:choose>
                <c:when test="${i == currentPage}">
                    <strong>${i}</strong>
                </c:when>
                <c:otherwise>
                    <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=${sortBy}&order=${order}&page=${i}">${i}</a>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        
        <c:if test="${currentPage < totalPages}">
            <a href="student?action=list&keyword=${fn:escapeXml(keyword)}&major=${fn:escapeXml(selectedMajor)}&sortBy=${sortBy}&order=${order}&page=${currentPage + 1}">Next &raquo;</a>
        </c:if>
    </div>
    
    <p class="pagination-info">
        Showing page ${currentPage} of ${totalPages}
        <c:if test="${totalPages > 0}">
            (Total records: ${totalRecords})
        </c:if>
    </p>

    <script>
        function clearFilter(filterType) {
            let url = new URL(window.location.href);
            
            switch(filterType) {
                case 'keyword':
                    url.searchParams.delete('keyword');
                    break;
                case 'major':
                    url.searchParams.delete('major');
                    break;
                case 'sort':
                    url.searchParams.set('sortBy', 'id');
                    url.searchParams.set('order', 'desc');
                    break;
            }
            
            // Keep page parameter if exists
            if (!url.searchParams.has('page')) {
                url.searchParams.set('page', '1');
            }
            
            // Ensure action is list
            url.searchParams.set('action', 'list');
            
            window.location.href = url.toString();
        }
    </script>
</body>
</html>
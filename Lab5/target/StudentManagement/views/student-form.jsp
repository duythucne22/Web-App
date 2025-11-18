<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>
        <c:choose>
            <c:when test="${student != null}">Edit Student</c:when>
            <c:otherwise>Add New Student</c:otherwise>
        </c:choose>
    </title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 600px;
            margin: 50px auto;
            background-color: white;
            padding: 30px;
            border-radius: 10px;
        }
        h2 { color: #333; margin-bottom: 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="text"], input[type="email"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .btn-submit {
            background-color: #28a745;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-right: 10px;
        }
        .btn-cancel {
            background-color: #6c757d;
            color: white;
            padding: 12px 30px;
            text-decoration: none;
            display: inline-block;
            border-radius: 5px;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .field-error {
            color: red;
            font-size: 14px;
            display: block;
            margin-top: 5px;
        }
        .photo-preview {
            margin-top: 15px;
            text-align: center;
        }
        .photo-preview img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 5px;
            border: 1px solid #ddd;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>
            <c:if test="${student != null}">✏️ Edit Student</c:if>
            <c:if test="${student == null}">➕ Add New Student</c:if>
        </h2>
        
        <c:if test="${not empty param.error}">
            <div class="error">${param.error}</div>
        </c:if>
        
        <form action="student" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="action" 
                   value="${student != null ? 'update' : 'insert'}">
            
            <c:if test="${student != null}">
                <input type="hidden" name="id" value="${student.id}">
            </c:if>
            
            <div class="form-group">
                <label>Student Code:</label>
                <input type="text" name="studentCode" 
                       value="${student.studentCode}" 
                       ${student != null ? 'readonly' : 'required'}>
                <c:if test="${not empty errorCode}">
                    <span class="field-error">${errorCode}</span>
                </c:if>
            </div>
            
            <div class="form-group">
                <label>Full Name:</label>
                <input type="text" name="fullName" 
                       value="${student.fullName}" required>
                <c:if test="${not empty errorName}">
                    <span class="field-error">${errorName}</span>
                </c:if>
            </div>
            
            <div class="form-group">
                <label>Email:</label>
                <input type="email" name="email" 
                       value="${student.email}">
                <c:if test="${not empty errorEmail}">
                    <span class="field-error">${errorEmail}</span>
                </c:if>
            </div>
            
            <div class="form-group">
                <label>Major:</label>
                <input type="text" name="major" 
                       value="${student.major}">
                <c:if test="${not empty errorMajor}">
                    <span class="field-error">${errorMajor}</span>
                </c:if>
            </div>
            
            <div class="form-group">
                <label>Profile Photo:</label>
                <input type="file" name="photo" accept="image/*">
                <c:if test="${not empty errorPhoto}">
                    <span class="field-error">${errorPhoto}</span>
                </c:if>
                
                <c:if test="${student != null && student.photo != null}">
                    <div class="photo-preview">
                        <p>Current photo:</p>
                        <img src="${pageContext.request.contextPath}/uploads/${student.photo}" alt="Student photo">
                    </div>
                </c:if>
            </div>
            
            <button type="submit" class="btn-submit">
                <c:if test="${student != null}">💾 Update</c:if>
                <c:if test="${student == null}">💾 Save</c:if>
            </button>
            <a href="student?action=list" class="btn-cancel">Cancel</a>
        </form>
    </div>
</body>
</html>
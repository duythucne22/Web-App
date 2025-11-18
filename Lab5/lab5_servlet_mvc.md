# LAB 5: SERVLET & MVC PATTERN
## Setup Guide & Sample Code

**Course:** Web Application Development  
**Duration:** 2.5 hours  
**Prerequisites:** Lab 1 completed (JSP + MySQL CRUD)

> **Note:** This lab refactors Lab 1 code into MVC architecture. Read this BEFORE the lab session.

---

## 📋 TABLE OF CONTENTS

1. [Why MVC?](#1-why-mvc)
2. [MVC Architecture Overview](#2-mvc-architecture-overview)
3. [Understanding Servlets](#3-understanding-servlets)
4. [Project Setup](#4-project-setup)
5. [Sample Code - MVC Implementation](#5-sample-code---mvc-implementation)
6. [JSTL Introduction](#6-jstl-introduction)
7. [Running the Demo](#7-running-the-demo)
8. [Comparison: Before vs After](#8-comparison-before-vs-after)
9. [Best Practices](#9-best-practices)
10. [Summary](#10-summary)

---

## 1. WHY MVC?

### Problems with JSP-Only Approach (Lab 1)

Example from Lab 1:

```jsp
<%@ page import="java.sql.*" %>
<%
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(...);
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM students");
        
        while (rs.next()) {
            // Display logic mixed with database logic
%>
    <tr>
        <td><%= rs.getString("name") %></td>
    </tr>
<%
        }
    } catch (SQLException e) {
        // Error handling
    } finally {
        // Close connections
    }
%>
```

**Issues:**

- ❌ **Mixing Concerns** - Database code + HTML in same file
- ❌ **Code Duplication** - Connection code repeated everywhere
- ❌ **Hard to Maintain** - Changes require editing multiple JSP files
- ❌ **No Reusability** - Can't reuse logic for different interfaces (web, mobile API)
- ❌ **Hard to Test** - Can't unit test JSP pages
- ❌ **Team Conflicts** - Designers and developers work on same files

### Benefits of MVC

- ✅ **Separation of Concerns** - Each layer has single responsibility
- ✅ **Reusability** - Business logic can serve web, mobile, API
- ✅ **Maintainability** - Changes isolated to specific layers
- ✅ **Testability** - Can unit test models and controllers
- ✅ **Team Collaboration** - Designers work on views, developers on logic
- ✅ **Industry Standard** - Used in all modern frameworks

---

## 2. MVC ARCHITECTURE OVERVIEW

### MVC Diagram

```
┌─────────┐
│ Browser │
└────┬────┘
     │ 1. HTTP Request
     ▼
┌──────────────┐
│ CONTROLLER   │ ◄── Servlet (Java Class)
│ (Servlet)    │     - Receives requests
└──────┬───────┘     - Calls Model
       │ 2. Process  - Selects View
       ▼
┌──────────────┐
│ MODEL        │ ◄── JavaBean + DAO
│ (Business    │     - Data objects
│  Logic)      │     - Database operations
└──────┬───────┘
       │ 3. Get Data
       ▼
┌──────────────┐
│ VIEW         │ ◄── JSP (Display Only)
│ (JSP)        │     - No business logic
└──────┬───────┘     - Only presentation
       │ 4. Render
       ▼
┌─────────┐
│ Browser │
└─────────┘
```

### Layer Responsibilities

**MODEL:**
- Represents data (Student, User objects)
- Business logic
- Database operations (DAO - Data Access Object)
- No knowledge of View or Controller

**VIEW:**
- Presentation layer (JSP)
- Displays data from Model
- No business logic
- No database access

**CONTROLLER:**
- Receives HTTP requests (Servlet)
- Processes user input
- Calls Model for data
- Selects appropriate View
- Passes data to View

### Request Flow Example

**User clicks "View Students":**

1. Browser → `GET /student?action=list`
2. `StudentController` receives request
3. Controller calls `StudentDAO.getAllStudents()`
4. DAO queries database, returns `List<Student>`
5. Controller sets attribute: `request.setAttribute("students", list)`
6. Controller forwards to `student-list.jsp`
7. JSP displays students from attribute
8. HTML response sent to browser

---

## 3. UNDERSTANDING SERVLETS

### What is a Servlet?

A Servlet is a Java class that handles HTTP requests and responses.

**Servlet Lifecycle:**

1. `init()` - Called once when servlet loads
2. `service()` - Called for each request
   - `doGet()` - Handles GET requests
   - `doPost()` - Handles POST requests
3. `destroy()` - Called when servlet unloads

### Basic Servlet Example

```java
// filepath: src/controller/HelloServlet.java
package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        
        out.println("<html>");
        out.println("<body>");
        out.println("<h1>Hello from Servlet!</h1>");
        out.println("</body>");
        out.println("</html>");
    }
}
```

**Explanation:**
- `@WebServlet("/hello")` - Maps URL `/hello` to this servlet
- `Extends HttpServlet` - Inherits servlet functionality
- `doGet()` - Handles HTTP GET requests
- `request` - Contains request data (parameters, headers)
- `response` - Used to send response back to client

**URL Mapping:**

```
http://localhost:8080/YourApp/hello
                                 ↑
                          Servlet URL pattern
```

### Servlet Annotations

```java
// Simple URL mapping
@WebServlet("/student")

// Multiple URL patterns
@WebServlet({"/student", "/students"})

// With name and parameters
@WebServlet(
    name = "StudentServlet",
    urlPatterns = {"/student"},
    loadOnStartup = 1
)
```

### doGet vs doPost

```java
@WebServlet("/demo")
public class DemoServlet extends HttpServlet {
    
    // Handles: GET /demo
    protected void doGet(HttpServletRequest request, HttpServletResponse response) {
        // Use for: viewing data, search, filter
        // Parameters visible in URL
    }
    
    // Handles: POST /demo
    protected void doPost(HttpServletRequest request, HttpServletResponse response) {
        // Use for: create, update, delete
        // Parameters in request body
    }
}
```

**When to use:**
- **GET:** Retrieve/display data, idempotent operations
- **POST:** Modify data, non-idempotent operations

---

## 4. PROJECT SETUP

### Project Structure

```
StudentManagementMVC/
│
├── Source Packages/
│   ├── model/
│   │   └── Student.java              (JavaBean/POJO)
│   │
│   ├── dao/
│   │   └── StudentDAO.java           (Data Access Object)
│   │
│   └── controller/
│       └── StudentController.java    (Servlet)
│
├── Web Pages/
│   ├── WEB-INF/
│   │   └── web.xml
│   │
│   └── views/
│       ├── student-list.jsp
│       └── student-form.jsp
│
└── Libraries/
    ├── MySQL Connector/J
    └── JSTL 1.2
```

### Required Libraries

**1. MySQL Connector/J** (already added in Lab 1)

**2. JSTL (JavaServer Pages Standard Tag Library)**

Download: `jstl-1.2.jar`

**Add to Project:**
- Right-click project → Properties
- Libraries → Add JAR/Folder
- Select `jstl-1.2.jar`
- OK

Or copy to: `WebContent/WEB-INF/lib/jstl-1.2.jar`

---

## 5. SAMPLE CODE - MVC IMPLEMENTATION

### 5.1 MODEL Layer

#### Student JavaBean (POJO)

```java
// filepath: src/model/Student.java
package model;

import java.sql.Timestamp;

public class Student {
    private int id;
    private String studentCode;
    private String fullName;
    private String email;
    private String major;
    private Timestamp createdAt;
    
    public Student() {
    }
    
    public Student(String studentCode, String fullName, String email, String major) {
        this.studentCode = studentCode;
        this.fullName = fullName;
        this.email = email;
        this.major = major;
    }
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getStudentCode() {
        return studentCode;
    }
    
    public void setStudentCode(String studentCode) {
        this.studentCode = studentCode;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getMajor() {
        return major;
    }
    
    public void setMajor(String major) {
        this.major = major;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    @Override
    public String toString() {
        return "Student{" +
                "id=" + id +
                ", studentCode='" + studentCode + '\'' +
                ", fullName='" + fullName + '\'' +
                '}';
    }
}
```

**Explanation:**

**JavaBean Rules:**
- Public class
- Private attributes
- Public no-argument constructor
- Public getters and setters
- Implements Serializable (optional)

**Purpose:**
- Represents one row in database
- Encapsulates student data
- Used to transfer data between layers

**Naming Convention:**
- Class name: PascalCase (`Student`)
- Attributes: camelCase (`studentCode`)
- Getters: `get` + AttributeName (`getStudentCode`)
- Setters: `set` + AttributeName (`setStudentCode`)
- Boolean getters: `is` + AttributeName (`isActive`)

#### Student DAO

```java
// filepath: src/dao/StudentDAO.java
package dao;

import model.Student;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StudentDAO {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/student_management";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "your_password";
    
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC Driver not found", e);
        }
    }
    
    public List<Student> getAllStudents() {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students ORDER BY id DESC";
        
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("id"));
                student.setStudentCode(rs.getString("student_code"));
                student.setFullName(rs.getString("full_name"));
                student.setEmail(rs.getString("email"));
                student.setMajor(rs.getString("major"));
                student.setCreatedAt(rs.getTimestamp("created_at"));
                
                students.add(student);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return students;
    }
    
    public Student getStudentById(int id) {
        String sql = "SELECT * FROM students WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("id"));
                student.setStudentCode(rs.getString("student_code"));
                student.setFullName(rs.getString("full_name"));
                student.setEmail(rs.getString("email"));
                student.setMajor(rs.getString("major"));
                student.setCreatedAt(rs.getTimestamp("created_at"));
                return student;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }
    
    public boolean addStudent(Student student) {
        String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, student.getStudentCode());
            pstmt.setString(2, student.getFullName());
            pstmt.setString(3, student.getEmail());
            pstmt.setString(4, student.getMajor());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean updateStudent(Student student) {
        String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, student.getFullName());
            pstmt.setString(2, student.getEmail());
            pstmt.setString(3, student.getMajor());
            pstmt.setInt(4, student.getId());
            
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public boolean deleteStudent(int id) {
        String sql = "DELETE FROM students WHERE id = ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    public List<Student> searchStudents(String keyword) {
        List<Student> students = new ArrayList<>();
        String sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            pstmt.setString(1, searchPattern);
            pstmt.setString(2, searchPattern);
            
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Student student = new Student();
                student.setId(rs.getInt("id"));
                student.setStudentCode(rs.getString("student_code"));
                student.setFullName(rs.getString("full_name"));
                student.setEmail(rs.getString("email"));
                student.setMajor(rs.getString("major"));
                students.add(student);
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return students;
    }
}
```

**Explanation:**

**DAO Pattern Purpose:**
- Centralizes all database operations
- Provides clean interface for data access
- Hides SQL complexity from other layers
- Makes testing easier (can mock DAO)

**Try-with-Resources:**

```java
try (Connection conn = getConnection();
     PreparedStatement pstmt = conn.prepareStatement(sql)) {
    // Use resources
} // Automatically closed
```

- Java 7+ feature
- Resources auto-closed when try block exits
- No need for finally block
- Cleaner code

**Method Return Types:**
- `List<Student>` - Multiple students
- `Student` - Single student (or null if not found)
- `boolean` - Success/failure for CUD operations

**Constants:**

```java
private static final String DB_URL = "...";
```

- Centralized configuration
- Easy to change
- Good practice

### 5.2 CONTROLLER Layer

```java
// filepath: src/controller/StudentController.java
package controller;

import dao.StudentDAO;
import model.Student;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/student")
public class StudentController extends HttpServlet {
    
    private StudentDAO studentDAO;
    
    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "list";
        }
        
        switch (action) {
            case "list":
                listStudents(request, response);
                break;
            case "new":
                showNewForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteStudent(request, response);
                break;
            default:
                listStudents(request, response);
                break;
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        
        if (action == null) {
            action = "insert";
        }
        
        switch (action) {
            case "insert":
                insertStudent(request, response);
                break;
            case "update":
                updateStudent(request, response);
                break;
            default:
                listStudents(request, response);
                break;
        }
    }
    
    private void listStudents(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<Student> students = studentDAO.getAllStudents();
        request.setAttribute("students", students);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
        dispatcher.forward(request, response);
    }
    
    private void showNewForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
        dispatcher.forward(request, response);
    }
    
    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        Student student = studentDAO.getStudentById(id);
        
        request.setAttribute("student", student);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
        dispatcher.forward(request, response);
    }
    
    private void insertStudent(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String studentCode = request.getParameter("studentCode");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");
        
        Student student = new Student(studentCode, fullName, email, major);
        
        if (studentDAO.addStudent(student)) {
            response.sendRedirect("student?action=list&message=Student added successfully");
        } else {
            response.sendRedirect("student?action=new&error=Failed to add student");
        }
    }
    
    private void updateStudent(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");
        
        Student student = new Student();
        student.setId(id);
        student.setFullName(fullName);
        student.setEmail(email);
        student.setMajor(major);
        
        if (studentDAO.updateStudent(student)) {
            response.sendRedirect("student?action=list&message=Student updated successfully");
        } else {
            response.sendRedirect("student?action=edit&id=" + id + "&error=Failed to update");
        }
    }
    
    private void deleteStudent(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        
        if (studentDAO.deleteStudent(id)) {
            response.sendRedirect("student?action=list&message=Student deleted successfully");
        } else {
            response.sendRedirect("student?action=list&error=Failed to delete student");
        }
    }
}
```

**Explanation:**

**Servlet Lifecycle Methods:**

`init()`:

```java
public void init() {
    studentDAO = new StudentDAO();
}
```

- Called once when servlet first loaded
- Initialize resources (DAO, connections, configs)
- Good place for one-time setup

`doGet()` / `doPost()`:
- Called for each request
- Route to appropriate handler method

**Action Parameter Pattern:**

```
/student?action=list           → listStudents()
/student?action=new            → showNewForm()
/student?action=edit&id=5      → showEditForm()
/student?action=delete&id=5    → deleteStudent()
```

**RequestDispatcher.forward():**

```java
RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
dispatcher.forward(request, response);
```

- Server-side forward
- URL doesn't change in browser
- Request/response objects passed to JSP
- Use for displaying views

**response.sendRedirect():**

```java
response.sendRedirect("student?action=list&message=Success");
```

- Client-side redirect (HTTP 302)
- Browser makes new request
- URL changes in browser
- Use after POST to prevent duplicate submission (PRG pattern)

**Setting Attributes:**

```java
request.setAttribute("students", studentList);
```

- Stores data in request scope
- Available to forwarded JSP
- JSP retrieves with `${students}`

### 5.3 VIEW Layer

#### Student List View

```jsp
<!-- filepath: WebContent/views/student-list.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
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
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
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
    </style>
</head>
<body>
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
    
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Student Code</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Major</th>
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
                        No students found.
                    </td>
                </tr>
            </c:if>
        </tbody>
    </table>
</body>
</html>
```

**Explanation:**

**JSTL Taglib Declaration:**

```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
```

- Import JSTL core library
- Use `c:` prefix for tags

**JSTL Tags Used:**

`c:if` - Conditional rendering:

```jsp
<c:if test="${not empty param.message}">
    <div>${param.message}</div>
</c:if>
```

- `${not empty var}` checks if variable exists and not empty
- `${param.message}` accesses URL parameter

`c:forEach` - Loop through collection:

```jsp
<c:forEach var="student" items="${students}">
    <td>${student.fullName}</td>
</c:forEach>
```

- `items="${students}"` - collection to iterate
- `var="student"` - loop variable
- Access properties with `${student.propertyName}`

**Expression Language (EL):**

```jsp
${student.fullName}
```

- Calls `student.getFullName()` automatically
- Cleaner than `<%= student.getFullName() %>`
- Returns empty string if null (safe)

**Ternary Operator in EL:**

```jsp
${student.email != null ? student.email : 'N/A'}
```

- If email not null, show email
- Else show 'N/A'

**No Java Code!**
- Pure presentation logic
- JSTL and EL replace scriptlets
- Cleaner, more readable

#### Student Form View

```jsp
<!-- filepath: WebContent/views/student-form.jsp -->
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
        
        <form action="student" method="POST">
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
            </div>
            
            <div class="form-group">
                <label>Full Name:</label>
                <input type="text" name="fullName" 
                       value="${student.fullName}" required>
            </div>
            
            <div class="form-group">
                <label>Email:</label>
                <input type="email" name="email" 
                       value="${student.email}">
            </div>
            
            <div class="form-group">
                <label>Major:</label>
                <input type="text" name="major" 
                       value="${student.major}">
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
```

**Explanation:**

**c:choose** - Switch/case statement:

```jsp
<c:choose>
    <c:when test="${student != null}">Edit</c:when>
    <c:otherwise>Add</c:otherwise>
</c:choose>
```

- Like switch-case in Java
- `c:when` = case
- `c:otherwise` = default

**Dynamic Form Values:**

```jsp
value="${student.fullName}"
```

- If student exists, pre-fill with current value
- If student is null, field is empty
- EL handles null gracefully (empty string)

**Dynamic Attributes:**

```jsp
${student != null ? 'readonly' : 'required'}
```

- Edit mode: readonly (can't change code)
- Add mode: required (must enter code)

**Single Form for Add/Edit:**
- Saves code duplication
- Check `${student != null}` to determine mode
- Different action: insert vs update

---

## 6. JSTL INTRODUCTION

### What is JSTL?

JSTL (JavaServer Pages Standard Tag Library) - Collection of tags for common JSP tasks.

### Why Use JSTL?

**Before (Scriptlet):**

```jsp
<% if (user != null) { %>
    <p>Welcome, <%= user.getName() %></p>
<% } %>

<ul>
<% for (Student s : students) { %>
    <li><%= s.getName() %></li>
<% } %>
</ul>
```

**After (JSTL):**

```jsp
<c:if test="${user != null}">
    <p>Welcome, ${user.name}</p>
</c:if>

<ul>
<c:forEach var="s" items="${students}">
    <li>${s.name}</li>
</c:forEach>
</ul>
```

✅ Cleaner, more readable  
✅ No Java code in JSP  
✅ Designer-friendly

### Core JSTL Tags

#### c:if

```jsp
<c:if test="${condition}">
    Content displayed if true
</c:if>
```

**Examples:**

```jsp
<c:if test="${user != null}">
    Welcome back!
</c:if>

<c:if test="${empty students}">
    No students found.
</c:if>

<c:if test="${student.age >= 18}">
    Adult
</c:if>
```

#### c:choose / c:when / c:otherwise

```jsp
<c:choose>
    <c:when test="${score >= 90}">A</c:when>
    <c:when test="${score >= 80}">B</c:when>
    <c:when test="${score >= 70}">C</c:when>
    <c:otherwise>F</c:otherwise>
</c:choose>
```

#### c:forEach

```jsp
<c:forEach var="item" items="${collection}">
    ${item.property}
</c:forEach>
```

**With Index:**

```jsp
<c:forEach var="item" items="${list}" varStatus="status">
    Row ${status.index}: ${item.name}
</c:forEach>
```

**varStatus Properties:**
- `${status.index}` - Current index (0-based)
- `${status.count}` - Current count (1-based)
- `${status.first}` - true if first iteration
- `${status.last}` - true if last iteration

#### c:set

```jsp
<c:set var="name" value="John" />
<p>${name}</p>
```

#### c:redirect

```jsp
<c:if test="${user == null}">
    <c:redirect url="login.jsp" />
</c:if>
```

### Expression Language (EL)

#### Basic Syntax

```jsp
${expression}
```

#### Accessing Properties

```jsp
${student.name}          <!-- Calls student.getName() -->
${student.email}         <!-- Calls student.getEmail() -->
${student.active}        <!-- Calls student.isActive() -->
```

#### Accessing Collections

```jsp
${students[0]}           <!-- First student -->
${studentMap['key']}     <!-- Map access -->
```

#### Implicit Objects

```jsp
${param.name}            <!-- request.getParameter("name") -->
${param.values.hobby}    <!-- request.getParameterValues("hobby") -->
${header.host}           <!-- request.getHeader("host") -->
${cookie.user.value}     <!-- Cookie value -->
${sessionScope.user}     <!-- session.getAttribute("user") -->
${applicationScope.settings} <!-- application.getAttribute("settings") -->
```

#### Operators

```jsp
${a == b}                <!-- Equals -->
${a != b}                <!-- Not equals -->
${a < b}                 <!-- Less than -->
${a > b}                 <!-- Greater than -->
${a && b}                <!-- AND -->
${a || b}                <!-- OR -->
${!a}                    <!-- NOT -->
${empty list}            <!-- Check if null or empty -->
${not empty list}        <!-- Check if not null and not empty -->
```

#### Ternary Operator

```jsp
${condition ? valueIfTrue : valueIfFalse}

${student.email != null ? student.email : 'No email'}
${user.active ? 'Active' : 'Inactive'}
```

---

## 7. RUNNING THE DEMO

### Build and Deploy

1. Clean previous build
2. Right-click project → Clean and Build
3. Right-click project → Run
4. NetBeans starts Tomcat and opens browser

### Test URL Patterns

**List students:**

```
http://localhost:8080/StudentManagementMVC/student
http://localhost:8080/StudentManagementMVC/student?action=list
```

**Add new student:**

```
http://localhost:8080/StudentManagementMVC/student?action=new
```

**Edit student:**

```
http://localhost:8080/StudentManagementMVC/student?action=edit&id=1
```

**Delete student:**

```
http://localhost:8080/StudentManagementMVC/student?action=delete&id=1
```

### Common Issues

| Issue | Solution |
|-------|----------|
| 404 on /student | Check servlet URL mapping |
| ClassNotFoundException | Verify package names match |
| Servlet not found | Clean and rebuild project |
| JSTL tags not working | Add jstl-1.2.jar to WEB-INF/lib |
| ${} shows literally | Add JSTL taglib directive |

---

## 8. COMPARISON: BEFORE VS AFTER

### Before MVC (Lab 1)

**list_students.jsp** - Mixed concerns:

```jsp
<%
    Connection conn = null;
    try {
        Class.forName("...");
        conn = DriverManager.getConnection(...);
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT * FROM students");
        
        while (rs.next()) {
%>
    <tr>
        <td><%= rs.getString("full_name") %></td>
    </tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        // close connections
    }
%>
```

❌ Database logic in JSP  
❌ Repeated connection code  
❌ Hard to test  
❌ Difficult to maintain

### After MVC (Lab 5)

**StudentController.java** - Business logic:

```java
private void listStudents(HttpServletRequest request, HttpServletResponse response) {
    List<Student> students = studentDAO.getAllStudents();
    request.setAttribute("students", students);
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
    dispatcher.forward(request, response);
}
```

**student-list.jsp** - Pure presentation:

```jsp
<c:forEach var="student" items="${students}">
    <tr>
        <td>${student.fullName}</td>
    </tr>
</c:forEach>
```

✅ Separated concerns  
✅ Reusable code  
✅ Testable  
✅ Maintainable

### Benefits Summary

| Aspect | Before (JSP) | After (MVC) |
|--------|--------------|-------------|
| Code Organization | Mixed | Separated |
| Reusability | Low | High |
| Maintainability | Difficult | Easy |
| Testing | Hard | Easy |
| Team Collaboration | Conflicts | Smooth |
| Scalability | Limited | Good |

---

## 9. BEST PRACTICES

### Model Layer

✅ One class per table  
✅ Follow JavaBean conventions  
✅ Use appropriate data types  
✅ Add validation methods if needed

### DAO Layer

✅ Use try-with-resources  
✅ Return appropriate types (List, Object, boolean)  
✅ Handle exceptions properly  
✅ Use constants for SQL

**Example:**

```java
private static final String SQL_SELECT_ALL = "SELECT * FROM students";
private static final String SQL_INSERT = "INSERT INTO students...";
```

### Controller Layer

✅ One servlet per entity (StudentController, UserController)  
✅ Use action parameter for routing  
✅ Validate input before calling DAO  
✅ Use forward for views, redirect after POST

**Validation Example:**

```java
private boolean validateStudent(Student student, HttpServletRequest request) {
    boolean isValid = true;
    
    if (student.getFullName() == null || student.getFullName().trim().isEmpty()) {
        request.setAttribute("errorName", "Name is required");
        isValid = false;
    }
    
    return isValid;
}
```

### View Layer

✅ Use JSTL, avoid scriptlets  
✅ No business logic in JSP  
✅ No direct database access  
✅ Keep views simple

---

## 10. SUMMARY

### What You Learned

✅ **MVC Architecture** - Separation of concerns  
✅ **Servlets** - Handle HTTP requests/responses  
✅ **JavaBeans** - Data encapsulation  
✅ **DAO Pattern** - Centralized data access  
✅ **JSTL** - Tag library for JSP  
✅ **EL** - Expression Language

### Key Concepts

**Model:**
- Represents data
- JavaBean + DAO
- No UI knowledge

**View:**
- Presents data
- JSP + JSTL
- No business logic

**Controller:**
- Handles requests
- Servlet
- Coordinates Model and View

### Why MVC Matters

- **Industry Standard** - Used by all frameworks
- **Scalable** - Easy to add features
- **Maintainable** - Changes isolated
- **Testable** - Unit test each layer
- **Team-Friendly** - Parallel development

### Next Lab Preview

**Lab 6: Authentication & Session Management**

- User login/logout
- Session handling
- Role-based access control
- Building on MVC foundation

---

**End of Setup Guide**

> Review this before Lab 5. Understand MVC concepts thoroughly!
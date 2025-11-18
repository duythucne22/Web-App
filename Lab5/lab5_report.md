# Lab 5: Servlet & MVC Pattern - Implementation Report

## Student Information
- **Name:** Huynh Chung Duy Thuc
- **Student ID:** ITCSIU22284
- **Course:** Web Application Development
- **Date:** November 11, 2025

## Lab Objective
Implement a Student Management System using the MVC (Model-View-Controller) architectural pattern with Servlets, JSP, and MySQL database. The system should support CRUD operations (Create, Read, Update, Delete) for student records.

## System Requirements
- **Model Layer:** Student JavaBean and StudentDAO for data handling
- **View Layer:** JSP pages for displaying and inputting student data
- **Controller Layer:** Servlet to handle HTTP requests and coordinate between Model and View
- **Database:** MySQL with Docker container
- **Web Server:** Tomcat 9 with Maven build system

## Implementation Overview

### 1. Project Structure
```
Lab5/
├── src/main/java/
│   ├── controller/StudentController.java
│   ├── dao/StudentDAO.java
│   └── model/Student.java
├── src/main/webapp/views/
│   ├── student-list.jsp
│   └── student-form.jsp
├── pom.xml
├── docker-compose.yml
└── init_db.sql
```

### 2. MVC Request Flow Explanation

This section explains how the MVC components interact for each CRUD operation, demonstrating the separation of concerns and request flow through the application layers.

#### 2.1 READ Operation - List All Students

**Request Flow:**
```
Browser → Controller → Model → Database → Model → Controller → View → Browser
```

**Detailed Steps:**

1. **User Action:** User opens browser and navigates to `http://localhost:8080/StudentManagement/student`

2. **HTTP Request:** Browser sends `GET /student` request to server

3. **Controller (StudentController.java):**
   - `doGet()` method receives the request
   - Extracts `action` parameter (null defaults to "list")
   - Routes to `listStudents()` method
   ```java
   private void listStudents(HttpServletRequest request, HttpServletResponse response) {
       List<Student> students = studentDAO.getAllStudents(); // Call Model
       request.setAttribute("students", students);            // Set data for View
       RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
       dispatcher.forward(request, response);                 // Forward to View
   }
   ```

4. **Model - DAO (StudentDAO.java):**
   - `getAllStudents()` method is called
   - Opens database connection using `getConnection()`
   - Executes SQL query: `SELECT * FROM students ORDER BY id DESC`
   - Maps each ResultSet row to Student object using setters
   - Returns `List<Student>` to Controller
   ```java
   public List<Student> getAllStudents() {
       List<Student> students = new ArrayList<>();
       // Execute query and map results to Student objects
       return students;
   }
   ```

5. **Model - JavaBean (Student.java):**
   - Plain Java objects holding student data
   - Each Student object represents one database row
   - Contains getters/setters for accessing data

6. **Controller (StudentController.java):**
   - Receives `List<Student>` from DAO
   - Stores list in request scope: `request.setAttribute("students", students)`
   - Forwards request to JSP view

7. **View (student-list.jsp):**
   - Retrieves student list: `${students}`
   - Uses JSTL `<c:forEach>` to iterate through list
   - Accesses Student properties via EL: `${student.fullName}`, `${student.email}`
   - Generates HTML table displaying all students
   ```jsp
   <c:forEach var="student" items="${students}">
       <tr>
           <td>${student.id}</td>
           <td>${student.studentCode}</td>
           <td>${student.fullName}</td>
           <!-- ... -->
       </tr>
   </c:forEach>
   ```

8. **HTTP Response:** Browser receives and renders HTML page with student list

**Key Points:**
- Controller doesn't know HTML structure
- View doesn't know database details
- Model handles only data operations
- Clean separation between layers

---

#### 2.2 CREATE Operation - Add New Student

**Request Flow (Two-Step Process):**
```
Step 1 (GET):  Browser → Controller → View → Browser (Display Form)
Step 2 (POST): Browser → Controller → Model → Database → Controller → View (Redirect)
```

**Detailed Steps:**

**STEP 1: Display Form (GET Request)**

1. **User Action:** User clicks "Add New Student" button

2. **HTTP Request:** Browser sends `GET /student?action=new`

3. **Controller (StudentController.java):**
   - `doGet()` receives request with `action=new`
   - Routes to `showNewForm()` method
   ```java
   private void showNewForm(HttpServletRequest request, HttpServletResponse response) {
       RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
       dispatcher.forward(request, response);
   }
   ```

4. **View (student-form.jsp):**
   - Checks if `${student}` is null (it is for new student)
   - Displays empty form with action="insert"
   - Student Code field is required and editable
   ```jsp
   <form action="student" method="POST">
       <input type="hidden" name="action" value="insert">
       <input type="text" name="studentCode" required>
       <input type="text" name="fullName" required>
       <!-- ... -->
   </form>
   ```

5. **Browser:** Displays form for user input

**STEP 2: Submit Form (POST Request)**

1. **User Action:** User fills form and clicks "Save" button

2. **HTTP Request:** Browser sends `POST /student` with form data:
   ```
   action=insert
   studentCode=ST004
   fullName=Pham Van D
   email=vand@example.com
   major=Data Science
   ```

3. **Controller (StudentController.java):**
   - `doPost()` receives request with `action=insert`
   - Routes to `insertStudent()` method
   - Extracts form parameters using `request.getParameter()`
   ```java
   private void insertStudent(HttpServletRequest request, HttpServletResponse response) {
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
   ```

4. **Model - JavaBean (Student.java):**
   - Constructor creates new Student object with form data
   ```java
   Student student = new Student(studentCode, fullName, email, major);
   ```

5. **Model - DAO (StudentDAO.java):**
   - `addStudent()` method is called with Student object
   - Opens database connection
   - Uses PreparedStatement to prevent SQL injection
   - Executes INSERT query: `INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)`
   - Returns `true` if successful, `false` if failed
   ```java
   public boolean addStudent(Student student) {
       String sql = "INSERT INTO students (student_code, full_name, email, major) VALUES (?, ?, ?, ?)";
       pstmt.setString(1, student.getStudentCode());
       pstmt.setString(2, student.getFullName());
       // ...
       return pstmt.executeUpdate() > 0;
   }
   ```

6. **Database:** New student record inserted into `students` table

7. **Controller (StudentController.java):**
   - Receives boolean result from DAO
   - Uses `response.sendRedirect()` for POST-Redirect-GET pattern
   - Redirects to list page with success message
   ```java
   response.sendRedirect("student?action=list&message=Student added successfully");
   ```

8. **Browser:** Receives redirect (HTTP 302), makes new GET request to list page

9. **View (student-list.jsp):**
   - Displays success message: `${param.message}`
   - Shows updated student list including new student

**Key Points:**
- Two-step process: GET (show form) → POST (submit data)
- POST-Redirect-GET pattern prevents duplicate submissions
- Validation in both client (HTML5) and server (Controller)
- PreparedStatement prevents SQL injection

---

#### 2.3 UPDATE Operation - Edit Existing Student

**Request Flow (Two-Step Process):**
```
Step 1 (GET):  Browser → Controller → Model → Database → Controller → View (Pre-filled Form)
Step 2 (POST): Browser → Controller → Model → Database → Controller → View (Redirect)
```

**Detailed Steps:**

**STEP 1: Display Pre-filled Form (GET Request)**

1. **User Action:** User clicks "Edit" link on a student row

2. **HTTP Request:** Browser sends `GET /student?action=edit&id=1`

3. **Controller (StudentController.java):**
   - `doGet()` receives request with `action=edit` and `id=1`
   - Routes to `showEditForm()` method
   - Extracts student ID from request parameter
   ```java
   private void showEditForm(HttpServletRequest request, HttpServletResponse response) {
       int id = Integer.parseInt(request.getParameter("id"));
       Student student = studentDAO.getStudentById(id);  // Fetch from database
       request.setAttribute("student", student);         // Pass to view
       RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
       dispatcher.forward(request, response);
   }
   ```

4. **Model - DAO (StudentDAO.java):**
   - `getStudentById()` method is called with id=1
   - Opens database connection
   - Executes SELECT query: `SELECT * FROM students WHERE id = ?`
   - Maps ResultSet to Student object
   - Returns Student object or null if not found
   ```java
   public Student getStudentById(int id) {
       String sql = "SELECT * FROM students WHERE id = ?";
       pstmt.setInt(1, id);
       ResultSet rs = pstmt.executeQuery();
       if (rs.next()) {
           Student student = new Student();
           student.setId(rs.getInt("id"));
           student.setStudentCode(rs.getString("student_code"));
           // ... map all fields
           return student;
       }
       return null;
   }
   ```

5. **Controller (StudentController.java):**
   - Receives Student object from DAO
   - Stores in request scope for JSP access

6. **View (student-form.jsp):**
   - Checks `${student != null}` (true for edit mode)
   - Displays form with action="update"
   - Pre-fills form fields with existing data: `value="${student.fullName}"`
   - Student Code field is readonly (cannot be changed)
   - Includes hidden field with student ID
   ```jsp
   <form action="student" method="POST">
       <input type="hidden" name="action" value="update">
       <input type="hidden" name="id" value="${student.id}">
       <input type="text" name="studentCode" value="${student.studentCode}" readonly>
       <input type="text" name="fullName" value="${student.fullName}" required>
       <!-- ... -->
   </form>
   ```

7. **Browser:** Displays form with current student data

**STEP 2: Submit Updated Data (POST Request)**

1. **User Action:** User modifies fields and clicks "Update" button

2. **HTTP Request:** Browser sends `POST /student` with form data:
   ```
   action=update
   id=1
   fullName=Nguyen Van A (Modified)
   email=newemail@example.com
   major=Computer Science
   ```

3. **Controller (StudentController.java):**
   - `doPost()` receives request with `action=update`
   - Routes to `updateStudent()` method
   - Extracts form parameters including ID
   ```java
   private void updateStudent(HttpServletRequest request, HttpServletResponse response) {
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
   ```

4. **Model - JavaBean (Student.java):**
   - New Student object created and populated with updated data
   - Note: Student Code is NOT updated (business rule)

5. **Model - DAO (StudentDAO.java):**
   - `updateStudent()` method is called with Student object
   - Opens database connection
   - Executes UPDATE query: `UPDATE students SET full_name=?, email=?, major=? WHERE id=?`
   - Uses PreparedStatement with WHERE clause to update specific record
   - Returns boolean indicating success/failure
   ```java
   public boolean updateStudent(Student student) {
       String sql = "UPDATE students SET full_name = ?, email = ?, major = ? WHERE id = ?";
       pstmt.setString(1, student.getFullName());
       pstmt.setString(2, student.getEmail());
       pstmt.setString(3, student.getMajor());
       pstmt.setInt(4, student.getId());
       return pstmt.executeUpdate() > 0;
   }
   ```

6. **Database:** Student record with id=1 is updated

7. **Controller (StudentController.java):**
   - Receives boolean result from DAO
   - Redirects to list page with success message (POST-Redirect-GET)

8. **View (student-list.jsp):**
   - Displays updated student list with modifications

**Key Points:**
- Edit operation requires fetching existing data first
- Student Code is readonly (primary business identifier)
- Only allowed fields are updatable (full_name, email, major)
- POST-Redirect-GET prevents resubmission on browser refresh

---

#### 2.4 DELETE Operation - Remove Student

**Request Flow:**
```
Browser (Confirm) → Controller → Model → Database → Controller → View (Redirect)
```

**Detailed Steps:**

1. **User Action:** User clicks "Delete" link on a student row

2. **Client-Side Confirmation:**
   - JavaScript confirm dialog appears: "Are you sure?"
   ```jsp
   <a href="student?action=delete&id=${student.id}" 
      onclick="return confirm('Are you sure?')">Delete</a>
   ```
   - If user clicks "Cancel", request is aborted
   - If user clicks "OK", request proceeds

3. **HTTP Request:** Browser sends `GET /student?action=delete&id=1`

4. **Controller (StudentController.java):**
   - `doGet()` receives request with `action=delete` and `id=1`
   - Routes to `deleteStudent()` method
   - Extracts student ID from request parameter
   ```java
   private void deleteStudent(HttpServletRequest request, HttpServletResponse response) {
       int id = Integer.parseInt(request.getParameter("id"));
       
       if (studentDAO.deleteStudent(id)) {
           response.sendRedirect("student?action=list&message=Student deleted successfully");
       } else {
           response.sendRedirect("student?action=list&error=Failed to delete student");
       }
   }
   ```

5. **Model - DAO (StudentDAO.java):**
   - `deleteStudent()` method is called with id=1
   - Opens database connection
   - Executes DELETE query: `DELETE FROM students WHERE id = ?`
   - Uses PreparedStatement for safe parameter binding
   - Returns boolean indicating success/failure
   ```java
   public boolean deleteStudent(int id) {
       String sql = "DELETE FROM students WHERE id = ?";
       pstmt.setInt(1, id);
       return pstmt.executeUpdate() > 0;
   }
   ```

6. **Database:** Student record with id=1 is permanently deleted

7. **Controller (StudentController.java):**
   - Receives boolean result from DAO
   - Checks if deletion was successful
   - Redirects to list page with appropriate message
   ```java
   response.sendRedirect("student?action=list&message=Student deleted successfully");
   ```

8. **View (student-list.jsp):**
   - Displays success message
   - Shows updated student list (without deleted student)
   - Uses JSTL to conditionally display message:
   ```jsp
   <c:if test="${not empty param.message}">
       <div class="message success">${param.message}</div>
   </c:if>
   ```

**Key Points:**
- Delete is a GET operation (simple, direct action)
- Client-side confirmation prevents accidental deletion
- No separate form needed
- Uses POST-Redirect-GET pattern via redirect
- Permanent deletion (no soft delete implemented)

---

#### 2.5 SEARCH Operation - Filter Students

**Request Flow:**
```
Browser → Controller → Model → Database → Model → Controller → View → Browser
```

**Detailed Steps:**

1. **User Action:** User types keyword in search box and clicks "Search"

2. **HTTP Request:** Browser sends `GET /student?action=search&keyword=Nguyen`

3. **Controller (StudentController.java):**
   - `doGet()` receives request with `action=search` and `keyword=Nguyen`
   - Routes to `searchStudents()` method
   - Extracts search keyword from request parameter
   - Validates keyword (checks if empty)
   ```java
   private void searchStudents(HttpServletRequest request, HttpServletResponse response) {
       String keyword = request.getParameter("keyword");
       
       if (keyword == null || keyword.trim().isEmpty()) {
           listStudents(request, response);  // Show all if empty
           return;
       }
       
       List<Student> students = studentDAO.searchStudents(keyword);
       request.setAttribute("students", students);
       request.setAttribute("keyword", keyword);  // Keep keyword in form
       
       RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
       dispatcher.forward(request, response);
   }
   ```

4. **Model - DAO (StudentDAO.java):**
   - `searchStudents()` method is called with keyword="Nguyen"
   - Opens database connection
   - Executes LIKE query: `SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ?`
   - Adds wildcards: `%Nguyen%` for partial matching
   - Maps matching ResultSet rows to Student objects
   - Returns filtered `List<Student>`
   ```java
   public List<Student> searchStudents(String keyword) {
       List<Student> students = new ArrayList<>();
       String sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
       String searchPattern = "%" + keyword + "%";
       pstmt.setString(1, searchPattern);
       pstmt.setString(2, searchPattern);
       // Execute and map results
       return students;
   }
   ```

5. **Controller (StudentController.java):**
   - Receives filtered student list from DAO
   - Stores list in request scope
   - Also stores keyword to keep search box populated

6. **View (student-list.jsp):**
   - Displays search form with keyword preserved: `value="${keyword}"`
   - Shows "Clear" button if search is active
   - Uses same JSTL forEach loop to display filtered results
   - Conditionally displays "No students found matching..." message
   ```jsp
   <input type="text" name="keyword" value="${keyword}">
   
   <c:if test="${empty students}">
       <c:when test="${not empty keyword}">
           No students found matching "${keyword}"
       </c:when>
   </c:if>
   ```

7. **Browser:** Displays filtered student list matching search criteria

**Key Points:**
- Uses LIKE operator for partial matching (case-insensitive)
- Searches both full_name and student_code fields
- Preserves keyword in search box for user convenience
- Shows "Clear" button to reset search
- Same view template handles both full list and search results

---

### 2.6 MVC Communication Summary

**Data Flow Direction:**
```
Browser ←→ Controller ←→ Model (DAO + JavaBean) ←→ Database
                ↓
              View
```

**Component Responsibilities:**

| Component | Responsibilities | Does NOT Do |
|-----------|-----------------|-------------|
| **Model (Student.java)** | Hold data, getters/setters | Business logic, database access |
| **Model (StudentDAO.java)** | Database CRUD operations, SQL queries | UI logic, HTTP handling |
| **Controller (StudentController.java)** | Route requests, call Model, select View | Direct database access, HTML generation |
| **View (JSP)** | Display data with JSTL/EL | Database queries, business logic |

**Request Scope vs Session:**
- `request.setAttribute()` - Data available only for current request (Model → View)
- Used for passing student list, individual student, messages
- Data lost after response sent (stateless)

**Forward vs Redirect:**
- `forward()` - Server-side, URL unchanged, used for displaying views (GET)
- `redirect()` - Client-side, URL changes, used after POST (POST-Redirect-GET pattern)

**Why MVC?**
1. **Maintainability:** Change database? Only modify DAO. Change UI? Only modify JSP.
2. **Reusability:** Same DAO can serve web app, mobile API, desktop app
3. **Testability:** Can unit test DAO and Controller independently
4. **Team Collaboration:** Frontend developers work on JSP, backend on DAO/Controller
5. **Clear Structure:** Easy to understand and navigate codebase

### 3. Model Layer Implementation

#### Student.java (JavaBean)
- Private fields: id, studentCode, fullName, email, major, createdAt
- Public getters and setters
- Constructor overloads
- toString() method for debugging

#### StudentDAO.java (Data Access Object)
- Database connection using Docker MySQL service
- CRUD methods: getAllStudents(), getStudentById(), addStudent(), updateStudent(), deleteStudent()
- Search functionality: searchStudents()
- Uses PreparedStatement for SQL injection prevention
- Try-with-resources for automatic resource management

### 3. Controller Layer Implementation

#### StudentController.java (Servlet)
- @WebServlet("/student") annotation for URL mapping
- doGet() method handles: list, new, edit, delete, search actions
- doPost() method handles: insert, update actions
- RequestDispatcher for forwarding to JSP views
- response.sendRedirect() for POST-redirect-GET pattern
- Basic validation and error handling

### 4. View Layer Implementation

#### student-list.jsp
- Displays student table with JSTL c:forEach
- Conditional messages for success/error
- Search form for filtering students
- Action links for edit/delete operations
- Responsive table design

#### student-form.jsp
- Single form for both add and edit operations
- Dynamic form fields based on mode (add/edit)
- JSTL conditional rendering for titles and buttons
- Client-side validation with HTML5 attributes

### 5. Database Configuration
- Docker Compose with MySQL 8.0 and Tomcat 9
- Database initialization script (init_db.sql)
- Connection string: jdbc:mysql://mysql:3306/student_management
- Sample data insertion for testing

## Key Features Implemented

### CRUD Operations
1. **Create:** Add new student with unique student code
2. **Read:** List all students, view individual student details
3. **Update:** Edit existing student information (except student code)
4. **Delete:** Remove student with confirmation dialog

### Additional Features
- **Search:** Filter students by name or student code
- **Validation:** Basic input validation and error messages
- **Responsive UI:** Clean, modern interface with CSS styling
- **MVC Separation:** Clear separation of concerns between layers

## Testing Results

### Test Cases Executed

| Test Case | Input | Expected Result | Actual Result | Status |
|-----------|-------|-----------------|---------------|--------|
| List Students | GET /student | Display all students | Shows 3 sample students | ✅ Pass |
| Add Student | Valid student data | Student added, redirect to list | Student added successfully | ✅ Pass |
| Edit Student | Modify existing student | Student updated | Student updated successfully | ✅ Pass |
| Delete Student | Click delete link | Student removed | Student deleted successfully | ✅ Pass |
| Search Students | Keyword "Nguyen" | Filter results | Shows matching students | ✅ Pass |
| Invalid Input | Empty name | Error message | Validation error displayed | ✅ Pass |

![List students](.\img\list.png "GET /students")
![Add student](.\img\add.png "POST /student")
![Edit student](.\img\edit.png "UPDATE /student")
![Delete student](.\img\del.png "DEL /student")
![Search students](.\img\search.png)
![](.\img\no-match.png)


### URL Patterns Tested
- `http://localhost:8080/StudentManagement/student` - List students
- `http://localhost:8080/StudentManagement/student?action=new` - Add form
- `http://localhost:8080/StudentManagement/student?action=edit&id=1` - Edit form
- `http://localhost:8080/StudentManagement/student?action=delete&id=1` - Delete student

## Challenges Faced and Solutions

### Challenge 1: Package Namespace Compatibility
**Problem:** Tomcat 9 uses javax.servlet while modern guides show jakarta.servlet
**Solution:** Used javax.servlet.* imports for Tomcat 9 compatibility

### Challenge 2: Docker Database Connection
**Problem:** Connection refused when using localhost
**Solution:** Used service name "mysql" in JDBC URL for Docker networking

### Challenge 3: Maven WAR Deployment
**Problem:** WAR file not deploying to Tomcat container
**Solution:** Configured Docker volume mount in docker-compose.yml

## Code Quality Metrics

- **Lines of Code:** ~400 lines total
- **Classes:** 3 Java classes + 2 JSP pages
- **Database Tables:** 1 (students)
- **HTTP Methods:** GET, POST
- **JSTL Tags Used:** c:if, c:forEach, c:choose, c:when, c:otherwise

## Conclusion

The Student Management System was successfully implemented using the MVC architectural pattern. The application demonstrates proper separation of concerns with:

- **Model:** Clean data access layer with DAO pattern
- **View:** Presentation-only JSP pages using JSTL
- **Controller:** Centralized request handling with servlet

Key achievements:
- ✅ Complete CRUD functionality
- ✅ MVC architecture implementation
- ✅ Database integration with Docker
- ✅ Responsive web interface
- ✅ Input validation and error handling

The implementation follows web development best practices and provides a solid foundation for more complex web applications.

## References
- Lab 5 Guide: lab5_servlet_mvc.md
- Java Servlet API Documentation
- JSTL Documentation
- Docker Compose Documentation
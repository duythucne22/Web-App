# Lab 4 — Part B: Homework Exercises (Styled & Quick Snippets)

A concise, formatted version of the tasks with ready-to-copy snippets and a highlighted tips block for quick implementation.

> **💡 Quick Tip:** Place the form and pagination parameters in list_students.jsp. Use GET for search so the keyword appears in the URL. Validate input server-side in process_add.jsp and process_edit.jsp.

# EXERCISE 5: SEARCH FUNCTIONALITY (Snippets)

Search form (copy into list_students.jsp):

```html
<form action="list_students.jsp" method="GET">
    <input type="text" name="keyword" placeholder="Search by name or code..." value="${param.keyword}">
    <button type="submit">Search</button>
    <a href="list_students.jsp">Clear</a>
</form>
```

Search logic (JSP / Java pseudocode):

```java
// Pseudocode for list_students.jsp (use PreparedStatement)
String keyword = request.getParameter("keyword");
if (keyword != null && !keyword.trim().isEmpty()) {
    String sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    pstmt.setString(2, "%" + keyword + "%");
} else {
    String sql = "SELECT * FROM students ORDER BY id DESC";
    pstmt = conn.prepareStatement(sql);
}
```

(Optional) Highlighting term in results (simple approach):

```html
<!-- Replace matched text in display -->
<%= studentName.replaceAll("(?i)("+Pattern.quote(keyword)+")", "<mark>$1</mark>") %>
```

# EXERCISE 6: VALIDATION ENHANCEMENT (Snippets)

Email validation (server-side):

```java
String email = request.getParameter("email");
if (email != null && !email.isEmpty()) {
    if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
        response.sendRedirect("add_student.jsp?error=Invalid+email+format");
        return;
    }
}
```

Student code pattern:

```java
String code = request.getParameter("student_code");
if (code == null || !code.matches("[A-Z]{2}[0-9]{3,}")) {
    response.sendRedirect("add_student.jsp?error=Student+code+must+be+2+uppercase+letters+followed+by+3+digits+or+more");
    return;
}
```

# EXERCISE 7: PAGINATION (Snippets)

Pagination parameters (JSP):

```java
String pageParam = request.getParameter("page");
int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
int recordsPerPage = 10;
int offset = (currentPage - 1) * recordsPerPage;

// Use LIMIT/OFFSET in SQL
String sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
pstmt = conn.prepareStatement(sql);
pstmt.setInt(1, recordsPerPage);
pstmt.setInt(2, offset);
```

Get total records:

```java
// getTotalRecords() implementation idea
String countSql = "SELECT COUNT(*) FROM students";
pstmt = conn.prepareStatement(countSql);
rs = pstmt.executeQuery();
if (rs.next()) totalRecords = rs.getInt(1);
int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
```

Pagination links (JSP snippet):

```jsp
<div class="pagination">
    <% if (currentPage > 1) { %>
        <a href="list_students.jsp?page=<%= currentPage - 1 %>&keyword=<%= URLEncoder.encode(keyword,"UTF-8") %>">Previous</a>
    <% } %>
    <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) { %>
            <strong><%= i %></strong>
        <% } else { %>
            <a href="list_students.jsp?page=<%= i %>&keyword=<%= URLEncoder.encode(keyword,"UTF-8") %>"><%= i %></a>
        <% } %>
    <% } %>
    <% if (currentPage < totalPages) { %>
        <a href="list_students.jsp?page=<%= currentPage + 1 %>&keyword=<%= URLEncoder.encode(keyword,"UTF-8") %>">Next</a>
    <% } %>
</div>
```

# UI / UX Snippets (Messages, Loading, Responsive table)

Success/Error message styling + auto-hide:

```html
<style>
.message { padding:10px; margin:10px 0; border-radius:4px; }
.message.success { background:#e6ffed; color:#046b24; border-left:4px solid #2ecc71; }
.message.error { background:#ffecec; color:#8b0000; border-left:4px solid #e74c3c; }
.table-responsive { overflow-x:auto; }
@media (max-width:768px){ table{font-size:12px} th,td{padding:5px} }
</style>

<div class="message success">✓ Student added successfully</div>
<script>
setTimeout(function(){ document.querySelectorAll('.message').forEach(m=>m.style.display='none'); }, 3000);
function submitForm(form){ var btn=form.querySelector('button[type=submit]'); btn.disabled=true; btn.textContent='Processing...'; return true; }
</script>
```

# PART B: HOMEWORK EXERCISES (40 points)

Deadline: Before next lab session (1 week)
Submission: Upload to learning management system
Format: ZIP file containing complete project

## EXERCISE 5: SEARCH FUNCTIONALITY (15 points)

Estimated Time: 45 minutes

Add search capability to find students by name or code.

Requirements:

5.1: Create Search Form (3 points)

    Add search form at top of list_students.jsp
    Input field for keyword
    Search button
    Method: GET (so search term appears in URL)

HTML Structure:

<form action="list_students.jsp" method="GET">
    <input type="text" name="keyword" placeholder="Search by name or code...">
    <button type="submit">Search</button>
    <a href="list_students.jsp">Clear</a>
</form>

5.2: Implement Search Logic (12 points)

Modify list_students.jsp to handle search:

// Pseudocode:
String keyword = request.getParameter("keyword");

if (keyword != null && !keyword.isEmpty()) {
    // Search query with LIKE operator
    sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + keyword + "%");
    pstmt.setString(2, "%" + keyword + "%");
} else {
    // Normal query
    sql = "SELECT * FROM students ORDER BY id DESC";
}

Evaluation Criteria:
Criteria 	Points
Search form added correctly 	3
LIKE operator used properly 	4
Searches both name and code 	3
Displays search results 	3
"Clear" link works 	2

Test Cases:
Search Term 	Expected Results
"John" 	Shows all students with "John" in name
"SV001" 	Shows student with code SV001
"science" 	Shows students in Computer Science/Data Science
"" (empty) 	Shows all students

Bonus (+2 points): Highlight search term in results

## EXERCISE 6: VALIDATION ENHANCEMENT (10 points)

Estimated Time: 30 minutes

Improve validation for better data quality.

6.1: Email Validation (5 points)

Add email format validation in process_add.jsp and process_edit.jsp:

Requirements:

    Check if email is provided
    If provided, validate format using regex
    Regex pattern: ^[A-Za-z0-9+_.-]+@(.+)$
    Display error if invalid

Java Code:

String email = request.getParameter("email");
if (email != null && !email.isEmpty()) {
    if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
        // Invalid email format
        response.sendRedirect("add_student.jsp?error=Invalid email format");
        return;
    }
}

Test Cases:
Email Input |	Expected Result
john@email.com |	Valid, accepts
john.doe@company.co.uk |	Valid, accepts
john@email |	Invalid, rejects
johnemail.com |	Invalid, rejects
(empty) |	Valid, accepts (optional field)

6.2: Student Code Pattern Validation (5 points)

Validate student code follows pattern: 2 uppercase letters + 3+ digits

Requirements:

    Pattern: [A-Z]{2}[0-9]{3,}
    Examples: SV001, IT123, CS9999 (valid)
    Examples: sv001, S001, SV12 (invalid)
    Check in server-side code
    Display clear error message

Evaluation Criteria:
Criteria 	Points
Email validation regex correct 	3
Error displayed for invalid email 	2
Student code pattern validated 	3
Error displayed for invalid code 	2

## EXERCISE 7: USER EXPERIENCE IMPROVEMENTS (15 points)

Estimated Time: 60 minutes

7.1: Pagination (8 points)

Add pagination to display 10 students per page.

Requirements:

Database Query with LIMIT:

SELECT * FROM students 
ORDER BY id DESC 
LIMIT ? OFFSET ?

Calculate Pagination:

// Get page number from URL (default = 1)
String pageParam = request.getParameter("page");
int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;

// Records per page
int recordsPerPage = 10;

// Calculate offset
int offset = (currentPage - 1) * recordsPerPage;

// Get total records for pagination
int totalRecords = getTotalRecords(); // You need to implement this
int totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

Display Pagination Links:

<div class="pagination">
    <% if (currentPage > 1) { %>
        <a href="list_students.jsp?page=<%= currentPage - 1 %>">Previous</a>
    <% } %>
    
    <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) { %>
            <strong><%= i %></strong>
        <% } else { %>
            <a href="list_students.jsp?page=<%= i %>"><%= i %></a>
        <% } %>
    <% } %>
    
    <% if (currentPage < totalPages) { %>
        <a href="list_students.jsp?page=<%= currentPage + 1 %>">Next</a>
    <% } %>
</div>

Evaluation Criteria:
Criteria 	Points
LIMIT/OFFSET query implemented 	3
Page number from URL parameter 	2
Total pages calculated correctly 	2
Pagination links display 	1

7.2: Improved UI/UX (7 points)

Enhance the visual design and user experience.

Requirements:

a) Success/Error Message Styling (2 points)

    Add distinct colors (green for success, red for error)
    Add icons (✓ for success, ✗ for error)
    Auto-hide after 3 seconds (JavaScript)

<script>
setTimeout(function() {
    var messages = document.querySelectorAll('.message');
    messages.forEach(function(msg) {
        msg.style.display = 'none';
    });
}, 3000);
</script>

b) Loading States (2 points)

    Disable submit button after clicking to prevent double submission
    Show "Processing…" text

<script>
function submitForm(form) {
    var btn = form.querySelector('button[type="submit"]');
    btn.disabled = true;
    btn.textContent = 'Processing...';
    return true;
}
</script>

<form onsubmit="return submitForm(this)">

c) Responsive Table (3 points)

    Table scrollable on small screens
    Better mobile layout

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

Evaluation Criteria:
Criteria 	Points
Message styling improved 	2
Button loading state 	2
Responsive design 	3

# BONUS EXERCISES (Optional - Extra Credit)

Not required, but can earn up to 10 bonus points

BONUS 1: Export to CSV (5 points)

Add functionality to export student list to CSV file.

Hint: Create export_csv.jsp:

<%
response.setContentType("text/csv");
response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

out.println("ID,Student Code,Full Name,Email,Major");

// Query and loop through students
while (rs.next()) {
    out.println(rs.getInt("id") + "," + 
                rs.getString("student_code") + "," +
                rs.getString("full_name") + "," +
                rs.getString("email") + "," +
                rs.getString("major"));
}
%>

BONUS 2: Sort by Column (5 points)

Add ability to sort table by clicking column headers.

Requirements:

    Click "Full Name" header → sort alphabetically
    Click "Created At" → sort by date
    Toggle ascending/descending

Hint:

String sortBy = request.getParameter("sort"); // column name
String order = request.getParameter("order"); // asc or desc

if (sortBy == null) sortBy = "id";
if (order == null) order = "desc";

String sql = "SELECT * FROM students ORDER BY " + sortBy + " " + order;

BONUS 3: Bulk Delete (5 points)

Add checkboxes to select multiple students and delete them at once.

Requirements:

    Checkbox for each student row
    "Select All" checkbox
    "Delete Selected" button
    Confirmation before bulk delete

# HOMEWORK SUBMISSION GUIDELINES
What to Submit:

1. Complete Project ZIP File:

StudentManagement.zip
├── src/ (if any Java files)
├── web/
│   ├── list_students.jsp
│   ├── add_student.jsp
│   ├── process_add.jsp
│   ├── edit_student.jsp
│   ├── process_edit.jsp
│   └── delete_student.jsp
├── nbproject/
└── README.txt (see below)

2. README.txt File:

STUDENT INFORMATION:
Name: [Your Name]
Student ID: [Your ID]
Class: [Your Class]

COMPLETED EXERCISES:
[x] Exercise 5: Search Functionality
[x] Exercise 6: Validation Enhancement
[x] Exercise 7: Pagination
[ ] Bonus 1: CSV Export
[ ] Bonus 2: Sortable Columns

KNOWN ISSUES:
- [List any bugs or incomplete features]

EXTRA FEATURES:
- [List any additional features you added]

TIME SPENT: [Approximate hours]

REFERENCES USED:
- [List any websites, tutorials, or resources you used]

3. Screenshots (5-10 images):

    Main list page
    Add student form
    Edit student form
    Search results
    Validation errors
    Pagination (if implemented)

Grading Rubric:
Category 	Points 	Criteria
Functionality 	25 	All required features work correctly
Code Quality 	8 	Clean code, proper naming, comments
Error Handling 	4 	Validates input, handles errors gracefully
Documentation 	3 	README file complete and clear

Total Homework Points: 40
Bonus Points: Up to 10
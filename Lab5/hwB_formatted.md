# PART B: HOMEWORK EXERCISES (40 points)

**Deadline:** Before next lab session (1 week)  
**Submission:** Upload ZIP file to LMS

---

## Exercise 5: Search Functionality (12 points)

**Estimated Time:** 45 minutes

**Objective:** Add search capability to find students by name, code, or email.

### 5.1 Update StudentDAO (4 points)

Add `searchStudents(String keyword)` to `StudentDAO.java`.

Requirements:

- Return `List<Student>`
- Search across three columns: `student_code`, `full_name`, `email`
- Use SQL `LIKE` operator with wildcards (`%`)
- Use `PreparedStatement` (avoid SQL injection)
- Return results ordered by `id` DESC
- Use try-with-resources for resource management

Hint — SQL pattern:

```sql
SELECT * FROM students
WHERE student_code LIKE ? OR full_name LIKE ? OR email LIKE ?
ORDER BY id DESC
```

Java hint — building the pattern:

```java
String searchPattern = "%" + keyword + "%";
// set the same pattern for all 3 placeholders
```

Edge cases to consider:

- `keyword` null or empty — show all students or return empty list depending on desired behavior
- Reuse mapping logic from `getAllStudents()` to construct `Student` objects

Test snippet:

```java
StudentDAO dao = new StudentDAO();
List<Student> results = dao.searchStudents("john");
System.out.println("Found " + results.size() + " students");
for (Student s : results) System.out.println(s);
```

---

### 5.2 Add Search Controller Method (4 points)

Add a `searchStudents` handler to `StudentController.java`.

Requirements:

- Create `private void searchStudents(HttpServletRequest request, HttpServletResponse response)`
- Get `keyword` parameter
- If `keyword` is null/empty, show all students
- Call DAO's `searchStudents` method
- Set `students` and `keyword` as request attributes
- Forward to `student-list.jsp`
- Update `doGet()` switch to handle `action=search`

Method skeleton:

```java
private void searchStudents(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
    // 1. Get keyword parameter
    // 2. Decide DAO method (search or getAll)
    // 3. Get list
    // 4. Set request attributes: students, keyword
    // 5. Forward to /views/student-list.jsp
}
```

---

### 5.3 Update Student List View (4 points)

Add a search form to `student-list.jsp`.

Requirements:

- Form submits to `student` servlet using GET
- Include hidden field: `<input type="hidden" name="action" value="search">`
- Text input for `keyword`, meaningful placeholder
- Submit button (🔍 allowed)
- Show `Clear` or `Show All` only when searching
- Display: `Search results for: [keyword]` when keyword present
- Preserve `keyword` value in the input after search

JSTL examples:

```jsp
<c:if test="${not empty keyword}">
    <!-- show clear button or message -->
</c:if>

<input type="text" name="keyword" value="${keyword}" placeholder="Search by name, code or email">
```

Form example:

```html
<div class="search-box">
  <form action="student" method="get">
    <input type="hidden" name="action" value="search">
    <input type="text" name="keyword" value="${keyword}" placeholder="Search students...">
    <button type="submit">🔍</button>
    <c:if test="${not empty keyword}">
      <a href="student?action=list">Clear</a>
    </c:if>
  </form>
</div>
```

---

## Exercise 6: Server-side Validation (10 points)

**Estimated Time:** 40 minutes

### 6.1 Create validateStudent() (5 points)

Add to `StudentController.java`:

```java
private boolean validateStudent(Student student, HttpServletRequest request) {
    boolean isValid = true;

    // Student Code
    if (student.getStudentCode() == null || student.getStudentCode().trim().isEmpty()) {
        request.setAttribute("errorCode", "Student code is required");
        isValid = false;
    } else if (!student.getStudentCode().matches("[A-Z]{2}[0-9]{3,}")) {
        request.setAttribute("errorCode", "Invalid format. Use 2 letters + 3+ digits (e.g., SV001)");
        isValid = false;
    }

    // Full name (min length 2)
    if (student.getFullName() == null || student.getFullName().trim().length() < 2) {
        request.setAttribute("errorName", "Full name must be at least 2 characters");
        isValid = false;
    }

    // Email (optional)
    if (student.getEmail() != null && !student.getEmail().trim().isEmpty()) {
        String emailPattern = "^[A-Za-z0-9+_.-]+@(.+)$";
        if (!student.getEmail().matches(emailPattern)) {
            request.setAttribute("errorEmail", "Invalid email format");
            isValid = false;
        }
    }

    // Major
    if (student.getMajor() == null || student.getMajor().trim().isEmpty()) {
        request.setAttribute("errorMajor", "Major is required");
        isValid = false;
    }

    return isValid;
}
```

### 6.2 Integrate into insert/update (3 points)

Call `validateStudent()` before DAO operations. On failure set `student` attribute and forward back to form:

```java
if (!validateStudent(student, request)) {
    request.setAttribute("student", student);
    RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
    dispatcher.forward(request, response);
    return;
}
```

### 6.3 Display validation errors in `student-form.jsp` (2 points)

Example for Student Code field:

```jsp
<div class="form-group">
  <label for="studentCode">Student Code:</label>
  <input type="text" id="studentCode" name="studentCode" value="${student.studentCode}">
  <c:if test="${not empty errorCode}">
    <span class="error">${errorCode}</span>
  </c:if>
</div>

<style>
.error { color: red; font-size: 14px; display: block; margin-top: 5px; }
</style>
```

---

## Exercise 7: Sorting & Filtering (10 points)

**Estimated Time:** 50 minutes

### 7.1 DAO methods (4 points)

Add:

```java
public List<Student> getStudentsSorted(String sortBy, String order) { /* ... */ }
public List<Student> getStudentsByMajor(String major) { /* ... */ }
```

Validate `sortBy` against allowed columns (`id`, `student_code`, `full_name`, `email`, `major`) before concatenating into SQL to avoid injection.

### 7.2 Controller (3 points)

Implement `sortStudents()` and `filterStudents()` or enhance `listStudents()` to accept `sortBy`, `order`, and `major` params. Add cases to `doGet()` for `action=sort` and `action=filter`.

### 7.3 View changes (3 points)

Sortable headers example:

```html
<th><a href="student?action=sort&sortBy=full_name&order=asc">Name</a></th>
```

Filter dropdown example (preserve selected):

```jsp
<select name="major">
  <option value="">All Majors</option>
  <option value="Computer Science" ${selectedMajor == 'Computer Science' ? 'selected' : ''}>Computer Science</option>
  <!-- etc -->
</select>
```

---

## Exercise 8: Pagination (Optional, 8 points)

**Estimated Time:** 60 minutes

### 8.1 DAO pagination helpers

```java
public int getTotalStudents() { /* SELECT COUNT(*) ... */ }
public List<Student> getStudentsPaginated(int offset, int limit) { /* LIMIT/OFFSET */ }
```

### 8.2 Controller: calculate offset and total pages

```java
String pageParam = request.getParameter("page");
int currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
int recordsPerPage = 10;
int offset = (currentPage - 1) * recordsPerPage;
```

### 8.3 View: pagination controls (JSTL)

```jsp
<div class="pagination">
  <c:if test="${currentPage > 1}">
    <a href="student?action=list&page=${currentPage - 1}">« Previous</a>
  </c:if>
  <c:forEach begin="1" end="${totalPages}" var="i">
    <c:choose>
      <c:when test="${i == currentPage}"><strong>${i}</strong></c:when>
      <c:otherwise><a href="student?action=list&page=${i}">${i}</a></c:otherwise>
    </c:choose>
  </c:forEach>
  <c:if test="${currentPage < totalPages}">
    <a href="student?action=list&page=${currentPage + 1}">Next »</a>
  </c:if>
</div>
<p>Showing page ${currentPage} of ${totalPages}</p>
```

---

## Bonus Exercises (optional)

- Export to Excel (Apache POI)  
- Photo Upload (multipart + file storage)  
- Combined Search + Filter + Sort (dynamic SQL builder)

---

## Homework Submission Guidelines

Prepare `StudentManagementMVC.zip` including `src/` (model, dao, controller), `WebContent/views/` and a `README.txt` with student info, completed exercises checklist, features, known issues and screenshots.

---

## Common Mistakes & Tips

- Don't put DB code in JSP or use scriptlets.  
- Keep SQL in DAO, use JSTL in views, close resources with try-with-resources.  
- For JSTL you may need the JSTL library and taglib directive:

```jsp
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
```

---

## Summary

This document outlines exercises 5–8 and optional bonuses with implementation hints and example code blocks. Implement the DAO/controller/view changes as described, add validation, and test thoroughly.

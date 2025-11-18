// filepath: src/controller/StudentController.java
package controller;

import dao.StudentDAO;
import model.Student;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@WebServlet("/student")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1MB
    maxFileSize = 5 * 1024 * 1024,    // 5MB
    maxRequestSize = 10 * 1024 * 1024 // 10MB
)
public class StudentController extends HttpServlet {
    
    private StudentDAO studentDAO;
    private static final String UPLOAD_DIR = "uploads";
    private static final long serialVersionUID = 1L;
    
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
            case "search":
                searchStudents(request, response);
                break;
            case "sort":
                sortStudents(request, response);
                break;
            case "filter":
                filterStudents(request, response);
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
        
        // Get all parameters
        String keyword = request.getParameter("keyword");
        String major = request.getParameter("major");
        String sortBy = request.getParameter("sortBy");
        String order = request.getParameter("order");
        String pageParam = request.getParameter("page");
        
        // Set default values
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "id";
        }
        if (order == null || order.trim().isEmpty()) {
            order = "desc";
        }
        
        // Clean parameters
        keyword = (keyword != null && !keyword.trim().isEmpty()) ? keyword.trim() : null;
        major = (major != null && !major.trim().isEmpty()) ? major.trim() : null;
        
        // Get current page (default to 1)
        int currentPage = 1;
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                currentPage = Integer.parseInt(pageParam);
                if (currentPage < 1) {
                    currentPage = 1;
                }
            } catch (NumberFormatException e) {
                currentPage = 1;
            }
        }
        
        // Records per page
        int recordsPerPage = 10;
        
        // Get filtered/sorted/searched students
        List<Student> students = studentDAO.searchFilterSortStudents(keyword, major, sortBy, order);
        int totalRecords = students.size();
        
        // Apply pagination manually (since we already have all filtered data)
        int totalPages = (totalRecords == 0) ? 1 : (int) Math.ceil((double) totalRecords / recordsPerPage);
        
        // Handle page > totalPages
        if (currentPage > totalPages && totalPages > 0) {
            currentPage = totalPages;
        }
        
        // Apply pagination to the list
        int startIndex = (currentPage - 1) * recordsPerPage;
        int endIndex = Math.min(startIndex + recordsPerPage, totalRecords);
        List<Student> paginatedStudents = new ArrayList<>();
        
        if (startIndex < totalRecords) {
            paginatedStudents = students.subList(startIndex, endIndex);
        }
        
        // Set attributes
        request.setAttribute("students", paginatedStudents);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalRecords", totalRecords);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedMajor", major);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);
        
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
            throws ServletException, IOException {
        
        String studentCode = request.getParameter("studentCode");
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");
        
        Student student = new Student(studentCode, fullName, email, major);
        
        // Handle photo upload
        Part photoPart = request.getPart("photo");
        String photoFilename = handleFileUpload(photoPart, request);
        if (photoFilename != null) {
            student.setPhoto(photoFilename);
        }
        
        // Validate
        if (!validateStudent(student, request)) {
            request.setAttribute("student", student);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        if (studentDAO.addStudent(student)) {
            response.sendRedirect("student?action=list&message=Student added successfully");
        } else {
            response.sendRedirect("student?action=new&error=Failed to add student");
        }
    }

    private void updateStudent(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        int id = Integer.parseInt(request.getParameter("id"));
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String major = request.getParameter("major");
        
        Student student = new Student();
        student.setId(id);
        student.setFullName(fullName);
        student.setEmail(email);
        student.setMajor(major);
        
        // Keep existing photo if not uploading new one
        Student existingStudent = studentDAO.getStudentById(id);
        String currentPhoto = existingStudent != null ? existingStudent.getPhoto() : null;
        
        // Handle photo upload
        Part photoPart = request.getPart("photo");
        if (photoPart != null && photoPart.getSize() > 0) {
            String newPhoto = handleFileUpload(photoPart, request);
            if (newPhoto != null) {
                student.setPhoto(newPhoto);
                // Delete old photo if exists
                if (currentPhoto != null && !currentPhoto.isEmpty()) {
                    deleteOldPhoto(currentPhoto, request);
                }
            }
        } else {
            student.setPhoto(currentPhoto); // Keep existing photo
        }
        
        // Validate
        if (!validateStudent(student, request)) {
            request.setAttribute("student", student);
            RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-form.jsp");
            dispatcher.forward(request, response);
            return;
        }
        
        if (studentDAO.updateStudent(student)) {
            response.sendRedirect("student?action=list&message=Student updated successfully");
        } else {
            response.sendRedirect("student?action=edit&id=" + id + "&error=Failed to update");
        }
    }

    private void deleteOldPhoto(String photoFilename, HttpServletRequest request) {
        if (photoFilename == null || photoFilename.isEmpty()) {
            return;
        }
        
        try {
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            Path photoPath = Paths.get(uploadPath, photoFilename);
            
            if (Files.exists(photoPath)) {
                Files.delete(photoPath);
            }
        } catch (IOException e) {
            e.printStackTrace();
            request.setAttribute("errorPhoto", "Failed to delete old photo: " + e.getMessage());
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
    
    private void searchStudents(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // This method is now handled by the enhanced listStudents method
        // Just redirect to list with the search parameters
        String keyword = request.getParameter("keyword");
        if (keyword == null || keyword.trim().isEmpty()) {
            response.sendRedirect("student?action=list");
            return;
        }
        
        // Redirect to list action with search parameter
        response.sendRedirect("student?action=list&keyword=" + URLEncoder.encode(keyword.trim(), "UTF-8"));
    }

    private void sortStudents(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String sortBy = request.getParameter("sortBy");
        String order = request.getParameter("order");
        
        if (sortBy == null) sortBy = "id";
        if (order == null) order = "asc";
        
        List<Student> students = studentDAO.getStudentsSorted(sortBy, order);
        
        request.setAttribute("students", students);
        request.setAttribute("sortBy", sortBy);
        request.setAttribute("order", order);
        
        RequestDispatcher dispatcher = request.getRequestDispatcher("/views/student-list.jsp");
        dispatcher.forward(request, response);
    }

    private void filterStudents(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // This is now handled by the enhanced listStudents method
        String major = request.getParameter("major");
        
        if (major == null || major.trim().isEmpty()) {
            response.sendRedirect("student?action=list");
            return;
        }
        
        response.sendRedirect("student?action=list&major=" + URLEncoder.encode(major.trim(), "UTF-8"));
    }

    private boolean validateStudent(Student student, HttpServletRequest request) {
        boolean isValid = true;
        
        // Validate student code
        if (student.getStudentCode() == null || student.getStudentCode().trim().isEmpty()) {
            request.setAttribute("errorCode", "Student code is required");
            isValid = false;
        } else if (!student.getStudentCode().matches("[A-Z]{2}[0-9]{3,}")) {
            request.setAttribute("errorCode", "Invalid format. Use 2 letters + 3+ digits (e.g., SV001)");
            isValid = false;
        }
        
        // Validate full name
        if (student.getFullName() == null || student.getFullName().trim().isEmpty()) {
            request.setAttribute("errorName", "Full name is required");
            isValid = false;
        } else if (student.getFullName().trim().length() < 2) {
            request.setAttribute("errorName", "Full name must be at least 2 characters");
            isValid = false;
        }
        
        // Validate email (only if provided)
        String email = student.getEmail();
        if (email != null && !email.trim().isEmpty()) {
            if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
                request.setAttribute("errorEmail", "Invalid email format");
                isValid = false;
            }
        }
        
        // Validate major
        if (student.getMajor() == null || student.getMajor().trim().isEmpty()) {
            request.setAttribute("errorMajor", "Major is required");
            isValid = false;
        }
        
        return isValid;
    }

    private String handleFileUpload(Part filePart, HttpServletRequest request) throws IOException {
        if (filePart == null || filePart.getSize() == 0) {
            return null;
        }
        
        // Get filename
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        
        // Validate file type
        String fileExtension = fileName.substring(fileName.lastIndexOf(".")).toLowerCase();
        if (!Arrays.asList(".jpg", ".jpeg", ".png", ".gif").contains(fileExtension)) {
            request.setAttribute("errorPhoto", "Only JPG, JPEG, PNG, and GIF files are allowed");
            return null;
        }
        
        // Generate unique filename to prevent conflicts
        String uniqueFileName = UUID.randomUUID().toString() + fileExtension;
        
        // Create uploads directory if it doesn't exist
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdir();
        }
        
        // Save file
        try (InputStream inputStream = filePart.getInputStream()) {
            Files.copy(inputStream, Paths.get(uploadPath, uniqueFileName), StandardCopyOption.REPLACE_EXISTING);
        }
        
        return uniqueFileName;
    }
}
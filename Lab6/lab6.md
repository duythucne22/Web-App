# LAB 6: AUTHENTICATION & SESSION MANAGEMENT
## Setup Guide & Sample Code

**Course:** Web Application Development  
**Duration:** 2.5 hours  
**Prerequisites:** Lab 5 completed (Servlet & MVC Pattern)

> **Note:** This lab builds on Lab 5 by adding user authentication, session management, and role-based access control. Read this BEFORE the lab session.

## 📋 TABLE OF CONTENTS

1. [Why Authentication?](#1-why-authentication)
2. [Authentication vs Authorization](#2-authentication-vs-authorization)
3. [Session Management Concepts](#3-session-management-concepts)
4. [Cookie Management](#4-cookie-management)
5. [Security Best Practices](#5-security-best-practices)
6. [Project Setup](#6-project-setup)
7. [Sample Code - Authentication Implementation](#7-sample-code---authentication-implementation)
8. [Servlet Filters](#8-servlet-filters)
9. [Role-Based Access Control](#9-role-based-access-control)
10. [Running the Demo](#10-running-the-demo)

---

## 1. WHY AUTHENTICATION?

### Security Problems Without Authentication

Without authentication:

- ❌ Anyone can access any page
- ❌ No user identification
- ❌ Cannot track user activity
- ❌ No access control
- ❌ Data is vulnerable

**Example - Unprotected Application:**

```text
User types URL directly:
→ http://localhost:8080/app/student?action=delete&id=1

Result: Student deleted without verification!
```

### Benefits of Authentication

- ✅ **User Identity** - Know who is using the system
- ✅ **Access Control** - Restrict features by role
- ✅ **Audit Trail** - Track who did what
- ✅ **Data Protection** - Secure sensitive information
- ✅ **User Experience** - Personalized interface
- ✅ **Compliance** - Meet security requirements

---

## 2. AUTHENTICATION VS AUTHORIZATION

### Authentication

**"Who are you?"**

The process of verifying user identity.

```text
┌──────────────────────────────────┐
│   User enters credentials        │
│   (username + password)          │
└────────────┬─────────────────────┘
             ▼
┌──────────────────────────────────┐
│   System verifies credentials    │
│   against database               │
└────────────┬─────────────────────┘
             ▼
┌──────────────────────────────────┐
│   Creates session for user       │
│   (logged in)                    │
└──────────────────────────────────┘
```

**Methods:**
- Username/Password
- Email/Password
- Two-Factor Authentication (2FA)
- Biometric (fingerprint, face)
- OAuth (Google, Facebook login)

### Authorization

**"What can you do?"**

The process of determining what an authenticated user can access.

```text
┌──────────────────────────────────┐
│   User is authenticated          │
│   (we know who they are)         │
└────────────┬─────────────────────┘
             ▼
┌──────────────────────────────────┐
│   Check user's role/permissions  │
│   (admin, user, guest)           │
└────────────┬─────────────────────┘
             ▼
┌──────────────────────────────────┐
│   Grant or deny access           │
│   to specific resources          │
└──────────────────────────────────┘
```

**Example Roles:**
- **Admin:** Full access (CRUD all data)
- **User:** Limited access (CRUD own data)
- **Guest:** Read-only access

### Comparison

| Aspect | Authentication | Authorization |
|--------|---------------|---------------|
| Question | Who are you? | What can you do? |
| When | Login | Every request |
| Process | Verify credentials | Check permissions |
| Result | Identity confirmed | Access granted/denied |
| Example | Enter password | View admin panel |

---

## 3. SESSION MANAGEMENT CONCEPTS

### What is a Session?

A session is a way to store user information across multiple requests.

**Problem: HTTP is stateless**

```text
Request 1: User logs in → Server responds
Request 2: User views page → Server doesn't remember login!
```

**Solution: Sessions**

```text
Request 1: User logs in → Server creates session → Returns session ID
Request 2: User views page → Sends session ID → Server remembers user!
```

### How Sessions Work

```text
1. User logs in successfully
   ↓
2. Server creates session object
   session.setAttribute("user", userObject)
   ↓
3. Server sends session ID to browser (cookie)
   JSESSIONID=ABC123XYZ
   ↓
4. Browser stores session ID
   ↓
5. Browser sends session ID with every request
   ↓
6. Server retrieves session using ID
   User user = (User) session.getAttribute("user")
   ↓
7. Server knows who the user is!
```

### Session Lifecycle

```java
// filepath: session-example.java
// CREATE SESSION
HttpSession session = request.getSession(true);

// STORE DATA
session.setAttribute("user", userObject);
session.setAttribute("role", "admin");

// RETRIEVE DATA
User user = (User) session.getAttribute("user");
String role = (String) session.getAttribute("role");

// CHECK IF EXISTS
if (session.getAttribute("user") == null) {
    // User not logged in
}

// REMOVE SPECIFIC ATTRIBUTE
session.removeAttribute("tempData");

// DESTROY SESSION (logout)
session.invalidate();

// SET TIMEOUT (30 minutes)
session.setMaxInactiveInterval(30 * 60);
```

### Session Scope

Four Scopes in JSP/Servlet:

```java
// filepath: scope-example.java
// 1. PAGE SCOPE - Single JSP page only
pageContext.setAttribute("key", value);

// 2. REQUEST SCOPE - Single request (forward only)
request.setAttribute("key", value);

// 3. SESSION SCOPE - Multiple requests (same user)
session.setAttribute("key", value);

// 4. APPLICATION SCOPE - All users, entire application
application.setAttribute("key", value);
```

**When to use SESSION:**
- User login information
- Shopping cart
- User preferences
- Multi-step forms
- Temporary user data

---

## 4. COOKIE MANAGEMENT

### What is a Cookie?

A cookie is a small piece of data stored on the client-side (browser) that is sent with every HTTP request to the server.

**Key Characteristics:**
- Stored in browser (client-side)
- Sent automatically with every request
- Has expiration time
- Limited size (4KB)
- Can persist across browser sessions
- Domain and path specific

### How Cookies Work

```text
1. Server creates cookie
   ↓
2. Server sends cookie to browser
   Set-Cookie: username=john; Max-Age=3600
   ↓
3. Browser stores cookie
   ↓
4. Browser sends cookie with every request
   Cookie: username=john
   ↓
5. Server reads cookie value
   String username = getCookieValue(request, "username")
   ↓
6. Server can use the data!
```

### Cookie vs Session Comparison

| Aspect | Cookie | Session |
|--------|--------|---------|
| Storage Location | Client (browser) | Server (memory/database) |
| Size Limit | 4KB per cookie | No practical limit |
| Security | Less secure (visible to client) | More secure (server-side) |
| Lifetime | Can persist for years | Usually temporary (timeout) |
| Data Type | String only | Any Java object |
| Performance | Sent with every request (overhead) | Only session ID sent |
| Use Cases | Preferences, Remember Me | User authentication, cart |

### Cookie Lifecycle in Java

**Creating a Cookie:**

```java
// filepath: cookie-create-example.java
// Create cookie
Cookie cookie = new Cookie("username", "john");

// Set properties
cookie.setMaxAge(7 * 24 * 60 * 60); // 7 days in seconds
cookie.setPath("/"); // Available to entire application
cookie.setHttpOnly(true); // Cannot be accessed by JavaScript (XSS protection)
cookie.setSecure(true); // Only sent over HTTPS (production)

// Send to browser
response.addCookie(cookie);
```

**Reading Cookies:**

```java
// filepath: cookie-read-example.java
// Get all cookies
Cookie[] cookies = request.getCookies();

// Find specific cookie
public String getCookieValue(HttpServletRequest request, String name) {
    if (request.getCookies() != null) {
        for (Cookie cookie : request.getCookies()) {
            if (cookie.getName().equals(name)) {
                return cookie.getValue();
            }
        }
    }
    return null;
}

// Usage
String username = getCookieValue(request, "username");
if (username != null) {
    System.out.println("Found username: " + username);
}
```

**Updating a Cookie:**

```java
// filepath: cookie-update-example.java
// Create new cookie with same name
Cookie cookie = new Cookie("username", "newValue");
cookie.setMaxAge(7 * 24 * 60 * 60);
cookie.setPath("/");
response.addCookie(cookie); // Overwrites existing cookie
```

**Deleting a Cookie:**

```java
// filepath: cookie-delete-example.java
// Set max age to 0
Cookie cookie = new Cookie("username", "");
cookie.setMaxAge(0); // Delete immediately
cookie.setPath("/"); // Must match original path
response.addCookie(cookie);
```

### Cookie Attributes Explained

```java
// filepath: cookie-attributes-example.java
Cookie cookie = new Cookie("name", "value");

// 1. MAX-AGE / EXPIRES
cookie.setMaxAge(3600); // Seconds (1 hour)
// -1 = Session cookie (deleted when browser closes)
// 0 = Delete immediately
// > 0 = Persist for specified seconds

// 2. PATH
cookie.setPath("/"); // Available to all pages
cookie.setPath("/student"); // Only /student/* URLs

// 3. DOMAIN
cookie.setDomain(".example.com"); // Available to all subdomains
// Defaults to current domain only

// 4. SECURE
cookie.setSecure(true); // Only sent over HTTPS
// ALWAYS true in production!

// 5. HTTPONLY
cookie.setHttpOnly(true); // Not accessible via JavaScript
// Protects against XSS attacks
```

### Common Cookie Use Cases

**1. Remember Me Functionality:**

```java
// filepath: remember-me-example.java
// When user checks "Remember Me" on login
if (rememberMe) {
    // Store encrypted token
    String token = generateSecureToken(user.getId());
    
    Cookie rememberCookie = new Cookie("remember_token", token);
    rememberCookie.setMaxAge(30 * 24 * 60 * 60); // 30 days
    rememberCookie.setPath("/");
    rememberCookie.setHttpOnly(true);
    rememberCookie.setSecure(true);
    
    response.addCookie(rememberCookie);
    
    // Store token in database with expiration
    saveRememberToken(user.getId(), token, expirationDate);
}

// On subsequent visits (in Filter)
String token = getCookieValue(request, "remember_token");
if (token != null) {
    User user = getUserByToken(token);
    if (user != null && !isTokenExpired(token)) {
        // Auto-login user
        HttpSession session = request.getSession(true);
        session.setAttribute("user", user);
    } else {
        // Delete invalid token
        deleteRememberMeCookie(response);
    }
}
```

**2. User Preferences:**

```java
// filepath: preferences-example.java
// Save theme preference
Cookie themeCookie = new Cookie("theme", "dark");
themeCookie.setMaxAge(365 * 24 * 60 * 60); // 1 year
themeCookie.setPath("/");
response.addCookie(themeCookie);

// Read and apply preference
String theme = getCookieValue(request, "theme");
if (theme != null) {
    request.setAttribute("userTheme", theme);
}
```

**3. Language Selection:**

```java
// filepath: language-example.java
// Save language choice
Cookie langCookie = new Cookie("language", "vi");
langCookie.setMaxAge(365 * 24 * 60 * 60);
langCookie.setPath("/");
response.addCookie(langCookie);
```

**4. Shopping Cart (for guests):**

```java
// filepath: cart-cookie-example.java
// Add item to cart (as JSON string)
String cartData = serializeCart(cart);
Cookie cartCookie = new Cookie("guest_cart", cartData);
cartCookie.setMaxAge(7 * 24 * 60 * 60); // 7 days
cartCookie.setPath("/");
response.addCookie(cartCookie);
```

### Cookie Security Best Practices

**❌ NEVER store sensitive data in cookies:**

```java
// filepath: cookie-security-bad.java
// WRONG! Never do this
Cookie cookie = new Cookie("password", user.getPassword());
Cookie cookie = new Cookie("creditCard", cardNumber);
Cookie cookie = new Cookie("ssn", socialSecurity);
```

**✅ DO store tokens and references:**

```java
// filepath: cookie-security-good.java
// CORRECT! Store encrypted token
String token = encryptToken(user.getId());
Cookie cookie = new Cookie("auth_token", token);
cookie.setHttpOnly(true);
cookie.setSecure(true);
```

### Session ID Cookie (JSESSIONID)

**What is JSESSIONID?**

- Automatically created by servlet container
- Contains session identifier
- Links browser to server-side session
- Deleted when browser closes (by default)

```text
Browser Request:
Cookie: JSESSIONID=ABC123XYZ789
       ↓
Server looks up session using ID
       ↓
Retrieves session data
session.getAttribute("user")
```

You don't create JSESSIONID manually:

```java
// filepath: jsessionid-example.java
// This automatically creates JSESSIONID cookie
HttpSession session = request.getSession(true);

// Browser receives:
// Set-Cookie: JSESSIONID=ABC123XYZ789; Path=/; HttpOnly
```

### Complete Cookie Utility Class

```java
// filepath: src/util/CookieUtil.java
package util;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class CookieUtil {
    
    /**
     * Create and add cookie to response
     */
    public static void createCookie(HttpServletResponse response, 
                                   String name, 
                                   String value, 
                                   int maxAge) {
        Cookie cookie = new Cookie(name, value);
        cookie.setMaxAge(maxAge);
        cookie.setPath("/");
        cookie.setHttpOnly(true);
        // cookie.setSecure(true); // Enable in production with HTTPS
        response.addCookie(cookie);
    }
    
    /**
     * Get cookie value by name
     */
    public static String getCookieValue(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (cookie.getName().equals(name)) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }
    
    /**
     * Check if cookie exists
     */
    public static boolean hasCookie(HttpServletRequest request, String name) {
        return getCookieValue(request, name) != null;
    }
    
    /**
     * Delete cookie by setting max age to 0
     */
    public static void deleteCookie(HttpServletResponse response, String name) {
        Cookie cookie = new Cookie(name, "");
        cookie.setMaxAge(0);
        cookie.setPath("/");
        response.addCookie(cookie);
    }
    
    /**
     * Update cookie value
     */
    public static void updateCookie(HttpServletResponse response, 
                                   String name, 
                                   String newValue, 
                                   int maxAge) {
        createCookie(response, name, newValue, maxAge);
    }
}
```

### Cookie vs Session: When to Use What?

**Use Cookies for:**
- ✅ Remember Me functionality
- ✅ User preferences (theme, language)
- ✅ Tracking (analytics)
- ✅ Non-sensitive data that persists
- ✅ Guest shopping cart

**Use Sessions for:**
- ✅ User authentication state
- ✅ Shopping cart (logged in users)
- ✅ Multi-step form data
- ✅ Temporary sensitive data
- ✅ Complex objects

**Use Both for:**
- ✅ Auto-login (cookie stores token, session stores user)
- ✅ User preferences (cookie for storage, session for current state)
- ✅ Security (session for auth, cookie for additional validation)

---

## 5. SECURITY BEST PRACTICES

### Password Security

**❌ NEVER store plain text passwords:**

```sql
-- filepath: password-security-bad.sql
-- WRONG!
INSERT INTO users (username, password) 
VALUES ('john', 'password123');
```

**✅ Always hash passwords:**

```java
// filepath: password-security-good.java
// Using BCrypt (recommended)
String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());

// Store in database
INSERT INTO users (username, password) 
VALUES ('john', '$2a$10$EixZaYVK1fsbw1ZfbX3OXe...');

// Verify during login
if (BCrypt.checkpw(inputPassword, storedHashedPassword)) {
    // Password correct
}
```

### Common Security Vulnerabilities

**1. SQL Injection:**

```java
// filepath: sql-injection-example.java
// ❌ VULNERABLE
String sql = "SELECT * FROM users WHERE username='" + username + "'";

// ✅ SAFE - Use PreparedStatement
String sql = "SELECT * FROM users WHERE username = ?";
PreparedStatement pstmt = conn.prepareStatement(sql);
pstmt.setString(1, username);
```

**2. Session Hijacking:**

```java
// filepath: session-security-example.java
// ✅ PROTECTION
// - Use HTTPS
// - Regenerate session ID after login
request.getSession().invalidate();
request.getSession(true);

// - Set session timeout
session.setMaxInactiveInterval(30 * 60); // 30 minutes
```

**3. XSS (Cross-Site Scripting):**

```jsp
<!-- filepath: xss-protection-example.jsp -->
<!-- ❌ VULNERABLE -->
<p>Welcome, <%= username %></p>

<!-- ✅ SAFE - JSTL auto-escapes -->
<p>Welcome, <c:out value="${username}"/></p>
```

**4. Cookie Security:**

```java
// filepath: cookie-security-example.java
// ❌ VULNERABLE
Cookie cookie = new Cookie("user_data", sensitiveInfo);
response.addCookie(cookie);

// ✅ SECURE
Cookie cookie = new Cookie("auth_token", encryptedToken);
cookie.setHttpOnly(true);  // Prevents XSS
cookie.setSecure(true);    // HTTPS only
cookie.setPath("/");
response.addCookie(cookie);
```

### Security Checklist

- ✅ Hash passwords (BCrypt)
- ✅ Use HTTPS in production
- ✅ Validate all user input
- ✅ Use PreparedStatement
- ✅ Set session timeout
- ✅ Use HttpOnly and Secure flags for cookies
- ✅ Implement CSRF protection
- ✅ Use strong password policy
- ✅ Log security events
- ✅ Implement account lockout
- ✅ Keep dependencies updated

---

## 6. PROJECT SETUP

### Database Schema

Create users table:

```sql
-- filepath: database-schema.sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'user') DEFAULT 'user',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL
);

-- Insert sample users (password is 'password123' hashed with BCrypt)
INSERT INTO users (username, password, full_name, role) VALUES
('admin', '$2a$10$YourHashedPasswordHere', 'Admin User', 'admin'),
('john', '$2a$10$YourHashedPasswordHere', 'John Doe', 'user'),
('jane', '$2a$10$YourHashedPasswordHere', 'Jane Smith', 'user');
```

### Project Structure

```text
StudentManagementMVC/
│
├── Source Packages/
│   ├── model/
│   │   ├── Student.java
│   │   └── User.java                 (NEW)
│   │
│   ├── dao/
│   │   ├── StudentDAO.java
│   │   └── UserDAO.java              (NEW)
│   │
│   ├── controller/
│   │   ├── StudentController.java
│   │   ├── LoginController.java     (NEW)
│   │   └── LogoutController.java    (NEW)
│   │
│   └── filter/
│       ├── AuthFilter.java          (NEW)
│       └── AdminFilter.java         (NEW)
│
├── Web Pages/
│   ├── views/
│   │   ├── student-list.jsp
│   │   ├── student-form.jsp
│   │   ├── login.jsp                (NEW)
│   │   └── dashboard.jsp            (NEW)
│   │
│   └── WEB-INF/
│       └── web.xml
│
└── Libraries/
    ├── MySQL Connector/J
    ├── JSTL
    └── BCrypt (jbcrypt-0.4.jar)     (NEW)
```

### Required Library

BCrypt for password hashing:

**Maven:**

```xml
<!-- filepath: pom.xml -->
<dependency>
    <groupId>org.mindrot</groupId>
    <artifactId>jbcrypt</artifactId>
    <version>0.4</version>
</dependency>
```

---

## 7. SAMPLE CODE - AUTHENTICATION IMPLEMENTATION

### 7.1 User Model

```java
// filepath: src/model/User.java
package model;

import java.sql.Timestamp;

public class User {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String role;
    private boolean isActive;
    private Timestamp createdAt;
    private Timestamp lastLogin;
    
    // Constructors
    public User() {
    }
    
    public User(String username, String password, String fullName, String role) {
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.role = role;
    }
    
    // Getters and Setters
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public boolean isActive() {
        return isActive;
    }
    
    public void setActive(boolean active) {
        isActive = active;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(Timestamp lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    // Utility methods
    public boolean isAdmin() {
        return "admin".equalsIgnoreCase(this.role);
    }
    
    public boolean isUser() {
        return "user".equalsIgnoreCase(this.role);
    }
    
    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", fullName='" + fullName + '\'' +
                ", role='" + role + '\'' +
                ", isActive=" + isActive +
                '}';
    }
}
```

**Code Explanation:**

This User class is a JavaBean (POJO) that represents a user in our system.

**Key Points:**
- **Private attributes:** Follow encapsulation principle - data is hidden from outside access
- **Timestamp fields:** `createdAt` and `lastLogin` track when the user was created and last logged in
- **role attribute:** Stores user's role as String ("admin" or "user") for access control
- **isActive attribute:** Boolean flag to enable/disable user accounts without deleting them
- **Utility methods:** `isAdmin()` and `isUser()` provide convenient ways to check user roles without string comparison everywhere
- **toString():** Useful for debugging - prints user information (note: password is excluded for security)

### 7.2 UserDAO

```java
// filepath: src/dao/UserDAO.java
package dao;

import model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.*;

public class UserDAO {
    
    private static final String DB_URL = "jdbc:mysql://localhost:3306/student_management";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    
    // SQL Queries
    private static final String SQL_AUTHENTICATE = 
        "SELECT * FROM users WHERE username = ? AND is_active = TRUE";
    
    private static final String SQL_UPDATE_LAST_LOGIN = 
        "UPDATE users SET last_login = NOW() WHERE id = ?";
    
    private static final String SQL_GET_BY_ID = 
        "SELECT * FROM users WHERE id = ?";
    
    private static final String SQL_GET_BY_USERNAME = 
        "SELECT * FROM users WHERE username = ?";
    
    private static final String SQL_INSERT = 
        "INSERT INTO users (username, password, full_name, role) VALUES (?, ?, ?, ?)";
    
    // Get database connection
    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
    }
    
    /**
     * Authenticate user with username and password
     * @return User object if authentication successful, null otherwise
     */
    public User authenticate(String username, String password) {
        User user = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL_AUTHENTICATE)) {
            
            pstmt.setString(1, username);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String hashedPassword = rs.getString("password");
                    
                    // Verify password with BCrypt
                    if (BCrypt.checkpw(password, hashedPassword)) {
                        user = mapResultSetToUser(rs);
                        
                        // Update last login time
                        updateLastLogin(user.getId());
                    }
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user;
    }
    
    /**
     * Update user's last login timestamp
     */
    private void updateLastLogin(int userId) {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL_UPDATE_LAST_LOGIN)) {
            
            pstmt.setInt(1, userId);
            pstmt.executeUpdate();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    /**
     * Get user by ID
     */
    public User getUserById(int id) {
        User user = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL_GET_BY_ID)) {
            
            pstmt.setInt(1, id);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = mapResultSetToUser(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user;
    }
    
    /**
     * Get user by username
     */
    public User getUserByUsername(String username) {
        User user = null;
        
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL_GET_BY_USERNAME)) {
            
            pstmt.setString(1, username);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    user = mapResultSetToUser(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return user;
    }
    
    /**
     * Create new user with hashed password
     */
    public boolean createUser(User user) {
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL_INSERT)) {
            
            // Hash password before storing
            String hashedPassword = BCrypt.hashpw(user.getPassword(), BCrypt.gensalt());
            
            pstmt.setString(1, user.getUsername());
            pstmt.setString(2, hashedPassword);
            pstmt.setString(3, user.getFullName());
            pstmt.setString(4, user.getRole());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Map ResultSet to User object
     */
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setRole(rs.getString("role"));
        user.setActive(rs.getBoolean("is_active"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setLastLogin(rs.getTimestamp("last_login"));
        return user;
    }
    
    /**
     * Test method - Generate hashed password
     */
    public static void main(String[] args) {
        // Generate hash for "password123"
        String plainPassword = "password123";
        String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
        System.out.println("Plain: " + plainPassword);
        System.out.println("Hashed: " + hashedPassword);
        
        // Test verification
        boolean matches = BCrypt.checkpw(plainPassword, hashedPassword);
        System.out.println("Verification: " + matches);
    }
}
```

**Code Explanation:**

This UserDAO class handles all database operations related to users.

**Key Methods Explained:**

1. **authenticate(username, password):**
   - Purpose: Verify user credentials during login
   - Uses BCrypt to compare plain password with stored hash
   - Returns User object if valid, null if invalid

2. **BCrypt Security:**
   - `BCrypt.hashpw()`: Creates one-way hash (cannot be reversed)
   - `BCrypt.checkpw()`: Safely compares password with hash
   - Same password + different salt = different hash (more secure)

### 7.3 Login Controller

```java
// filepath: src/controller/LoginController.java
package controller;

import dao.UserDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    
    private UserDAO userDAO;
    
    @Override
    public void init() {
        userDAO = new UserDAO();
    }
    
    /**
     * Display login page
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard");
            return;
        }
        
        // Show login page
        request.getRequestDispatcher("/views/login.jsp").forward(request, response);
    }
    
    /**
     * Process login form
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("remember");
        
        // Validate input
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            
            request.setAttribute("error", "Username and password are required");
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
            return;
        }
        
        // Authenticate user
        User user = userDAO.authenticate(username, password);
        
        if (user != null) {
            // Authentication successful
            
            // Invalidate old session (prevent session fixation)
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            
            // Create new session
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());
            session.setAttribute("fullName", user.getFullName());
            
            // Set session timeout (30 minutes)
            session.setMaxInactiveInterval(30 * 60);
            
            // Handle "Remember Me" (optional - cookie implementation)
            if ("on".equals(rememberMe)) {
                // TODO: Implement remember me functionality with cookie
            }
            
            // Redirect based on role
            if (user.isAdmin()) {
                response.sendRedirect("dashboard");
            } else {
                response.sendRedirect("student?action=list");
            }
            
        } else {
            // Authentication failed
            request.setAttribute("error", "Invalid username or password");
            request.setAttribute("username", username); // Keep username in form
            request.getRequestDispatcher("/views/login.jsp").forward(request, response);
        }
    }
}
```

**Code Explanation:**

The LoginController handles the entire login process.

**Servlet Annotations:**

- `@WebServlet("/login")`: Maps this servlet to URL pattern /login
  - Handles both GET and POST requests to /login URL

**Method Breakdown:**

- **init():**
  - Called once when servlet is first loaded
  - Initializes the UserDAO instance
  - Makes DAO available for all requests without recreating it

- **doGet() - Display Login Page:**
  - Purpose: Show the login form to users
  - Check if already logged in:
    - `request.getSession(false)`: Get existing session, don't create new one
    - If user is already logged in, redirect to dashboard (avoid re-login)
  - Show login page: Forward to login.jsp if not logged in

- **doPost() - Process Login Form:**

  ```text
  Step 1: Get credentials from form
      Retrieves username and password from POST parameters
      Gets "remember me" checkbox value

  Step 2: Validate input
      Checks if username or password is empty
      If empty, shows error and returns to login page
      Keeps username in form (better UX - user doesn't retype)

  Step 3: Authenticate
      Calls userDAO.authenticate() to verify credentials
      Returns User object if valid, null if invalid

  Step 4a: Success path
      Security: Invalidate old session to prevent session fixation attack
      Create fresh session with request.getSession(true)
      Store user data in session:
        session.setAttribute("user", user): Complete user object
        session.setAttribute("role", user.getRole()): Quick role access
        session.setAttribute("fullName", user.getFullName()): Display name
      Set session timeout: setMaxInactiveInterval(30 * 60) = 30 minutes
      Role-based redirect:
        Admin → dashboard (admin panel)
        Regular user → student list (main feature)

  Step 4b: Failure path
      Set error message for display
      Keep username to avoid retyping
      Forward back to login page (not redirect - preserves error message)
  ```

**Security Measures:**

- ✅ Session Regeneration: New session ID after login prevents session fixation
- ✅ Session Timeout: Auto-logout after 30 minutes of inactivity
- ✅ Password Hidden: Password never stored in session or displayed
- ✅ Prevent Double Login: Check existing session before showing login page

**Forward vs Redirect:**

- Forward: Used on authentication failure - keeps error message in request scope
- Redirect: Used on success - prevents form resubmission on browser refresh

### 7.4 Logout Controller

```java
// filepath: src/controller/LogoutController.java
package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get current session
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            // Invalidate session
            session.invalidate();
        }
        
        // Redirect to login page with message
        response.sendRedirect("login?message=You have been logged out successfully");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
```

### 7.5 Dashboard Controller

```java
// filepath: src/controller/DashboardController.java
package controller;

import dao.StudentDAO;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/dashboard")
public class DashboardController extends HttpServlet {
    
    private StudentDAO studentDAO;
    
    @Override
    public void init() {
        studentDAO = new StudentDAO();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get user from session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        
        // Get statistics
        int totalStudents = studentDAO.getTotalStudents();
        
        // Set attributes
        request.setAttribute("totalStudents", totalStudents);
        request.setAttribute("welcomeMessage", "Welcome back, " + user.getFullName() + "!");
        
        // Forward to dashboard
        request.getRequestDispatcher("/views/dashboard.jsp").forward(request, response);
    }
}
```

### 7.6 Login View

```jsp
<!-- filepath: WebContent/views/login.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Student Management System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .login-container {
            background: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            width: 100%;
            max-width: 400px;
        }
        
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .login-header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .login-header p {
            color: #666;
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #333;
            font-weight: 500;
        }
        
        .form-group input[type="text"],
        .form-group input[type="password"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ddd;
            border-radius: 5px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .remember-me {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .remember-me input {
            margin-right: 8px;
        }
        
        .remember-me label {
            color: #666;
            font-size: 14px;
        }
        
        .btn-login {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
        }
        
        .alert {
            padding: 12px;
            border-radius: 5px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        
        .alert-error {
            background: #fee;
            color: #c33;
            border: 1px solid #fcc;
        }
        
        .alert-success {
            background: #efe;
            color: #3c3;
            border: 1px solid #cfc;
        }
        
        .demo-credentials {
            margin-top: 20px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 5px;
            font-size: 12px;
        }
        
        .demo-credentials h4 {
            margin-bottom: 10px;
            color: #333;
        }
        
        .demo-credentials p {
            margin: 5px 0;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <h1>🔐 Login</h1>
            <p>Student Management System</p>
        </div>
        
        <!-- Error Message -->
        <c:if test="${not empty error}">
            <div class="alert alert-error">
                ❌ ${error}
            </div>
        </c:if>
        
        <!-- Success Message -->
        <c:if test="${not empty param.message}">
            <div class="alert alert-success">
                ✅ ${param.message}
            </div>
        </c:if>
        
        <!-- Login Form -->
        <form action="login" method="post">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" 
                       id="username" 
                       name="username" 
                       value="${username}"
                       placeholder="Enter your username"
                       required
                       autofocus>
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" 
                       id="password" 
                       name="password" 
                       placeholder="Enter your password"
                       required>
            </div>
            
            <div class="remember-me">
                <input type="checkbox" id="remember" name="remember">
                <label for="remember">Remember me</label>
            </div>
            
            <button type="submit" class="btn-login">Login</button>
        </form>
        
        <!-- Demo Credentials -->
        <div class="demo-credentials">
            <h4>Demo Credentials:</h4>
            <p><strong>Admin:</strong> username: admin / password: password123</p>
            <p><strong>User:</strong> username: john / password: password123</p>
        </div>
    </div>
</body>
</html>
```

### 7.7 Dashboard View

```jsp
<!-- filepath: WebContent/views/dashboard.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Dashboard</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f5f5f5;
        }
        
        .navbar {
            background: #2c3e50;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .navbar h2 {
            font-size: 20px;
        }
        
        .navbar-right {
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .user-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .role-badge {
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .role-admin {
            background: #e74c3c;
        }
        
        .role-user {
            background: #3498db;
        }
        
        .btn-logout {
            padding: 8px 20px;
            background: #e74c3c;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 14px;
            transition: background 0.3s;
        }
        
        .btn-logout:hover {
            background: #c0392b;
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .welcome-card {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        
        .welcome-card h1 {
            color: #2c3e50;
            margin-bottom: 10px;
        }
        
        .welcome-card p {
            color: #7f8c8d;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 20px;
        }
        
        .stat-icon {
            font-size: 40px;
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
        }
        
        .stat-icon-students {
            background: #e8f4fd;
        }
        
        .stat-content h3 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 5px;
        }
        
        .stat-content p {
            color: #7f8c8d;
            font-size: 14px;
        }
        
        .quick-actions {
            background: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .quick-actions h2 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        
        .action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }
        
        .action-btn {
            padding: 20px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 8px;
            text-align: center;
            transition: all 0.3s;
            display: block;
        }
        
        .action-btn:hover {
            background: #2980b9;
            transform: translateY(-2px);
        }
        
        .action-btn-primary {
            background: #3498db;
        }
        
        .action-btn-success {
            background: #27ae60;
        }
        
        .action-btn-warning {
            background: #f39c12;
        }
    </style>
</head>
<body>
    <!-- Navigation Bar -->
    <div class="navbar">
        <h2>📚 Student Management System</h2>
        <div class="navbar-right">
            <div class="user-info">
                <span>${sessionScope.fullName}</span>
                <span class="role-badge role-${sessionScope.role}">
                    ${sessionScope.role}
                </span>
            </div>
            <a href="logout" class="btn-logout">Logout</a>
        </div>
    </div>
    
    <!-- Main Content -->
    <div class="container">
        <!-- Welcome Card -->
        <div class="welcome-card">
            <h1>${welcomeMessage}</h1>
            <p>Here's what's happening with your students today.</p>
        </div>
        
        <!-- Statistics -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon stat-icon-students">
                    👨‍🎓
                </div>
                <div class="stat-content">
                    <h3>${totalStudents}</h3>
                    <p>Total Students</p>
                </div>
            </div>
        </div>
        
        <!-- Quick Actions -->
        <div class="quick-actions">
            <h2>Quick Actions</h2>
            <div class="action-grid">
                <a href="student?action=list" class="action-btn action-btn-primary">
                    📋 View All Students
                </a>
                
                <c:if test="${sessionScope.role eq 'admin'}">
                    <a href="student?action=new" class="action-btn action-btn-success">
                        ➕ Add New Student
                    </a>
                </c:if>
                
                <a href="student?action=search" class="action-btn action-btn-warning">
                    🔍 Search Students
                </a>
            </div>
        </div>
    </div>
</body>
</html>
```

---

## 8. SERVLET FILTERS

### What is a Filter?

A Filter is a component that intercepts requests and responses to perform preprocessing or postprocessing tasks.

**Filter Lifecycle:**

```text
1. init()      - Called once when filter loads
2. doFilter()  - Called for each request
3. destroy()   - Called when filter unloads
```

### How Filters Work

```text
Client Request
     ↓
Filter 1 → doFilter() → [preprocessing]
     ↓
Filter 2 → doFilter() → [preprocessing]
     ↓
Servlet → service()
     ↓
Filter 2 → doFilter() → [postprocessing]
     ↓
Filter 1 → doFilter() → [postprocessing]
     ↓
Client Response
```

### Authentication Filter

```java
// filepath: src/filter/AuthFilter.java
package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Authentication Filter - Checks if user is logged in
 * Protects all pages except login and public resources
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {"/*"})
public class AuthFilter implements Filter {
    
    // Public URLs that don't require authentication
    private static final String[] PUBLIC_URLS = {
        "/login",
        "/logout",
        ".css",
        ".js",
        ".png",
        ".jpg",
        ".jpeg",
        ".gif"
    };
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AuthFilter initialized");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestURI.substring(contextPath.length());
        
        // Check if this is a public URL
        if (isPublicUrl(path)) {
            // Allow access to public URLs
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);
        
        if (isLoggedIn) {
            // User is logged in, allow access
            chain.doFilter(request, response);
        } else {
            // User not logged in, redirect to login
            String loginURL = contextPath + "/login";
            httpResponse.sendRedirect(loginURL);
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("AuthFilter destroyed");
    }
    
    /**
     * Check if URL is public (doesn't require authentication)
     */
    private boolean isPublicUrl(String path) {
        for (String publicUrl : PUBLIC_URLS) {
            if (path.contains(publicUrl)) {
                return true;
            }
        }
        return false;
    }
}
```

### Admin Authorization Filter

```java
// filepath: src/filter/AdminFilter.java
package filter;

import model.User;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Admin Filter - Checks if user has admin role
 * Protects admin-only pages
 */
@WebFilter(filterName = "AdminFilter", urlPatterns = {"/student"})
public class AdminFilter implements Filter {
    
    // Admin-only actions
    private static final String[] ADMIN_ACTIONS = {
        "new",
        "insert",
        "edit",
        "update",
        "delete"
    };
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        System.out.println("AdminFilter initialized");
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        String action = httpRequest.getParameter("action");
        
        // Check if this action requires admin role
        if (isAdminAction(action)) {
            HttpSession session = httpRequest.getSession(false);
            
            if (session != null) {
                User user = (User) session.getAttribute("user");
                
                if (user != null && user.isAdmin()) {
                    // User is admin, allow access
                    chain.doFilter(request, response);
                } else {
                    // User is not admin, deny access
                    httpResponse.sendRedirect(httpRequest.getContextPath() + 
                        "/student?action=list&error=Access denied. Admin privileges required.");
                }
            } else {
                // No session, redirect to login
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
            }
        } else {
            // Not an admin action, allow access
            chain.doFilter(request, response);
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("AdminFilter destroyed");
    }
    
    /**
     * Check if action requires admin role
     */
    private boolean isAdminAction(String action) {
        if (action == null) return false;
        
        for (String adminAction : ADMIN_ACTIONS) {
            if (adminAction.equals(action)) {
                return true;
            }
        }
        return false;
    }
}
```

---

## 9. ROLE-BASED ACCESS CONTROL

### Update Student List View

```jsp
<!-- filepath: WebContent/views/student-list.jsp -->
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <!-- ...existing code... -->
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
    
    <div class="container">
        <h1>📚 Student List</h1>
        
        <!-- Add button - Admin only -->
        <c:if test="${sessionScope.role eq 'admin'}">
            <div style="margin: 20px 0;">
                <a href="student?action=new" class="btn-add">➕ Add New Student</a>
            </div>
        </c:if>
        
        <!-- Student Table -->
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Code</th>
                    <th>Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <c:if test="${sessionScope.role eq 'admin'}">
                        <th>Actions</th>
                    </c:if>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="student" items="${students}">
                    <tr>
                        <td>${student.id}</td>
                        <td>${student.studentCode}</td>
                        <td>${student.fullName}</td>
                        <td>${student.email}</td>
                        <td>${student.major}</td>
                        
                        <!-- Action buttons - Admin only -->
                        <c:if test="${sessionScope.role eq 'admin'}">
                            <td>
                                <a href="student?action=edit&id=${student.id}" 
                                   class="btn-edit">Edit</a>
                                <a href="student?action=delete&id=${student.id}" 
                                   class="btn-delete"
                                   onclick="return confirm('Delete this student?')">Delete</a>
                            </td>
                        </c:if>
                    </tr>
                </c:forEach>
                
                <c:if test="${empty students}">
                    <tr>
                        <td colspan="6" style="text-align: center;">
                            No students found
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
</body>
</html>
```

---

## 10. RUNNING THE DEMO

### Step-by-Step Testing

**1. Setup Database:**

```sql
-- filepath: setup-database.sql
-- Create users table
CREATE TABLE users (...);

-- Insert test users
INSERT INTO users (username, password, full_name, role) VALUES (...);
```

**2. Generate Hashed Passwords:**

```java
// filepath: generate-passwords.java
// Run UserDAO.main() to generate hashes
public static void main(String[] args) {
    String plainPassword = "password123";
    String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
    System.out.println("Hashed: " + hashedPassword);
}
```

**3. Deploy Application:**
- Clean and Build project
- Run on Tomcat

**4. Test Login Flow:**

```text
1. Access: http://localhost:8080/YourApp/
   → Redirected to login (AuthFilter)

2. Login with: admin / password123
   → Creates session
   → Redirected to dashboard

3. Click "View All Students"
   → Shows student list
   → Edit/Delete buttons visible (admin)

4. Logout
   → Session invalidated
   → Redirected to login

5. Login with: john / password123
   → Regular user view
   → No Edit/Delete buttons

6. Try to access: /student?action=new
   → AdminFilter blocks access
   → Error message displayed
```

### Test URLs

**Public (no login required):**
- `/login`
- `/logout`

**Protected (login required):**
- `/dashboard`
- `/student?action=list`

**Admin only:**
- `/student?action=new`
- `/student?action=edit&id=1`
- `/student?action=delete&id=1`

### Common Issues

| Issue | Solution |
|-------|----------|
| 404 on /login | Check servlet mapping |
| Filter not working | Verify @WebFilter annotation |
| Session null error | Check session creation in LoginController |
| BCrypt ClassNotFoundException | Add jbcrypt-0.4.jar library |
| Redirected to login repeatedly | Check PUBLIC_URLS in AuthFilter |
| Admin actions allowed for users | Check AdminFilter mapping |

---

## 11. BEST PRACTICES

### Security

- ✅ Always hash passwords (never store plain text)
- ✅ Use PreparedStatement (prevent SQL injection)
- ✅ Regenerate session ID after login (prevent session fixation)
- ✅ Set session timeout (automatic logout)
- ✅ Validate all input (never trust user input)
- ✅ Use HTTPS in production
- ✅ Implement CSRF protection for forms
- ✅ Log security events (login attempts, etc.)

### Session Management

**✅ Check session before access:**

```java
// filepath: session-check-example.java
HttpSession session = request.getSession(false);
if (session == null || session.getAttribute("user") == null) {
    // Not logged in
}
```

**✅ Store minimal data in session:**

```java
// filepath: session-storage-example.java
// Good - store only necessary data
session.setAttribute("user", user);
session.setAttribute("role", user.getRole());

// Bad - don't store entire database
session.setAttribute("allStudents", largeList);
```

**✅ Invalidate on logout:**

```java
// filepath: session-invalidate-example.java
session.invalidate();
```

### Authorization

**✅ Check permissions in multiple layers:**
- Filter (URL level)
- Controller (action level)
- View (UI level)

**✅ Fail securely:**

```java
// filepath: fail-secure-example.java
// Default deny
if (user == null || !user.isAdmin()) {
    // Deny access
    response.sendRedirect("error.jsp");
    return;
}
```

---

## 12. SUMMARY

### What You Learned

- ✅ **Authentication** - Verify user identity
- ✅ **Session Management** - Track user across requests
- ✅ **Authorization** - Control access based on role
- ✅ **Servlet Filters** - Intercept and process requests
- ✅ **Password Hashing** - Secure password storage with BCrypt
- ✅ **Role-Based Access Control** - Different permissions per role

### Key Concepts

**Authentication Flow:**

```text
1. User enters credentials
2. System verifies against database
3. Create session with user data
4. Redirect to appropriate page
```

**Authorization Flow:**

```text
1. User makes request
2. Filter checks if logged in
3. Filter checks user role
4. Allow or deny access
```

**Session Management:**

```java
// filepath: session-management-summary.java
- session.setAttribute()              // Store data
- session.getAttribute()              // Retrieve data
- session.invalidate()                // Destroy session
- session.setMaxInactiveInterval()    // Set timeout
```

### Security Principles

- **Defense in Depth** - Multiple security layers
- **Principle of Least Privilege** - Minimum necessary permissions
- **Fail Securely** - Default deny access
- **Never Trust Input** - Always validate
- **Keep Secrets Secret** - Hash passwords, secure keys

---

## End of Setup Guide

> Review this before Lab 6. Understand authentication and session concepts thoroughly!
# Lab 9 Exercises: Spring Security & JWT Authentication

**Course:** Web Application Development  
**Lab Duration:** 2.5 hours  
**Total Points:** 100 (In-class: 60, Homework: 40)

## 📚 Before You Start

**Prerequisites**
- ✅ Completed Lab 8 (REST API + DTO Pattern)
- ✅ Read Lab 9 Setup Guide
- ✅ Understanding of authentication vs authorization
- ✅ Basic knowledge of JWT
- ✅ Thunder Client or Postman ready

## Lab Objectives

By the end of this lab you should be able to:

1. Implement Spring Security in REST APIs
2. Create user authentication with JWT
3. Hash passwords with BCrypt
4. Protect endpoints with role-based access
5. Implement login/register/logout functionality
6. Use `@PreAuthorize` for method-level security
7. Handle 401 and 403 errors properly

---

## Part A — In-Class Exercises (60 points)

**Time Allocation:** 2.5 hours  
**Submission:** Demonstrate working authentication to instructor

### Exercise 1 — Project Setup & User Entity (15 points)

**Estimated Time:** 25 minutes

#### Task 1.1: Add Security Dependencies (5 points)

Update `pom.xml` and add the following dependencies:

```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- JWT Dependencies -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>

<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

**Evaluation Criteria**

| Criteria                            | Points |
|-------------------------------------|:------:|
| Spring Security dependency added    |   2    |
| JWT dependencies added correctly    |   2    |
| Maven dependencies resolve          |   1    |

---

#### Task 1.2: Create `User` Entity and `Role` Enum (5 points)

File: `src/main/java/com/example/securecustomerapi/entity/Role.java`

```java
package com.example.securecustomerapi.entity;

public enum Role {
    USER,
    ADMIN
}
```

File: `src/main/java/com/example/securecustomerapi/entity/User.java` — template to complete:

```java
package com.example.securecustomerapi.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "users")
public class User {
        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        private Long id;

        @Column(unique = true, nullable = false)
        private String username;

        @Column(unique = true, nullable = false)
        private String email;

        @Column(nullable = false)
        private String password;

        private String fullName;

        @Enumerated(EnumType.STRING)
        private Role role = Role.USER;

        private Boolean isActive = true;

        private LocalDateTime createdAt;
        private LocalDateTime updatedAt;

        @PrePersist
        protected void onCreate() {
                createdAt = LocalDateTime.now();
        }

        @PreUpdate
        protected void onUpdate() {
                updatedAt = LocalDateTime.now();
        }

        // Add constructors, getters, setters
}
```

**Evaluation Criteria**

| Criteria                          | Points |
|-----------------------------------|:------:|
| Entity annotations correct        |   2    |
| Role enum created                 |   1    |
| Lifecycle callbacks implemented   |   1    |
| Getters/setters complete          |   1    |

---

#### Task 1.3: Database Setup (5 points)

Create `users` table (MySQL example):

```sql
USE customer_management;

CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('USER','ADMIN') DEFAULT 'USER',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert test users (password is "password123" hashed with BCrypt)
INSERT INTO users (username, email, password, full_name, role) VALUES
    ('admin', 'admin@example.com', '$2a$10$XptfskLsT1l/bRTLRiiCgejHqOpgXFreUnNUa35gJdCr2v2QbVFzu', 'Admin User', 'ADMIN'),
    ('john',  'john@example.com',  '$2a$10$XptfskLsT1l/bRTLRiiCgejHqOpgXFreUnNUa35gJdCr2v2QbVFzu', 'John Doe',   'USER'),
    ('jane',  'jane@example.com',  '$2a$10$XptfskLsT1l/bRTLRiiCgejHqOpgXFreUnNUa35gJdCr2v2QbVFzu', 'Jane Smith', 'USER');
```

Update `application.properties` with JWT configuration:

```properties
# JWT Configuration
jwt.secret=mySecretKeyForJWTTokenGenerationAndValidationMustBeLongEnough256Bits
jwt.expiration=86400000
```

**Evaluation Criteria**

| Criteria                 | Points |
|--------------------------|:------:|
| Users table created      |   2    |
| Sample users inserted    |   2    |
| JWT config added         |   1    |

Checkpoint #1: Run application and verify users table exists.

### Exercise 2: DTO & Repository (10 points)

Estimated Time: 20 minutes
Task 2.1: Create Authentication DTOs (5 points)

Create these DTO files:

    LoginRequestDTO.java
    LoginResponseDTO.java
    RegisterRequestDTO.java
    UserResponseDTO.java

Template for LoginRequestDTO:

package com.example.securecustomerapi.dto;

import jakarta.validation.constraints.NotBlank;

public class LoginRequestDTO {
    
    @NotBlank(message = "Username is required")
    private String username;
    
    @NotBlank(message = "Password is required")
    private String password;
    
    // TODO: Add constructors, getters, setters
}

Template for LoginResponseDTO:

package com.example.securecustomerapi.dto;

public class LoginResponseDTO {
    
    private String token;
    private String type = "Bearer";
    private String username;
    private String email;
    private String role;
    
    // TODO: Add constructors, getters, setters
}

Evaluation Criteria:
Criteria 	Points
LoginRequestDTO with validation 	1
LoginResponseDTO complete 	1
RegisterRequestDTO with validation 	2
UserResponseDTO complete 	1
Task 2.2: Create User Repository (5 points)

File: src/main/java/com/example/securecustomerapi/repository/UserRepository.java

Template:

package com.example.securecustomerapi.repository;

import com.example.securecustomerapi.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // TODO: Add method to find by username
    
    // TODO: Add method to find by email
    
    // TODO: Add method to check if username exists
    
    // TODO: Add method to check if email exists
}

Evaluation Criteria:
Criteria 	Points
Repository extends JpaRepository 	2
Custom query methods defined 	3

Checkpoint #2: Test repository by running a simple query.
EXERCISE 3: JWT & SECURITY COMPONENTS (20 points)

Estimated Time: 45 minutes
Task 3.1: Create JWT Token Provider (8 points)

File: src/main/java/com/example/securecustomerapi/security/JwtTokenProvider.java

Template:

package com.example.securecustomerapi.security;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtTokenProvider {
    
    @Value("${jwt.secret}")
    private String jwtSecret;
    
    @Value("${jwt.expiration}")
    private long jwtExpiration;
    
    // TODO: Implement generateToken(Authentication authentication)
    // 1. Get UserDetails from authentication
    // 2. Calculate expiry date (now + jwtExpiration)
    // 3. Create SecretKey from jwtSecret
    // 4. Build JWT with subject (username), issuedAt, expiration
    // 5. Sign with key and return token string
    
    // TODO: Implement getUsernameFromToken(String token)
    // 1. Create SecretKey from jwtSecret
    // 2. Parse token to get claims
    // 3. Return subject (username)
    
    // TODO: Implement validateToken(String token)
    // 1. Try to parse and validate token
    // 2. Return true if valid
    // 3. Catch exceptions and return false
}

Hints:

// Generate token example
public String generateToken(Authentication authentication) {
    UserDetails userDetails = (UserDetails) authentication.getPrincipal();
    Date now = new Date();
    Date expiryDate = new Date(now.getTime() + jwtExpiration);
    
    SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));
    
    return Jwts.builder()
            .subject(userDetails.getUsername())
            .issuedAt(now)
            .expiration(expiryDate)
            .signWith(key)
            .compact();
}

Evaluation Criteria:
Criteria 	Points
generateToken() implemented 	3
getUsernameFromToken() implemented 	2
validateToken() implemented 	3
Task 3.2: Create JWT Authentication Filter (7 points)

File: src/main/java/com/example/securecustomerapi/security/JwtAuthenticationFilter.java

Template:

package com.example.securecustomerapi.security;

import com.example.securecustomerapi.service.CustomUserDetailsService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    
    @Autowired
    private JwtTokenProvider tokenProvider;
    
    @Autowired
    private CustomUserDetailsService customUserDetailsService;
    
    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain) throws ServletException, IOException {
        try {
            // TODO: 1. Extract JWT from request header
            String jwt = getJwtFromRequest(request);
            
            // TODO: 2. Validate token
            // TODO: 3. Get username from token
            // TODO: 4. Load user details
            // TODO: 5. Create authentication object
            // TODO: 6. Set authentication in SecurityContext
            
        } catch (Exception ex) {
            logger.error("Could not set user authentication", ex);
        }
        
        filterChain.doFilter(request, response);
    }
    
    // TODO: Implement getJwtFromRequest(HttpServletRequest request)
    // 1. Get "Authorization" header
    // 2. Check if starts with "Bearer "
    // 3. Return token (remove "Bearer " prefix)
    private String getJwtFromRequest(HttpServletRequest request) {
        return null;
    }
}

Evaluation Criteria:
Criteria 	Points
Filter extends OncePerRequestFilter 	1
JWT extraction from header 	2
Token validation logic 	2
Authentication set in SecurityContext 	2
Task 3.3: Create Custom UserDetailsService (5 points)

File: src/main/java/com/example/securecustomerapi/service/CustomUserDetailsService.java

Template:

package com.example.securecustomerapi.service;

import com.example.securecustomerapi.entity.User;
import com.example.securecustomerapi.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // TODO: 1. Find user by username from repository
        // TODO: 2. Throw UsernameNotFoundException if not found
        // TODO: 3. Return Spring Security User object with:
        //    - username
        //    - password
        //    - enabled status
        //    - authorities (roles)
        
        return null;
    }
    
    // TODO: Create helper method to convert Role to GrantedAuthority
    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        // Return collection with "ROLE_" + role name
        return null;
    }
}

Evaluation Criteria:
Criteria 	Points
Implements UserDetailsService 	1
loadUserByUsername() implemented 	3
Authorities conversion correct 	1

Checkpoint #3: Verify all security components compile.
EXERCISE 4: SECURITY CONFIGURATION (15 points)

Estimated Time: 40 minutes
Task 4.1: Create Security Config (10 points)

File: src/main/java/com/example/securecustomerapi/security/SecurityConfig.java

Template:

package com.example.securecustomerapi.security;

import com.example.securecustomerapi.service.CustomUserDetailsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
    
    @Autowired
    private CustomUserDetailsService userDetailsService;
    
    @Autowired
    private JwtAuthenticationEntryPoint authenticationEntryPoint;
    
    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;
    
    // TODO: Create PasswordEncoder bean (BCryptPasswordEncoder)
    @Bean
    public PasswordEncoder passwordEncoder() {
        return null;
    }
    
    // TODO: Create AuthenticationManager bean
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return null;
    }
    
    // TODO: Create DaoAuthenticationProvider bean
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        return null;
    }
    
    // TODO: Create SecurityFilterChain bean
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .exceptionHandling(exception -> 
                exception.authenticationEntryPoint(authenticationEntryPoint)
            )
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            .authorizeHttpRequests(auth -> auth
                // TODO: Permit /api/auth/** endpoints
                // TODO: Require authentication for /api/customers GET
                // TODO: Require ADMIN role for /api/customers POST, PUT, DELETE
                // TODO: Require authentication for all other requests
                .anyRequest().authenticated()
            );
        
        // TODO: Set authentication provider
        // TODO: Add JWT filter before UsernamePasswordAuthenticationFilter
        
        return http.build();
    }
}

Hints:

.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/auth/**").permitAll()
    .requestMatchers(HttpMethod.GET, "/api/customers/**").authenticated()
    .requestMatchers(HttpMethod.POST, "/api/customers/**").hasRole("ADMIN")
    .requestMatchers(HttpMethod.PUT, "/api/customers/**").hasRole("ADMIN")
    .requestMatchers(HttpMethod.DELETE, "/api/customers/**").hasRole("ADMIN")
    .anyRequest().authenticated()
)

Evaluation Criteria:
Criteria 	Points
PasswordEncoder bean created 	1
AuthenticationManager configured 	2
SecurityFilterChain configured 	3
Endpoint security rules correct 	3
JWT filter added correctly 	1
Task 4.2: Create Authentication Entry Point (5 points)

File: src/main/java/com/example/securecustomerapi/security/JwtAuthenticationEntryPoint.java

Template:

package com.example.securecustomerapi.security;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
    
    @Override
    public void commence(HttpServletRequest request,
                        HttpServletResponse response,
                        AuthenticationException authException) throws IOException {
        
        // TODO: Set response content type and status
        // TODO: Create error response map
        // TODO: Write JSON response
    }
}

Evaluation Criteria:
Criteria 	Points
Implements AuthenticationEntryPoint 	2
Returns proper 401 JSON response 	3

Checkpoint #4: Run application - should require authentication now.
EXERCISE 5: USER SERVICE & AUTH CONTROLLER (remaining time)

Estimated Time: Remaining lab time
Task 5.1: Implement User Service (Points included in completion)

Create UserService interface and implementation with:

    login()
    register()
    getCurrentUser()

Task 5.2: Create Auth Controller (Points included in completion)

Create endpoints:

    POST /api/auth/login
    POST /api/auth/register
    GET /api/auth/me
    POST /api/auth/logout

Task 5.3: Update Customer Controller (Points included in completion)

Add @PreAuthorize annotations:

@PreAuthorize("hasRole('ADMIN')")
@PostMapping
public ResponseEntity<CustomerResponseDTO> createCustomer(...) {
    // Only ADMIN can access
}

Checkpoint #5: Test complete authentication flow with Thunder Client.
PART B: HOMEWORK EXERCISES (40 points)

Deadline: 1 week
Submission: Complete project + Postman collection
EXERCISE 6: PASSWORD MANAGEMENT (12 points)

Estimated Time: 45 minutes
Task 6.1: Change Password Endpoint (6 points)

Create DTO:

public class ChangePasswordDTO {
    @NotBlank
    private String currentPassword;
    
    @NotBlank
    @Size(min = 6)
    private String newPassword;
    
    @NotBlank
    private String confirmPassword;
}

Add to AuthController:

@PutMapping("/change-password")
public ResponseEntity<?> changePassword(@Valid @RequestBody ChangePasswordDTO dto) {
    // 1. Get current user from SecurityContext
    // 2. Verify current password
    // 3. Check new password matches confirm
    // 4. Hash and update password
    // 5. Return success message
}

Task 6.2: Forgot Password (6 points)

Create password reset token system:

    Add fields to User entity:

private String resetToken;
private LocalDateTime resetTokenExpiry;

    POST /api/auth/forgot-password
        Generate reset token
        Save token and expiry (e.g., 1 hour)
        Return token (in real app, send via email)

    POST /api/auth/reset-password
        Verify reset token is valid and not expired
        Update password
        Clear reset token

EXERCISE 7: USER PROFILE MANAGEMENT (10 points)

Estimated Time: 40 minutes
Task 7.1: View Profile (3 points)

@GetMapping("/api/users/profile")
public ResponseEntity<UserResponseDTO> getProfile() {
    // Get current user from SecurityContext
    // Return user details
}

Task 7.2: Update Profile (4 points)

Create DTO:

public class UpdateProfileDTO {
    @NotBlank
    private String fullName;
    
    @Email
    private String email;
}

Add endpoint:

@PutMapping("/api/users/profile")
public ResponseEntity<UserResponseDTO> updateProfile(@Valid @RequestBody UpdateProfileDTO dto) {
    // Update user's full name and email
    // Return updated user
}

Task 7.3: Delete Account (3 points)

@DeleteMapping("/api/users/account")
public ResponseEntity<?> deleteAccount(@RequestParam String password) {
    // Verify password
    // Set user.isActive = false (soft delete)
    // Return success message
}

EXERCISE 8: ADMIN ENDPOINTS (10 points)

Estimated Time: 40 minutes
Task 8.1: List All Users (3 points)

@GetMapping("/api/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<List<UserResponseDTO>> getAllUsers() {
    // Return all users (admin only)
}

Task 8.2: Update User Role (4 points)

Create DTO:

public class UpdateRoleDTO {
    @NotNull
    private Role role;
}

Add endpoint:

@PutMapping("/api/admin/users/{id}/role")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<UserResponseDTO> updateUserRole(
    @PathVariable Long id,
    @Valid @RequestBody UpdateRoleDTO dto) {
    // Update user's role
    // Return updated user
}

Task 8.3: Deactivate/Activate User (3 points)

@PatchMapping("/api/admin/users/{id}/status")
@PreAuthorize("hasRole('ADMIN')")
public ResponseEntity<UserResponseDTO> toggleUserStatus(@PathVariable Long id) {
    // Toggle user's isActive status
    // Return updated user
}

EXERCISE 9: REFRESH TOKEN (8 points)

Estimated Time: 35 minutes
Task 9.1: Create Refresh Token Entity (3 points)

@Entity
@Table(name = "refresh_tokens")
public class RefreshToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    @Column(unique = true, nullable = false)
    private String token;
    
    @Column(nullable = false)
    private LocalDateTime expiryDate;
}

Task 9.2: Generate Refresh Token (2 points)

Update login to return refresh token:

public LoginResponseDTO login(LoginRequestDTO loginRequest) {
    // Authenticate user
    // Generate access token
    // Generate refresh token (longer expiry, e.g., 7 days)
    // Save refresh token to database
    // Return both tokens
}

Task 9.3: Refresh Access Token (3 points)

Create endpoint:

@PostMapping("/api/auth/refresh")
public ResponseEntity<LoginResponseDTO> refreshToken(@RequestBody RefreshTokenDTO dto) {
    // Verify refresh token exists and not expired
    // Get user from refresh token
    // Generate new access token
    // Return new access token (and optionally new refresh token)
}

BONUS EXERCISES (Optional - Extra Credit)

Not required, earn up to 20 bonus points
BONUS 1: Email Verification (7 points)

On registration:

    Generate verification token
    Send email with verification link
    User clicks link: /api/auth/verify?token=xxx
    Activate account

Use JavaMail API:

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-mail</artifactId>
</dependency>

BONUS 2: Login Activity Log (6 points)

Track user logins:

    Create LoginHistory entity:

@Entity
public class LoginHistory {
    private Long id;
    private User user;
    private LocalDateTime loginTime;
    private String ipAddress;
    private String userAgent;
}

    Log each successful login
    Create endpoint to view login history

BONUS 3: Two-Factor Authentication (7 points)

Implement basic 2FA:

    Generate 6-digit code on login
    Send code via email
    User submits code to complete login
    Code expires after 5 minutes

HOMEWORK SUBMISSION GUIDELINES
What to Submit:

1. Complete Project ZIP:

secure-customer-api.zip
├── src/main/java/com/example/securecustomerapi/
│   ├── entity/
│   │   ├── User.java
│   │   └── Role.java
│   ├── dto/ (all DTOs)
│   ├── repository/
│   │   └── UserRepository.java
│   ├── security/
│   │   ├── JwtTokenProvider.java
│   │   ├── JwtAuthenticationFilter.java
│   │   ├── JwtAuthenticationEntryPoint.java
│   │   └── SecurityConfig.java
│   ├── service/
│   │   ├── CustomUserDetailsService.java
│   │   ├── UserService.java
│   │   └── UserServiceImpl.java
│   └── controller/
│       ├── AuthController.java
│       └── CustomerRestController.java (updated)
├── pom.xml
└── README.md

2. README.md:

# Secure Customer API with JWT Authentication

## Student Information
- **Name:** Huynh Chung Duy Thuc
- **Student ID:** ITCSIU22
- **Class:** [Your Class]

## Features Implemented

### Authentication
- ✅ User registration
- ✅ User login with JWT
- ✅ Logout
- ✅ Get current user
- ✅ Password hashing with BCrypt

### Authorization
- ✅ Role-based access control (USER, ADMIN)
- ✅ Protected endpoints
- ✅ Method-level security with @PreAuthorize

### Additional Features
- ✅ Change password
- ✅ Forgot password / Reset password
- ✅ User profile management
- ✅ Admin user management
- [ ] Refresh token
- [ ] Email verification (Bonus)

## API Endpoints

### Public Endpoints
- POST /api/auth/register
- POST /api/auth/login

### Protected Endpoints (Authenticated)
- GET /api/auth/me
- POST /api/auth/logout
- GET /api/customers
- GET /api/customers/{id}

### Admin Only Endpoints
- POST /api/customers
- PUT /api/customers/{id}
- DELETE /api/customers/{id}
- GET /api/admin/users
- PUT /api/admin/users/{id}/role

## Test Users
| Username | Password | Role |
|----------|----------|------|
| admin | password123 | ADMIN |
| john | password123 | USER |
| jane | password123 | USER |

## How to Run
1. Create database: `customer_management`
2. Run SQL scripts to create tables
3. Update `application.properties` with your MySQL credentials
4. Run: `mvn spring-boot:run`
5. Test with Thunder Client using provided collection

## Testing
Import Postman collection: `Secure_Customer_API.postman_collection.json`

All endpoints tested and working.

## Security
- Passwords hashed with BCrypt
- JWT tokens with 24-hour expiration
- Stateless authentication
- CORS enabled for frontend
- Protected endpoints with Spring Security

## Known Issues
- [List any bugs]

## Time Spent
Approximately [X] hours

3. Postman Collection:
Export complete collection with:

    Registration examples
    Login examples
    Protected endpoint examples with tokens
    Admin endpoint examples
    Error cases (401, 403)

4. Screenshots:

    Registration success (201 Created)
    Login success with token
    Access protected endpoint with token (200 OK)
    Access protected endpoint without token (401 Unauthorized)
    USER trying to delete (403 Forbidden)
    ADMIN successfully deleting (200 OK)
    Current user profile
    Change password success

5. Database Export:

    database.sql with users table and sample data

EVALUATION RUBRIC
In-Class (60 points):
Component 	Points
Project Setup & User Entity 	15
DTO & Repository 	10
JWT & Security Components 	20
Security Configuration 	15
Homework (40 points):
Exercise 	Points
Password Management 	12
User Profile Management 	10
Admin Endpoints 	10
Refresh Token 	8
Bonus (20 points):
Feature 	Points
Email Verification 	7
Login Activity Log 	6
Two-Factor Authentication 	7
Code Quality Deductions:

    No password hashing: -10
    Exposing passwords in responses: -10
    Hardcoded JWT secret: -5
    No validation on auth endpoints: -5
    Not using @PreAuthorize: -5
    Weak JWT secret (<256 bits): -3

Total Possible: 120 points (including bonus)
COMMON MISTAKES TO AVOID
❌ DON'T:

1. Return password in responses:

// DON'T include password in UserResponseDTO!
public class UserResponseDTO {
    private String username;
    private String password;  // ❌ SECURITY RISK!
}

2. Store plain text passwords:

// DON'T save plain password
user.setPassword(registerRequest.getPassword());  // ❌

3. Use weak JWT secret:

# DON'T use short secret
jwt.secret=secret  # ❌ Too short!

4. Forget to validate token:

// DON'T skip validation
String username = tokenProvider.getUsernameFromToken(token);
// ❌ What if token is invalid or expired?

✅ DO:

1. Exclude password from responses:

public class UserResponseDTO {
    private String username;
    private String email;
    // No password field ✅
}

2. Hash passwords:

user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));  // ✅

3. Use strong JWT secret:

jwt.secret=myVeryLongAndSecureSecretKeyThatIsAtLeast256BitsLongWithRandomCharacters  # ✅

4. Always validate tokens:

if (StringUtils.hasText(jwt) && tokenProvider.validateToken(jwt)) {
    // Token is valid ✅
}

TROUBLESHOOTING
Issue 1: 401 Unauthorized on public endpoints

Symptom: Cannot access /api/auth/login

Solution:

.authorizeHttpRequests(auth -> auth
    .requestMatchers("/api/auth/**").permitAll()  // Make sure this is present
    ...
)

Issue 2: JWT validation fails

Symptom: "Invalid JWT token" errors

Solution:

    Verify JWT secret in application.properties matches
    Check token format: "Bearer <token>"
    Ensure token hasn't expired
    Verify no extra spaces in header

Issue 3: Password authentication fails

Symptom: Login fails with correct password

Solution:

    Ensure password is hashed with BCrypt in database
    Check PasswordEncoder bean is configured
    Test password: passwordEncoder.matches(raw, hashed)

Issue 4: Role-based access not working

Symptom: User can access admin endpoints

Solution:

// Ensure role has "ROLE_" prefix in authorities
new SimpleGrantedAuthority("ROLE_" + user.getRole().name())

// Use hasRole() not hasAuthority()
@PreAuthorize("hasRole('ADMIN')")  // ✅
@PreAuthorize("hasAuthority('ADMIN')")  // ❌ Won't work

Issue 5: CORS errors from frontend

Solution:

@CrossOrigin(origins = "http://localhost:3000")
// Or in SecurityConfig:
.cors(cors -> cors.configurationSource(request -> {
    CorsConfiguration config = new CorsConfiguration();
    config.setAllowedOrigins(Arrays.asList("http://localhost:3000"));
    config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
    config.setAllowedHeaders(Arrays.asList("*"));
    return config;
}))

TESTING CHECKLIST
Authentication Flow:

✅ POST /api/auth/register

    Valid registration → 201 Created
    Duplicate username → 409 Conflict
    Invalid email → 400 Bad Request
    Weak password → 400 Bad Request

✅ POST /api/auth/login

    Valid credentials → 200 OK with token
    Invalid username → 401 Unauthorized
    Invalid password → 401 Unauthorized
    Inactive user → 401 Unauthorized

✅ GET /api/auth/me

    With valid token → 200 OK
    Without token → 401 Unauthorized
    With expired token → 401 Unauthorized

Authorization Flow:

✅ GET /api/customers (Any authenticated user)

    With USER token → 200 OK
    With ADMIN token → 200 OK
    Without token → 401 Unauthorized

✅ POST /api/customers (Admin only)

    With ADMIN token → 201 Created
    With USER token → 403 Forbidden
    Without token → 401 Unauthorized

✅ DELETE /api/customers/{id} (Admin only)

    With ADMIN token → 200 OK
    With USER token → 403 Forbidden
    Without token → 401 Unauthorized

Edge Cases:

✅ Token expiration handling
✅ Invalid token format
✅ Malformed JWT
✅ Missing Authorization header
✅ Wrong token signature
✅ Concurrent login sessions
✅ Password change with wrong current password
✅ Update profile with existing email
RESOURCES
Spring Security:

    Official Docs: https://spring.io/projects/spring-security
    Spring Security Architecture: https://spring.io/guides/topicals/spring-security-architecture
    Method Security: https://docs.spring.io/spring-security/reference/servlet/authorization/method-security.html

JWT:

    JWT.io: https://jwt.io/ (decode/verify tokens)
    JJWT Library: https://github.com/jwtk/jjwt
    JWT Best Practices: https://tools.ietf.org/html/rfc8725

BCrypt:

    BCrypt Explained: https://auth0.com/blog/hashing-in-action-understanding-bcrypt/
    Online BCrypt Generator: https://bcrypt-generator.com/

Testing:

    Postman: https://www.postman.com/
    Thunder Client: VS Code extension

SUMMARY
In-Class Checklist:

✅ Added Spring Security & JWT dependencies
✅ Created User entity and Role enum
✅ Implemented authentication DTOs
✅ Built JWT token provider
✅ Created JWT authentication filter
✅ Configured Spring Security
✅ Implemented login and register
✅ Protected endpoints with roles
Homework Checklist:

✅ Password management (change/reset)
✅ User profile management
✅ Admin user management
✅ Refresh token mechanism
✅ Complete API documentation
✅ Comprehensive testing
Key Takeaways:

    Spring Security is powerful - Handles authentication and authorization
    JWT is stateless - Perfect for REST APIs and microservices
    BCrypt is essential - Never store plain text passwords
    Role-based access works - @PreAuthorize provides method-level security
    Testing is critical - Test all auth flows and edge cases
    Security is hard - Follow best practices, never skip validation

Good luck with Lab 9! 🔐

Remember: Security is not optional. Always protect your users' data!

⚠️ SECURITY REMINDERS:

    ALWAYS hash passwords with BCrypt
    NEVER expose passwords in API responses
    ALWAYS use HTTPS in production
    NEVER commit JWT secrets to version control
    ALWAYS validate and sanitize user inputs
    ALWAYS set appropriate token expiration times
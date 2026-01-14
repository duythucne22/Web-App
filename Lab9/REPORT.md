# Lab 9 Report: Spring Security & JWT Authentication

**Course:** Web Application Development  
**Lab:** Lab 9 - Spring Security & JWT Authentication  
**Student:** Huynh Chung Duy Thuc  
**Date:** December 9, 2025

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Authentication Flow](#2-architecture--authentication-flow)
3. [Project Structure](#3-project-structure)
4. [Implementation Details](#4-implementation-details)
   - [4.1 Dependencies Setup](#41-dependencies-setup)
   - [4.2 Entity Layer](#42-entity-layer)
   - [4.3 DTO Layer](#43-dto-layer)
   - [4.4 Repository Layer](#44-repository-layer)
   - [4.5 Security Components](#45-security-components)
   - [4.6 Service Layer](#46-service-layer)
   - [4.7 Controller Layer](#47-controller-layer)
5. [Authentication Flow Diagram](#5-authentication-flow-diagram)
6. [API Endpoints](#6-api-endpoints)
7. [Security Features](#7-security-features)
8. [Testing Guide](#8-testing-guide)
9. [Summary](#9-summary)

---

## 1. Project Overview

This project implements a **Secure Customer Management REST API** with JWT (JSON Web Token) authentication using Spring Security. The application provides:

- **User Authentication**: Registration, login, and logout functionality
- **JWT Token Management**: Stateless authentication using JWT tokens
- **Role-Based Access Control (RBAC)**: USER and ADMIN roles with different permissions
- **Password Security**: BCrypt password hashing
- **Protected Endpoints**: Method-level security with `@PreAuthorize`

### Technologies Used

| Technology | Version | Purpose |
|------------|---------|---------|
| Spring Boot | 3.4.12 | Application Framework |
| Spring Security | 6.x | Security Framework |
| Spring Data JPA | 3.x | Database Operations |
| JWT (JJWT) | 0.12.3 | Token Generation/Validation |
| MySQL | 8.x | Database |
| Lombok | Latest | Boilerplate Reduction |
| Java | 21 | Programming Language |

---

## 2. Architecture & Authentication Flow

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              CLIENT                                      │
│                    (Thunder Client / Postman / Frontend)                 │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         SPRING SECURITY FILTER CHAIN                     │
│  ┌─────────────────────────────────────────────────────────────────────┐│
│  │                    JwtAuthenticationFilter                          ││
│  │  1. Extract JWT from Authorization header                           ││
│  │  2. Validate token using JwtTokenProvider                           ││
│  │  3. Load UserDetails from CustomUserDetailsService                  ││
│  │  4. Set Authentication in SecurityContext                           ││
│  └─────────────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                            CONTROLLER LAYER                              │
│  ┌────────────────────┐    ┌──────────────────────────┐                 │
│  │   AuthController   │    │   CustomerRestController  │                 │
│  │  - /api/auth/**    │    │   - /api/customers/**     │                 │
│  │  - Login/Register  │    │   - CRUD operations       │                 │
│  └────────────────────┘    └──────────────────────────┘                 │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                             SERVICE LAYER                                │
│  ┌────────────────────────┐    ┌────────────────────────────────────┐   │
│  │      UserService       │    │       CustomerService               │   │
│  │  - Authentication      │    │  - Customer CRUD operations         │   │
│  │  - Registration        │    │                                     │   │
│  └────────────────────────┘    └────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                           REPOSITORY LAYER                               │
│  ┌────────────────────────┐    ┌────────────────────────────────────┐   │
│  │    UserRepository      │    │     CustomerRepository              │   │
│  └────────────────────────┘    └────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              DATABASE                                    │
│                           MySQL - customer_management                    │
│                     [users table] [customers table]                      │
└─────────────────────────────────────────────────────────────────────────┘
```

### JWT Authentication Flow

```
┌────────────────────────────────────────────────────────────────────────────┐
│                         AUTHENTICATION FLOW                                 │
└────────────────────────────────────────────────────────────────────────────┘

1. LOGIN FLOW:
   ┌────────┐         ┌────────────────┐         ┌─────────────────┐
   │ Client │──POST──▶│ AuthController │──auth──▶│ UserServiceImpl │
   │        │ /login  │                │         │                 │
   └────────┘         └────────────────┘         └────────┬────────┘
                                                          │
                              ┌────────────────────────────┘
                              ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │  1. AuthenticationManager.authenticate(username, password)          │
   │  2. CustomUserDetailsService.loadUserByUsername()                   │
   │  3. BCrypt password verification                                    │
   │  4. JwtTokenProvider.generateToken(authentication)                  │
   │  5. Return LoginResponseDTO with JWT token                          │
   └─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
   ┌────────┐         ┌────────────────────────────────────────┐
   │ Client │◀────────│ { token: "eyJhbG...", type: "Bearer" } │
   └────────┘         └────────────────────────────────────────┘


2. ACCESSING PROTECTED ENDPOINTS:
   ┌────────┐                    ┌────────────────────────────┐
   │ Client │──GET /api/customers│ JwtAuthenticationFilter    │
   │        │  Authorization:    │                            │
   │        │  Bearer <token>    │ 1. Extract token           │
   └────────┘                    │ 2. Validate with provider  │
                                 │ 3. Load UserDetails        │
                                 │ 4. Set SecurityContext     │
                                 └─────────────┬──────────────┘
                                               │
                              ┌────────────────┘
                              ▼
   ┌─────────────────────────────────────────────────────────────────────┐
   │  SecurityContext now contains authenticated user                    │
   │  → @PreAuthorize("hasRole('ADMIN')") checks pass/fail               │
   │  → Controller method executes if authorized                         │
   └─────────────────────────────────────────────────────────────────────┘
```

---

## 3. Project Structure

```
customer-api/
├── pom.xml                                    # Maven dependencies
├── src/
│   ├── main/
│   │   ├── java/com/example/securecustomerapi/
│   │   │   ├── CustomerApiApplication.java   # Main entry point
│   │   │   │
│   │   │   ├── config/                        # Configuration
│   │   │   │   ├── RateLimitInterceptor.java
│   │   │   │   └── WebConfig.java
│   │   │   │
│   │   │   ├── controller/                    # REST Controllers
│   │   │   │   ├── AuthController.java        # Authentication endpoints
│   │   │   │   └── CustomerRestController.java# Customer CRUD endpoints
│   │   │   │
│   │   │   ├── dto/                           # Data Transfer Objects
│   │   │   │   ├── LoginRequestDTO.java
│   │   │   │   ├── LoginResponseDTO.java
│   │   │   │   ├── RegisterRequestDTO.java
│   │   │   │   ├── UserResponseDTO.java
│   │   │   │   ├── CustomerRequestDTO.java
│   │   │   │   ├── CustomerResponseDTO.java
│   │   │   │   ├── CustomerUpdateDTO.java
│   │   │   │   └── ErrorResponseDTO.java
│   │   │   │
│   │   │   ├── entity/                        # JPA Entities
│   │   │   │   ├── User.java
│   │   │   │   ├── Customer.java
│   │   │   │   └── enums/
│   │   │   │       ├── Role.java
│   │   │   │       └── CustomerStatus.java
│   │   │   │
│   │   │   ├── exception/                     # Exception Handling
│   │   │   │   ├── DuplicateResourceException.java
│   │   │   │   ├── GlobalExceptionHandler.java
│   │   │   │   └── ResourceNotFoundException.java
│   │   │   │
│   │   │   ├── repository/                    # Data Access Layer
│   │   │   │   ├── UserRepository.java
│   │   │   │   └── CustomerRepository.java
│   │   │   │
│   │   │   ├── security/                      # Security Components
│   │   │   │   ├── SecurityConfig.java        # Security configuration
│   │   │   │   ├── JwtTokenProvider.java      # JWT token operations
│   │   │   │   ├── JwtAuthenticationFilter.java# JWT filter
│   │   │   │   ├── JwtAuthenticationEntryPoint.java# 401 handler
│   │   │   │   └── JwtAccessDeniedHandler.java# 403 handler
│   │   │   │
│   │   │   └── service/                       # Business Logic
│   │   │       ├── UserService.java
│   │   │       ├── UserServiceImpl.java
│   │   │       ├── CustomUserDetailsService.java
│   │   │       ├── CustomerService.java
│   │   │       └── CustomerServiceImpl.java
│   │   │
│   │   └── resources/
│   │       └── application.properties         # App configuration
│   │
│   └── test/                                  # Test classes
└── target/                                    # Compiled classes
```

---

## 4. Implementation Details

### 4.1 Dependencies Setup

The `pom.xml` includes essential dependencies for security:

```xml
<!-- Spring Security - Core security framework -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- JWT API - Interface for JWT operations -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.3</version>
</dependency>

<!-- JWT Implementation - Core JWT functionality -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-impl</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>

<!-- JWT Jackson - JSON serialization for JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-jackson</artifactId>
    <version>0.12.3</version>
    <scope>runtime</scope>
</dependency>
```

**Configuration in `application.properties`:**

```properties
# JWT Configuration
jwt.secret=9e2208503780187928313e2c4bc82b76bfdb32bf3078b2572cd2b54787bbe9df
jwt.expiration=86400000  # 24 hours in milliseconds
```

---

### 4.2 Entity Layer

#### Role Enum (`Role.java`)

```java
package com.example.securecustomerapi.entity.enums;

public enum Role {
    USER,   // Regular user - can view customers
    ADMIN   // Admin - can perform all CRUD operations
}
```

**Purpose:** Defines the two roles in the system. The `ADMIN` role has elevated privileges.

#### User Entity (`User.java`)

```java
@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String username;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(nullable = false)
    private String password;  // BCrypt hashed

    @Column(name = "full_name")
    private String fullName;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Role role = Role.USER;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
```

**Key Points:**
| Annotation | Purpose |
|------------|---------|
| `@Entity` | Marks class as JPA entity |
| `@Table(name = "users")` | Maps to `users` database table |
| `@Column(unique = true)` | Ensures username/email uniqueness |
| `@Enumerated(EnumType.STRING)` | Stores role as string (USER/ADMIN) |
| `@CreatedDate`, `@LastModifiedDate` | Auto-populate timestamps |

---

### 4.3 DTO Layer

DTOs (Data Transfer Objects) separate API request/response from entity structure.

#### LoginRequestDTO

```java
@Getter @Setter
@AllArgsConstructor @NoArgsConstructor
public class LoginRequestDTO {

    @NotBlank(message = "Username is required")
    private String username;

    @NotBlank(message = "Password is required")
    private String password;
}
```

**Purpose:** Captures login credentials. `@NotBlank` ensures fields are not empty.

#### LoginResponseDTO

```java
@Getter @Setter
@AllArgsConstructor @NoArgsConstructor
public class LoginResponseDTO {
    private String token;           // JWT token
    private String type = "Bearer"; // Token type
    private String username;
    private String email;
    private String role;
}
```

**Purpose:** Returns JWT token and user info after successful login.

#### RegisterRequestDTO

```java
@Data
@NoArgsConstructor @AllArgsConstructor
public class RegisterRequestDTO {

    @NotBlank(message = "Username is required")
    @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
    private String username;

    @NotBlank(message = "Email is required")
    @Email(message = "Invalid email format")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 6, message = "Password must be at least 6 characters")
    private String password;

    @NotBlank(message = "Full name is required")
    @Size(min = 2, max = 100, message = "Full name must be 2-100 characters")
    private String fullName;
}
```

**Purpose:** Validates registration input with comprehensive validation rules.

#### UserResponseDTO

```java
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
public class UserResponseDTO {
    private Long id;
    private String username;
    private String email;
    private String fullName;
    private Role role;
    private Boolean isActive;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    // Note: NO password field - security best practice!
}
```

**Purpose:** Returns user info without exposing sensitive data like password.

---

### 4.4 Repository Layer

#### UserRepository

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // Find user by username (for authentication)
    Optional<User> findByUsername(String username);

    // Find user by email (for profile/validation)
    Optional<User> findByEmail(String email);

    // Check if username exists (for registration)
    Boolean existsByUsername(String username);

    // Check if email exists (for registration)
    Boolean existsByEmail(String email);
}
```

**Spring Data JPA Magic:**
- Method names are parsed to generate SQL queries automatically
- `findByUsername(String username)` → `SELECT * FROM users WHERE username = ?`
- `existsByEmail(String email)` → `SELECT COUNT(*) > 0 FROM users WHERE email = ?`

---

### 4.5 Security Components

#### JwtTokenProvider

This is the **core component** for JWT operations.

```java
@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.expiration}")
    private long jwtExpiration;

    // 1. GENERATE TOKEN
    public String generateToken(Authentication authentication) {
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + jwtExpiration);

        // Create secret key from string
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));

        return Jwts.builder()
                .subject(userDetails.getUsername())  // Store username in token
                .issuedAt(now)                       // Token creation time
                .expiration(expiryDate)              // Token expiry time
                .signWith(key)                       // Sign with secret key
                .compact();                          // Build token string
    }

    // 2. EXTRACT USERNAME FROM TOKEN
    public String getUsernameFromToken(String token) {
        SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));

        Claims claims = Jwts.parser()
                .verifyWith(key)           // Verify signature
                .build()
                .parseSignedClaims(token)  // Parse token
                .getPayload();             // Get claims

        return claims.getSubject();        // Return username
    }

    // 3. VALIDATE TOKEN
    public boolean validateToken(String token) {
        try {
            SecretKey key = Keys.hmacShaKeyFor(jwtSecret.getBytes(StandardCharsets.UTF_8));

            Jwts.parser()
                    .verifyWith(key)
                    .build()
                    .parseSignedClaims(token);

            return true;  // Token is valid
        } catch (MalformedJwtException ex) {
            System.out.println("Invalid JWT token");
        } catch (ExpiredJwtException ex) {
            System.out.println("Expired JWT token");
        } catch (UnsupportedJwtException ex) {
            System.out.println("Unsupported JWT token");
        } catch (IllegalArgumentException ex) {
            System.out.println("JWT claims string is empty");
        }
        return false;  // Token is invalid
    }
}
```

**JWT Token Structure:**
```
eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTcwMjE0NDAwMCwiZXhwIjoxNzAyMjMwNDAwfQ.xyz123...
│                    │                                                                      │
└─────HEADER─────────┴──────────────────────PAYLOAD─────────────────────────────────────────┴─────SIGNATURE─────
```

| Part | Content |
|------|---------|
| Header | Algorithm (HS256) and type (JWT) |
| Payload | Subject (username), issued at, expiration |
| Signature | HMAC-SHA256 hash for verification |

---

#### JwtAuthenticationFilter

This filter intercepts **every request** to validate JWT tokens.

```java
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Autowired
    private CustomUserDetailsService customUserDetailsService;

    // Skip filter for auth endpoints (login/register don't need tokens)
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/api/auth/");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        try {
            // 1. Extract JWT from "Authorization: Bearer <token>" header
            String jwt = getJwtFromRequest(request);

            // 2. Validate token and set authentication
            if (StringUtils.hasText(jwt) && tokenProvider.validateToken(jwt)) {
                // 3. Get username from token
                String username = tokenProvider.getUsernameFromToken(jwt);

                // 4. Load user details from database
                UserDetails userDetails = customUserDetailsService.loadUserByUsername(username);

                // 5. Create authentication object
                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(
                        userDetails, null, userDetails.getAuthorities());

                authentication.setDetails(
                    new WebAuthenticationDetailsSource().buildDetails(request));

                // 6. Set authentication in SecurityContext
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception ex) {
            logger.error("Could not set user authentication", ex);
        }

        // Continue filter chain
        filterChain.doFilter(request, response);
    }

    // Extract token from Authorization header
    private String getJwtFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");

        if (StringUtils.hasText(bearerToken) && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);  // Remove "Bearer " prefix
        }
        return null;
    }
}
```

**Filter Flow:**
```
Request comes in
        │
        ▼
┌───────────────────────────┐
│ Is path /api/auth/** ?    │
│                           │
│   YES → Skip filter       │
│   NO  → Continue          │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ Extract Authorization     │
│ header                    │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ Has "Bearer " prefix?     │
│                           │
│   NO  → Continue (401)    │
│   YES → Extract token     │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ Validate token            │
│                           │
│   Invalid → Continue (401)│
│   Valid   → Set auth      │
└───────────────────────────┘
        │
        ▼
┌───────────────────────────┐
│ Continue to controller    │
└───────────────────────────┘
```

---

#### CustomUserDetailsService

Bridges Spring Security with our User entity.

```java
@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        // Find user in database
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new UsernameNotFoundException("User not found: " + username));

        // Convert to Spring Security User object
        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                user.getIsActive(),    // enabled
                true,                   // accountNonExpired
                true,                   // credentialsNonExpired
                true,                   // accountNonLocked
                getAuthorities(user));  // roles/authorities
    }

    // Convert Role to GrantedAuthority
    private Collection<? extends GrantedAuthority> getAuthorities(User user) {
        // Spring Security requires "ROLE_" prefix for hasRole() checks
        return Collections.singletonList(
                new SimpleGrantedAuthority("ROLE_" + user.getRole().name()));
    }
}
```

**Important:** The `"ROLE_"` prefix is required for `hasRole('ADMIN')` to work. Spring Security automatically adds this prefix when checking roles.

---

#### SecurityConfig

The main configuration class for Spring Security.

```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity  // Enables @PreAuthorize
public class SecurityConfig {

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private JwtAuthenticationEntryPoint authenticationEntryPoint;

    @Autowired
    private JwtAccessDeniedHandler accessDeniedHandler;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    // Password encoder bean - BCrypt is industry standard
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // Authentication manager for login
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) 
            throws Exception {
        return authConfig.getAuthenticationManager();
    }

    // DAO authentication provider
    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    // Main security filter chain configuration
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Disable CSRF (not needed for stateless JWT)
            .csrf(csrf -> csrf.disable())
            
            // Exception handling
            .exceptionHandling(exception -> exception
                    .authenticationEntryPoint(authenticationEntryPoint)  // 401 handler
                    .accessDeniedHandler(accessDeniedHandler))           // 403 handler
            
            // Stateless session (no server-side session)
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            
            // Authorization rules
            .authorizeHttpRequests(auth -> auth
                    // Public endpoints - no authentication required
                    .requestMatchers("/api/auth/**").permitAll()
                    
                    // Customer endpoints - role-based access
                    .requestMatchers(HttpMethod.GET, "/api/customers/**").authenticated()
                    .requestMatchers(HttpMethod.POST, "/api/customers/**").hasRole("ADMIN")
                    .requestMatchers(HttpMethod.PUT, "/api/customers/**").hasRole("ADMIN")
                    .requestMatchers(HttpMethod.DELETE, "/api/customers/**").hasRole("ADMIN")
                    
                    // All other requests need authentication
                    .anyRequest().authenticated());

        // Add custom authentication provider
        http.authenticationProvider(authenticationProvider());
        
        // Add JWT filter before UsernamePasswordAuthenticationFilter
        http.addFilterBefore(jwtAuthenticationFilter, 
                UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
```

**Authorization Rules Explained:**

| Endpoint Pattern | Method | Access Level |
|------------------|--------|--------------|
| `/api/auth/**` | ALL | Public (no auth) |
| `/api/customers/**` | GET | Any authenticated user |
| `/api/customers/**` | POST | ADMIN only |
| `/api/customers/**` | PUT | ADMIN only |
| `/api/customers/**` | DELETE | ADMIN only |
| Everything else | ALL | Authenticated |

---

#### JwtAuthenticationEntryPoint (401 Handler)

```java
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request,
            HttpServletResponse response,
            AuthenticationException authException) throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);  // 401

        Map<String, Object> data = new HashMap<>();
        data.put("timestamp", LocalDateTime.now().toString());
        data.put("status", HttpServletResponse.SC_UNAUTHORIZED);
        data.put("error", "Unauthorized");
        data.put("message", "Authentication required. Please provide valid JWT token.");
        data.put("path", request.getRequestURI());

        ObjectMapper objectMapper = new ObjectMapper();
        response.getWriter().write(objectMapper.writeValueAsString(data));
    }
}
```

**Response Example (401):**
```json
{
    "timestamp": "2025-12-09T10:30:00",
    "status": 401,
    "error": "Unauthorized",
    "message": "Authentication required. Please provide valid JWT token.",
    "path": "/api/customers"
}
```

---

#### JwtAccessDeniedHandler (403 Handler)

```java
@Component
public class JwtAccessDeniedHandler implements AccessDeniedHandler {

    @Override
    public void handle(HttpServletRequest request,
            HttpServletResponse response,
            AccessDeniedException accessDeniedException) throws IOException {

        response.setContentType("application/json;charset=UTF-8");
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);  // 403

        Map<String, Object> data = new HashMap<>();
        data.put("timestamp", LocalDateTime.now().toString());
        data.put("status", HttpServletResponse.SC_FORBIDDEN);
        data.put("error", "Forbidden");
        data.put("message", "Access denied. You don't have permission.");
        data.put("path", request.getRequestURI());

        ObjectMapper objectMapper = new ObjectMapper();
        response.getWriter().write(objectMapper.writeValueAsString(data));
    }
}
```

**Response Example (403):**
```json
{
    "timestamp": "2025-12-09T10:30:00",
    "status": 403,
    "error": "Forbidden",
    "message": "Access denied. You don't have permission to access this resource.",
    "path": "/api/customers"
}
```

---

### 4.6 Service Layer

#### UserService Interface

```java
public interface UserService {
    LoginResponseDTO login(LoginRequestDTO loginRequest);
    UserResponseDTO register(RegisterRequestDTO registerRequest);
    UserResponseDTO getCurrentUser(String username);
}
```

#### UserServiceImpl

```java
@Service
@Transactional
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider tokenProvider;

    @Override
    public LoginResponseDTO login(LoginRequestDTO loginRequest) {
        try {
            // 1. Authenticate with Spring Security
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            loginRequest.getUsername(),
                            loginRequest.getPassword()));

            // 2. Set authentication in SecurityContext
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // 3. Generate JWT token
            String token = tokenProvider.generateToken(authentication);

            // 4. Get user details for response
            User user = userRepository.findByUsername(loginRequest.getUsername())
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));

            // 5. Return response with token
            return new LoginResponseDTO(
                    token,
                    "Bearer",
                    user.getUsername(),
                    user.getEmail(),
                    user.getRole().name());
                    
        } catch (BadCredentialsException e) {
            throw new RuntimeException("Invalid username or password");
        }
    }

    @Override
    public UserResponseDTO register(RegisterRequestDTO registerRequest) {
        // 1. Check for duplicate username
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            throw new DuplicateResourceException("Username already exists");
        }

        // 2. Check for duplicate email
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new DuplicateResourceException("Email already exists");
        }

        // 3. Create new user with hashed password
        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setEmail(registerRequest.getEmail());
        user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));  // BCrypt!
        user.setFullName(registerRequest.getFullName());
        user.setRole(Role.USER);  // Default role
        user.setIsActive(true);

        // 4. Save and return
        User savedUser = userRepository.save(user);
        return convertToDTO(savedUser);
    }

    @Override
    public UserResponseDTO getCurrentUser(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return convertToDTO(user);
    }

    private UserResponseDTO convertToDTO(User user) {
        return new UserResponseDTO(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getFullName(),
                user.getRole(),
                user.getIsActive(),
                user.getCreatedAt(),
                user.getUpdatedAt());
    }
}
```

---

### 4.7 Controller Layer

#### AuthController

```java
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    // POST /api/auth/login
    @PostMapping("/login")
    public ResponseEntity<LoginResponseDTO> login(@Valid @RequestBody LoginRequestDTO loginRequest) {
        LoginResponseDTO response = userService.login(loginRequest);
        return ResponseEntity.ok(response);
    }

    // POST /api/auth/register
    @PostMapping("/register")
    public ResponseEntity<UserResponseDTO> register(@Valid @RequestBody RegisterRequestDTO registerRequest) {
        UserResponseDTO response = userService.register(registerRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // GET /api/auth/me - Get current authenticated user
    @GetMapping("/me")
    public ResponseEntity<UserResponseDTO> getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String username = authentication.getName();
        UserResponseDTO user = userService.getCurrentUser(username);
        return ResponseEntity.ok(user);
    }

    // POST /api/auth/logout
    @PostMapping("/logout")
    public ResponseEntity<Map<String, String>> logout() {
        // JWT is stateless - logout is handled client-side
        Map<String, String> response = new HashMap<>();
        response.put("message", "Logged out successfully. Please remove token from client.");
        return ResponseEntity.ok(response);
    }
}
```

#### CustomerRestController (with Security)

```java
@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class CustomerRestController {

    private final CustomerService customerService;

    // GET - Any authenticated user can access
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllCustomers(...) {
        // Implementation
    }

    @GetMapping("/{id}")
    public ResponseEntity<CustomerResponseDTO> getCustomerById(@PathVariable Long id) {
        // Implementation
    }

    // POST - Admin only
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")  // Method-level security
    public ResponseEntity<CustomerResponseDTO> createCustomer(
            @Valid @RequestBody CustomerRequestDTO requestDTO) {
        // Only ADMIN role can reach here
    }

    // PUT - Admin only
    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CustomerResponseDTO> updateCustomer(
            @PathVariable Long id,
            @Valid @RequestBody CustomerRequestDTO requestDTO) {
        // Only ADMIN role can reach here
    }

    // DELETE - Admin only
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, String>> deleteCustomer(@PathVariable Long id) {
        // Only ADMIN role can reach here
    }

    // PATCH - Admin only
    @PatchMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<CustomerResponseDTO> partialUpdateCustomer(
            @PathVariable Long id,
            @Valid @RequestBody CustomerUpdateDTO updateDTO) {
        // Only ADMIN role can reach here
    }
}
```

---

## 5. Authentication Flow Diagram

### Login Flow

```
┌─────────┐                ┌──────────────┐              ┌─────────────────┐
│ Client  │                │AuthController│              │ UserServiceImpl │
└────┬────┘                └──────┬───────┘              └────────┬────────┘
     │                            │                               │
     │  POST /api/auth/login      │                               │
     │  {username, password}      │                               │
     │───────────────────────────▶│                               │
     │                            │                               │
     │                            │  login(LoginRequestDTO)       │
     │                            │──────────────────────────────▶│
     │                            │                               │
     │                            │         ┌─────────────────────┴─────────────────────┐
     │                            │         │ 1. AuthenticationManager.authenticate()  │
     │                            │         │ 2. CustomUserDetailsService.loadUser()   │
     │                            │         │ 3. BCrypt.matches(password, hash)        │
     │                            │         │ 4. JwtTokenProvider.generateToken()      │
     │                            │         └─────────────────────┬─────────────────────┘
     │                            │                               │
     │                            │  LoginResponseDTO             │
     │                            │◀──────────────────────────────│
     │                            │                               │
     │  200 OK                    │                               │
     │  {token, type, user...}    │                               │
     │◀───────────────────────────│                               │
     │                            │                               │
```

### Protected Resource Access Flow

```
┌─────────┐          ┌───────────────────┐          ┌──────────────┐          ┌──────────────┐
│ Client  │          │JwtAuthFilter      │          │SecurityConfig│          │Controller    │
└────┬────┘          └─────────┬─────────┘          └──────┬───────┘          └──────┬───────┘
     │                         │                           │                         │
     │  GET /api/customers     │                           │                         │
     │  Authorization: Bearer  │                           │                         │
     │  eyJhbG...              │                           │                         │
     │────────────────────────▶│                           │                         │
     │                         │                           │                         │
     │         ┌───────────────┴───────────────┐           │                         │
     │         │ 1. Extract token from header  │           │                         │
     │         │ 2. Validate with JwtProvider  │           │                         │
     │         │ 3. Get username from token    │           │                         │
     │         │ 4. Load UserDetails           │           │                         │
     │         │ 5. Create Authentication      │           │                         │
     │         │ 6. Set SecurityContext        │           │                         │
     │         └───────────────┬───────────────┘           │                         │
     │                         │                           │                         │
     │                         │  filterChain.doFilter()   │                         │
     │                         │──────────────────────────▶│                         │
     │                         │                           │                         │
     │                         │           ┌───────────────┴───────────────┐         │
     │                         │           │ Check authorization rules:    │         │
     │                         │           │ - /api/customers GET needs    │         │
     │                         │           │   authenticated() ✓           │         │
     │                         │           └───────────────┬───────────────┘         │
     │                         │                           │                         │
     │                         │                           │  Dispatch to controller │
     │                         │                           │────────────────────────▶│
     │                         │                           │                         │
     │                         │                           │  Response               │
     │◀──────────────────────────────────────────────────────────────────────────────│
     │                         │                           │                         │
```

---

## 6. API Endpoints

### Authentication Endpoints

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/auth/register` | Public | Register new user |
| POST | `/api/auth/login` | Public | Login and get JWT token |
| GET | `/api/auth/me` | Authenticated | Get current user info |
| POST | `/api/auth/logout` | Authenticated | Logout (client-side) |

### Customer Endpoints

| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/customers` | USER, ADMIN | List all customers |
| GET | `/api/customers/{id}` | USER, ADMIN | Get customer by ID |
| POST | `/api/customers` | ADMIN only | Create customer |
| PUT | `/api/customers/{id}` | ADMIN only | Update customer |
| PATCH | `/api/customers/{id}` | ADMIN only | Partial update |
| DELETE | `/api/customers/{id}` | ADMIN only | Delete customer |
| GET | `/api/customers/search` | USER, ADMIN | Search customers |
| GET | `/api/customers/status/{status}` | USER, ADMIN | Filter by status |

---

## 7. Security Features

### 1. Password Hashing (BCrypt)

```java
// During registration
user.setPassword(passwordEncoder.encode(registerRequest.getPassword()));

// Example: "password123" becomes:
// $2a$10$XptfskLsT1l/bRTLRiiCgejHqOpgXFreUnNUa35gJdCr2v2QbVFzu
```

BCrypt features:
- **Salt**: Automatically generated and stored in hash
- **Cost Factor**: 10 rounds (2^10 = 1024 iterations)
- **One-way**: Cannot be reversed to get original password

### 2. Stateless JWT Authentication

- No server-side session storage
- Token contains all necessary information
- Scalable across multiple servers
- Token expiration: 24 hours (86400000 ms)

### 3. Role-Based Access Control

| Role | Permissions |
|------|-------------|
| USER | View customers, view profile |
| ADMIN | All USER permissions + Create/Update/Delete customers |

### 4. Security Headers

- CSRF disabled (stateless API)
- CORS enabled for frontend
- Proper error responses (401, 403)

---

## 8. Testing Guide

### Test Users

| Username | Password | Role |
|----------|----------|------|
| admin | password123 | ADMIN |
| john | password123 | USER |
| jane | password123 | USER |

### Test Scenarios

#### 1. Register New User
```
POST /api/auth/register
Content-Type: application/json

{
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "password123",
    "fullName": "New User"
}

Expected: 201 Created
```

#### 2. Login
```
POST /api/auth/login
Content-Type: application/json

{
    "username": "admin",
    "password": "password123"
}

Expected: 200 OK with JWT token
```

#### 3. Access Protected Endpoint (with token)
```
GET /api/customers
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

Expected: 200 OK with customer list
```

#### 4. Access Protected Endpoint (without token)
```
GET /api/customers

Expected: 401 Unauthorized
```

#### 5. USER Trying to Delete (Forbidden)
```
DELETE /api/customers/1
Authorization: Bearer <USER_TOKEN>

Expected: 403 Forbidden
```

#### 6. ADMIN Deleting (Success)
```
DELETE /api/customers/1
Authorization: Bearer <ADMIN_TOKEN>

Expected: 200 OK
```

---

## 9. Summary

### What Was Implemented

| Exercise | Component | Status |
|----------|-----------|--------|
| 1.1 | Security Dependencies | ✅ |
| 1.2 | User Entity & Role Enum | ✅ |
| 1.3 | Database Setup | ✅ |
| 2.1 | Authentication DTOs | ✅ |
| 2.2 | UserRepository | ✅ |
| 3.1 | JwtTokenProvider | ✅ |
| 3.2 | JwtAuthenticationFilter | ✅ |
| 3.3 | CustomUserDetailsService | ✅ |
| 4.1 | SecurityConfig | ✅ |
| 4.2 | AuthenticationEntryPoint | ✅ |
| 5.1 | UserService | ✅ |
| 5.2 | AuthController | ✅ |
| 5.3 | @PreAuthorize on CustomerController | ✅ |

### Key Concepts Learned

1. **Spring Security Filter Chain**: Understanding how requests flow through security filters
2. **JWT Token Lifecycle**: Generation, validation, and extraction of user information
3. **BCrypt Password Hashing**: Secure storage of passwords
4. **Role-Based Access Control**: Restricting endpoints based on user roles
5. **Method-Level Security**: Using `@PreAuthorize` for fine-grained access control
6. **Stateless Authentication**: Understanding JWT's stateless nature
7. **Exception Handling**: Custom 401 and 403 error responses

### Security Best Practices Applied

✅ Passwords hashed with BCrypt  
✅ Passwords never exposed in API responses  
✅ JWT secret is 256+ bits  
✅ Token validation on every request  
✅ Proper HTTP status codes (401, 403)  
✅ CORS configured for frontend  
✅ Stateless session management  
✅ Role-based endpoint protection  

---

**End of Report**

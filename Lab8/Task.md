# Lab 8 Exercises: REST API & DTO Pattern

**Course:** Web Application Development  
**Lab Duration:** 2.5 hours  
**Total Points:** 100 points (In-class: 60 points, Homework: 40 points)

---

## Before you start (Prerequisites)
- ✅ Completed Lab 7 (Spring Boot + JPA CRUD)  
- ✅ Read Lab 8 Setup Guide  
- ✅ Understanding of HTTP methods and status codes  
- ✅ Thunder Client or Postman installed (for testing)  
- ✅ MySQL running with database ready

**Software**
- Java: JDK 17+  
- IDE: VS Code with Spring extensions  
- API Testing: Thunder Client or Postman  
- Database: MySQL 8.0+

---

## Lab Objectives
By the end of this lab, you should be able to:
- Build RESTful APIs with `@RestController`
- Implement DTO pattern for request/response
- Use HTTP methods correctly (GET, POST, PUT, DELETE, PATCH)
- Handle exceptions with `@RestControllerAdvice`
- Validate inputs with `@Valid`
- Test APIs with REST clients
- Return proper HTTP status codes

---

# Part A: In-Class Exercises (60 points)

_Time Allocation: 2.5 hours_  
_Submission: Demonstrate API endpoints to instructor_

## Exercise 1: Project Setup & Entity (15 points)

**Estimated Time:** 25 minutes

### Task 1.1: Create Spring Boot Project (5 points)
Use Spring Initializr with:
- Spring Boot: 3.3.x
- Group: `com.example`
- Artifact: `customer-api`
- Java: 17

Dependencies:
- Spring Web
- Spring Data JPA
- MySQL Driver
- Validation

Evaluation: project creation, dependencies, structure (5 points)

### Task 1.2: Database Setup (5 points)
Create DB and table:

```sql
CREATE DATABASE customer_management;
USE customer_management;

CREATE TABLE customers (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  customer_code VARCHAR(20) UNIQUE NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  status ENUM('ACTIVE', 'INACTIVE') DEFAULT 'ACTIVE',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO customers (customer_code, full_name, email, phone, address, status) VALUES
('C001', 'John Doe', 'john.doe@example.com', '+1-555-0101', '123 Main St, New York', 'ACTIVE'),
('C002', 'Jane Smith', 'jane.smith@example.com', '+1-555-0102', '456 Oak Ave, Los Angeles', 'ACTIVE'),
('C003', 'Bob Johnson', 'bob.johnson@example.com', '+1-555-0103', '789 Pine Rd, Chicago', 'ACTIVE');
```

Example `application.properties`:

```
spring.application.name=customer-api
server.port=8080

spring.datasource.url=jdbc:mysql://localhost:3306/customer_management?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=password

spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
```

### Task 1.3: Create Customer Entity (5 points)
File: `src/main/java/com/example/customerapi/entity/Customer.java`

- Add `@Entity`, `@Table`
- Use `@Id`, `@GeneratedValue` for `id`
- Add `@Column` constraints for fields
- Add `@Enumerated` for status and lifecycle callbacks `@PrePersist`, `@PreUpdate`
- Create `CustomerStatus` enum `{ ACTIVE, INACTIVE }`

Evaluation: JPA annotations, lifecycle callbacks, getters/setters, enum

Checkpoint #1: Run the application to verify mapping.

---

## Exercise 2: DTO Layer (15 points)

**Estimated Time:** 30 minutes

### Task 2.1: Create Request DTO (5 points)
File: `src/main/java/com/example/customerapi/dto/CustomerRequestDTO.java`

Validation requirements:
- `customerCode`: `@NotBlank`, `@Size(3,20)`, `@Pattern("^C\\d{3,}$")`
- `fullName`: `@NotBlank`, `@Size(2,100)`
- `email`: `@NotBlank`, `@Email`
- `phone`: `@Pattern("^\\+?[0-9]{10,20}$")`
- `address`: `@Size(max=500)`

No `id` field. Add constructors, getters, setters.

### Task 2.2: Create Response DTO (5 points)
File: `src/main/java/com/example/customerapi/dto/CustomerResponseDTO.java`

Fields:
- `Long id`
- `String customerCode`
- `String fullName`
- `String email`
- `String phone`
- `String address`
- `String status`
- `LocalDateTime createdAt`

Add constructors, getters, setters.

### Task 2.3: Create Error Response DTO (5 points)
File: `src/main/java/com/example/customerapi/dto/ErrorResponseDTO.java`

Fields:
- `LocalDateTime timestamp` (auto-generated)
- `int status`
- `String error`
- `String message`
- `String path`
- `List<String> details`

Add constructors (default timestamp) and getters/setters.

Checkpoint #2: Ensure DTO classes compile.

---

## Exercise 3: Repository & Service (10 points)

**Estimated Time:** 20 minutes

### Task 3.1: Create Repository (3 points)
File: `src/main/java/com/example/customerapi/repository/CustomerRepository.java`

Extend `JpaRepository<Customer, Long>` and add methods:
- `Optional<Customer> findByCustomerCode(String code);`
- `Optional<Customer> findByEmail(String email);`
- `boolean existsByCustomerCode(String code);`
- `boolean existsByEmail(String email);`
- `List<Customer> findByStatus(CustomerStatus status);`

### Task 3.2: Service Interface (2 points)
File: `src/main/java/com/example/customerapi/service/CustomerService.java`
Include standard CRUD methods:
- `List<CustomerResponseDTO> getAllCustomers();`
- `CustomerResponseDTO getCustomerById(Long id);`
- `CustomerResponseDTO createCustomer(CustomerRequestDTO requestDTO);`
- `CustomerResponseDTO updateCustomer(Long id, CustomerRequestDTO requestDTO);`
- `void deleteCustomer(Long id);`

### Task 3.3: Implement Service (5 points)
File: `src/main/java/com/example/customerapi/service/CustomerServiceImpl.java`
- Implement repository calls and conversions
- Throw `ResourceNotFoundException` and `DuplicateResourceException` where appropriate
- Add helper methods to convert between Entity and DTO

Checkpoint #3: Test service methods.

---

## Exercise 4: REST Controller (20 points)

**Estimated Time:** 50 minutes

### Task 4.1: Create Basic REST Controller (10 points)
File: `src/main/java/com/example/customerapi/controller/CustomerRestController.java`

- Add `@RestController`, `@RequestMapping("/api/customers")`, `@CrossOrigin(origins = "*")`
- Inject `CustomerService`
- Endpoints:
  - `GET /api/customers` -> list customers
  - `GET /api/customers/{id}` -> single customer
  - `POST /api/customers` -> create (201)
  - `PUT /api/customers/{id}` -> update
  - `DELETE /api/customers/{id}` -> delete (return message)

Example snippets:

```java
@GetMapping
public ResponseEntity<List<CustomerResponseDTO>> getAllCustomers() {
    List<CustomerResponseDTO> customers = customerService.getAllCustomers();
    return ResponseEntity.ok(customers);
}

@PostMapping
public ResponseEntity<CustomerResponseDTO> createCustomer(@Valid @RequestBody CustomerRequestDTO dto) {
    CustomerResponseDTO created = customerService.createCustomer(dto);
    return ResponseEntity.status(HttpStatus.CREATED).body(created);
}

@DeleteMapping("/{id}")
public ResponseEntity<Map<String, String>> deleteCustomer(@PathVariable Long id) {
    customerService.deleteCustomer(id);
    Map<String, String> response = new HashMap<>();
    response.put("message", "Customer deleted successfully");
    return ResponseEntity.ok(response);
}
```

### Task 4.2: Add Exception Handling (10 points)
Create exceptions:

- `ResourceNotFoundException extends RuntimeException`
- `DuplicateResourceException extends RuntimeException`

Implement global handler:
File: `src/main/java/com/example/customerapi/exception/GlobalExceptionHandler.java`

- Annotate with `@RestControllerAdvice`
- Handle:
  - `ResourceNotFoundException` -> 404
  - `DuplicateResourceException` -> 409
  - `MethodArgumentNotValidException` -> 400 (collect field errors)
  - `Exception` -> 500

Use `ErrorResponseDTO` to structure error responses.

Checkpoint #4: Test all endpoints with Thunder Client.

---

# Part B: Homework Exercises (40 points)

## Exercise 5: Search & Filter Endpoints (12 points)

### Task 5.1: Search Customers (6 points)
Add repository method:

```java
@Query("SELECT c FROM Customer c WHERE " +
       "LOWER(c.fullName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
       "LOWER(c.email) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
       "LOWER(c.customerCode) LIKE LOWER(CONCAT('%', :keyword, '%'))")
List<Customer> searchCustomers(@Param("keyword") String keyword);
```

Service: `List<CustomerResponseDTO> searchCustomers(String keyword);`

Controller:

```java
@GetMapping("/search")
public ResponseEntity<List<CustomerResponseDTO>> searchCustomers(@RequestParam String keyword) {
    return ResponseEntity.ok(customerService.searchCustomers(keyword));
}
```

Test: `GET /api/customers/search?keyword=john`

### Task 5.2: Filter by Status (3 points)
Controller:

```java
@GetMapping("/status/{status}")
public ResponseEntity<List<CustomerResponseDTO>> getCustomersByStatus(@PathVariable String status) {
    return ResponseEntity.ok(customerService.getCustomersByStatus(status));
}
```

Test: `/api/customers/status/ACTIVE`

### Task 5.3: Advanced Search (3 points)
Controller:

```java
@GetMapping("/advanced-search")
public ResponseEntity<List<CustomerResponseDTO>> advancedSearch(
    @RequestParam(required = false) String name,
    @RequestParam(required = false) String email,
    @RequestParam(required = false) String status) {
    return ResponseEntity.ok(customerService.advancedSearch(name, email, status));
}
```

---

## Exercise 6: Pagination & Sorting (10 points)

### Task 6.1: Pagination (5 points)
Service should support `Page<CustomerResponseDTO> getAllCustomers(int page, int size)`.

Controller example:

```java
@GetMapping
public ResponseEntity<Map<String, Object>> getAllCustomers(
    @RequestParam(defaultValue = "0") int page,
    @RequestParam(defaultValue = "10") int size) {

    Page<CustomerResponseDTO> customerPage = customerService.getAllCustomers(page, size);

    Map<String, Object> response = new HashMap<>();
    response.put("customers", customerPage.getContent());
    response.put("currentPage", customerPage.getNumber());
    response.put("totalItems", customerPage.getTotalElements());
    response.put("totalPages", customerPage.getTotalPages());

    return ResponseEntity.ok(response);
}
```

### Task 6.2: Sorting (3 points)
Add `sortBy` and `sortDir` params or accept a `Sort`/`Pageable` in service.

### Task 6.3: Combine Pagination + Sorting (2 points)
Support query: `GET /api/customers?page=0&size=5&sortBy=fullName&sortDir=asc`

---

## Exercise 7: Partial Update with PATCH (10 points)

### Task 7.1: Update DTO (3 points)
Create `CustomerUpdateDTO` with optional fields:
- `fullName`, `email`, `phone`, `address`

### Task 7.2: Implement PATCH Endpoint (5 points)
Controller:

```java
@PatchMapping("/{id}")
public ResponseEntity<CustomerResponseDTO> partialUpdateCustomer(
    @PathVariable Long id,
    @RequestBody CustomerUpdateDTO updateDTO) {

    return ResponseEntity.ok(customerService.partialUpdateCustomer(id, updateDTO));
}
```

Service should update only non-null fields and save.

### Task 7.3: Test PUT vs PATCH (2 points)
Examples provided in Task.

---

## Exercise 8: API Documentation (8 points)

### Task 8.1: Create Postman Collection (4 points)
Export as `Customer_API.postman_collection.json` with all endpoints.

### Task 8.2: Document API Responses (2 points)
Create `API_DOCUMENTATION.md` describing base URL, endpoints, and response examples.

### Task 8.3: Add Examples for Status Codes (2 points)
Include examples for: 200, 201, 400, 404, 409, 500.

---

## Bonus Exercises (Optional)
- API Versioning (v1/v2 controllers)  
- HATEOAS links (add dependency and extend response DTOs)  
- Rate limiting with Bucket4j and an interceptor

---

## Homework Submission Guidelines
Project ZIP layout example, README template, testing checklist, resources, and known issues are included. Follow the checklist to prepare submission files.

---

## Troubleshooting (Common Issues)
- 404 endpoints: verify `@RestController`, mapping, and app running
- Validation not working: ensure `@Valid` and validation dependency; check global handler
- JSON parsing errors: Content-Type header; DTO getters/setters
- CORS: use `@CrossOrigin` or WebMvcConfigurer

---

## Testing Checklist (examples)
- ✅ GET /api/customers -> 200
- ✅ GET /api/customers/1 -> 200
- ✅ POST /api/customers -> 201
- ✅ POST validation error -> 400
- ✅ Duplicate -> 409
- ✅ PUT update -> 200
- ✅ DELETE -> 200
- ✅ Search and pagination tests

---

## Resources
- REST API Tutorial: https://restfulapi.net/  
- Spring REST Guides: https://spring.io/guides/gs/rest-service/  
- Spring HATEOAS: https://spring.io/projects/spring-hateoas  
- Postman / Thunder Client links

---

## Summary
This document guides you through creating a Customer REST API using Spring Boot, JPA, DTO pattern, validation, exception handling, search/filtering, pagination/sorting, PATCH updates, documentation, and optional bonus features.
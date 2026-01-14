# API Documentation - Customer Management System

## Base URL
`http://localhost:8080/api/customers`

## Endpoints

### 1. Get All Customers (List)
- **Method:** `GET`
- **URL:** `/api/customers`
- **Description:** Retrieves a list of all customers.
- **Response:** `200 OK` (List of CustomerResponseDTO)

### 2. Get All Customers (Pagination & Sorting) - Exercise 6
- **Method:** `GET`
- **URL:** `/api/customers?page={page}&size={size}&sortBy={field}&sortDir={asc|desc}`
- **Parameters:**
  - `page` (int): Page number (0-indexed)
  - `size` (int): Number of items per page
  - `sortBy` (string): Field to sort by (e.g., `fullName`, `email`)
  - `sortDir` (string): Sort direction (`asc` or `desc`)
- **Example:** `/api/customers?page=0&size=5&sortBy=fullName&sortDir=asc`
- **Response:** `200 OK` (Page object with content and metadata)

### 3. Get Customer by ID
- **Method:** `GET`
- **URL:** `/api/customers/{id}`
- **Response:** `200 OK` or `404 Not Found`

### 4. Create Customer
- **Method:** `POST`
- **URL:** `/api/customers`
- **Body:** `CustomerRequestDTO` (JSON)
- **Response:** `201 Created` or `400 Bad Request` (Validation) or `409 Conflict` (Duplicate)

### 5. Update Customer (Full)
- **Method:** `PUT`
- **URL:** `/api/customers/{id}`
- **Body:** `CustomerRequestDTO` (JSON)
- **Response:** `200 OK` or `404 Not Found` or `409 Conflict`

### 6. Partial Update Customer (PATCH) - Exercise 7
- **Method:** `PATCH`
- **URL:** `/api/customers/{id}`
- **Body:** `CustomerUpdateDTO` (JSON) - Only include fields to update
- **Example Body:** `{"fullName": "New Name"}`
- **Response:** `200 OK` or `404 Not Found`

### 7. Delete Customer
- **Method:** `DELETE`
- **URL:** `/api/customers/{id}`
- **Response:** `200 OK`

### 8. Search Customers - Exercise 5
- **Method:** `GET`
- **URL:** `/api/customers/search?keyword={keyword}`
- **Response:** `200 OK`

### 9. Filter by Status - Exercise 5
- **Method:** `GET`
- **URL:** `/api/customers/status/{status}`
- **Example:** `/api/customers/status/ACTIVE`
- **Response:** `200 OK`

### 10. Advanced Search - Exercise 5
- **Method:** `GET`
- **URL:** `/api/customers/advanced-search?name={name}&email={email}&status={status}`
- **Response:** `200 OK`

## Curl Test Endpoints (Exercise 8)

```bash
# 1. List all
curl -X GET http://localhost:8080/api/customers

# 2. Pagination & Sorting
curl -X GET "http://localhost:8080/api/customers?page=0&size=2&sortBy=fullName&sortDir=desc"

# 3. Search
curl -X GET "http://localhost:8080/api/customers/search?keyword=John"

# 4. PATCH Update
curl -X PATCH http://localhost:8080/api/customers/1 -H "Content-Type: application/json" -d '{"fullName": "John Doe Patched"}'
```

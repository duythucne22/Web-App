# REST API Part A Automated Test Script
Write-Host "1. List all customers (GET)"
curl.exe -X GET http://localhost:8080/api/customers
Write-Host "\n2. Get a single customer by ID (GET)"
curl.exe -X GET http://localhost:8080/api/customers/1
Write-Host "\n3. Create a new customer (POST)"
curl.exe -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C100","fullName":"Alice Example","email":"alice@example.com","phone":"+12345678901","address":"1 Test Lane"}'
Write-Host "\n4. Create with validation error (POST, missing fullName)"
curl.exe -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C101","email":"bademail.com","phone":"123","address":"A"}'
Write-Host "\n5. Create duplicate customer (POST, should return 409)"
curl.exe -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C100","fullName":"Duplicate","email":"alice@example.com","phone":"+12345678901","address":"1 Test Lane"}'
Write-Host "\n6. Update a customer (PUT)"
curl.exe -X PUT http://localhost:8080/api/customers/1 -H "Content-Type: application/json" -d '{"customerCode":"C001","fullName":"John Doe Updated","email":"john.doe@example.com","phone":"+1-555-0101","address":"123 Main St, New York"}'
Write-Host "\n7. Delete a customer (DELETE)"
curl.exe -X DELETE http://localhost:8080/api/customers/1
Write-Host "\n8. Get a non-existent customer (GET, should return 404)"
curl.exe -X GET http://localhost:8080/api/customers/9999
Write-Host "\n9. Delete a non-existent customer (DELETE, should return 404)"
curl.exe -X DELETE http://localhost:8080/api/customers/9999

# Part B: Homework Exercises
Write-Host "\n--- Part B: Homework Exercises ---"

Write-Host "\n10. Search Customers (Exercise 5)"
curl.exe -X GET "http://localhost:8080/api/customers/search?keyword=John"

Write-Host "\n11. Filter by Status (Exercise 5)"
curl.exe -X GET "http://localhost:8080/api/customers/status/ACTIVE"

Write-Host "\n12. Advanced Search (Exercise 5)"
curl.exe -X GET "http://localhost:8080/api/customers/advanced-search?name=John&status=ACTIVE"

Write-Host "\n13. Pagination & Sorting (Exercise 6)"
curl.exe -X GET "http://localhost:8080/api/customers?page=0&size=2&sortBy=fullName&sortDir=desc"

Write-Host "\n14. Partial Update (PATCH) (Exercise 7)"
# Note: Assuming customer with ID 2 exists (Jane Smith)
curl.exe -X PATCH http://localhost:8080/api/customers/2 -H "Content-Type: application/json" -d '{"fullName": "Jane Smith Patched", "phone": "+1-999-9999"}'

Write-Host "\n15. Verify PATCH Update (GET)"
curl.exe -X GET http://localhost:8080/api/customers/2

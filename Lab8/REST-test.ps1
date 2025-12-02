# REST API Part A Automated Test Script
Write-Host "1. List all customers (GET)"
curl -X GET http://localhost:8080/api/customers
Write-Host "\n2. Get a single customer by ID (GET)"
curl -X GET http://localhost:8080/api/customers/1
Write-Host "\n3. Create a new customer (POST)"
curl -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C100","fullName":"Alice Example","email":"alice@example.com","phone":"+12345678901","address":"1 Test Lane"}'
Write-Host "\n4. Create with validation error (POST, missing fullName)"
curl -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C101","email":"bademail.com","phone":"123","address":"A"}'
Write-Host "\n5. Create duplicate customer (POST, should return 409)"
curl -X POST http://localhost:8080/api/customers -H "Content-Type: application/json" -d '{"customerCode":"C100","fullName":"Duplicate","email":"alice@example.com","phone":"+12345678901","address":"1 Test Lane"}'
Write-Host "\n6. Update a customer (PUT)"
curl -X PUT http://localhost:8080/api/customers/1 -H "Content-Type: application/json" -d '{"customerCode":"C001","fullName":"John Doe Updated","email":"john.doe@example.com","phone":"+1-555-0101","address":"123 Main St, New York"}'
Write-Host "\n7. Delete a customer (DELETE)"
curl -X DELETE http://localhost:8080/api/customers/1
Write-Host "\n8. Get a non-existent customer (GET, should return 404)"
curl -X GET http://localhost:8080/api/customers/9999
Write-Host "\n9. Delete a non-existent customer (DELETE, should return 404)"
curl -X DELETE http://localhost:8080/api/customers/9999

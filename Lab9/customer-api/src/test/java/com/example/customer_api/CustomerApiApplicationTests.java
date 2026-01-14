// package com.example.customer_api;

// import static org.junit.jupiter.api.Assertions.*;

// import java.util.List;

// import org.junit.jupiter.api.BeforeEach;
// import org.junit.jupiter.api.Test;
// import org.springframework.beans.factory.annotation.Autowired;
// import org.springframework.boot.test.context.SpringBootTest;
// import org.springframework.transaction.annotation.Transactional;

// import com.example.customer_api.dto.CustomerRequestDTO;
// import com.example.customer_api.dto.CustomerResponseDTO;
// import com.example.customer_api.entity.enums.CustomerStatus;
// import com.example.customer_api.exception.DuplicateResourceException;
// import com.example.customer_api.exception.ResourceNotFoundException;
// import com.example.customer_api.service.CustomerService;

// @SpringBootTest
// @Transactional
// class CustomerApiApplicationTests {

// @Autowired
// private CustomerService customerService;

// private CustomerRequestDTO testCustomerRequest;

// @BeforeEach
// void setUp() {
// testCustomerRequest = new CustomerRequestDTO();
// testCustomerRequest.setCustomerCode("C1001");
// testCustomerRequest.setFullName("John Doe");
// testCustomerRequest.setEmail("newPerson@example.com");
// testCustomerRequest.setPhone("+1234567890");
// testCustomerRequest.setAddress("123 Main Street");
// testCustomerRequest.setStatus("ACTIVE");
// }

// @Test
// void contextLoads() {
// assertNotNull(customerService);
// }

// @Test
// void testCreateCustomer_Success() {
// CustomerResponseDTO response =
// customerService.createCustomer(testCustomerRequest);

// assertNotNull(response);
// assertNotNull(response.getId());
// assertEquals("C1001", response.getCustomerCode());
// assertEquals("John Doe", response.getFullName());
// assertEquals("newPerson@example.com", response.getEmail());
// assertEquals("+1234567890", response.getPhone());
// assertEquals("123 Main Street", response.getAddress());
// assertNotNull(response.getCreatedAt());
// }

// @Test
// void testCreateCustomer_DuplicateCustomerCode() {
// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO duplicateRequest = new CustomerRequestDTO();
// duplicateRequest.setCustomerCode("C12345"); // Same code
// duplicateRequest.setFullName("Jane Smith");
// duplicateRequest.setEmail("jane.smith@example.com");
// duplicateRequest.setPhone("+9876543210");

// assertThrows(DuplicateResourceException.class, () -> {
// customerService.createCustomer(duplicateRequest);
// });
// }

// @Test
// void testCreateCustomer_DuplicateEmail() {
// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO duplicateRequest = new CustomerRequestDTO();
// duplicateRequest.setCustomerCode("C1002");
// duplicateRequest.setFullName("Jane Smith");
// duplicateRequest.setEmail("john.doe@example.com");
// duplicateRequest.setPhone("+9876543210");

// assertThrows(DuplicateResourceException.class, () -> {
// customerService.createCustomer(duplicateRequest);
// });
// }

// @Test
// void testGetAllCustomers() {
// CustomerRequestDTO customer2 = new CustomerRequestDTO();
// customer2.setCustomerCode("C1002");
// customer2.setFullName("Duy Tien");
// customer2.setEmail("duytien@example.com");
// customer2.setPhone("+9876543210");
// customerService.createCustomer(customer2);

// List<CustomerResponseDTO> customers = customerService.getAllCustomers();

// assertNotNull(customers);
// assertTrue(customers.size() >= 2);
// }

// @Test
// void testGetCustomerById_Success() {
// Long id = 1L;
// CustomerResponseDTO found = customerService.getCustomerById(id);

// assertNotNull(found);
// assertEquals("C001", found.getCustomerCode());
// assertEquals("John Doe", found.getFullName());
// }

// @Test
// void testGetCustomerById_NotFound() {
// assertThrows(ResourceNotFoundException.class, () -> {
// customerService.getCustomerById(99999L);
// });
// }

// @Test
// void testUpdateCustomer_Success() {
// CustomerResponseDTO created =
// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO updateRequest = new CustomerRequestDTO();
// updateRequest.setCustomerCode("C1001"); // Same code
// updateRequest.setFullName("John Updated");
// updateRequest.setEmail("john.updated@example.com");
// updateRequest.setPhone("+1111111111");
// updateRequest.setAddress("456 New Street");

// CustomerResponseDTO updated = customerService.updateCustomer(created.getId(),
// updateRequest);

// assertNotNull(updated);
// assertEquals(created.getId(), updated.getId());
// assertEquals("John Updated", updated.getFullName());
// assertEquals("john.updated@example.com", updated.getEmail());
// assertEquals("+1111111111", updated.getPhone());
// assertEquals("456 New Street", updated.getAddress());
// }

// @Test
// void testUpdateCustomer_NotFound() {

// assertThrows(ResourceNotFoundException.class, () -> {
// customerService.updateCustomer(99999L, testCustomerRequest);
// });
// }

// @Test
// void testUpdateCustomer_DuplicateEmail() {

// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO customer2 = new CustomerRequestDTO();
// customer2.setCustomerCode("C1002");
// customer2.setFullName("Jane Smith");
// customer2.setEmail("hoanghuy@example.com");
// customer2.setPhone("+9876543210");
// CustomerResponseDTO created2 = customerService.createCustomer(customer2);

// // Try to update customer2 with email from customer1
// CustomerRequestDTO updateRequest = new CustomerRequestDTO();
// updateRequest.setCustomerCode("C1002");
// updateRequest.setFullName("Jane Smith");
// updateRequest.setEmail("john.doe@example.com"); // Email from customer1
// updateRequest.setPhone("+9876543210");

// assertThrows(DuplicateResourceException.class, () -> {
// customerService.updateCustomer(created2.getId(), updateRequest);
// });
// }

// @Test
// void testDeleteCustomer_Success() {

// CustomerResponseDTO created =
// customerService.createCustomer(testCustomerRequest);
// Long customerId = created.getId();

// customerService.deleteCustomer(customerId);

// assertThrows(ResourceNotFoundException.class, () -> {
// customerService.getCustomerById(customerId);
// });
// }

// @Test
// void testDeleteCustomer_NotFound() {

// assertThrows(ResourceNotFoundException.class, () -> {
// customerService.deleteCustomer(99999L);
// });
// }

// @Test
// void testSearchCustomers() {

// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO customer2 = new CustomerRequestDTO();
// customer2.setCustomerCode("C1002");
// customer2.setFullName("Jane Smith");
// customer2.setEmail("hoanghuy@example.com");
// customer2.setPhone("+9876543210");
// customerService.createCustomer(customer2);

// List<CustomerResponseDTO> results = customerService.searchCustomers("John");

// assertNotNull(results);
// assertTrue(results.size() > 0);
// assertTrue(results.stream().anyMatch(c -> c.getFullName().contains("John")));
// }

// @Test
// void testSearchCustomers_NoResults() {

// List<CustomerResponseDTO> results =
// customerService.searchCustomers("NonExistentName");

// assertNotNull(results);
// assertTrue(results.isEmpty());
// }

// @Test
// void testGetCustomersByStatus() {

// customerService.createCustomer(testCustomerRequest);

// CustomerRequestDTO customer2 = new CustomerRequestDTO();
// customer2.setCustomerCode("C1002");
// customer2.setFullName("Jane Smith");
// customer2.setEmail("hoanghuy2@example.com");
// customer2.setPhone("+9876543210");
// customer2.setStatus("INACTIVE");
// customerService.createCustomer(customer2);

// List<CustomerResponseDTO> activeCustomers =
// customerService.getCustomersByStatus(CustomerStatus.ACTIVE);

// assertNotNull(activeCustomers);
// assertTrue(activeCustomers.size() > 0);
// assertTrue(activeCustomers.stream().allMatch(c ->
// "ACTIVE".equals(c.getStatus())));
// }

// // @Test
// // void testGetCustomersByStatus_NoResults() {

// // List<CustomerResponseDTO> results =
// // customerService.getCustomersByStatus("SUSPENDED");

// // assertNotNull(results);

// // }

// }

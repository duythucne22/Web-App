package com.example.customerapi.service;

import java.util.List;

import org.springframework.data.domain.Page;

import com.example.customerapi.dto.CustomerRequestDTO;
import com.example.customerapi.dto.CustomerResponseDTO;
import com.example.customerapi.dto.CustomerUpdateDTO;

public interface CustomerService {
    List<CustomerResponseDTO> getAllCustomers();
    // Exercise 6: Pagination & Sorting
    Page<CustomerResponseDTO> getAllCustomers(int page, int size, String sortBy, String sortDir);
    
    CustomerResponseDTO getCustomerById(Long id);
    CustomerResponseDTO createCustomer(CustomerRequestDTO requestDTO);
    CustomerResponseDTO updateCustomer(Long id, CustomerRequestDTO requestDTO);
    // Exercise 7: Partial Update with PATCH
    CustomerResponseDTO partialUpdateCustomer(Long id, CustomerUpdateDTO updateDTO);
    
    void deleteCustomer(Long id);
    
    List<CustomerResponseDTO> searchCustomers(String keyword);
    List<CustomerResponseDTO> getCustomersByStatus(String status);
    List<CustomerResponseDTO> advancedSearch(String name, String email, String status);
}

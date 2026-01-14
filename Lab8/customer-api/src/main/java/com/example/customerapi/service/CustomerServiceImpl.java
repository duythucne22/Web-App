package com.example.customerapi.service;

import com.example.customerapi.dto.CustomerRequestDTO;
import com.example.customerapi.dto.CustomerResponseDTO;
import com.example.customerapi.dto.CustomerUpdateDTO;
import com.example.customerapi.entity.Customer;
import com.example.customerapi.entity.CustomerStatus;
import com.example.customerapi.exception.DuplicateResourceException;
import com.example.customerapi.exception.ResourceNotFoundException;
import com.example.customerapi.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CustomerServiceImpl implements CustomerService {
    @Autowired
    private CustomerRepository customerRepository;

    private CustomerResponseDTO toDTO(Customer customer) {
        return new CustomerResponseDTO(
            customer.getId(),
            customer.getCustomerCode(),
            customer.getFullName(),
            customer.getEmail(),
            customer.getPhone(),
            customer.getAddress(),
            customer.getStatus().name(),
            customer.getCreatedAt()
        );
    }

    private void checkDuplicate(CustomerRequestDTO dto, Long excludeId) {
        Optional<Customer> byCode = customerRepository.findByCustomerCode(dto.getCustomerCode());
        if (byCode.isPresent() && (excludeId == null || !byCode.get().getId().equals(excludeId))) {
            throw new DuplicateResourceException("Customer code already exists");
        }
        Optional<Customer> byEmail = customerRepository.findByEmail(dto.getEmail());
        if (byEmail.isPresent() && (excludeId == null || !byEmail.get().getId().equals(excludeId))) {
            throw new DuplicateResourceException("Email already exists");
        }
    }

    @Override
    public List<CustomerResponseDTO> getAllCustomers() {
        return customerRepository.findAll().stream().map(this::toDTO).collect(Collectors.toList());
    }

    // Exercise 6: Pagination & Sorting
    @Override
    public Page<CustomerResponseDTO> getAllCustomers(int page, int size, String sortBy, String sortDir) {
        Sort sort = sortDir.equalsIgnoreCase(Sort.Direction.ASC.name()) 
            ? Sort.by(sortBy).ascending() 
            : Sort.by(sortBy).descending();
        
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Customer> customers = customerRepository.findAll(pageable);
        
        return customers.map(this::toDTO);
    }

    @Override
    public CustomerResponseDTO getCustomerById(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        return toDTO(customer);
    }

    @Override
    public CustomerResponseDTO createCustomer(CustomerRequestDTO requestDTO) {
        checkDuplicate(requestDTO, null);
        Customer customer = new Customer();
        customer.setCustomerCode(requestDTO.getCustomerCode());
        customer.setFullName(requestDTO.getFullName());
        customer.setEmail(requestDTO.getEmail());
        customer.setPhone(requestDTO.getPhone());
        customer.setAddress(requestDTO.getAddress());
        customer.setStatus(CustomerStatus.ACTIVE);
        Customer saved = customerRepository.save(customer);
        return toDTO(saved);
    }

    @Override
    public CustomerResponseDTO updateCustomer(Long id, CustomerRequestDTO requestDTO) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        checkDuplicate(requestDTO, id);
        customer.setCustomerCode(requestDTO.getCustomerCode());
        customer.setFullName(requestDTO.getFullName());
        customer.setEmail(requestDTO.getEmail());
        customer.setPhone(requestDTO.getPhone());
        customer.setAddress(requestDTO.getAddress());
        // status and createdAt not updated here
        Customer saved = customerRepository.save(customer);
        return toDTO(saved);
    }

    // Exercise 7: Partial Update with PATCH
    @Override
    public CustomerResponseDTO partialUpdateCustomer(Long id, CustomerUpdateDTO updateDTO) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        
        if (updateDTO.getFullName() != null) {
            customer.setFullName(updateDTO.getFullName());
        }
        if (updateDTO.getEmail() != null) {
            // Check for duplicate email if it's being updated
            Optional<Customer> byEmail = customerRepository.findByEmail(updateDTO.getEmail());
            if (byEmail.isPresent() && !byEmail.get().getId().equals(id)) {
                throw new DuplicateResourceException("Email already exists");
            }
            customer.setEmail(updateDTO.getEmail());
        }
        if (updateDTO.getPhone() != null) {
            customer.setPhone(updateDTO.getPhone());
        }
        if (updateDTO.getAddress() != null) {
            customer.setAddress(updateDTO.getAddress());
        }
        
        Customer saved = customerRepository.save(customer);
        return toDTO(saved);
    }

    @Override
    public void deleteCustomer(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        customerRepository.delete(customer);
    }

    @Override
    public List<CustomerResponseDTO> searchCustomers(String keyword) {
        return customerRepository.searchCustomers(keyword).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }

    @Override
    public List<CustomerResponseDTO> getCustomersByStatus(String status) {
        try {
            CustomerStatus customerStatus = CustomerStatus.valueOf(status.toUpperCase());
            return customerRepository.findByStatus(customerStatus).stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        } catch (IllegalArgumentException e) {
            throw new RuntimeException("Invalid status: " + status);
        }
    }

    @Override
    public List<CustomerResponseDTO> advancedSearch(String name, String email, String status) {
        CustomerStatus customerStatus = null;
        if (status != null && !status.isEmpty()) {
            try {
                customerStatus = CustomerStatus.valueOf(status.toUpperCase());
            } catch (IllegalArgumentException e) {
                // Ignore invalid status or throw exception depending on requirements
                // For now, we'll ignore it or treat as null
            }
        }
        return customerRepository.advancedSearch(name, email, customerStatus).stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
}

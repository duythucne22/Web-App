package com.example.customerapi.service;

import com.example.customerapi.dto.CustomerRequestDTO;
import com.example.customerapi.dto.CustomerResponseDTO;
import com.example.customerapi.entity.Customer;
import com.example.customerapi.entity.CustomerStatus;
import com.example.customerapi.exception.DuplicateResourceException;
import com.example.customerapi.exception.ResourceNotFoundException;
import com.example.customerapi.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
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

    @Override
    public void deleteCustomer(Long id) {
        Customer customer = customerRepository.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("Customer not found"));
        customerRepository.delete(customer);
    }
}
